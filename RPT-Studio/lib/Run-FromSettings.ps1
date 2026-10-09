<#
.SYNOPSIS
  Reads settings.ini (next to this script), lets the user pick a connection from the
  Crystal Designer "My Connections" list (or 0 = build ODBC Driver 18 from SERVER/DATABASE),
  then runs Set-DatasourceLocation.ps1 for every FOLDER= line. Started by RUN.bat.

  User-facing text is Thai and comes from messages.txt (UTF-8). This .ps1 stays ASCII.
  If messages.txt is missing, English fallback text is shown.
#>
param(
    [string] $SettingsFile = '',
    [string] $MessagesFile = ''
)

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
if (-not $SettingsFile) { $SettingsFile = Join-Path $scriptDir 'settings.ini' }
if (-not $MessagesFile) { $MessagesFile = Join-Path $scriptDir 'messages.txt' }
$setScript  = Join-Path $scriptDir 'Set-DatasourceLocation.ps1'
$helper     = Join-Path $scriptDir 'CrConnections.ps1'
$logFile    = Join-Path $scriptDir '_SetLocation.log'

# ---------------------------------------------------------------- messages (Thai)
$MSG = @{}
$EN = @{
    TITLE='Set Datasource Location of Crystal Report (.rpt) files'
    STEP1='Step 1/3  Check the .rpt folder'; STEP2='Step 2/3  Choose a connection'; STEP3='Step 3/3  Check and confirm'
    WARN_NOT_UTF8='settings.ini is not UTF-8 - read as Thai ANSI (cp874)'
    ERR_SETTINGS_MISSING='settings file not found: {0}'; ERR_SCRIPT_MISSING='script not found: {0}'
    ERR_YESNO='{0} must be yes or no (got ''{1}'')'; HOW_FIX_SETTINGS='Fix: edit settings.ini, save, run RUN.bat again'
    FOLDER_EMPTY='FOLDER is empty in settings.ini'; FOLDER_ASK='Type Y then Enter to choose a folder (anything else = cancel)'
    FOLDER_DIALOG='Choose the folder with .rpt files'; FOLDER_PICKED='Folder: {0}'; FOLDER_PICKED_TIP='To keep it, put it in settings.ini as FOLDER='
    FOLDER_NOT_FOUND='FOLDER not found: {0}'; FOLDER_NOT_FOUND_FIX='Fix: correct FOLDER= in settings.ini'; FOLDER_OK='Folder found: {0}'
    CONN_LOADING='Reading Crystal Reports "My Connections" of the current Windows user ...'
    CONN_NONE='No connection found in My Connections of this user'; CONN_HEADER='Connections:'
    CONN_ZERO='  [0] none of these - build a new ODBC Driver 18 connection from SERVER / DATABASE in settings.ini'
    CONN_ITEM_NAME='Name'; CONN_ITEM_TYPE='Type'; CONN_ITEM_SERVER='Server'; CONN_ITEM_DB='Database'; CONN_ITEM_USER='User'
    CONN_NO_NAME='(no name)'; CONN_SKIPPED='{0} unusable entr(y/ies) not shown'
    CONN_ASK='Type the number then Enter (empty = cancel)'; CONN_BAD_INPUT='No number ''{0}'' in the list, try again'
    CONN_FROM_SETTINGS='Using CONNECTION={0} from settings.ini'; CONN_NOT_FOUND='Connection ''{0}'' (CONNECTION in settings.ini) not found'
    CONN_NOT_FOUND_FIX='Fix: use a name or number from the list above, or leave CONNECTION= empty'
    CONN_AMBIGUOUS='More than one connection is named ''{0}'' - use the number'
    CONN_NUMBER_TIP='Note: numbers can change when Crystal Designer is used; prefer the name in settings.ini'
    CONN_SELECTED='Selected: [{0}] {1}'
    SERVER_EMPTY='0 selected but SERVER is empty in settings.ini'; SERVER_EMPTY_FIX='Fix: set SERVER= in settings.ini or pick a connection'
    SUM_FOLDER='  Folder     : {0}'; SUM_SUBFOLDERS='  Subfolders : {0}'; SUM_CONN='  Connection : {0}'
    SUM_CONN_NEW='  Connection : new ODBC Driver 18 for SQL Server'; SUM_TYPE='  Type       : {0}'; SUM_SERVER='  Server     : {0}'
    SUM_DB='  Database   : {0}'; SUM_DB_KEEP='(keep existing)'; SUM_DB_OVERRIDE='  Note       : DATABASE={0} from settings.ini replaces the connection database ({1})'
    SUM_USER='  User       : {0}'; SUM_USER_KEEP='(keep existing)'; SUM_TRUST='  Trust cert : {0}'; SUM_BACKUP='  Backup     : {0}'
    SUM_MODE_TEST='  Mode       : TEST ONLY (files will NOT be changed)'; SUM_MODE_REAL='  Mode       : REAL RUN (files WILL be changed)'
    CONFIRM='Type Y then Enter to start (anything else = cancel)'; CANCELLED='Cancelled. No file was changed.'
    RUNNING='Processing: {0}'; RESULT_TITLE='Summary'
    RESULT_OK_TEST='{0} file(s) passed the test (not written)'; RESULT_OK_REAL='{0} file(s) saved and verified'
    RESULT_ERR='{0} file(s) failed (not changed)'; RESULT_SKIP='{0} file(s) skipped'
    RESULT_FILE_ERR='  FAILED: {0}'; RESULT_FILE_REASON='      reason: {0}'; RESULT_FILE_SKIP='  skipped: {0}'
    RESULT_CHILD_FAIL='The worker stopped early (exit code {0}) for {1}'
    NEXT_TITLE='Next step'; NEXT_TEST_OK='Test passed. To change the files, set TEST_ONLY=no in settings.ini and run RUN.bat again'
    NEXT_REAL_OK='Done. Open one .rpt in Crystal Reports and check Database > Set Datasource Location before using it'
    NEXT_BACKUP='Originals were backed up as .rpt.bak'; NEXT_ERR='See _SetLocation.log for details, fix and run again'
    NEXT_NONE='No .rpt file in the chosen folder - check FOLDER in settings.ini'; YES='yes'; NO='no'
}
if (Test-Path -LiteralPath $MessagesFile) {
    try {
        $mt = [System.IO.File]::ReadAllText($MessagesFile, [System.Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
        foreach ($line in ($mt -split "`r?`n")) {
            if ($line -match '^\s*[;#]' -or $line.IndexOf('=') -lt 1) { continue }
            $i = $line.IndexOf('=')
            $MSG[$line.Substring(0, $i).Trim()] = $line.Substring($i + 1)
        }
    } catch {}
}
function M([string]$key) {
    $t = if ($MSG.ContainsKey($key)) { $MSG[$key] } elseif ($EN.ContainsKey($key)) { $EN[$key] } else { $key }
    if ($args.Count) { return [string]::Format($t, [object[]]$args) }
    return $t
}
function Say([string]$text, [string]$color = '') {
    if ($color) { Write-Host $text -ForegroundColor $color } else { Write-Host $text }
}
function Fail([string]$text, [string]$fix = '') {
    Say ('[!] ' + $text) 'Red'
    if ($fix) { Say ('    ' + $fix) 'Yellow' }
    exit 2
}

if (-not (Test-Path -LiteralPath $SettingsFile)) { Fail (M 'ERR_SETTINGS_MISSING' $SettingsFile) }
foreach ($s in @($setScript, $helper)) {
    if (-not (Test-Path -LiteralPath $s)) { Fail (M 'ERR_SCRIPT_MISSING' $s) }
}

# ---------------------------------------------------------------- settings.ini
# KEY=VALUE, ';' or '#' = comment, FOLDER may repeat
$cfg     = @{}
$folders = New-Object System.Collections.Generic.List[string]
# Notepad may save as UTF-8 (with/without BOM) or ANSI (Thai = cp874): try strict UTF-8 first.
$bytes = [IO.File]::ReadAllBytes($SettingsFile)
try {
    $text = (New-Object Text.UTF8Encoding($false, $true)).GetString($bytes)
} catch {
    $text = [Text.Encoding]::GetEncoding(874).GetString($bytes)
    Say (M 'WARN_NOT_UTF8') 'Yellow'
}
$text = $text.TrimStart([char]0xFEFF)
foreach ($line in ($text -split "`r?`n")) {
    $t = $line.Trim()
    if ($t -eq '' -or $t.StartsWith(';') -or $t.StartsWith('#')) { continue }
    $i = $t.IndexOf('=')
    if ($i -lt 1) { continue }
    $key = $t.Substring(0, $i).Trim().ToUpperInvariant()
    $val = $t.Substring($i + 1).Trim().Trim('"')
    if ($key -eq 'FOLDER') {
        # a trailing \ before the closing quote would swallow the next argument of the child process
        $val = $val.TrimEnd('\')
        if ($val -match '^[A-Za-z]:$') { $val += '\.' }
        if ($val) { $folders.Add($val) }
    }
    else { $cfg[$key] = $val }
}

function Get-YesNo([string]$key, [string]$default) {
    $v = "$($cfg[$key])".Trim().ToLowerInvariant()
    if ($v -eq '') { return $default }
    if ($v -in @('yes','y','true','1')) { return 'yes' }
    if ($v -in @('no','n','false','0'))  { return 'no' }
    Fail (M 'ERR_YESNO' $key $cfg[$key]) (M 'HOW_FIX_SETTINGS')
}
function YN([string]$v) { if ($v -eq 'yes') { M 'YES' } else { M 'NO' } }

$server     = "$($cfg['SERVER'])"
$database   = "$($cfg['DATABASE'])"
$user       = "$($cfg['USER'])"
$connSetting= "$($cfg['CONNECTION'])"
$testOnly   = Get-YesNo 'TEST_ONLY' 'yes'
$backup     = Get-YesNo 'BACKUP' 'yes'
$recurse    = Get-YesNo 'INCLUDE_SUBFOLDERS' 'yes'
$trust      = Get-YesNo 'TRUST_SERVER_CERTIFICATE' 'yes'

Say ''
Say ('=== ' + (M 'TITLE') + ' ===') 'Cyan'

# ---------------------------------------------------------------- step 1: folder
Say ''
Say (M 'STEP1') 'Cyan'
if ($folders.Count -eq 0) {
    Say ('[!] ' + (M 'FOLDER_EMPTY')) 'Yellow'
    $ans = Read-Host (M 'FOLDER_ASK')
    if ($null -eq $ans -or "$ans".Trim().ToUpperInvariant() -ne 'Y') { Say (M 'CANCELLED') 'Yellow'; exit 0 }
    Add-Type -AssemblyName System.Windows.Forms
    $owner = New-Object System.Windows.Forms.Form
    $owner.TopMost = $true
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = M 'FOLDER_DIALOG'
    $dlg.ShowNewFolderButton = $false
    $res = $dlg.ShowDialog($owner)
    $owner.Dispose()
    if ($res -ne [System.Windows.Forms.DialogResult]::OK -or -not $dlg.SelectedPath) { Say (M 'CANCELLED') 'Yellow'; exit 0 }
    $p = $dlg.SelectedPath.TrimEnd('\')
    if ($p -match '^[A-Za-z]:$') { $p += '\.' }
    $folders.Add($p)
    Say (M 'FOLDER_PICKED' $p)
    Say (M 'FOLDER_PICKED_TIP') 'DarkGray'
}
$bad = $false
foreach ($f in $folders) {
    if (Test-Path -LiteralPath $f) { Say (M 'FOLDER_OK' $f) }
    else { Say ('[!] ' + (M 'FOLDER_NOT_FOUND' $f)) 'Red'; $bad = $true }
}
if ($bad) { Say ('    ' + (M 'FOLDER_NOT_FOUND_FIX')) 'Yellow'; exit 2 }

# ---------------------------------------------------------------- step 2: connection
Say ''
Say (M 'STEP2') 'Cyan'
Say (M 'CONN_LOADING') 'DarkGray'
. $helper
$all = @(Get-CrHistoryEntries)
$conns = @($all | Where-Object { $_.Usable })
$skipped = $all.Count - $conns.Count

function Show-Conn([int]$n, $c) {
    $name = if ($c.Name) { $c.Name } else { M 'CONN_NO_NAME' }
    Say ("  [$n] $name") 'White'
    $typ = $c.DbType
    if ($c.Driver) { $typ += ' / ' + $c.Driver }
    Say ("        {0}: {1}" -f (M 'CONN_ITEM_TYPE'), $typ) 'DarkGray'
    Say ("        {0}: {1}    {2}: {3}    {4}: {5}" -f (M 'CONN_ITEM_SERVER'), $c.Server,
         (M 'CONN_ITEM_DB'), $(if ($c.Database) { $c.Database } else { '-' }),
         (M 'CONN_ITEM_USER'), $(if ($c.User) { $c.User } else { '-' })) 'DarkGray'
}

if ($conns.Count -eq 0) { Say (M 'CONN_NONE') 'Yellow' }
else {
    Say (M 'CONN_HEADER')
    for ($n = 1; $n -le $conns.Count; $n++) { Show-Conn $n $conns[$n - 1] }
}
Say (M 'CONN_ZERO') 'White'
if ($skipped -gt 0) { Say (M 'CONN_SKIPPED' $skipped) 'DarkGray' }
Say ''

$choice = $null    # 0 = settings mode, else 1-based index
if ($connSetting) {
    Say (M 'CONN_FROM_SETTINGS' $connSetting)
    $num = 0
    if ([int]::TryParse($connSetting, [ref]$num)) {
        if ($num -ge 0 -and $num -le $conns.Count) { $choice = $num }
        else { Fail (M 'CONN_NOT_FOUND' $connSetting) (M 'CONN_NOT_FOUND_FIX') }
        if ($num -gt 0) { Say (M 'CONN_NUMBER_TIP') 'DarkGray' }
    } else {
        $hits = @()
        for ($n = 1; $n -le $conns.Count; $n++) {
            if ($conns[$n - 1].Name -and $conns[$n - 1].Name -ieq $connSetting) { $hits += $n }
        }
        if ($hits.Count -eq 0) { Fail (M 'CONN_NOT_FOUND' $connSetting) (M 'CONN_NOT_FOUND_FIX') }
        if ($hits.Count -gt 1) { Fail (M 'CONN_AMBIGUOUS' $connSetting) (M 'CONN_NOT_FOUND_FIX') }
        $choice = $hits[0]
    }
} else {
    while ($null -eq $choice) {
        $ans = Read-Host (M 'CONN_ASK')
        if ($null -eq $ans -or "$ans".Trim() -eq '') { Say (M 'CANCELLED') 'Yellow'; exit 0 }
        $num = 0
        if ([int]::TryParse("$ans".Trim(), [ref]$num) -and $num -ge 0 -and $num -le $conns.Count) { $choice = $num }
        else { Say (M 'CONN_BAD_INPUT' "$ans".Trim()) 'Yellow' }
    }
}
$sel = $null
if ($choice -gt 0) {
    $sel = $conns[$choice - 1]
    Say (M 'CONN_SELECTED' $choice $(if ($sel.Name) { $sel.Name } else { M 'CONN_NO_NAME' })) 'Green'
} else {
    Say (M 'CONN_SELECTED' 0 'SERVER / DATABASE (settings.ini)') 'Green'
    if (-not $server) { Fail (M 'SERVER_EMPTY') (M 'SERVER_EMPTY_FIX') }
}

# ---------------------------------------------------------------- step 3: summary + confirm
Say ''
Say (M 'STEP3') 'Cyan'
foreach ($f in $folders) { Say (M 'SUM_FOLDER' $f) }
Say (M 'SUM_SUBFOLDERS' (YN $recurse))
if ($sel) {
    Say (M 'SUM_CONN' $(if ($sel.Name) { $sel.Name } else { M 'CONN_NO_NAME' }))
    Say (M 'SUM_TYPE' ($sel.DbType + $(if ($sel.Driver) { ' / ' + $sel.Driver } else { '' })))
    Say (M 'SUM_SERVER' $sel.Server)
    if ($database) {
        Say (M 'SUM_DB' $database)
        if ($database -ne $sel.Database) { Say (M 'SUM_DB_OVERRIDE' $database $(if ($sel.Database) { $sel.Database } else { '-' })) 'Yellow' }
    } else { Say (M 'SUM_DB' $(if ($sel.Database) { $sel.Database } else { '-' })) }
    Say (M 'SUM_USER' $(if ($user) { $user } elseif ($sel.User) { $sel.User } else { '-' }))
} else {
    Say (M 'SUM_CONN_NEW')
    Say (M 'SUM_SERVER' $server)
    Say (M 'SUM_DB' $(if ($database) { $database } else { M 'SUM_DB_KEEP' }))
    Say (M 'SUM_USER' $(if ($user) { $user } else { M 'SUM_USER_KEEP' }))
    Say (M 'SUM_TRUST' (YN $trust))
}
Say (M 'SUM_BACKUP' (YN $backup))
if ($testOnly -eq 'yes') { Say (M 'SUM_MODE_TEST') 'Yellow' } else { Say (M 'SUM_MODE_REAL') 'Red' }
Say ''
$ans = Read-Host (M 'CONFIRM')
if ($null -eq $ans -or "$ans".Trim().ToUpperInvariant() -ne 'Y') { Say (M 'CANCELLED') 'Yellow'; exit 0 }

# ---------------------------------------------------------------- run (child process per folder; it calls exit) - same bitness
$psExe = Join-Path $PSHOME 'powershell.exe'
$resultFile = Join-Path ([System.IO.Path]::GetTempPath()) ('setloc_result_' + [guid]::NewGuid().ToString('N') + '.txt')
$rc = 0
$childFails = @()
$noFiles = $false
foreach ($f in $folders) {
    $gci = @{ LiteralPath = $f; Filter = '*.rpt'; File = $true; ErrorAction = 'SilentlyContinue' }
    if ($recurse -eq 'yes') { $gci['Recurse'] = $true }
    $cnt = if (Test-Path -LiteralPath $f -PathType Leaf) { 1 } else { @(Get-ChildItem @gci | Where-Object { $_.Extension -eq '.rpt' }).Count }
    if ($cnt -eq 0) { $noFiles = $true; Say ('[!] ' + (M 'NEXT_NONE') + " ($f)") 'Yellow'; continue }

    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $setScript,
                 '-Path', $f, '-ResultFile', $resultFile, '-LogFile', $logFile)
    if ($sel) {
        $argList += @('-ConnectionFile', $sel.File)
        if ($sel.Name) { $argList += @('-ConnectionName', $sel.Name) }
    } else {
        $argList += @('-NewServer', $server, '-TrustServerCertificate', $trust)
    }
    if ($database)          { $argList += @('-NewDatabase', $database) }
    if ($user)              { $argList += @('-NewUser', $user) }
    if ($backup  -eq 'no')  { $argList += '-NoBackup' }
    if ($recurse -eq 'no')  { $argList += '-NoRecurse' }
    if ($testOnly -eq 'yes'){ $argList += '-WhatIf' }

    Say ''
    Say ('--- ' + (M 'RUNNING' $f) + ' ---') 'Cyan'
    $before = if (Test-Path -LiteralPath $resultFile) { @([System.IO.File]::ReadAllLines($resultFile)).Count } else { 0 }
    & $psExe @argList
    $code = $LASTEXITCODE
    $after = if (Test-Path -LiteralPath $resultFile) { @([System.IO.File]::ReadAllLines($resultFile)).Count } else { 0 }
    if ($code -ne 0) {
        $rc = $code
        if ($after -eq $before) { $childFails += (M 'RESULT_CHILD_FAIL' $code $f) }
    }
}

# ---------------------------------------------------------------- summary
$ok = @(); $err = @(); $skip = @()
if (Test-Path -LiteralPath $resultFile) {
    foreach ($l in [System.IO.File]::ReadAllLines($resultFile, [System.Text.Encoding]::UTF8)) {
        $p = $l -split "`t", 3
        if ($p.Count -lt 2) { continue }
        switch ($p[0]) {
            'OK'   { $ok   += ,$p }
            'ERR'  { $err  += ,$p }
            'SKIP' { $skip += ,$p }
        }
    }
    Remove-Item -LiteralPath $resultFile -Force -ErrorAction SilentlyContinue
}
Say ''
Say ('=== ' + (M 'RESULT_TITLE') + ' ===') 'Cyan'
if ($testOnly -eq 'yes') { Say (M 'RESULT_OK_TEST' $ok.Count) $(if ($ok.Count) { 'Green' } else { 'White' }) }
else                     { Say (M 'RESULT_OK_REAL' $ok.Count) $(if ($ok.Count) { 'Green' } else { 'White' }) }
if ($err.Count)  {
    Say (M 'RESULT_ERR' $err.Count) 'Red'
    foreach ($e in $err) { Say (M 'RESULT_FILE_ERR' $e[1]) 'Red'; if ($e.Count -ge 3) { Say (M 'RESULT_FILE_REASON' $e[2]) 'DarkGray' } }
}
if ($skip.Count) {
    Say (M 'RESULT_SKIP' $skip.Count) 'Yellow'
    foreach ($s in $skip) { Say (M 'RESULT_FILE_SKIP' $s[1]) 'Yellow' }
}
foreach ($m in $childFails) { Say ('[!] ' + $m) 'Red' }

Say ''
Say ((M 'NEXT_TITLE') + ':') 'Cyan'
if ($err.Count -or $childFails.Count) {
    Say ('  ' + (M 'NEXT_ERR')) 'Yellow'
    if ($rc -eq 0) { $rc = 1 }
} elseif ($ok.Count -eq 0) {
    Say ('  ' + (M 'NEXT_NONE')) 'Yellow'
    if ($rc -eq 0) { $rc = 1 }
} elseif ($testOnly -eq 'yes') {
    Say ('  ' + (M 'NEXT_TEST_OK')) 'Yellow'
} else {
    Say ('  ' + (M 'NEXT_REAL_OK')) 'Green'
    if ($backup -eq 'yes') { Say ('  ' + (M 'NEXT_BACKUP')) 'Green' }
}
exit $rc
