# ============================================================
# Import .rpt -> RDOC   (dot-sourced by rdoc-cli.ps1)
# Rules copied from Import_SQL_Direct.ps1 (Enconfund/Seoul):
#   file must exist; ObjectType not empty / '-' and in $TypeCodeMap;
#   DocName = layoutName, else file name; duplicate key = DocName+TypeCode;
#   DocCode = TypeCode + next 4-digit seq; Author only on INSERT;
#   system layouts (Author ''/SYSTEM) never touched. Writes RDOC only.
# Fix (b): DB plugin loaded by rdoc-cli according to profile.engine (not MSSQL always).
# Fix (c): max sequence computed in PowerShell (no ISNUMERIC/LEN -> works on HANA too).
# All identifiers double-quoted so HANA (case-sensitive) works.
# ============================================================

$TypeCodeMap = @{
    "30"="JDT2"; "23"="QUT2"; "17"="RDR2"; "15"="DLN2"; "16"="RDN2"; "203"="DPI2"
    "13"="INV2"; "14"="RIN2"; "1470000113"="PRQ2"; "540000405"="PQT2"; "22"="POR2"
    "20"="PDN2"; "21"="RPD2"; "204"="DPO2"; "18"="PCH2"; "19"="RPC2"; "69"="IPF1"
    "24"="RCT1"; "46"="VPM1"; "59"="IGN1"; "60"="IGE1"; "67"="WTR1"
    "1250000001"="WTQ1"; "1470000065"="INC1"
    "162"=""        # Inventory Revaluation - no RTYP code, skipped (unchanged)
    "202"="WOR1"
}

function Test-IsSystemAuthor([string]$a) { $u = ([string]$a).Trim().ToUpper(); return ($u -eq '' -or $u -eq 'SYSTEM') }

function Get-DBMaxSeqMap {
    param($Conn)
    $map = @{}
    $cmd = $Conn.CreateCommand()
    $cmd.CommandText = 'SELECT "DocCode", "TypeCode" FROM "RDOC"'
    $r = $cmd.ExecuteReader()
    while ($r.Read()) {
        $dc = [string]$r["DocCode"]; $tc = [string]$r["TypeCode"]
        if ($dc.Length -ge 5 -and $dc.Length -ge $tc.Length + 1 -and $dc.StartsWith($tc)) {
            $rest = $dc.Substring($tc.Length)
            $seg = $rest.Substring(0, [Math]::Min(4, $rest.Length))
            if ($seg -match '^\d+$') { $v = [int]$seg; if (-not $map.ContainsKey($tc) -or $map[$tc] -lt $v) { $map[$tc] = $v } }
        }
    }
    $r.Close()
    return $map
}

function Resolve-RptPath {
    param($Row, [string]$RptRoot)
    $folder = [string]$Row.folder
    if ([string]::IsNullOrWhiteSpace($folder)) { $folder = $RptRoot }
    elseif (-not [IO.Path]::IsPathRooted($folder)) { $folder = Join-Path $RptRoot $folder }
    return (Join-Path $folder ([string]$Row.file))
}

# Plans every row (no writes). Returns list of ordered dicts with status/reason/docCode/typeCode/action.
function Get-RdocImportPlan {
    param($Conn, $Rows, [string]$RptRoot, [string]$OnDuplicate)
    $maxSeq = Get-DBMaxSeqMap $Conn
    $plan = @()
    foreach ($row in $Rows) {
        $o = [ordered]@{ file=[string]$row.file; folder=[string]$row.folder; objectType=[string]$row.objectType; layoutName=[string]$row.layoutName
                         path=""; typeCode=""; docCode=""; docName=""; status="Error"; reason=""; action="" }
        try {
            $path = Resolve-RptPath $row $RptRoot; $o.path = $path
            $docName = if ([string]::IsNullOrWhiteSpace($row.layoutName)) { [string]$row.file } else { [string]$row.layoutName }
            $o.docName = $docName
            if ([string]::IsNullOrWhiteSpace($row.file) -or -not (Test-Path -LiteralPath $path)) { $o.status="Skip"; $o.reason="file missing: $path"; $plan += $o; continue }
            $ot = ([string]$row.objectType).Trim()
            if ($ot -eq '' -or $ot -eq '-') { $o.status="Skip"; $o.reason="no ObjectType"; $plan += $o; continue }
            if (-not $TypeCodeMap.ContainsKey($ot) -or [string]::IsNullOrWhiteSpace($TypeCodeMap[$ot])) { $o.status="Skip"; $o.reason="unmapped ObjectType=$ot"; $plan += $o; continue }
            $tc = $TypeCodeMap[$ot]; $o.typeCode = $tc
            $chk = $Conn.CreateCommand()
            $chk.CommandText = Convert-DBSql "SELECT `"DocCode`", `"Author`" FROM `"RDOC`" WHERE `"DocName`"=${DB_PARAM}n AND `"TypeCode`"=${DB_PARAM}t"
            Add-DBParam $chk "${DB_PARAM}n" $docName
            Add-DBParam $chk "${DB_PARAM}t" $tc
            $rd = $chk.ExecuteReader(); $exist = $null; $existAuthor = ""
            if ($rd.Read()) { $exist = [string]$rd["DocCode"]; $existAuthor = [string]$rd["Author"] }
            $rd.Close()
            if ($exist) {
                if (Test-IsSystemAuthor $existAuthor) { $o.status="Skip"; $o.reason="system layout $exist (never touched)"; $o.docCode=$exist; $plan += $o; continue }
                switch ($OnDuplicate) {
                    "Skip"   { $o.status="Skip"; $o.reason="exists DocCode=$exist (onDuplicate=Skip)"; $o.docCode=$exist }
                    "Update" { $o.status="Update"; $o.action="UPDATE"; $o.docCode=$exist; $o.reason="exists, Template will be replaced" }
                    "Insert" { if (-not $maxSeq.ContainsKey($tc)) { $maxSeq[$tc]=0 }; $maxSeq[$tc]++; $o.docCode = "{0}{1:D4}" -f $tc, $maxSeq[$tc]
                               $o.status="New"; $o.action="INSERT"; $o.reason="duplicate DocName allowed (onDuplicate=Insert), existing=$exist" }
                }
            } else {
                if (-not $maxSeq.ContainsKey($tc)) { $maxSeq[$tc]=0 }
                $maxSeq[$tc]++; $o.docCode = "{0}{1:D4}" -f $tc, $maxSeq[$tc]
                $o.status="New"; $o.action="INSERT"; $o.reason="new layout"
            }
        } catch { $o.status="Error"; $o.reason=$_.Exception.Message }
        $plan += $o
    }
    return ,$plan
}

function Get-FileMd5([byte[]]$bytes) {
    $md5 = [System.Security.Cryptography.MD5]::Create()
    try { return [BitConverter]::ToString($md5.ComputeHash($bytes)).Replace("-","") } finally { $md5.Dispose() }
}

# ------------------------------------------------------------
# Real import (dryRun=false). CONTRACT_v2 sec.3 + 4:
#  - batch folder backups\<profile>\imports\<batchId>\ ; manifest.json written (atomic) BEFORE touching DB
#  - before-Template of every row to UPDATE saved as <docCode>.before.rpt BEFORE touching DB
#  - one transaction per row (RDOC only for import; children untouched) ; commit per row
#  - manifest.pending set before commit, moved to inserted/updated after commit (atomic rewrite)
#    so a kill between commit and manifest update is still undoable (UndoImport resolves pending by RptHash)
# ------------------------------------------------------------
function Get-ImportBatchRoot([string]$ProfileName) { Join-Path (Join-Path (Get-BackupRoot) $ProfileName) 'imports' }

function Invoke-RdocImportWrite {
    param($Conn, $Plan, [string]$Author, $Prof)
    $batchId = Get-Date -Format 'yyyyMMdd_HHmmss'
    $dir = Join-Path (Get-ImportBatchRoot $Prof.name) $batchId
    if (Test-Path -LiteralPath $dir) { Start-Sleep -Seconds 1; $batchId = Get-Date -Format 'yyyyMMdd_HHmmss'; $dir = Join-Path (Get-ImportBatchRoot $Prof.name) $batchId }
    New-Item -ItemType Directory -Force $dir | Out-Null
    $mf = Join-Path $dir 'manifest.json'
    $man = [ordered]@{ batchId=$batchId; time=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss'); profile=[string]$Prof.name; engine=$DB_ENGINE
        companyDb=[string]$Prof.companyDb; status='running'; pid=$PID; inserted=@(); updated=@(); pending=$null; failed=@(); undone=$false; undoneAt=$null }

    # 1) save before-state of rows to UPDATE (read-only), then write manifest -> only then touch DB
    $before = @{}
    foreach ($o in $Plan) {
        if ($o.status -ne 'Update') { continue }
        $c = $Conn.CreateCommand(); $c.CommandText = Get-SqlRdocBefore; Add-DBParam $c "${DB_PARAM}DocCode" $o.docCode
        $r = $c.ExecuteReader()
        try {
            if (-not $r.Read()) { $o.status = 'Error'; $o.reason = 'row vanished before write'; continue }
            $tf = "$($o.docCode).before.rpt"
            $blob = $r["Template"]
            if ($blob -is [byte[]]) { $part = Join-Path $dir "$tf.part"; [IO.File]::WriteAllBytes($part, $blob); Move-PartFile $part (Join-Path $dir $tf) } else { $tf = $null }
            $before[$o.docCode] = [ordered]@{ templateFile=$tf; rptHash=[string]$r["RptHash"]; updateDate=(Format-DbDate $r["UpdateDate"]) }
        } finally { $r.Close() }
    }
    Write-JsonAtomic $mf $man
    Write-Host "batch $batchId manifest: $mf"

    $ins=0; $upd=0; $skp=0; $err=0
    foreach ($o in $Plan) {
        if ($o.status -ne 'New' -and $o.status -ne 'Update') {
            $o.result = $o.status; if ($o.status -eq 'Skip') { $skp++ } else { $err++ }
            Write-Item ([string]$o.path) ($o.status -eq 'Skip') ("$($o.status): $($o.reason)"); continue
        }
        $tran = $null
        try {
            $bytes = [System.IO.File]::ReadAllBytes($o.path)
            $hash = Get-FileMd5 $bytes
            $man.pending = [ordered]@{ docCode=$o.docCode; action=$o.action; docName=$o.docName; typeCode=$o.typeCode; rptHash=$hash }
            Write-JsonAtomic $mf $man
            $tran = $Conn.BeginTransaction()
            $cmd = $Conn.CreateCommand(); $cmd.Transaction = $tran
            if ($o.action -eq 'UPDATE') {
                $cmd.CommandText = Get-SqlUpdateRdocTemplate
                Add-BlobParam $cmd "${DB_PARAM}Template" $bytes
                Add-DBParam $cmd "${DB_PARAM}RptHash" $hash
                Add-DBParam $cmd "${DB_PARAM}DocCode" $o.docCode
            } else {
                $cmd.CommandText = Get-SqlInsertRdoc
                Add-DBParam $cmd "${DB_PARAM}DocCode" $o.docCode
                Add-DBParam $cmd "${DB_PARAM}DocName" $o.docName
                Add-DBParam $cmd "${DB_PARAM}Author" $Author
                Add-DBParam $cmd "${DB_PARAM}TypeCode" $o.typeCode
                Add-BlobParam $cmd "${DB_PARAM}Template" $bytes
                Add-DBParam $cmd "${DB_PARAM}RptHash" $hash
            }
            $n = $cmd.ExecuteNonQuery()
            if ($n -lt 1) { throw "no row written (system layout?)" }
            $after = Get-RdocState $Conn $o.docCode $tran
            $tran.Commit(); $tran = $null
            $entry = [ordered]@{ docCode=$o.docCode; docName=$o.docName; typeCode=$o.typeCode }
            if ($o.action -eq 'UPDATE') { $entry.before = $before[$o.docCode]; $entry.after = [ordered]@{ rptHash=$after.rptHash; updateDate=$after.updateDate }; $man.updated += $entry; $upd++ }
            else { $entry.after = [ordered]@{ rptHash=$after.rptHash; updateDate=$after.updateDate }; $man.inserted += $entry; $ins++ }
            $man.pending = $null
            Write-JsonAtomic $mf $man
            $o.result = "$($o.action) OK"
            Write-Host ("{0} {1} -> DocCode={2} ({3} bytes)" -f $o.action, $o.file, $o.docCode, $bytes.Length)
            Write-Item $o.docCode $true "$($o.action) $($o.file)"
        } catch {
            if ($tran) { try { $tran.Rollback() } catch {} }
            $o.result = "FAIL: " + $_.Exception.Message; $err++
            $man.pending = $null; $man.failed += [ordered]@{ docCode=$o.docCode; file=$o.file; error=$_.Exception.Message }
            Write-JsonAtomic $mf $man
            Write-Host ("FAIL {0}: {1}" -f $o.file, $_.Exception.Message)
            Write-Item $o.docCode $false $_.Exception.Message
        }
    }
    $man.status = if ($err -gt 0) { 'failed' } else { 'complete' }
    Write-JsonAtomic $mf $man
    return [ordered]@{ batchId=$batchId; inserted=$ins; updated=$upd; skipped=$skp; errors=$err }
}
