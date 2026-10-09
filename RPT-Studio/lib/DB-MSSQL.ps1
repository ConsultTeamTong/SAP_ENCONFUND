# ============================================================
# DB Plugin: Microsoft SQL Server (System.Data.SqlClient, 64-bit OK)
# Copied from Enconfund\Tool\Scripts\DB-MSSQL.ps1
# ============================================================
$DB_ENGINE   = "MSSQL"
$DB_PARAM    = "@"
$DB_NOW      = "GETDATE()"
$DB_ISNUM    = "ISNUMERIC"
$DB_BLOBLEN  = "DATALENGTH"

function New-DBConnection {
    param([string]$Server, [string]$Database, [string]$User, [string]$Password, [int]$Timeout = 10, [string]$Port = "")
    $srv = if ($Port -and $Server -notmatch '[,\\]') { "$Server,$Port" } else { $Server }
    $cs = if ([string]::IsNullOrEmpty($User)) { "Server=$srv;Database=$Database;Integrated Security=True;Connection Timeout=$Timeout;" }
          else { "Server=$srv;Database=$Database;User ID=$User;Password=$Password;Connection Timeout=$Timeout;" }
    $conn = New-Object System.Data.SqlClient.SqlConnection $cs
    $conn.Open()
    return $conn
}

function Add-BlobParam {
    param($Command, [string]$Name, [byte[]]$Bytes)
    $p = $Command.Parameters.Add($Name, [System.Data.SqlDbType]::Image)
    $p.Value = $Bytes
}

function Add-DBParam {
    param($Command, [string]$Name, $Value)
    [void]$Command.Parameters.AddWithValue($Name, $Value)
}

function Convert-DBSql { param([string]$Sql) return $Sql }
