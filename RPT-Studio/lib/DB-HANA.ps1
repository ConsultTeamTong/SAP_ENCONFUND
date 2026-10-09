# ============================================================
# DB Plugin: SAP HANA (ODBC, driver HDBODBC32 -> run under SysWOW64 32-bit PowerShell)
# Copied from Enconfund\Tool\Scripts\DB-HANA.ps1 + fixes for RPT Studio.
# Same names as DB-MSSQL.ps1 so engine is swappable.
# Fix (c): $DB_ISNUM was "" -> Import sequence query broke on HANA.
#   Now max-sequence is computed in PowerShell (Get-DBMaxSeqMap), engine-neutral;
#   $DB_ISNUM kept only as an informative marker.
# ============================================================
$DB_ENGINE   = "HANA"
$DB_PARAM    = ":"                  # named placeholders, rewritten to ? by Convert-DBSql
$DB_NOW      = "CURRENT_TIMESTAMP"
$DB_ISNUM    = "-"                  # not used (see Get-DBMaxSeqMap in rdoc-cli)
$DB_BLOBLEN  = "LENGTH"             # byte length of BLOB
$DB_SCHEMA_PREFIX = ""              # CURRENTSCHEMA set in connection string

$HANA_ODBC_DRIVER  = "HDBODBC32"
$HANA_DEFAULT_PORT = "30015"

function New-DBConnection {
    param([string]$Server, [string]$Database, [string]$User, [string]$Password, [int]$Timeout = 10, [string]$Port = "")
    if ([Environment]::Is64BitProcess) {
        Write-Host "WARN: 64-bit process; HANA ODBC driver $HANA_ODBC_DRIVER is 32-bit (use SysWOW64 powershell)"
    }
    $node = if ($Server -match ":") { $Server } elseif ($Port) { "${Server}:$Port" } else { "${Server}:${HANA_DEFAULT_PORT}" }
    $cs = "Driver={$HANA_ODBC_DRIVER};ServerNode=$node;UID=$User;PWD=$Password;CURRENTSCHEMA=$Database;CHAR_AS_UTF8=1;"
    $conn = New-Object System.Data.Odbc.OdbcConnection $cs
    $conn.ConnectionTimeout = $Timeout
    $conn.Open()
    return $conn
}

function Add-BlobParam {
    param($Command, [string]$Name, [byte[]]$Bytes)
    $p = $Command.Parameters.Add($Name, [System.Data.Odbc.OdbcType]::Binary)
    $p.Value = $Bytes
}

function Add-DBParam {
    param($Command, [string]$Name, $Value)
    # ODBC binds positionally: call order must match ? order in SQL
    [void]$Command.Parameters.AddWithValue($Name, $Value)
}

function Convert-DBSql {
    param([string]$Sql)
    # :name -> ?   (skip inside string literals is not needed: our SQL has no ':' in literals)
    return [Regex]::Replace($Sql, ':[A-Za-z_]\w*', '?')
}
