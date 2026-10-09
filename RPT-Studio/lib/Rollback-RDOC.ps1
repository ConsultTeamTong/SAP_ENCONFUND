# ============================================================
# Rollback RDOC from a backup made by Backup-Rdoc   (dot-sourced by rdoc-cli.ps1)
# For each requested DocCode:
#   - existed in backup  -> restore Template (+RptHash) from backup  (RDOC UPDATE)
#   - not in backup (inserted after backup) -> delete RITM/RDC1/RCON children + RDOC row
#   - system layout (Author ''/SYSTEM) -> refused, never touched
# Writes only RDOC/RITM/RDC1/RCON (as original Rollback-BySelection, minus DFLT_PRNTING).
# One transaction. Write path NOT TESTED against a real DB (no test DB).
# ============================================================

function Get-RdocRollbackPlan {
    param($Conn, [string]$ProfileName, [string]$BackupId, [string[]]$DocCodes)
    $dir = Join-Path (Get-BackupRoot) $ProfileName
    $bak = Join-Path $dir "RDOC_Backup_$BackupId.bak"
    $csv = Join-Path $dir "RDOC_Backup_$BackupId.csv"
    if (-not (Test-Path $bak) -or -not (Test-Path $csv)) { throw "backup $BackupId not found for profile $ProfileName" }
    if (-not (Test-Path (Join-Path $dir "RDOC_Backup_$BackupId.json"))) { throw "backup $BackupId is incomplete (no .json meta) - refused" }
    $idx = @{}; foreach ($r in (Import-Csv $csv -Encoding UTF8)) { $idx[$r.DocCode] = $r }
    $blobs = Read-RdocBackupBlobs $bak
    $plan = @()
    foreach ($dc in $DocCodes) {
        $o = [ordered]@{ docCode=[string]$dc; action=""; reason="" }
        $cmd = $Conn.CreateCommand()
        $cmd.CommandText = Convert-DBSql "SELECT `"Author`" FROM `"RDOC`" WHERE `"DocCode`"=${DB_PARAM}d"
        Add-DBParam $cmd "${DB_PARAM}d" ([string]$dc)
        $rd = $cmd.ExecuteReader(); $exists = $false; $author = ""
        if ($rd.Read()) { $exists = $true; $author = [string]$rd["Author"] }
        $rd.Close()
        if ($exists -and (Test-IsSystemAuthor $author)) { $o.action="refuse"; $o.reason="system layout" }
        elseif ($idx.ContainsKey([string]$dc)) {
            if (Test-IsSystemAuthor $idx[[string]$dc].Author) { $o.action="refuse"; $o.reason="system layout in backup" }
            elseif (-not $exists) { $o.action="refuse"; $o.reason="row was deleted after backup; re-insert not supported" }
            elseif (-not $blobs.ContainsKey([string]$dc)) { $o.action="refuse"; $o.reason="no template in backup" }
            else { $o.action="restore"; $o.reason="Template from backup ($($blobs[[string]$dc].Length) bytes)" }
        } elseif ($exists) { $o.action="delete"; $o.reason="not in backup (inserted after it)" }
        else { $o.action="none"; $o.reason="not in DB and not in backup" }
        $plan += $o
    }
    return @{ plan = $plan; blobs = $blobs; idx = $idx }
}

function Invoke-RdocRollbackWrite {
    param($Conn, $PlanInfo)
    # same pattern as UndoImport: one transaction, shared SQL builders, ##ITEM## only after commit
    $restored = 0; $deleted = 0; $done = @()
    $tran = $Conn.BeginTransaction()
    try {
        foreach ($o in $PlanInfo.plan) {
            if ($o.action -eq 'restore') {
                # Rollback restores Template/RptHash; UpdateDate = now (the full backup does not keep UpdateDate)
                $c = $Conn.CreateCommand(); $c.Transaction = $tran; $c.CommandText = Get-SqlUpdateRdocTemplate
                Add-BlobParam $c "${DB_PARAM}Template" $PlanInfo.blobs[$o.docCode]
                Add-DBParam $c "${DB_PARAM}RptHash" ([string]$PlanInfo.idx[$o.docCode].RptHash)
                Add-DBParam $c "${DB_PARAM}DocCode" $o.docCode
                if ($c.ExecuteNonQuery() -lt 1) { throw "restore affected 0 rows for $($o.docCode)" }
                $restored++; $done += $o
            } elseif ($o.action -eq 'delete') {
                foreach ($tbl in 'RITM','RDC1','RCON') {
                    $c = $Conn.CreateCommand(); $c.Transaction = $tran; $c.CommandText = Get-SqlDeleteChild $tbl
                    Add-DBParam $c "${DB_PARAM}DocCode" $o.docCode
                    $n = $c.ExecuteNonQuery(); Write-Host "  $tbl : $n child rows deleted for $($o.docCode)"
                }
                $c = $Conn.CreateCommand(); $c.Transaction = $tran; $c.CommandText = Get-SqlDeleteRdoc
                Add-DBParam $c "${DB_PARAM}DocCode" $o.docCode
                if ($c.ExecuteNonQuery() -lt 1) { throw "delete affected 0 rows for $($o.docCode)" }
                $deleted++; $done += $o
            }
        }
        $tran.Commit()
        foreach ($o in $done) { Write-Item $o.docCode $true "$($o.action) committed" }
    } catch { try { $tran.Rollback() } catch {}; throw }
    return [ordered]@{ restored = $restored; deleted = $deleted }
}
