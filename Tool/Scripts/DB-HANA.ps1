# ============================================================
# DB Plugin: SAP HANA  (via ODBC)
# Dot-sourced by main scripts via: . "$PSScriptRoot\DB-$DBEngine.ps1"
# Exports the SAME names as DB-MSSQL.ps1 so the engine is swappable.
#
# This environment has the SAP HANA **ODBC** client (driver "HDBODBC32",
# 32-bit) but NOT the ADO.NET provider, so we use System.Data.Odbc.
#   -> Must run under 32-bit PowerShell:
#      %WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe
#   The Run*.bat wrappers switch to it automatically when DBENGINE=HANA.
#
# ODBC uses POSITIONAL parameters ("?"). We keep SQL written with named
# placeholders (:fn, :tc) for readability and let Convert-DBSql rewrite
# them to "?" -- parameters are then bound in the order Add-DBParam is
# called, which matches their left-to-right order in the SQL.
# ============================================================

$DB_PARAM    = ":"                  # named placeholders in SQL; rewritten to ? below
$DB_NOW      = "CURRENT_TIMESTAMP"  # current timestamp
$DB_ISNUM    = ""                   # no direct ISNUMERIC; not used by Export

$HANA_ODBC_DRIVER = "HDBODBC32"     # 32-bit HANA ODBC driver (see: Get-OdbcDriver)
$HANA_DEFAULT_PORT = "30015"        # 3<instance>15 ; instance 00 -> 30015

function New-DBConnection {
    param(
        [string]$Server,    # host  or  host:port (port = 3<inst>15)
        [string]$Database,  # HANA schema (CASE-SENSITIVE, usually UPPERCASE)
        [string]$User,
        [string]$Password,
        [int]$Timeout = 10
    )
    if (-not [Environment]::Is64BitProcess) { } else {
        Write-Warning "Running 64-bit; the HANA ODBC driver is 32-bit ($HANA_ODBC_DRIVER). If connect fails, run via SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
    }
    $node = if ($Server -match ":") { $Server } else { "${Server}:${HANA_DEFAULT_PORT}" }
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
    # ODBC binds positionally; the Name is cosmetic. Order of calls must
    # match the order of "?" placeholders in the (converted) SQL.
    [void]$Command.Parameters.AddWithValue($Name, $Value)
}

function Convert-DBSql {
    param([string]$Sql)
    # named placeholders (:fn, :tc, ...) -> positional ?
    return [Regex]::Replace($Sql, ':[A-Za-z_]\w*', '?')
}
