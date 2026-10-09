# ============================================================
# Backup RDOC (read-only on DB)   (dot-sourced by rdoc-cli.ps1)
# Based on Enconfund\Tool\Scripts\Backup-RDOC.ps1, made engine-neutral.
# Output: <backupRoot>\<profile>\RDOC_Backup_<ts>.csv / .bak / .json
#   .bak format: "RDOCBKP1" + int32 count + [DocCode(8 ASCII) + int32 len + bytes]*
#   (RDOCBKP2 = length-prefixed DocCode, only if a DocCode is longer than 8)
# Safe-on-kill (CONTRACT_v2 sec.3): .csv/.bak/.json are written as *.part, then renamed
#   .bak -> .csv -> .json LAST. A backup is complete only when its .json exists.
#   A kill leaves only *.part files (removed at the next Backup start) or, in the tiny
#   window between renames, .bak/.csv without .json -> ListBackups reports it as incomplete.
# ============================================================

function Get-BackupRoot { Join-Path (Split-Path -Parent $PSScriptRoot) 'backups' }

function Backup-Rdoc {
    param($Conn, [string]$ProfileName, [string]$CompanyDb, [switch]$NoItems)
    $dir = Join-Path (Get-BackupRoot) $ProfileName
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    # remove our own stale temp files from a killed run (pattern RDOC_Backup_*.part only)
    foreach ($s in Get-ChildItem -LiteralPath $dir -Filter 'RDOC_Backup_*.part' -File -ErrorAction SilentlyContinue) {
        Remove-Item -LiteralPath $s.FullName -Force; Write-Host "removed stale temp $($s.Name)"
    }
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    $base = Join-Path $dir "RDOC_Backup_$ts"
    $bak = "$base.bak"; $csvFile = "$base.csv"; $jsonFile = "$base.json"

    $cmd = $Conn.CreateCommand()
    $cmd.CommandText = "SELECT `"DocCode`", `"TypeCode`", `"DocName`", `"Category`", `"Author`", $DB_BLOBLEN(`"Template`") AS `"Bytes`", `"RptHash`" FROM `"RDOC`""
    $r = $cmd.ExecuteReader(); $rows = @()
    while ($r.Read()) {
        $rows += [PSCustomObject]@{ DocCode=[string]$r["DocCode"]; TypeCode=[string]$r["TypeCode"]; DocName=[string]$r["DocName"]
            Category=[string]$r["Category"]; Author=[string]$r["Author"]; Bytes=[string]$r["Bytes"]; RptHash=[string]$r["RptHash"] }
    }
    $r.Close()
    $rows | Export-Csv -Path "$csvFile.part" -NoTypeInformation -Encoding UTF8
    Write-Host "index of $($rows.Count) rows read"

    $long = @($rows | Where-Object { $_.DocCode.Length -gt 8 }).Count -gt 0
    $fs = [System.IO.File]::Open("$bak.part", 'Create')
    $bw = New-Object System.IO.BinaryWriter $fs
    $saved = 0
    try {
        $bw.Write([System.Text.Encoding]::ASCII.GetBytes($(if ($long) { "RDOCBKP2" } else { "RDOCBKP1" })))
        $bw.Write([int32]$rows.Count)
        $cmd2 = $Conn.CreateCommand()
        $cmd2.CommandText = 'SELECT "DocCode", "Template" FROM "RDOC" WHERE "Template" IS NOT NULL'
        $reader = $cmd2.ExecuteReader()
        while ($reader.Read()) {
            $code = [string]$reader["DocCode"]; $blob = $reader["Template"]
            if ($blob -is [byte[]]) {
                $cb = [System.Text.Encoding]::ASCII.GetBytes($(if ($long) { $code } else { $code.PadRight(8) }))
                if ($long) { $bw.Write([int32]$cb.Length) }
                $bw.Write($cb); $bw.Write([int32]$blob.Length); $bw.Write($blob); $saved++
                if (-not $NoItems) { Write-Item $code $true "$($blob.Length) bytes" }
            }
        }
        $reader.Close()
    } finally { $bw.Close(); $fs.Close() }

    $meta = [ordered]@{ backupId=$ts; time=(Get-Date).ToString("yyyy-MM-dd HH:mm:ss"); path=$bak; rowCount=$rows.Count; templates=$saved; profile=$ProfileName; companyDb=$CompanyDb }
    [IO.File]::WriteAllText("$jsonFile.part", ($meta | ConvertTo-Json -Compress), (New-Object System.Text.UTF8Encoding $false))
    Move-PartFile "$bak.part" $bak
    Move-PartFile "$csvFile.part" $csvFile
    Move-PartFile "$jsonFile.part" $jsonFile        # last: marks the backup complete
    Write-Host "Saved $saved binary templates -> $bak"
    return [ordered]@{ backupId = $ts; path = $bak }
}

function Get-RdocBackups {
    param([string]$ProfileName)
    $dir = Join-Path (Get-BackupRoot) $ProfileName
    $items = @()
    if (Test-Path $dir) {
        foreach ($b in Get-ChildItem $dir -Filter 'RDOC_Backup_*.bak' -File | Sort-Object Name -Descending) {
            $id = $b.BaseName.Substring(12); $j = Join-Path $dir "RDOC_Backup_$id.json"
            if (Test-Path -LiteralPath $j) {
                try { $m = Get-Content $j -Raw -Encoding UTF8 | ConvertFrom-Json
                    $items += [ordered]@{ backupId=$m.backupId; time=$m.time; path=$m.path; rowCount=$m.rowCount; profile=$m.profile; complete=$true } } catch {}
            } else {
                # .bak without .json: unfinished / pre-v2 backup -> listed, flagged, never auto-deleted
                $csv = Join-Path $dir "RDOC_Backup_$id.csv"
                $rc = if (Test-Path -LiteralPath $csv) { @(Import-Csv -LiteralPath $csv -Encoding UTF8).Count } else { $null }
                $items += [ordered]@{ backupId=$id; time=$b.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"); path=$b.FullName; rowCount=$rc; profile=$ProfileName; complete=$false
                    warning="no .json meta: backup may be incomplete (interrupted). Verify before using for Rollback." }
            }
        }
    }
    return ,$items
}

# Returns hashtable DocCode -> byte[] ; throws if the file is truncated
function Read-RdocBackupBlobs {
    param([string]$BakPath)
    $map = @{}
    $fs = [System.IO.File]::OpenRead($BakPath)
    try {
        $br = New-Object System.IO.BinaryReader $fs
        $magic = [System.Text.Encoding]::ASCII.GetString($br.ReadBytes(8))
        if ($magic -ne 'RDOCBKP1' -and $magic -ne 'RDOCBKP2') { throw "bad backup magic: $magic" }
        [void]$br.ReadInt32()
        while ($fs.Position -lt $fs.Length) {
            $clen = if ($magic -eq 'RDOCBKP2') { $br.ReadInt32() } else { 8 }
            $code = [System.Text.Encoding]::ASCII.GetString($br.ReadBytes($clen)).Trim()
            $len = $br.ReadInt32()
            $bytes = $br.ReadBytes($len)
            if ($bytes.Length -ne $len) { throw "backup file truncated at DocCode $code" }
            $map[$code] = $bytes
        }
    } finally { $fs.Close() }
    return $map
}
