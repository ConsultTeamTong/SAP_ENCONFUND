# ============================================================
# Undo-Import.ps1 - ListImportBatches / GetImportBatch / UndoImport (CONTRACT_v2 sec.4)
# dot-sourced by rdoc-cli.ps1 after DB plugin + Sql-RDOC.ps1 + Import-RDOC.ps1 + Backup-RDOC.ps1
# UndoImport: ONE transaction, all-or-nothing.
#   inserted -> delete DFLT_PRNTING (only if table exists with DocCode), RITM, RDC1, RCON, RDOC of that DocCode
#   updated  -> restore Template/RptHash/UpdateDate from batch files (manifest.before)
#   refuse   -> row changed after import (RptHash/UpdateDate != manifest.after) unless force; system layout always
# ============================================================

function Get-ImportManifestPath([string]$ProfileName, [string]$BatchId) {
    if ($BatchId -notmatch '^\d{8}_\d{6}$') { throw "bad batchId: $BatchId" }
    Join-Path (Join-Path (Get-ImportBatchRoot $ProfileName) $BatchId) 'manifest.json'
}

function Read-ImportManifest([string]$ProfileName, [string]$BatchId) {
    $p = Get-ImportManifestPath $ProfileName $BatchId
    if (-not (Test-Path -LiteralPath $p)) { throw "batch $BatchId not found for profile $ProfileName" }
    return (Get-Content -LiteralPath $p -Raw -Encoding UTF8 | ConvertFrom-Json)
}

# status 'running' whose process is gone => report 'cancelled' (killed / cancelled job)
function Get-EffectiveStatus($m) {
    if ($m.status -eq 'running') {
        $alive = $false
        if ($m.pid) { try { $pr = Get-Process -Id ([int]$m.pid) -ErrorAction Stop; $alive = $pr.ProcessName -like 'powershell*' } catch {} }
        if (-not $alive) { return 'cancelled' }
    }
    return [string]$m.status
}

function Get-ImportBatches([string]$ProfileName) {
    $root = Get-ImportBatchRoot $ProfileName; $items = @()
    if (Test-Path -LiteralPath $root) {
        foreach ($d in Get-ChildItem -LiteralPath $root -Directory | Sort-Object Name -Descending) {
            $mf = Join-Path $d.FullName 'manifest.json'; if (-not (Test-Path -LiteralPath $mf)) { continue }
            try { $m = Get-Content -LiteralPath $mf -Raw -Encoding UTF8 | ConvertFrom-Json
                $items += [ordered]@{ batchId=$m.batchId; time=$m.time; status=(Get-EffectiveStatus $m); insertedCount=@($m.inserted | Where-Object { $_ }).Count
                    updatedCount=@($m.updated | Where-Object { $_ }).Count; pendingDocCode=$(if ($m.pending) { [string]$m.pending.docCode } else { $null }); undone=[bool]$m.undone; profile=$m.profile } } catch {}
        }
    }
    return ,$items
}

function Get-UndoPlan($Conn, $Man, [string]$BatchDir, [bool]$Force) {
    $plan = @()
    if ($Man.undone -or $Man.status -eq 'undone') {
        foreach ($e in @($Man.inserted) + @($Man.updated)) { if ($e) { $plan += [ordered]@{ docCode=$e.docCode; action='refuse'; reason='batch already undone'; kind='' } } }
        return ,$plan
    }
    $ins = @($Man.inserted | Where-Object { $_ }); $upd = @($Man.updated | Where-Object { $_ })
    # resolve pending (killed between commit and manifest update): committed only if DB RptHash == pending hash
    if ($Man.pending) {
        $st = Get-RdocState $Conn ([string]$Man.pending.docCode)
        if ($st -and $st.rptHash -eq [string]$Man.pending.rptHash) {
            $e = [pscustomobject]@{ docCode=$Man.pending.docCode; docName=$Man.pending.docName; typeCode=$Man.pending.typeCode; after=[pscustomobject]@{ rptHash=$st.rptHash; updateDate=$st.updateDate }; before=$null; fromPending=$true }
            if ($Man.pending.action -eq 'INSERT') { $ins += $e } else { $plan += [ordered]@{ docCode=$e.docCode; action='refuse'; reason='pending UPDATE committed but before-state not recorded in manifest; restore manually from batch file'; kind='update' } }
        } else { $plan += [ordered]@{ docCode=[string]$Man.pending.docCode; action='none'; reason='pending row was not committed'; kind='pending' } }
    }
    foreach ($e in $ins) {
        $o = [ordered]@{ docCode=[string]$e.docCode; action=''; reason=''; kind='insert'; guardHash=[string]$e.after.rptHash; forced=$false }
        $st = Get-RdocState $Conn $o.docCode
        if (-not $st) { $o.action='none'; $o.reason='already gone' }
        elseif (Test-IsSystemAuthor $st.author) { $o.action='refuse'; $o.reason='system layout' }
        elseif (($st.rptHash -ne [string]$e.after.rptHash) -or ([string]$st.updateDate -ne [string]$e.after.updateDate)) {
            if ($Force) { $o.action='delete'; $o.reason='FORCED: changed after import'; $o.forced=$true } else { $o.action='refuse'; $o.reason="changed after import (RptHash/UpdateDate differ); use force" } }
        else { $o.action='delete'; $o.reason='inserted by this batch' + $(if ($e.fromPending) { ' (recovered from pending)' } else { '' }) }
        $plan += $o
    }
    foreach ($e in $upd) {
        $o = [ordered]@{ docCode=[string]$e.docCode; action=''; reason=''; kind='update'; templateFile=''; rptHash=''; updateDate=''; guardHash=[string]$e.after.rptHash; forced=$false }
        $st = Get-RdocState $Conn $o.docCode
        $tf = if ($e.before.templateFile) { Join-Path $BatchDir ([string]$e.before.templateFile) } else { '' }
        if (-not $st) { $o.action='refuse'; $o.reason='row deleted after import' }
        elseif (Test-IsSystemAuthor $st.author) { $o.action='refuse'; $o.reason='system layout' }
        elseif (-not $tf -or -not (Test-Path -LiteralPath $tf)) { $o.action='refuse'; $o.reason='before-template file missing in batch' }
        elseif (($st.rptHash -ne [string]$e.after.rptHash) -or ([string]$st.updateDate -ne [string]$e.after.updateDate)) {
            if ($Force) { $o.action='restore'; $o.reason='FORCED: changed after import'; $o.forced=$true } else { $o.action='refuse'; $o.reason='changed after import (RptHash/UpdateDate differ); use force' } }
        else { $o.action='restore'; $o.reason='restore before-state of this batch' }
        $o.templateFile = $tf; $o.rptHash = [string]$e.before.rptHash; $o.updateDate = [string]$e.before.updateDate
        $plan += $o
    }
    return ,$plan
}

function Invoke-UndoWrite($Conn, $Plan) {
    $deleted = 0; $restored = 0; $done = @()
    $tran = $Conn.BeginTransaction()
    try {
        $hasDflt = Test-TableHasDocCode $Conn 'DFLT_PRNTING' $tran
        Write-Host ("DFLT_PRNTING with DocCode present: {0}" -f $hasDflt)
        foreach ($o in $Plan) {
            if ($o.action -eq 'delete') {
                $tables = @('RITM','RDC1','RCON'); if ($hasDflt) { $tables = @('DFLT_PRNTING') + $tables }
                foreach ($t in $tables) {
                    $c = $Conn.CreateCommand(); $c.Transaction = $tran; $c.CommandText = Get-SqlDeleteChild $t
                    Add-DBParam $c "${DB_PARAM}DocCode" $o.docCode; $n = $c.ExecuteNonQuery(); Write-Host "  $t : $n row(s) for $($o.docCode)"
                }
                $guard = -not $o.forced
                $c = $Conn.CreateCommand(); $c.Transaction = $tran; $c.CommandText = Get-SqlDeleteRdoc -Guard:$guard
                Add-DBParam $c "${DB_PARAM}DocCode" $o.docCode
                if ($guard) { Add-DBParam $c "${DB_PARAM}GuardHash" $o.guardHash }
                if ($c.ExecuteNonQuery() -lt 1) { throw "RDOC delete affected 0 rows for $($o.docCode) (changed since plan?) - whole undo rolled back" }
                $deleted++
            } elseif ($o.action -eq 'restore') {
                $guard = -not $o.forced
                $c = $Conn.CreateCommand(); $c.Transaction = $tran; $c.CommandText = Get-SqlRestoreRdoc -Guard:$guard
                Add-BlobParam $c "${DB_PARAM}Template" ([IO.File]::ReadAllBytes($o.templateFile))
                Add-DBParam $c "${DB_PARAM}RptHash" $o.rptHash
                $ud = if ($o.updateDate) { [datetime]::Parse($o.updateDate, [Globalization.CultureInfo]::InvariantCulture) } else { [DBNull]::Value }
                Add-DBParam $c "${DB_PARAM}UpdateDate" $ud
                Add-DBParam $c "${DB_PARAM}DocCode" $o.docCode
                if ($guard) { Add-DBParam $c "${DB_PARAM}GuardHash" $o.guardHash }
                if ($c.ExecuteNonQuery() -lt 1) { throw "RDOC restore affected 0 rows for $($o.docCode) (changed since plan?) - whole undo rolled back" }
                $restored++
            } else { continue }
            $done += $o
        }
        $tran.Commit()
        # ##ITEM## only after commit: a kill before commit leaves no items (and no DB change)
        foreach ($o in $done) { Write-Item $o.docCode $true "$($o.action) committed" }
    } catch { try { $tran.Rollback() } catch {}; throw }
    return [ordered]@{ deleted=$deleted; restored=$restored }
}
