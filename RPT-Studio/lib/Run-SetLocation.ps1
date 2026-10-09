<#
.SYNOPSIS
  RPT Studio entry for Set Datasource Location (crystal-report). Wraps v4
  Set-DatasourceLocation.ps1 / CrConnections.ps1 (copied unchanged from Desktop\Set-DatasourceLocation).

  powershell.exe -NoProfile -ExecutionPolicy Bypass -File lib\Run-SetLocation.ps1 -Action Run|ListHistory -ArgsFile <json>

  Run args:
    { folderOrFiles:[...], testOnly:true, backup:true,
      target:{ engine:"MSSQL|HANA", server, database, user, password?, profile?, dsn?, useHistory? } }
    - useHistory = name or 1-based number of a Crystal "My Connections" entry (same list/numbering as
      ListHistory / v4 Run-FromSettings). Required for HANA targets and DSN targets, because v4 mode 0 can
      only build "ODBC Driver 18 for SQL Server" DSN-less connections.
    - without useHistory: engine must be MSSQL -> v4 mode 0 (-NewServer/-NewDatabase/-NewUser).
    - password: target.password, or target.profile -> Get-ProfilePassword (lib\Secrets.ps1). It is handed to
      the v4 child only through a process-scoped environment variable (never on the command line), v4 keeps it
      in memory only (never written into the .rpt; DoNotVerifyDB = no DB logon). Never printed.
  Output: human log lines, last line "##RESULT## {json}". Exit 0 ok / 1 fail. Never prompts.
#>
param(
    [Parameter(Mandatory)] [ValidateSet('Run','ListHistory')] [string] $Action,
    [string] $ArgsFile = ''
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}
$libDir    = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
$setScript = Join-Path $libDir 'Set-DatasourceLocation.ps1'
$helper    = Join-Path $libDir 'CrConnections.ps1'
$secrets   = Join-Path $libDir 'Secrets.ps1'
$script:Secret = $null

# every line goes straight to stdout and is flushed (server reads the log live; ##ITEM## must not lag)
function Out-Log([string]$m) { [Console]::Out.WriteLine($m); [Console]::Out.Flush() }
function Out-Item([string]$key, [bool]$ok, [string]$msg) {
    Out-Log ('##ITEM## ' + (Mask (([ordered]@{ key = $key; ok = $ok; msg = $msg }) | ConvertTo-Json -Compress)))
}
# Temp files owned by this wrapper (safe to delete on the next run):
#   <name>.rpt.rptstudio_tmp_<32 hex>.rpt       staged copy that v4 rewrites, then File.Replace -> <name>.rpt
#   <name>.rpt.bak.rptstudio_tmp_<32 hex>       backup being written, then renamed -> <name>.rpt.bak
$script:TmpRx = '\.rptstudio_tmp_[0-9a-f]{32}(\.rpt)?$'
function Mask([string]$s) {
    if ($script:Secret -and $s) { return $s.Replace($script:Secret, '********') }
    return $s
}
function Finish([bool]$ok, [string]$err, $data) {
    $o = [ordered]@{ ok = $ok; error = $(if ($err) { Mask $err } else { $null }); data = $(if ($null -ne $data) { $data } else { @{} }) }
    $json = Mask ($o | ConvertTo-Json -Depth 8 -Compress)
    Out-Log ('##RESULT## ' + $json)
    $script:Secret = $null
    exit $(if ($ok) { 0 } else { 1 })
}
function Get-Fam([string]$text) {
    # same rule as v4 Get-DbFamily
    if ($text -match 'HDBODBC|B1CRHPROXY|NDB@|HANA') { return 'HANA' }
    if ($text -match 'SQLNCLI|SQLOLEDB|MSOLEDBSQL|SQL Server') { return 'MSSQL' }
    return ''
}
function Get-UsableHistory {
    . $helper
    $all = @(Get-CrHistoryEntries)
    return ,@($all | Where-Object { $_.Usable })
}

try {
    $A = $null
    if ($ArgsFile) {
        if (-not (Test-Path -LiteralPath $ArgsFile)) { Finish $false "ArgsFile not found: $ArgsFile" $null }
        $raw = [IO.File]::ReadAllText($ArgsFile, [Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
        if ($raw.Trim()) { $A = $raw | ConvertFrom-Json }
    }
    $arch = if ([Environment]::Is64BitProcess) { 'x64' } else { 'x86' }
    Out-Log "[Run-SetLocation] action=$Action arch=$arch"

    # ------------------------------------------------------------------ ListHistory
    if ($Action -eq 'ListHistory') {
        . $helper
        $all = @(Get-CrHistoryEntries)
        $items = @(); $n = 0
        foreach ($c in $all) {
            $idx = $null
            if ($c.Usable) { $n++; $idx = $n }
            $fam = Get-Fam ("$($c.Driver) $($c.Server) " + $(if ($c.Props -and $c.Props.Contains('Connection String')) { [string]$c.Props['Connection String'] } else { '' }))
            $items += [ordered]@{ index = $idx; histIndex = $c.HistIndex; name = $c.Name; dbType = $c.DbType; driver = $c.Driver
                                  server = $c.Server; database = $c.Database; user = $c.User; engine = $fam
                                  usable = [bool]$c.Usable; note = $c.Note; file = $c.File; method = $c.Method }
        }
        Out-Log "My Connections: $($all.Count) entr(y/ies), $n usable"
        Finish $true $null @{ items = $items }
    }

    # ------------------------------------------------------------------ Run
    if (-not $A) { Finish $false 'ArgsFile with Run arguments is required' $null }
    $paths = @($A.folderOrFiles | Where-Object { "$_".Trim() } | ForEach-Object { "$_".Trim().Trim('"').TrimEnd('\') })
    if ($paths.Count -eq 0) { Finish $false 'folderOrFiles is empty' $null }
    foreach ($p in $paths) { if (-not (Test-Path -LiteralPath $p)) { Finish $false "path not found: $p" $null } }
    $t = $A.target
    if (-not $t) { Finish $false 'target is required' $null }
    $testOnly = if ($null -eq $A.testOnly) { $true } else { [bool]$A.testOnly }
    $backup   = if ($null -eq $A.backup)   { $true } else { [bool]$A.backup }
    $engine   = "$($t.engine)".Trim().ToUpperInvariant()
    $useHist  = "$($t.useHistory)".Trim()
    if ($useHist -in @('False','false','0')) { $useHist = '' }

    # password (only in memory)
    if ("$($t.password)") { $script:Secret = [string]$t.password }
    elseif ("$($t.profile)") {
        if (-not (Test-Path -LiteralPath $secrets)) { Finish $false "lib\Secrets.ps1 not found (needed for target.profile)" $null }
        . $secrets
        try { $script:Secret = [string](Get-ProfilePassword -Name ([string]$t.profile)) }
        catch { Finish $false "cannot read password of profile '$($t.profile)': $($_.Exception.Message)" $null }
        if (-not $script:Secret) { Out-Log "[WARN] profile '$($t.profile)' has no stored password - continuing without one" }
    }

    # target mode
    $childArgs = @{}
    $targetFam = ''
    if ($useHist) {
        $conns = Get-UsableHistory
        $sel = $null; $num = 0
        if ([int]::TryParse($useHist, [ref]$num)) {
            if ($num -ge 1 -and $num -le $conns.Count) { $sel = $conns[$num - 1] }
        } else {
            $hits = @($conns | Where-Object { $_.Name -and $_.Name -ieq $useHist })
            if ($hits.Count -gt 1) { Finish $false "more than one My Connections entry is named '$useHist' - use the number" $null }
            if ($hits.Count -eq 1) { $sel = $hits[0] }
        }
        if (-not $sel) { Finish $false "My Connections entry '$useHist' not found (see ListHistory)" $null }
        $childArgs['ConnectionFile'] = $sel.File
        if ($sel.Name) { $childArgs['ConnectionName'] = $sel.Name }
        if ("$($t.database)") { $childArgs['NewDatabase'] = [string]$t.database }
        if ("$($t.user)")     { $childArgs['NewUser'] = [string]$t.user }
        $targetFam = Get-Fam ("$($sel.Driver) $($sel.Server) " + $(if ($sel.Props.Contains('Connection String')) { [string]$sel.Props['Connection String'] } else { '' }))
        if (-not $targetFam -and $engine) { $targetFam = $engine }
        Out-Log "Target: My Connections '$($sel.Name)' ($($sel.DbType) / $($sel.Driver)) server=$($sel.Server)"
    } else {
        if ("$($t.dsn)") { Finish $false 'target.dsn is not supported by v4 mode 0 - create the DSN connection in Crystal Designer and pass it as target.useHistory' $null }
        if ($engine -ne 'MSSQL') { Finish $false "engine '$engine' needs target.useHistory: v4 mode 0 only builds 'ODBC Driver 18 for SQL Server' connections" $null }
        if (-not "$($t.server)") { Finish $false 'target.server is required' $null }
        $childArgs['NewServer'] = [string]$t.server
        if ("$($t.database)") { $childArgs['NewDatabase'] = [string]$t.database }
        if ("$($t.user)")     { $childArgs['NewUser'] = [string]$t.user }
        $targetFam = 'MSSQL'
        Out-Log "Target: ODBC Driver 18 for SQL Server server=$($t.server) db=$($t.database) user=$($t.user)"
    }
    if (-not $backup) { $childArgs['NoBackup'] = $true }
    Out-Log "testOnly=$testOnly backup=$backup paths=$($paths.Count) password=$(if ($script:Secret) { 'given (hidden)' } else { 'none' })"

    # ---- source family per file (for dialectWarning) - read only, temp copy
    $srcFam = @{}
    try {
        $gac = 'C:\Windows\Microsoft.NET\assembly\GAC_MSIL'
        foreach ($n in 'CrystalDecisions.Shared','CrystalDecisions.ReportSource','CrystalDecisions.CrystalReports.Engine') {
            $dll = Get-ChildItem (Join-Path $gac $n) -Recurse -Filter "$n.dll" | Sort-Object { [version](($_.Directory.Name -split '_')[1]) } -Descending | Select-Object -First 1
            [void][Reflection.Assembly]::LoadFrom($dll.FullName)
        }
        foreach ($n in 'ClientDoc','DataDefModel','Controllers') { [void][Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.ReportAppServer.$n") }
    } catch { Out-Log "[WARN] cannot load Crystal SDK for dialect check: $($_.Exception.Message)" }
    # ---- %TEMP% files this wrapper creates (setloc_log_<32hex>.log / setloc_result_<32hex>.txt) older than 1 day.
    #      v4 work folders %TEMP%\setloc_<guid>\ are NOT touched.
    $cut = (Get-Date).AddDays(-1)
    foreach ($x in @(Get-ChildItem -LiteralPath ([IO.Path]::GetTempPath()) -File -Filter 'setloc_*' -ErrorAction SilentlyContinue)) {
        if ($x.Name -notmatch '^setloc_(log_[0-9a-f]{32}\.log|result_[0-9a-f]{32}\.txt)$' -or $x.LastWriteTime -ge $cut) { continue }
        try { [IO.File]::Delete($x.FullName); Out-Log "[cleanup] removed old temp $($x.Name)" } catch { Out-Log "[WARN] cannot remove $($x.Name): $($_.Exception.Message)" }
    }
    # ---- clean up this wrapper's own leftovers from an earlier killed run (only names matching $TmpRx)
    foreach ($p in $paths) {
        $scan = if (Test-Path -LiteralPath $p -PathType Leaf) { @(Get-ChildItem -LiteralPath (Split-Path -Parent $p) -File) }
                else { @(Get-ChildItem -LiteralPath $p -File -Recurse) }
        foreach ($x in ($scan | Where-Object { $_.Name -match $script:TmpRx })) {
            try { Remove-Item -LiteralPath $x.FullName -Force; Out-Log "[cleanup] removed leftover temp $($x.FullName)" }
            catch { Out-Log "[WARN] cannot remove leftover temp $($x.FullName): $($_.Exception.Message)" }
        }
    }
    $files = New-Object System.Collections.Generic.List[string]
    foreach ($p in $paths) {
        if (Test-Path -LiteralPath $p -PathType Leaf) { $files.Add((Get-Item -LiteralPath $p).FullName) }
        else { Get-ChildItem -LiteralPath $p -Filter *.rpt -File -Recurse | Where-Object { $_.Extension -eq '.rpt' -and $_.Name -notlike '*.setloc_tmp.rpt' -and $_.Name -notmatch $script:TmpRx } | ForEach-Object { $files.Add($_.FullName) } }
    }
    if ($files.Count -eq 0) { Finish $false 'no .rpt file found in folderOrFiles' $null }
    foreach ($f in $files) {
        $doc = $null; $tmp = Join-Path ([IO.Path]::GetTempPath()) ('rs_' + [guid]::NewGuid().ToString('N') + '.rpt')
        try {
            [IO.File]::Copy($f, $tmp, $true)
            $doc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
            $doc.Load($tmp, [CrystalDecisions.Shared.OpenReportMethod]::OpenReportByTempCopy)
            $rcd = $doc.ReportClientDocument
            $tabs = @($rcd.DatabaseController.Database.Tables)
            foreach ($sn in @($rcd.SubreportController.GetSubreportNames())) { $tabs += @($rcd.SubreportController.GetSubreportDatabase($sn).Tables) }
            $fams = @{}
            foreach ($tb in $tabs) {
                $ci = $tb.ConnectionInfo; $txt = ''
                try { $lp = $ci.Attributes.Item('QE_LogonProperties')
                      foreach ($k in 'Provider','Connection String','Server','Data Source','DSN') { try { $txt += ' ' + [string]$lp.Item($k) } catch {} } } catch {}
                try { $txt += ' ' + [string]$ci.Attributes.Item('QE_ServerDescription') } catch {}
                $fm = Get-Fam $txt; if ($fm) { $fams[$fm] = 1 }
            }
            $srcFam[$f] = (@($fams.Keys) | Sort-Object) -join '+'
        } catch { $srcFam[$f] = '' }
        finally { if ($doc) { try { $doc.Close(); $doc.Dispose() } catch {} }; Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
    }

    # ---- run v4 once per FILE (child 64-bit). Safe-on-kill:
    #   real run: v4 rewrites a staged copy <file>.rptstudio_tmp_<guid>.rpt in the SAME folder (v4 itself
    #   verifies by re-opening and hash-checks it). The wrapper then writes <file>.bak via temp+rename
    #   and swaps the staged copy in with File.Replace (NTFS ReplaceFile, same volume) -> the real .rpt is
    #   either the old file or the new verified file, never half written.
    #   testOnly: v4 -WhatIf on the original (v4 never writes the original in -WhatIf).
    $psExe = Join-Path $PSHOME 'powershell.exe'
    $logFile = Join-Path ([IO.Path]::GetTempPath()) ('setloc_log_' + [guid]::NewGuid().ToString('N') + '.log')
    $childArgs['NoBackup'] = $true      # the wrapper makes the .bak itself (see above)
    $envName = 'RPTSTUDIO_SETLOC_PWD'
    $out = @(); $childFail = @()
    try {
        if ($script:Secret) { [Environment]::SetEnvironmentVariable($envName, $script:Secret, 'Process') }
        foreach ($f in $files) {
            $stage = $null; $status = 'ERR'; $msg = ''; $ct = 0
            $resultFile = Join-Path ([IO.Path]::GetTempPath()) ('setloc_result_' + [guid]::NewGuid().ToString('N') + '.txt')
            try {
                $target = $f
                if (-not $testOnly) {
                    $stage = $f + '.rptstudio_tmp_' + [guid]::NewGuid().ToString('N') + '.rpt'
                    [IO.File]::Copy($f, $stage, $false)
                    $target = $stage
                }
                $cfg = @{ Path = $target; ResultFile = $resultFile; LogFile = $logFile; WhatIf = $testOnly; Args = $childArgs; Script = $setScript }
                $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($cfg | ConvertTo-Json -Depth 5 -Compress)))
                $cmd = @"
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding(`$false)
`$c = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$b64')) | ConvertFrom-Json
`$h = @{ Path = `$c.Path; ResultFile = `$c.ResultFile; LogFile = `$c.LogFile }
foreach (`$pr in `$c.Args.PSObject.Properties) { if (`$pr.Name -eq 'NoBackup') { `$h['NoBackup'] = [switch]`$true } else { `$h[`$pr.Name] = [string]`$pr.Value } }
if (`$env:$envName) { `$h['NewPassword'] = `$env:$envName }
if (`$c.WhatIf) { `$h['WhatIf'] = [switch]`$true }
& `$c.Script @h
exit `$LASTEXITCODE
"@
                Out-Log "--- v4 Set-DatasourceLocation: $f$(if ($stage) { '  (staged copy ' + (Split-Path -Leaf $stage) + ')' }) ---"
                & $psExe -NoProfile -ExecutionPolicy Bypass -Command $cmd 2>&1 | ForEach-Object { Out-Log (Mask ([string]$_)) }
                $code = $LASTEXITCODE
                Out-Log "--- v4 exit code $code ---"
                $line = $null
                if (Test-Path -LiteralPath $resultFile) { $line = @([IO.File]::ReadAllLines($resultFile, [Text.Encoding]::UTF8) | Where-Object { $_ }) | Select-Object -Last 1 }
                if (-not $line) { throw "v4 stopped early (exit $code), no result" }
                $q = $line -split "`t", 3
                $status = $q[0]; $msg = if ($q.Count -ge 3) { Mask $q[2] } else { '' }
                if ($status -eq 'OK' -and $msg -match '(\d+)\s+table\(s\)') { $ct = [int]$Matches[1] }
                if ($status -eq 'OK' -and $stage) {
                    if ($backup) {
                        $bak = $f + '.bak'
                        if ([IO.File]::Exists($bak)) { Out-Log "  backup exists, kept as is (not overwritten) -> $bak" }
                        else {
                            $bt = $bak + '.rptstudio_tmp_' + [guid]::NewGuid().ToString('N')
                            [IO.File]::Copy($f, $bt, $false)
                            [IO.File]::Move($bt, $bak)
                            Out-Log "  backup -> $bak"
                        }
                    }
                    $hStage = (Get-FileHash -LiteralPath $stage -Algorithm SHA256).Hash
                    [IO.File]::Replace($stage, $f, [NullString]::Value)   # PS turns $null into '' for string args
                    $stage = $null
                    if ((Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash -ne $hStage) { throw 'file on disk differs from the verified staged copy after replace' }
                    $msg = "saved + verified $ct table(s)"
                    Out-Log "  replaced original with verified copy (File.Replace)"
                } elseif ($status -ne 'OK') { $msg = "$msg (original not changed)" }
            } catch {
                $status = 'ERR'; $msg = Mask $_.Exception.Message
                Out-Log "[ERR] $f : $msg"
                if ($msg -like 'v4 stopped early*') { $childFail += "$msg for $f" }
            } finally {
                if ($stage) { [IO.File]::Delete($stage) }
                if ([IO.File]::Exists($resultFile)) { [IO.File]::Delete($resultFile) }
            }
            $out += [ordered]@{ file = $f; ok = ($status -eq 'OK'); status = $status; changedTables = $ct; msg = $msg
                                sourceEngine = $(if ($srcFam.ContainsKey($f)) { $srcFam[$f] } else { '' }) }
            Out-Item $f ($status -eq 'OK') $msg
        }
    } finally {
        [Environment]::SetEnvironmentVariable($envName, $null, 'Process')
        if ([IO.File]::Exists($logFile)) { [IO.File]::Delete($logFile) }
    }

    # ---- dialect warning
    $diff = @($out | Where-Object { $_.sourceEngine -and $targetFam -and ($_.sourceEngine -split '\+' | Where-Object { $_ -ne $targetFam }) })
    $dw = $null
    if ($diff.Count) {
        $dw = "$($diff.Count) file(s) use $((@($diff | ForEach-Object { $_.sourceEngine }) | Sort-Object -Unique) -join ', ') but the target is $targetFam" +
              " - Command/SQL Expression syntax differs (HANA vs T-SQL) and is NOT converted; the report will probably fail at run time until its SQL is rewritten."
        Out-Log "[WARN] $dw"
    }
    $nOk = @($out | Where-Object { $_.ok }).Count
    $nBad = @($out | Where-Object { -not $_.ok -and $_.status -ne 'SKIP' }).Count
    $data = [ordered]@{ files = $out; dialectWarning = $dw; testOnly = $testOnly; okCount = $nOk; errCount = $nBad; targetEngine = $targetFam }
    if ($childFail.Count) { Finish $false ($childFail -join '; ') $data }
    if ($nBad -gt 0)      { Finish $false "$nBad file(s) failed (originals not changed)" $data }
    if ($nOk -eq 0)       { Finish $false 'no report was changed' $data }
    Finish $true $null $data
} catch {
    Finish $false $_.Exception.Message $null
}
