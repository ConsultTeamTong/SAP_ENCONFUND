<#
.SYNOPSIS
  Bulk Set Datasource Location for Crystal Report (.rpt) files -> ODBC Driver 18 for SQL Server.

.DESCRIPTION
  Scans a folder (or single .rpt), loads each report via Crystal Reports .NET SDK and
  re-points EVERY table (main report + all subreports) to an ODBC (RDO) DSN-less
  connection:
      DRIVER={<Driver>};SERVER=<NewServer>;DATABASE=<db>;Encrypt=<Encrypt>;TrustServerCertificate=<TSC>

  Why RAS and not Table.ApplyLogOnInfo:
    ApplyLogOnInfo / ConnectionInfo (Engine API) can only change ServerName / DatabaseName /
    UserID. It can NOT change the database driver, so a report built on
    "OLE DB (ADO) / SQLNCLI11" stays on OLE DB forever (this was the silent failure of v1).
    v2/v3 replaced the connection per table (SetTableLocation). That writes one connection
    record per table, which Designer shows as one UNNAMED connection node per table.
    v4 replaces each distinct connection once with DatabaseController.ReplaceConnection
    (DoNotVerifyDB, no database logon), which also updates the subreports, like Designer's
    Set Datasource Location > Update. Per-table SetTableLocation is only a logged fallback.

  Safety:
    * The report is saved to a temp file first, then RE-OPENED and every table is read
      back and compared with the expected values (DLL, DB type, connection string,
      server, database, table count, Command SQL text). Only when the verify passes is
      the original replaced. On mismatch the original is left untouched, ERR is logged,
      exit code = 1.
    * -WhatIf does the full change + save-to-temp + verify, then deletes the temp file.
      The original .rpt is never written in -WhatIf mode.
    * Green [OK] is printed only for "saved + verified" after ALL tables of the file
      passed. Per-table verify lines are [INFO]; any mismatch is [ERR].
    * By default the original is backed up to "<name>.rpt.bak" before it is replaced
      (an existing .bak is NOT overwritten, so the first original is kept).
      Use -NoBackup (or -BackupSuffix '') to disable.

  Security note (TrustServerCertificate):
    TrustServerCertificate=yes (default here) encrypts the traffic but does NOT validate
    the server certificate, so a man-in-the-middle cannot be detected. Use
    -TrustServerCertificate no when the SQL Server has a certificate from a trusted CA.

  Not verified:
    Whether SAP Business One prints layouts that use ODBC Driver 18, and whether B1
    overrides the report connection with its own login at print time, has NOT been
    confirmed. Test one layout in B1 before converting all of them.

  CR Runtime on this machine is installed in GAC_64, so the script runs as 64-bit
  PowerShell. Falls back to relaunch under SysWOW64 if only GAC_32 is present.

  Mode 2 (-ConnectionFile): use a connection from Crystal Designer "My Connections"
    -ConnectionFile = one of the XML files listed in HKCU\...\Crystal Data Source History
    (CrConnections.ps1 lists them). The WHOLE attribute set of that connection is used
    (Database DLL, Connection String / Provider, Server / Data Source, Database / Initial
    Catalog, UseDSNProperties, Trusted_Connection, User ID ...) exactly like
    Designer > Set Datasource Location > My Connections > Update. QE_DatabaseType is taken
    from the DLL (crdb_odbc.dll = ODBC (RDO), crdb_ado.dll = OLE DB (ADO); other DLLs are
    refused). Empty values, DBE_Item_Description (the list label) and any password key
    are NOT copied: no password is ever written into the .rpt.
    -NewDatabase overrides the database of the connection; -NewUser overrides the user.
    The verify step compares every copied property after re-opening the saved file.

.PARAMETER Path
  Folder to scan recursively, OR a single .rpt path.
.PARAMETER NewServer
  SQL Server host / host\instance / host,port (required unless -ConnectionFile is used).
.PARAMETER ConnectionFile
  Optional. XML file of a Designer "My Connections" entry (see Mode 2 above).
.PARAMETER ConnectionName
  Optional. Label of that connection (only written to the log).
.PARAMETER ResultFile
  Optional. Per-file result lines (UTF-8, tab separated: OK|ERR|SKIP, file, message)
  are appended here. Used by Run-FromSettings.ps1 for the final summary.
.PARAMETER OldServer
  Optional. Only tables whose current server matches (case-insensitive) are rewritten.
.PARAMETER NewDatabase
  Optional. New database name. Empty = keep each table's current database.
.PARAMETER NewUser
  Optional. SQL login stored in the report. Empty = keep existing user id.
.PARAMETER NewPassword
  Optional. Only kept in memory (never written into the connection string).
.PARAMETER Driver
  ODBC driver name. Default 'ODBC Driver 18 for SQL Server'.
.PARAMETER Encrypt
  ODBC 18 Encrypt keyword: yes | no | mandatory | optional | strict. Default yes
  (= ODBC 18 driver default).
.PARAMETER TrustServerCertificate
  yes | no. Default yes, because SQL Servers on a LAN usually use a self-signed
  certificate and ODBC 18 (Encrypt=yes) rejects it unless TrustServerCertificate=yes.
  Use 'no' if the server has a certificate from a trusted CA.
.PARAMETER Filter
  File mask. Default *.rpt
.PARAMETER NoRecurse
  Do not recurse into subfolders.
.PARAMETER BackupSuffix
  Default '.bak'. Original .rpt is copied to "<name>.rpt<suffix>" before it is
  replaced (skipped if that backup already exists). '' disables the backup.
.PARAMETER NoBackup
  Do not create a backup (same as -BackupSuffix ''; use this from the .bat, which
  cannot pass an empty argument).
.PARAMETER LogFile
  Log file path. Default <script-dir>\_SetLocation.log
.PARAMETER WhatIf
  Change + verify on a temp copy only; the original .rpt is not written.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory)] [string] $Path,
    [string] $NewServer       = '',
    [string] $ConnectionFile  = '',
    [string] $ConnectionName  = '',
    [string] $ResultFile      = '',
    [string] $OldServer       = '',
    [string] $NewDatabase     = '',
    [string] $NewUser         = '',
    [string] $NewPassword     = '',
    [string] $Driver          = 'ODBC Driver 18 for SQL Server',
    [ValidateSet('yes','no','mandatory','optional','strict')]
    [string] $Encrypt         = 'yes',
    [ValidateSet('yes','no')]
    [string] $TrustServerCertificate = 'yes',
    [string] $Filter          = '*.rpt',
    [switch] $NoRecurse,
    [string] $BackupSuffix    = '.bak',
    [switch] $NoBackup,
    [string] $LogFile         = ''
)
if ($NoBackup) { $BackupSuffix = '' }

# A trailing backslash before a closing quote ("C:\x\") arrives as C:\x" under -File.
$Path      = $Path.Trim().Trim('"').TrimEnd('\')
if ($Path -match '^[A-Za-z]:$') { $Path += '\' }
$NewServer = $NewServer.Trim()
$NewDatabase = $NewDatabase.Trim()
$NewUser   = $NewUser.Trim()
$ConnectionFile = $ConnectionFile.Trim().Trim('"')
$UseHist   = [bool]$ConnectionFile
if (-not $UseHist -and -not $NewServer) {
    Write-Error "Give -NewServer (build an ODBC Driver 18 connection) or -ConnectionFile (use a Designer 'My Connections' entry)."
    exit 2
}

if (-not $LogFile) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
    $LogFile = Join-Path $scriptDir '_SetLocation.log'
}

# --- Bitness check: CR Runtime native libs (ReportAppServer) live in GAC_32 or GAC_64
$arch = if ([Environment]::Is64BitProcess) { 'x64' } else { 'x86' }
Write-Host "[arch] running as $arch PowerShell" -ForegroundColor DarkGray
$gacRas32 = Test-Path 'C:\Windows\Microsoft.NET\assembly\GAC_32\CrystalDecisions.ReportAppServer.CommLayer'
$gacRas64 = Test-Path 'C:\Windows\Microsoft.NET\assembly\GAC_64\CrystalDecisions.ReportAppServer.CommLayer'
if (-not $gacRas32 -and -not $gacRas64) {
    Write-Error "Crystal Reports Runtime for .NET 4.0 not found (no ReportAppServer.CommLayer in GAC_32/GAC_64). Install CRRuntime_*_13_0_xx.msi from SAP."
    exit 2
}
if ([Environment]::Is64BitProcess -and -not $gacRas64 -and $gacRas32) {
    $ps86 = "$env:WINDIR\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
    Write-Host "[relaunch] CR runtime is 32-bit only - switching to $ps86" -ForegroundColor Yellow
    $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File', $PSCommandPath)
    foreach ($k in $PSBoundParameters.Keys) {
        $v = $PSBoundParameters[$k]
        if ($v -is [switch]) { if ($v.IsPresent) { $argList += "-$k" } }
        else                 { $argList += "-$k"; $argList += [string]$v }
    }
    & $ps86 @argList; exit $LASTEXITCODE
}
if (-not [Environment]::Is64BitProcess -and -not $gacRas32 -and $gacRas64) {
    Write-Error "Running 32-bit but CR Runtime is 64-bit only. Re-run from 64-bit PowerShell, or install CRRuntime_32bit_13_0_xx.msi."
    exit 2
}

# --- Locate & load Crystal Reports SDK (Engine from GAC_MSIL, RAS from GAC) ---
function Load-CrystalSDK {
    $gacRoot = 'C:\Windows\Microsoft.NET\assembly\GAC_MSIL'
    $names = 'CrystalDecisions.Shared','CrystalDecisions.ReportSource','CrystalDecisions.CrystalReports.Engine'
    foreach ($n in $names) {
        $dir = Join-Path $gacRoot $n
        if (-not (Test-Path $dir)) { throw "GAC folder not found: $dir" }
        $dll = Get-ChildItem $dir -Recurse -Filter "$n.dll" |
               Sort-Object { [version](($_.Directory.Name -split '_')[1]) } -Descending |
               Select-Object -First 1
        if (-not $dll) { throw "DLL not found under $dir" }
        [void][System.Reflection.Assembly]::LoadFrom($dll.FullName)
        Write-Host "[sdk] loaded $($dll.FullName)" -ForegroundColor DarkGray
    }
    foreach ($n in 'ClientDoc','DataDefModel','Controllers') {
        $a = [System.Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.ReportAppServer.$n")
        if (-not $a) { throw "RAS assembly not found: CrystalDecisions.ReportAppServer.$n" }
        Write-Host "[sdk] loaded $($a.Location)" -ForegroundColor DarkGray
    }
}
try { Load-CrystalSDK } catch { Write-Error "SDK load failed: $($_.Exception.Message)"; exit 3 }

# --- Logging ---
$logDir = Split-Path $LogFile -Parent
if ($logDir -and -not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force -WhatIf:$false -Confirm:$false | Out-Null
}
function Log {
    param([string]$Level,[string]$Msg)
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "[$ts][$Level] $Msg"
    switch ($Level) {
        'ERR'  { Write-Host $line -ForegroundColor Red }
        'WARN' { Write-Host $line -ForegroundColor Yellow }
        'OK'   { Write-Host $line -ForegroundColor Green }
        default{ Write-Host $line }
    }
    try { [System.IO.File]::AppendAllText($LogFile, $line + "`r`n", [System.Text.Encoding]::UTF8) }
    catch { Write-Host "  (log write failed: $($_.Exception.Message))" -ForegroundColor DarkRed }
}

function Write-Result([string]$status, [string]$file, [string]$msg) {
    if (-not $ResultFile) { return }
    $line = ($status, $file, ($msg -replace "[`t`r`n]+", ' ')) -join "`t"
    try { [System.IO.File]::AppendAllText($ResultFile, $line + "`r`n", (New-Object System.Text.UTF8Encoding($false))) } catch {}
}

$isWhatIf = [bool]$WhatIfPreference
Log 'INFO' "=== Set-DatasourceLocation v4 (RAS ReplaceConnection) start ==="

# --- Mode 2: connection from Designer "My Connections" (read-only) ---
$Hist = $null
if ($UseHist) {
    . (Join-Path $(if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }) 'CrConnections.ps1')
    try {
        if (-not [System.IO.File]::Exists($ConnectionFile)) { throw "file not found" }
        $Hist = ConvertTo-CrConnEntry (Read-CrConnectionFile $ConnectionFile) $ConnectionFile 0
    } catch {
        Log 'ERR' "Cannot read connection file '$ConnectionFile': $($_.Exception.Message)"
        exit 4
    }
    if (-not $Hist.Usable) { Log 'ERR' "Connection '$($Hist.Name)' cannot be used: $($Hist.Note)"; exit 4 }
    $script:HistDb   = if ($NewDatabase) { $NewDatabase } else { $Hist.Database }
    $script:HistUser = if ($NewUser) { $NewUser } else { $Hist.User }
    Log 'INFO' "Path=$Path  OldServer=$OldServer  NewDatabase=$NewDatabase  NewUser=$NewUser  WhatIf=$isWhatIf  Backup=$(if($BackupSuffix){'*.rpt'+$BackupSuffix}else{'OFF'})"
    Log 'INFO' "Target (My Connections, read via $($Hist.Method)): name='$(if($ConnectionName){$ConnectionName}else{$Hist.Name})'  DLL=$($Hist.Dll)  Type=$($Hist.DbType)  Driver/Provider=$($Hist.Driver)  Server=$($Hist.Server)  Database=$($script:HistDb)  User=$($script:HistUser)"
    Log 'INFO' "  source file: $ConnectionFile"
    if ($Hist.DbType -eq 'ODBC (RDO)' -and $Hist.Driver -and -not $Hist.Driver.StartsWith('DSN ')) {
        if (-not (Test-Path ("HKLM:\SOFTWARE\WOW6432Node\ODBC\ODBCINST.INI\" + $Hist.Driver))) {
            Log 'WARN' "ODBC driver '$($Hist.Driver)' is not in the 32-bit ODBC driver list of this PC. The location is set anyway; the report can only be previewed on a PC that has this driver."
        }
    }
} else {
Log 'INFO' "Path=$Path  NewServer=$NewServer  OldServer=$OldServer  NewDatabase=$NewDatabase  NewUser=$NewUser  WhatIf=$isWhatIf  Backup=$(if($BackupSuffix){'*.rpt'+$BackupSuffix}else{'OFF'})"
Log 'INFO' "Target: Database DLL=crdb_odbc.dll  Type=ODBC (RDO)  Driver={$Driver}  Encrypt=$Encrypt  TrustServerCertificate=$TrustServerCertificate"

# --- Is the ODBC driver registered on this machine? (setting location does not need it,
#     but the report cannot be previewed/printed here without it) ---
$drv64 = Test-Path ("HKLM:\SOFTWARE\ODBC\ODBCINST.INI\" + $Driver)
$drv32 = Test-Path ("HKLM:\SOFTWARE\WOW6432Node\ODBC\ODBCINST.INI\" + $Driver)
if (-not ($drv64 -and $drv32)) {
    Log 'WARN' "ODBC driver '$Driver' registered: 64-bit=$drv64 32-bit=$drv32. Location can still be set, but reports will not run on this PC until the driver is installed (x64 MSI installs both 64-bit and 32-bit)."
}
}

# --- Enumerate .rpt files ---
$rpts = @()
$badChars = [System.IO.Path]::GetInvalidPathChars() + [char[]]'*?'
if ($Path.IndexOfAny($badChars) -ge 0) {
    Log 'ERR' "Path contains invalid characters (often a quoted path ending with \ e.g. ""C:\x\"" which swallows the next arguments): $Path"
    exit 4
}
if (Test-Path -LiteralPath $Path -PathType Leaf) {
    if ($Path -like '*.rpt') { $rpts = ,(Get-Item -LiteralPath $Path) }
    else { Log 'ERR' "Path is a file but not .rpt: $Path"; exit 4 }
} elseif (Test-Path -LiteralPath $Path -PathType Container) {
    $gciArgs = @{ LiteralPath = $Path; Filter = $Filter; File = $true }
    if (-not $NoRecurse) { $gciArgs['Recurse'] = $true }
    $rpts = @(Get-ChildItem @gciArgs | Where-Object { $_.Extension -eq '.rpt' -and $_.Name -notlike '*.setloc_tmp.rpt' })
} else {
    Log 'ERR' "Path not found: $Path"; exit 4
}
Log 'INFO' "Found $($rpts.Count) report file(s)."

# --- RAS helpers ---
$script:famWarn = 0
$script:fbTotal = 0
function Get-DbFamily([string]$text) {
    if ($text -match 'HDBODBC|B1CRHPROXY|NDB@|HANA') { return 'HANA' }
    if ($text -match 'SQLNCLI|SQLOLEDB|MSOLEDBSQL|SQL Server') { return 'SQL Server' }
    return ''
}
function Get-Attr($ci, [string]$key) {
    try { return $ci.Attributes.Item($key) } catch { return $null }
}
function Get-LogonProp($ci, [string]$key) {
    $lp = Get-Attr $ci 'QE_LogonProperties'
    if ($null -eq $lp) { return $null }
    try { return $lp.Item($key) } catch { return $null }
}
function Get-CurServer($ci) {
    foreach ($v in @((Get-Attr $ci 'QE_ServerDescription'), (Get-LogonProp $ci 'Data Source'), (Get-LogonProp $ci 'Server'))) {
        if ($v) { return [string]$v }
    }
    return ''
}
function Get-CurDatabase($ci) {
    foreach ($v in @((Get-Attr $ci 'QE_DatabaseName'), (Get-LogonProp $ci 'Initial Catalog'), (Get-LogonProp $ci 'Database'))) {
        if ($v) { return [string]$v }
    }
    return ''
}
function Get-ConnString([string]$db) {
    return "DRIVER={$Driver};SERVER=$NewServer;DATABASE=$db;Encrypt=$Encrypt;TrustServerCertificate=$TrustServerCertificate"
}
function Get-TargetUser($oldCi) {
    if ($NewUser) { return $NewUser }
    return [string]$oldCi.UserName
}
function New-OdbcConnInfo($oldCi, [string]$db) {
    $lp = New-Object CrystalDecisions.ReportAppServer.DataDefModel.PropertyBagClass
    $lp.Add('Connection String', (Get-ConnString $db))
    $lp.Add('Server', $NewServer)
    $lp.Add('Database', $db)
    $lp.Add('UseDSNProperties', 'False')
    # For ODBC (RDO) the user id is only persisted in the .rpt when it is also put in the
    # logon property bag as 'User ID' (ConnectionInfo.UserName alone is lost on save --
    # tested 2026-10-08 with CR for .NET 13.0.4000 x64).
    $user = Get-TargetUser $oldCi
    if ($user) { $lp.Add('User ID', $user) }
    $at = New-Object CrystalDecisions.ReportAppServer.DataDefModel.PropertyBagClass
    $at.Add('Database DLL', 'crdb_odbc.dll')
    $at.Add('QE_DatabaseName', $db)
    $at.Add('QE_DatabaseType', 'ODBC (RDO)')
    $at.Add('QE_LogonProperties', $lp)
    $at.Add('QE_ServerDescription', $NewServer)
    $at.Add('QE_SQLDB', 'True')
    $at.Add('SSO Enabled', 'False')
    $ci = New-Object CrystalDecisions.ReportAppServer.DataDefModel.ConnectionInfoClass
    $ci.Attributes = $at
    $ci.Kind = [CrystalDecisions.ReportAppServer.DataDefModel.CrConnectionInfoKindEnum]::crConnectionInfoKindCRQE
    if ($user)        { $ci.UserName = $user }
    if ($NewPassword) { $ci.Password = $NewPassword }
    return $ci
}
# --- Mode 2 helpers -------------------------------------------------------------
function Test-IsPasswordKey([string]$k) { return ($k -match '^(?i)\s*(password|pwd)\s*$') }
function Remove-ConnStrPassword([string]$cs) {
    return ($cs -replace '(?i)(?:^|;)\s*(?:pwd|password)\s*=\s*(?:\{[^}]*\}|[^;]*)', '').Trim(';')
}
function Set-ConnStrDatabase([string]$cs, [string]$db) {
    # only the DATABASE= keyword (not databaseName= of B1CRHPROXY)
    return [regex]::Replace($cs, '(?i)((?:^|;)\s*DATABASE\s*=\s*)(\{[^}]*\}|[^;]*)', { param($m) $m.Groups[1].Value + $db })
}
# Logon property bag that will be written for the selected connection (ordered).
# 'User ID' / 'UserId' are not in this list: the engine drops them from the logon
# properties on save and keeps the user in ConnectionInfo.UserName (checked by verify).
function Get-HistLogonPairs {
    $isAdo = ($Hist.DbType -eq 'OLE DB (ADO)')
    $pairs = [ordered]@{}
    foreach ($k in $Hist.Props.Keys) {
        if ($k -eq '__Method' -or $k -eq 'DBE_Item_Description' -or $k -eq 'User ID' -or $k -eq 'UserId' -or $k -eq 'Database DLL') { continue }   # 'Database DLL' is an attribute, Designer never puts it in the logon properties
        if (Test-IsPasswordKey $k) { Log 'WARN' "  password property '$k' of the connection is NOT copied"; continue }
        $v = [string]$Hist.Props[$k]
        if ($v -eq '') { continue }     # Designer does not store empty properties in the .rpt
        if ($k -eq 'Connection String') {
            $v2 = Remove-ConnStrPassword $v
            if ($v2 -ne $v) { Log 'WARN' "  PWD= removed from Connection String (password is never written)"; $v = $v2 }
            if ($NewDatabase -and $v -match '(?i)(?:^|;)\s*DATABASE\s*=') { $v = Set-ConnStrDatabase $v $NewDatabase }
        }
        $pairs[$k] = $v
    }
    if ($NewDatabase) {
        if ($isAdo) { $pairs['Initial Catalog'] = $NewDatabase } else { $pairs['Database'] = $NewDatabase }
    }
    return $pairs
}
function Get-HistWantAttrs {
    return [ordered]@{
        'Database DLL'         = $Hist.Dll
        'QE_DatabaseType'      = $Hist.DbType
        'QE_ServerDescription' = $Hist.Server
        'QE_DatabaseName'      = [string]$script:HistDb
        'QE_SQLDB'             = $(if ($Hist.DbType -eq 'ODBC (RDO)') { 'True' } else { 'False' })
        'SSO Enabled'          = 'False'
    }
}
function New-HistConnInfo {
    $lp = New-Object CrystalDecisions.ReportAppServer.DataDefModel.PropertyBagClass
    $pairs = Get-HistLogonPairs
    foreach ($k in $pairs.Keys) { $lp.Add($k, $pairs[$k]) }
    if ($script:HistUser) { $lp.Add('User ID', $script:HistUser) }
    $at = New-Object CrystalDecisions.ReportAppServer.DataDefModel.PropertyBagClass
    $w = Get-HistWantAttrs
    foreach ($k in $w.Keys) { $at.Add($k, $w[$k]) }
    $at.Add('QE_LogonProperties', $lp)
    $ci = New-Object CrystalDecisions.ReportAppServer.DataDefModel.ConnectionInfoClass
    $ci.Attributes = $at
    $ci.Kind = [CrystalDecisions.ReportAppServer.DataDefModel.CrConnectionInfoKindEnum]::crConnectionInfoKindCRQE
    if ($script:HistUser) { $ci.UserName = $script:HistUser }
    # never set $ci.Password
    return $ci
}

function Get-CmdText($t) {
    try { return [string]$t.CommandText } catch { return '' }
}

# --- v4: replace whole connections (like Designer > Set Datasource Location > Update on the
# connection node) instead of SetTableLocation per table.
# Found 2026-10-08 (RAS for .NET 13.0.31 x64): SetTableLocation per table writes ONE NEW
# connection record per table into the QESession stream (stream size 8380 -> 17901 bytes for a
# 4-table report; Designer's own save kept 8380). That is what Designer shows as one unnamed
# connection node per table. DatabaseController.ReplaceConnection keeps one connection record
# and also updates every subreport that uses the same connection.
function Get-ConnKey($ci) {
    $parts = @((Get-Attr $ci 'Database DLL'), (Get-Attr $ci 'QE_ServerDescription'), (Get-Attr $ci 'QE_DatabaseName'),
               [string]$ci.UserName, (Get-LogonProp $ci 'Connection String'), (Get-LogonProp $ci 'Provider'),
               (Get-LogonProp $ci 'Data Source'), (Get-LogonProp $ci 'Initial Catalog'), (Get-LogonProp $ci 'Server'),
               (Get-LogonProp $ci 'Database'))
    return (($parts | ForEach-Object { [string]$_ }) -join '|')
}
# New connection for ReplaceConnection. It MUST start from a clone of the existing connection:
# a brand-new ConnectionInfoClass passed to ReplaceConnection makes the RAS engine spin at 100% CPU
# for ever (no network traffic) when the database DLL changes (tested 2026-10-08).
function New-ReplacementConnInfo($oldCi, [string]$db) {
    $tmpl = if ($UseHist) { New-HistConnInfo } else { New-OdbcConnInfo $oldCi $db }
    $nc = $oldCi.Clone($true)
    $nc.Attributes = $tmpl.Attributes
    $nc.Kind = $tmpl.Kind
    if ([string]$tmpl.UserName) { $nc.UserName = $tmpl.UserName }
    if (-not $UseHist -and $NewPassword) { $nc.Password = $NewPassword }
    return $nc
}
# Sizes of the QESession streams (main = 'QESession', subreports = 'Subdocument N/QESession').
# The QESession stream holds the connection records; RAS does not expose a connection count, so
# the stream size is used as a proxy to detect "one connection per table" (it grows ~70-115%).
if (-not ('SetLocStg' -as [type])) {
Add-Type -TypeDefinition @'
using System; using System.Collections.Generic; using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
public static class SetLocStg {
  [DllImport("ole32.dll")] static extern int StgOpenStorage([MarshalAs(UnmanagedType.LPWStr)] string name, IntPtr prio, uint mode, IntPtr excl, uint res, out IStorage stg);
  [ComImport, Guid("0000000b-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
  public interface IStorage {
    void CreateStream(string a, uint b, uint c, uint d, out IStream s);
    void OpenStream(string a, IntPtr r, uint m, uint res, out IStream s);
    void CreateStorage(string a, uint b, uint c, uint d, out IStorage s);
    void OpenStorage([MarshalAs(UnmanagedType.LPWStr)] string name, IntPtr p, uint mode, IntPtr excl, uint res, out IStorage s);
    void CopyTo(); void MoveElementTo(); void Commit(); void Revert();
    void EnumElements(uint a, IntPtr b, uint c, out IEnumSTATSTG e);
  }
  [ComImport, Guid("0000000d-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
  public interface IEnumSTATSTG { [PreserveSig] int Next(uint celt, [Out, MarshalAs(UnmanagedType.LPArray)] System.Runtime.InteropServices.ComTypes.STATSTG[] r, out uint f); }
  public static Dictionary<string,long> QeSizes(string file) {
    var d = new Dictionary<string,long>(); IStorage s;
    int hr = StgOpenStorage(file, IntPtr.Zero, 0x10, IntPtr.Zero, 0, out s);
    if (hr != 0) throw new Exception("cannot open " + file + " as compound file, hr=0x" + hr.ToString("X"));
    try { Walk(s, "", d); } finally { Marshal.ReleaseComObject(s); }
    return d;
  }
  static void Walk(IStorage s, string prefix, Dictionary<string,long> d) {
    IEnumSTATSTG e; s.EnumElements(0, IntPtr.Zero, 0, out e);
    var a = new System.Runtime.InteropServices.ComTypes.STATSTG[1]; uint f;
    try {
      while (e.Next(1, a, out f) == 0 && f == 1) {
        string n = a[0].pwcsName;
        if (a[0].type == 1 && n.StartsWith("Subdocument")) {
          IStorage c; s.OpenStorage(n, IntPtr.Zero, 0x10, IntPtr.Zero, 0, out c);
          try { Walk(c, prefix + n + "/", d); } finally { Marshal.ReleaseComObject(c); }
        } else if (a[0].type == 2 && n == "QESession") { d[prefix + n] = a[0].cbSize; }
      }
    } finally { Marshal.ReleaseComObject(e); }
  }
}
'@
}
function Get-ScopeConnCounts($all) {
    $h = @{}
    foreach ($e in $all) {
        if (-not $h.ContainsKey($e.Scope)) { $h[$e.Scope] = @{} }
        $h[$e.Scope][(Get-ConnKey $e.Table.ConnectionInfo)] = 1
    }
    $r = @{}; foreach ($k in $h.Keys) { $r[$k] = $h[$k].Count }
    return $r
}
# Connection count check (before vs after) -> list of error strings.
function Test-ConnCounts($before, $after, $qeBefore, $qeAfter) {
    $errs = @()
    foreach ($s in $before.Keys) {
        $a = if ($after.ContainsKey($s)) { $after[$s] } else { 0 }
        if ($a -gt $before[$s]) { $errs += "[$s] distinct connections $a > before $($before[$s])" }
    }
    foreach ($s in $qeBefore.Keys) {
        $b = [long]$qeBefore[$s]
        if (-not $qeAfter.ContainsKey($s)) { $errs += "stream $s missing after save"; continue }
        $a = [long]$qeAfter[$s]
        # one record per table instead of one per connection made this stream grow +53 % to +114 %
        # (2-4 tables); ReplaceConnection stayed between -33 % and +10 % (8 test reports, 2026-10-08)
        if ($a -gt ($b * 1.3 + 512)) { $errs += "stream $s grew $b -> $a bytes: connection was split into one connection per table" }
    }
    return ,$errs
}
function Get-QeSizes([string]$file) {
    $h = @{}
    $d = [SetLocStg]::QeSizes($file)
    foreach ($k in $d.Keys) { $h[$k] = [long]$d[$k] }
    return $h
}

# Collect every table of the main report and all subreports (RAS view).
# Crystal does not allow a subreport inside a subreport, so one level is complete.
function Get-AllTables($rcd) {
    $list = New-Object System.Collections.ArrayList
    foreach ($t in @($rcd.DatabaseController.Database.Tables)) {
        [void]$list.Add([pscustomobject]@{ Scope='main'; Sub=$null; Table=$t })
    }
    foreach ($sn in @($rcd.SubreportController.GetSubreportNames())) {
        foreach ($t in @($rcd.SubreportController.GetSubreportDatabase($sn).Tables)) {
            [void]$list.Add([pscustomobject]@{ Scope="sub:$sn"; Sub=$sn; Table=$t })
        }
    }
    return ,$list
}

# Plan for one table (nothing is changed here): $null = skipped by -OldServer.
function Get-TablePlan($entry) {
    $t   = $entry.Table
    $ci  = $t.ConnectionInfo
    $curServer = Get-CurServer $ci
    $curDb     = Get-CurDatabase $ci
    $curType   = Get-Attr $ci 'QE_DatabaseType'
    if ($OldServer -and ($curServer -ne $OldServer)) {
        Log 'INFO' "  [$($entry.Scope)] skip table '$($t.Alias)' (server='$curServer' != OldServer)"
        return $null
    }
    if ($UseHist) {
        # Warn (do not block) when the chosen connection is another database family than the report,
        # e.g. a T-SQL report (SQL Server) re-pointed to a HANA connection: it saves fine but fails at run time.
        $curFam  = Get-DbFamily ("$(Get-LogonProp $ci 'Provider') $(Get-LogonProp $ci 'Connection String') $curServer")
        $histFam = Get-DbFamily ("$($Hist.Driver) $($Hist.Props['Provider']) $($Hist.Props['Connection String']) $($Hist.Server)")
        if ($curFam -and $histFam -and $curFam -ne $histFam) {
            Log 'WARN' "  [$($entry.Scope)] '$($t.Alias)' report is $curFam but the chosen connection is $histFam -- the SQL of this report will probably NOT run on it"
            $script:famWarn++
        }
        $db = [string]$script:HistDb
        $user = [string]$script:HistUser
        $newSrv = $Hist.Server; $newType = $Hist.DbType
    } else {
        $db = if ($NewDatabase) { $NewDatabase } else { $curDb }
        if (-not $db) { throw "[$($entry.Scope)] table '$($t.Alias)': current database is empty and -NewDatabase not given" }
        $user = Get-TargetUser $ci
        $newSrv = $NewServer; $newType = 'ODBC (RDO)'
    }
    $qn = $null
    if ($t.ClassName -ne 'CrystalReports.CommandTable' -and $curDb -and $db -and $curDb -ne $db -and $t.QualifiedName -like "$curDb.*") {
        $qn = $db + $t.QualifiedName.Substring($curDb.Length)
    }
    Log 'INFO' "  [$($entry.Scope)] '$($t.Alias)' $curType server '$curServer' db '$curDb' -> $newType server '$newSrv' db '$db'"
    return [pscustomobject]@{ Key="$($entry.Scope)|$($t.Alias)"; Db=$db; Cmd=(Get-CmdText $t); User=$user
                              OldConn=(Get-ConnKey $ci); WantQN=$qn; Scope=$entry.Scope; Alias=$t.Alias }
}


# Re-open a saved .rpt and compare every table with what we expect.
function Test-SavedReport([string]$file, $expected, [int]$expectedTableCount, $connBefore, $qeBefore) {
    $errs = New-Object System.Collections.ArrayList
    $vdoc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
    try {
        $vdoc.Load($file, [CrystalDecisions.Shared.OpenReportMethod]::OpenReportByTempCopy)
        $all = Get-AllTables $vdoc.ReportClientDocument
        if ($all.Count -ne $expectedTableCount) {
            [void]$errs.Add("table count $($all.Count) != expected $expectedTableCount")
        }
        $connAfter = Get-ScopeConnCounts $all
        $qeAfter   = Get-QeSizes $file
        foreach ($m in (Test-ConnCounts $connBefore $connAfter $qeBefore $qeAfter)) { [void]$errs.Add($m) }
        foreach ($s in ($connBefore.Keys | Sort-Object)) {
            Log 'INFO' "  verify connections [$s] before=$($connBefore[$s]) after=$($connAfter[$s])"
        }
        foreach ($sk in ($qeBefore.Keys | Sort-Object)) {
            Log 'INFO' "  verify connection stream $sk $($qeBefore[$sk]) -> $($qeAfter[$sk]) bytes"
        }
        $seen = 0
        foreach ($e in $all) {
            $key = "$($e.Scope)|$($e.Table.Alias)"
            if (-not $expected.ContainsKey($key)) { continue }   # skipped by -OldServer
            $seen++
            $x  = $expected[$key]
            $ci = $e.Table.ConnectionInfo
            if ($null -ne (Get-LogonProp $ci 'Database DLL')) {
                # SetTableLocation (fallback, same as v3) always adds it; ReplaceConnection must not
                if ($x.PSObject.Properties['Fallback']) { Log 'WARN' "  [$key] fallback table has logon property 'Database DLL' (same as v3 output; Designer does not write it)" }
                else { [void]$errs.Add("[$key] logon property 'Database DLL' present (per-table SetTableLocation artefact, Designer never writes it)") }
            }
            if ($x.WantQN -and $e.Table.QualifiedName -ne $x.WantQN) { [void]$errs.Add("[$key] QualifiedName='$($e.Table.QualifiedName)' expected '$($x.WantQN)'") }
            if ($UseHist) {
                $bad = @()
                $wa = Get-HistWantAttrs
                foreach ($k in $wa.Keys) {
                    $g = [string](Get-Attr $ci $k)
                    if ($g -ne $wa[$k]) { $bad += "$k='$g' expected '$($wa[$k])'" }
                }
                $wl = Get-HistLogonPairs
                foreach ($k in $wl.Keys) {
                    $g = [string](Get-LogonProp $ci $k)
                    # The CR engine stores some keys under another name on save (seen with
                    # CR for .NET 13.0.4000): 'Server Type' -> 'PreQEServerType'.
                    if ($g -eq '' -and $k -eq 'Server Type') { $g = [string](Get-LogonProp $ci 'PreQEServerType') }
                    if ($g -cne $wl[$k]) { $bad += "logon '$k'='$g' expected '$($wl[$k])'" }
                }
                if ([string]$ci.UserName -ne [string]$x.User) { $bad += "UserName='$($ci.UserName)' expected '$($x.User)'" }
                $lpGot = Get-Attr $ci 'QE_LogonProperties'
                if ($lpGot) {
                    foreach ($k in $lpGot.PropertyIDs) {
                        if ((Test-IsPasswordKey $k) -and [string]$lpGot.Item($k)) { $bad += "password property '$k' found in saved file" }
                    }
                }
                if ((Get-LogonProp $ci 'Connection String') -match '(?i)(^|;)\s*(pwd|password)\s*=') { $bad += "password found in Connection String" }
                if ((Get-CmdText $e.Table) -ne $x.Cmd) { $bad += "Command SQL text changed" }
                if ($bad.Count) { [void]$errs.Add("[$key] " + ($bad -join '; ')) }
                else { Log 'INFO' "  verify [$($e.Scope)] '$($e.Table.Alias)' $(Get-Attr $ci 'QE_DatabaseType') | server '$(Get-Attr $ci 'QE_ServerDescription')' db '$(Get-Attr $ci 'QE_DatabaseName')' | $($wl.Count) logon properties match" }
                continue
            }
            $got = [ordered]@{
                'Database DLL'         = [string](Get-Attr $ci 'Database DLL')
                'QE_DatabaseType'      = [string](Get-Attr $ci 'QE_DatabaseType')
                'QE_ServerDescription' = [string](Get-Attr $ci 'QE_ServerDescription')
                'QE_DatabaseName'      = [string](Get-Attr $ci 'QE_DatabaseName')
                'Connection String'    = [string](Get-LogonProp $ci 'Connection String')
                'UserName'             = [string]$ci.UserName
            }
            $want = [ordered]@{
                'Database DLL'         = 'crdb_odbc.dll'
                'QE_DatabaseType'      = 'ODBC (RDO)'
                'QE_ServerDescription' = $NewServer
                'QE_DatabaseName'      = $x.Db
                'Connection String'    = (Get-ConnString $x.Db)
                'UserName'             = [string]$x.User
            }
            $bad = @()
            foreach ($k in $want.Keys) { if ($got[$k] -ne $want[$k]) { $bad += "$k='$($got[$k])' expected '$($want[$k])'" } }
            if ((Get-CmdText $e.Table) -ne $x.Cmd) { $bad += "Command SQL text changed" }
            if ($bad.Count) { [void]$errs.Add("[$key] " + ($bad -join '; ')) }
            else { Log 'INFO' "  verify [$($e.Scope)] '$($e.Table.Alias)' $($got['QE_DatabaseType']) | $($got['Connection String'])" }
        }
        if ($seen -ne $expected.Count) { [void]$errs.Add("verified $seen table(s) but changed $($expected.Count)") }
    } finally {
        try { $vdoc.Close(); $vdoc.Dispose() } catch {}
    }
    return ,$errs
}

# Paths >= 260 chars fail in the CR engine ("Load report failed." / SaveAs "cannot find
# the path"). Work on short copies in %TEMP% and use \\?\ only for the file copies.
function Get-FileSha256([string]$p) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $fs  = [System.IO.File]::OpenRead($p)
    try { return [BitConverter]::ToString($sha.ComputeHash($fs)) } finally { $fs.Dispose(); $sha.Dispose() }
}
function Get-LongPath([string]$p) { if ($p.StartsWith('\\?\')) { $p } elseif ($p.StartsWith('\\')) { '\\?\UNC\' + $p.Substring(2) } else { '\\?\' + $p } }

# --- Process each report ---
$okCount = 0; $errCount = 0; $skipCount = 0
foreach ($f in $rpts) {
    Log 'INFO' "--> $($f.FullName)"
    $doc  = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
    $work = Join-Path ([System.IO.Path]::GetTempPath()) ('setloc_' + [guid]::NewGuid().ToString('N'))
    try {
        [void][System.IO.Directory]::CreateDirectory($work)
        $src = Join-Path $work 'src.rpt'
        $tmp = Join-Path $work 'out.rpt'
        [System.IO.File]::Copy((Get-LongPath $f.FullName), $src, $true)

        $doc.Load($src, [CrystalDecisions.Shared.OpenReportMethod]::OpenReportByTempCopy)
        $rcd = $doc.ReportClientDocument
        $all = Get-AllTables $rcd
        $subCount = @($rcd.SubreportController.GetSubreportNames()).Count
        Log 'INFO' "  $($all.Count) table(s), $subCount subreport(s)"

        $expected = @{}
        $plans = New-Object System.Collections.ArrayList
        foreach ($e in $all) {
            $r = Get-TablePlan $e
            if ($r) { $expected[$r.Key] = $r; [void]$plans.Add($r) }
        }
        $connBefore = Get-ScopeConnCounts $all
        $qeBefore   = Get-QeSizes $src

        # 1) one ReplaceConnection per distinct old connection (main DatabaseController: it also
        #    updates every subreport table that uses the same connection, like Designer's Update)
        $doneConn = @{}
        foreach ($p in $plans) {
            if ($doneConn.ContainsKey($p.OldConn)) { continue }
            $doneConn[$p.OldConn] = 1
            $live = $null
            foreach ($e in (Get-AllTables $rcd)) { if ((Get-ConnKey $e.Table.ConnectionInfo) -eq $p.OldConn) { $live = $e; break } }
            if (-not $live) { continue }   # already replaced together with an earlier connection
            $oldCi = $live.Table.ConnectionInfo
            $newCi = New-ReplacementConnInfo $oldCi $p.Db
            $rcd.DatabaseController.ReplaceConnection($oldCi, $newCi, $null,
                [CrystalDecisions.ReportAppServer.DataDefModel.CrDBOptionsEnum]::crDBOptionDoNotVerifyDB)
            Log 'INFO' "  ReplaceConnection (found at [$($live.Scope)] '$($live.Table.Alias)') -> server '$(Get-Attr $newCi 'QE_ServerDescription')' db '$(Get-Attr $newCi 'QE_DatabaseName')'"
        }
        if ($expected.Count -eq 0) {
            Log 'WARN' "  no tables matched -- nothing to save"
            Write-Result 'SKIP' $f.FullName 'no tables matched'
            $skipCount++
            continue
        }

        # Save to a temp file, verify it, and only then replace the original.
        # (ReplaceConnection updates subreports only in the saved file, not in the open RAS view,
        #  so the "was every table reached" check is done on the re-opened temp file.)
        $doc.SaveAs($tmp)
        try { $doc.Close() } catch {}

        # 2) any planned table that ReplaceConnection did not reach, or a real table whose
        #    database qualifier must change: fall back to SetTableLocation for that table only
        #    (logged as WARN; the connection count check fails the file if this splits a connection)
        $doc2 = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
        try {
            $doc2.Load($tmp, [CrystalDecisions.Shared.OpenReportMethod]::OpenReportByTempCopy)
            $rcd2 = $doc2.ReportClientDocument
            $nFallback = 0
            foreach ($e in (Get-AllTables $rcd2)) {
                $key = "$($e.Scope)|$($e.Table.Alias)"
                if (-not $expected.ContainsKey($key)) { continue }
                $x = $expected[$key]; $ci = $e.Table.ConnectionInfo
                $wantDll = if ($UseHist) { $Hist.Dll } else { 'crdb_odbc.dll' }
                $wantSrv = if ($UseHist) { $Hist.Server } else { $NewServer }
                $reached = ((Get-Attr $ci 'Database DLL') -eq $wantDll -and (Get-Attr $ci 'QE_ServerDescription') -eq $wantSrv -and
                            [string](Get-Attr $ci 'QE_DatabaseName') -eq [string]$x.Db)
                $qnOk = (-not $x.WantQN) -or ($e.Table.QualifiedName -eq $x.WantQN)
                if ($reached -and $qnOk) { continue }
                $why = if (-not $reached) { 'not reached by ReplaceConnection' } else { "qualified name '$($e.Table.QualifiedName)' still has the old database" }
                Log 'WARN' "  [$($e.Scope)] '$($e.Table.Alias)' $why -- fallback SetTableLocation for this table"
                $newT = $e.Table.Clone($true)
                $newT.ConnectionInfo = New-ReplacementConnInfo $ci $x.Db
                if ($x.WantQN) { $newT.QualifiedName = $x.WantQN }
                if ($e.Sub) { $rcd2.SubreportController.SetTableLocation($e.Sub, $e.Table, $newT) }
                else        { $rcd2.DatabaseController.SetTableLocation($e.Table, $newT) }
                $x | Add-Member -NotePropertyName Fallback -NotePropertyValue $true -Force
                $nFallback++; $script:fbTotal++
            }
            if ($nFallback) {
                $tmp2 = Join-Path $work 'out2.rpt'
                $doc2.SaveAs($tmp2)
                $tmp = $tmp2
            }
        } finally { try { $doc2.Close(); $doc2.Dispose() } catch {} }

        $verr = Test-SavedReport $tmp $expected $all.Count $connBefore $qeBefore
        if ($verr.Count) {
            foreach ($m in $verr) { Log 'ERR' "  verify FAILED $m" }
            throw "verify failed ($($verr.Count) problem(s)); original left unchanged"
        }

        if ($isWhatIf) {
            Log 'INFO' "  WhatIf: changed + verified $($expected.Count) table(s) on temp copy -- original NOT written"
            Write-Result 'OK' $f.FullName "test only: $($expected.Count) table(s) changed + verified on a temp copy"
            $okCount++
        } elseif ($PSCmdlet.ShouldProcess($f.FullName, "Replace with verified copy ($($expected.Count) table(s))")) {
            if ($BackupSuffix) {
                $bak = "$($f.FullName)$BackupSuffix"
                if ([System.IO.File]::Exists((Get-LongPath $bak))) {
                    Log 'INFO' "  backup exists, kept as is (not overwritten) -> $bak"
                } else {
                    [System.IO.File]::Copy((Get-LongPath $f.FullName), (Get-LongPath $bak), $false)
                    Log 'INFO' "  backup -> $bak"
                }
            }
            [System.IO.File]::Copy($tmp, (Get-LongPath $f.FullName), $true)
            # Make sure the file on disk really is the verified copy (read-only file,
            # sync tool, etc. could have blocked or reverted the write).
            $hTmp = Get-FileSha256 $tmp
            $hDst = Get-FileSha256 (Get-LongPath $f.FullName)
            if ($hTmp -ne $hDst) { throw "file on disk differs from the verified copy after write (hash mismatch)" }
            Log 'OK'   "  saved + verified $($expected.Count) table(s)"
            Write-Result 'OK' $f.FullName "saved + verified $($expected.Count) table(s)"
            $okCount++
        }
    } catch {
        Log 'ERR' "  $($f.Name): $($_.Exception.Message)"
        Write-Result 'ERR' $f.FullName $_.Exception.Message
        $errCount++
    } finally {
        try { $doc.Close(); $doc.Dispose() } catch {}
        if (Test-Path -LiteralPath $work) { Remove-Item -LiteralPath $work -Recurse -Force -WhatIf:$false -Confirm:$false -ErrorAction SilentlyContinue }
    }
}

Log 'INFO' "=== Done. ok=$okCount  err=$errCount  skipped=$skipCount  total=$($rpts.Count) ==="
if ($script:fbTotal) {
    Log 'WARN' "NOTE: $($script:fbTotal) table(s) were moved per table (fallback, see WARN lines). Open one such report in Designer > Database > Set Datasource Location and check its connection node."
}
if ($script:famWarn) {
    Log 'WARN' "WARNING: $($script:famWarn) table(s) were moved to a different database type (SQL Server <-> HANA). Check that this is the right connection before using the reports."
}
if ($errCount) {
    Log 'ERR'  "RESULT: FAIL -- $errCount file(s) failed (see [ERR] lines above); those originals were NOT changed"
    exit 1
} elseif ($okCount -eq 0) {
    Log 'WARN' "RESULT: NOTHING CHANGED -- no report was saved"
    exit 1
} elseif ($isWhatIf) {
    Log 'WARN' "RESULT: WHATIF ONLY -- $okCount file(s) changed + verified on temp copies, originals NOT written"
    exit 0
} else {
    Log 'OK'   "RESULT: PASS -- $okCount file(s) saved and verified by re-opening"
    exit 0
}
