# ============================================================
# Export RDOC.Template -> .rpt + _ExportIndex.csv   (dot-sourced by rdoc-cli.ps1)
# Logic copied from Enconfund\Tool\Scripts\Export-RDOCToRpt.ps1 (file naming,
# collision rule, ORDER BY, CSV columns identical). Read-only on DB.
# Fix (a): default outDir = <rptRoot>\<companyDb>; folder is never wiped.
# ============================================================

$ObjTypeMap = @{
    "JDT2"="30"; "QUT2"="23"; "RDR2"="17"; "DLN2"="15"; "RDN2"="16"
    "DPI2"="203"; "INV2"="13"; "RIN2"="14"; "PRQ2"="1470000113"; "PQT2"="540000405"
    "POR2"="22"; "PDN2"="20"; "RPD2"="21"; "DPO2"="204"; "PCH2"="18"; "RPC2"="19"
    "IPF1"="69"; "RCT1"="24"; "VPM1"="46"; "IGN1"="59"; "IGE1"="60"; "WTR1"="67"
    "WTQ1"="1250000001"; "INC1"="1470000065"; "WOR1"="202"
}

function Sanitize([string]$name) {
    if ([string]::IsNullOrWhiteSpace($name)) { return "_unnamed" }
    $invalid = [System.IO.Path]::GetInvalidFileNameChars() -join ''
    $re = "[{0}]" -f [Regex]::Escape($invalid)
    return ($name -replace $re, '_').Trim()
}

function Export-Rdoc {
    param($Conn, [string[]]$DocCodes, [string]$OutDir, [switch]$SystemToo)
    if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
    Write-Host "Export target: $OutDir"

    $where = @('"Template" IS NOT NULL')
    if (-not $SystemToo) { $where += 'UPPER(COALESCE("Author",'''')) NOT IN ('''',''SYSTEM'')' }
    $cmd = $Conn.CreateCommand()
    if ($DocCodes -and $DocCodes.Count -gt 0) {
        $ph = @(); $i = 0
        foreach ($d in $DocCodes) { $ph += "${DB_PARAM}dc$i"; $i++ }
        $where += ('"DocCode" IN (' + ($ph -join ',') + ')')
    }
    $cmd.CommandText = Convert-DBSql ('SELECT "DocCode", "DocName", "TypeCode", "Author", "Category", "Template" FROM "RDOC" WHERE ' + ($where -join ' AND ') + ' ORDER BY "TypeCode", "DocName"')
    $i = 0; foreach ($d in $DocCodes) { Add-DBParam $cmd "${DB_PARAM}dc$i" ([string]$d); $i++ }

    $reader = $cmd.ExecuteReader()
    $index = @(); $files = @(); $used = @{}; $n = 0; $seen = @{}
    while ($reader.Read()) {
        $docCode  = [string]$reader["DocCode"]
        $docName  = [string]$reader["DocName"]
        $typeCode = [string]$reader["TypeCode"]
        $blob     = $reader["Template"]
        $seen[$docCode] = $true
        if (-not ($blob -is [byte[]])) { $files += [ordered]@{docCode=$docCode;file="";ok=$false;msg="Template not binary"}; Write-Item $docCode $false "Template not binary"; continue }
        $base = Sanitize $docName
        $file = "$base.rpt"
        if ($used.ContainsKey($file.ToLower())) { $file = "$base`_$docCode.rpt" }
        $used[$file.ToLower()] = $true
        $path = Join-Path $OutDir $file
        try {
            [System.IO.File]::WriteAllBytes("$path.part", $blob); Move-PartFile "$path.part" $path   # safe-on-kill
            $n++
            $objType = if ($ObjTypeMap.ContainsKey($typeCode)) { $ObjTypeMap[$typeCode] } else { "" }
            $index += [PSCustomObject]@{
                No=$n; Module=[string]$reader["Category"]; RPT_FileName=$file; RPT_Folder="_ExportedFromSAP"
                ObjectType=$objType; LayoutName=$docName; DocCode=$docCode; TypeCode=$typeCode
                Author=[string]$reader["Author"]; Bytes=$blob.Length
            }
            $files += [ordered]@{docCode=$docCode;file=$path;ok=$true;msg="$($blob.Length) bytes"}
            Write-Host ("  [{0,4}] {1,-10} {2,-8} {3} ({4} bytes)" -f $n, $docCode, $typeCode, $file, $blob.Length)
            Write-Item $docCode $true $path
        } catch {
            $files += [ordered]@{docCode=$docCode;file=$path;ok=$false;msg=$_.Exception.Message}; Write-Item $docCode $false $_.Exception.Message
            if (Test-Path -LiteralPath "$path.part") { Remove-Item -LiteralPath "$path.part" -Force }
        }
    }
    $reader.Close()
    foreach ($d in $DocCodes) {
        if (-not $seen.ContainsKey([string]$d)) { $files += [ordered]@{docCode=[string]$d;file="";ok=$false;msg="not found / system layout / no template"}; Write-Item ([string]$d) $false "not found / system layout / no template" }
    }
    $csv = Join-Path $OutDir "_ExportIndex.csv"
    if ($index.Count -gt 0) { $index | Export-Csv -Path "$csv.part" -NoTypeInformation -Encoding UTF8; Move-PartFile "$csv.part" $csv }
    Write-Host "Exported $n .rpt file(s) -> $OutDir"
    return [ordered]@{ outDir = $OutDir; files = $files; indexCsv = $(if ($index.Count -gt 0) { $csv } else { "" }) }
}
