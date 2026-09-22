# ============================================================
# Test DB connection to SAP B1 Company DB (MSSQL or HANA)
# Verifies you can read the RDOC table before running import/export.
# Engine selected via -DBEngine -> dot-sources DB-<engine>.ps1.
# ============================================================
param(
    [string]$Server     = "SLD-C072",
    [string]$CompanyDB  = "SBO_SDA",
    [string]$DBUser     = "sa",
    [string]$DBPassword = "1q2w3e4r",
    [ValidateSet("MSSQL","HANA")]
    [string]$DBEngine   = "MSSQL"
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\DB-$DBEngine.ps1"

# --- resolve host + port for the reachability checks ---------------
# HANA SERVER is "host:port" (port = 3<inst>15). MSSQL uses 1433 and
# SERVER may be "host" or "host\instance".
$hostName = $Server
$port     = if ($DBEngine -eq "HANA") { 30015 } else { 1433 }
if ($Server -match "^(.*):(\d+)$") {
    $hostName = $Matches[1]; $port = [int]$Matches[2]
} elseif ($Server -match "^(.*)\\") {
    $hostName = $Matches[1]   # strip \instance for ping
}

Write-Host "Engine: $DBEngine  Host: $hostName  Port: $port" -ForegroundColor DarkCyan

Write-Host "[1/4] Pinging $hostName ..." -ForegroundColor Cyan
$ping = Test-Connection -ComputerName $hostName -Count 2 -Quiet -ErrorAction SilentlyContinue
Write-Host "      Ping: $(if($ping){'OK'}else{'FAIL (host not reachable / ICMP blocked)'})" -ForegroundColor $(if($ping){'Green'}else{'Yellow'})

Write-Host "[2/4] Testing TCP port $port on $hostName ..." -ForegroundColor Cyan
$tcp = Test-NetConnection -ComputerName $hostName -Port $port -WarningAction SilentlyContinue
Write-Host "      TCP ${port}: $(if($tcp.TcpTestSucceeded){'OPEN'}else{'CLOSED/BLOCKED'})" -ForegroundColor $(if($tcp.TcpTestSucceeded){'Green'}else{'Red'})

Write-Host "[3/4] Testing $DBEngine connection to $CompanyDB ..." -ForegroundColor Cyan
try {
    $conn = New-DBConnection -Server $Server -Database $CompanyDB -User $DBUser -Password $DBPassword
    $ver = try { $conn.ServerVersion } catch { "(n/a)" }
    Write-Host "      DB Login: OK (server $ver)" -ForegroundColor Green

    Write-Host "[4/4] Counting layouts in RDOC ..." -ForegroundColor Cyan
    $cmd = $conn.CreateCommand()
    # Identifiers double-quoted so the same SQL works on case-sensitive
    # HANA and on MSSQL (SqlClient runs QUOTED_IDENTIFIER ON by default).
    $cmd.CommandText = Convert-DBSql 'SELECT COUNT(*) AS "Total", SUM(CASE WHEN "Category"=''C'' THEN 1 ELSE 0 END) AS "Crystal", SUM(CASE WHEN UPPER(COALESCE("Author",'''')) NOT IN ('''',''SYSTEM'') THEN 1 ELSE 0 END) AS "UserEdited" FROM "RDOC"'
    $rdr = $cmd.ExecuteReader()
    if ($rdr.Read()) {
        Write-Host "      Total layouts    : $($rdr['Total'])" -ForegroundColor Green
        Write-Host "      Crystal (C)      : $($rdr['Crystal'])" -ForegroundColor Green
        Write-Host "      User-edited      : $($rdr['UserEdited']) (non-system, exportable)" -ForegroundColor Green
    }
    $rdr.Close()
    $conn.Close()
    Write-Host ""
    Write-Host "READY ($DBEngine)" -ForegroundColor Green
} catch {
    Write-Host "      DB FAIL: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshoot:" -ForegroundColor Yellow
    if ($DBEngine -eq "HANA") {
        Write-Host "  - 'SAP HANA Client not found' -> install hdbclient (Sap.Data.Hana.v4.5.dll)"
        Write-Host "  - 'authentication failed'      -> wrong DBUser/DBPassword"
        Write-Host "  - 'cannot connect'             -> wrong host:port (port = 3<inst>15) or firewall"
        Write-Host "  - 'invalid schema name'        -> CompanyDB must be the HANA schema (UPPERCASE, case-sensitive)"
    } else {
        Write-Host "  - 'Login failed for user'      -> wrong DBUser/DBPassword"
        Write-Host "  - 'Cannot open database X'      -> wrong CompanyDB name"
        Write-Host "  - 'A network-related error'    -> wrong Server name or SQL service down"
    }
}
