# ============================================================
# Export Crystal Layouts FROM SAP B1 RDOC -> .rpt files on disk
# Reverse of Import_SQL_Direct.ps1.
# Dumps RDOC.Template (BLOB) to individual <DocName>.rpt files and
# writes an index CSV that maps each file back to DocCode/TypeCode,
# so a later UPDATE re-import matches the SAME RDOC row.
#
# Use this when the .rpt source files are gone but the layouts still
# live inside SAP (e.g. before an MSSQL -> HANA datasource update).
# ============================================================
param(
    [string]$Server     = "SLD-C072",
    [string]$CompanyDB  = "SBO_SDA",
    [string]$DBUser     = "sa",
    [string]$DBPassword = "1q2w3e4r",
    [string]$OutDir     = "$PSScriptRoot\..\ExportedFromSAP",
    [string]$FilterDocName = "",   # e.g. "Invoice" -> only DocName LIKE %Invoice%
    [string]$FilterTypeCode = "",  # e.g. "INV2"   -> only that TypeCode
    [ValidateSet("MSSQL","HANA")]
    [string]$DBEngine = "MSSQL",   # which DB plugin to load
    [switch]$SystemToo             # include system layouts (Author=''/SYSTEM). Default: skip
)

. "$PSScriptRoot\DB-$DBEngine.ps1"

# TypeCode -> ObjectType (reverse of Import_SQL_Direct $TypeCodeMap).
# Used to regenerate the import map so re-import picks the same TypeCode.
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

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
Write-Host "Export target: $OutDir" -ForegroundColor Cyan

$conn = New-DBConnection -Server $Server -Database $CompanyDB -User $DBUser -Password $DBPassword

# SQL is engine-neutral:
#  - COALESCE works on both; Template byte length computed in PowerShell
#    (no DATALENGTH/LENGTH split); LIKE value parameterised (no '%'+x concat)
#  - identifiers double-quoted so case-sensitive HANA matches the real
#    column case; MSSQL accepts it too (QUOTED_IDENTIFIER ON by default)
$where = @('"Template" IS NOT NULL')
if (-not $SystemToo)        { $where += 'UPPER(COALESCE("Author",'''')) NOT IN ('''',''SYSTEM'')' }
if ($FilterDocName)         { $where += "`"DocName`" LIKE ${DB_PARAM}fn" }
if ($FilterTypeCode)        { $where += "`"TypeCode`" = ${DB_PARAM}tc" }
$whereSql = $where -join " AND "

$cmd = $conn.CreateCommand()
$cmd.CommandText = Convert-DBSql "SELECT `"DocCode`", `"DocName`", `"TypeCode`", `"Author`", `"Category`", `"Template`" FROM `"RDOC`" WHERE $whereSql ORDER BY `"TypeCode`", `"DocName`""
if ($FilterDocName)  { Add-DBParam $cmd "${DB_PARAM}fn" "%$FilterDocName%" }
if ($FilterTypeCode) { Add-DBParam $cmd "${DB_PARAM}tc" $FilterTypeCode }

$reader = $cmd.ExecuteReader()
$index = @()
$used  = @{}   # de-dup filenames
$n = 0
while ($reader.Read()) {
    $docCode  = [string]$reader["DocCode"]
    $docName  = [string]$reader["DocName"]
    $typeCode = [string]$reader["TypeCode"]
    $blob     = $reader["Template"]
    if (-not ($blob -is [byte[]])) { continue }

    $base = Sanitize $docName
    $file = "$base.rpt"
    if ($used.ContainsKey($file.ToLower())) {
        $file = "$base`_$docCode.rpt"   # collision -> append DocCode (always unique)
    }
    $used[$file.ToLower()] = $true

    $path = Join-Path $OutDir $file
    [System.IO.File]::WriteAllBytes($path, $blob)
    $n++

    $objType = if ($ObjTypeMap.ContainsKey($typeCode)) { $ObjTypeMap[$typeCode] } else { "" }
    $index += [PSCustomObject]@{
        No           = $n
        Module       = [string]$reader["Category"]
        RPT_FileName = $file
        RPT_Folder   = "_ExportedFromSAP"
        ObjectType   = $objType
        LayoutName   = $docName        # exact DocName -> re-import matches same RDOC row
        DocCode      = $docCode
        TypeCode     = $typeCode
        Author       = [string]$reader["Author"]
        Bytes        = $blob.Length
    }
    Write-Host ("  [{0,4}] {1,-10} {2,-8} {3} ({4} bytes)" -f $n, $docCode, $typeCode, $file, $blob.Length)
}
$reader.Close()
$conn.Close()

$csv = Join-Path $OutDir "_ExportIndex.csv"
$index | Export-Csv -Path $csv -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Exported $n .rpt file(s) -> $OutDir" -ForegroundColor Green
Write-Host "Index map -> $csv" -ForegroundColor Green
Write-Host ""
Write-Host "Next: open one in Crystal Designer to confirm it loads, then run" -ForegroundColor Yellow
Write-Host "Set-DatasourceLocation only if you actually need to re-point it." -ForegroundColor Yellow
