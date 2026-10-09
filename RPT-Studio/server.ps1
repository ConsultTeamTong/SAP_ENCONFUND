# RPT Studio - local web server (PowerShell 5.1, 64-bit host)
# Serves ui\index.html and a JSON API on http://127.0.0.1:<Port>/ (loopback only).
# Every tool runs as a child powershell.exe (bitness by profile engine); log -> jobs\<jobId>.log
param(
    [int]$Port = 8765,
    [string]$LibDir = '',
    [switch]$NoBrowser,
    [string]$PickTestDir = ''   # test mode: pick endpoints return paths from this folder, no dialog
)
$ErrorActionPreference = 'Stop'
$Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $LibDir) { $LibDir = Join-Path $Root 'lib' }
$LibDir  = (Resolve-Path -LiteralPath $LibDir -ErrorAction SilentlyContinue).Path
if (-not $LibDir) { $LibDir = Join-Path $Root 'lib' }
$UiFile  = Join-Path $Root 'ui\index.html'
$JobsDir = Join-Path $Root 'jobs'
$TmpDir  = Join-Path $env:TEMP 'rptstudio-args'
foreach ($d in @($JobsDir, $TmpDir)) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null } }

$PS64 = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
if (-not [Environment]::Is64BitProcess -and (Test-Path (Join-Path $env:WINDIR 'Sysnative'))) {
    $PS64 = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
}
$PS32 = Join-Path $env:WINDIR 'SysWOW64\WindowsPowerShell\v1.0\powershell.exe'
$ToolScript = @{ rdoc = 'rdoc-cli.ps1'; map = 'Map-Excel.ps1'; setloc = 'Run-SetLocation.ps1' }
# rdoc actions that do not touch the DB -> always 64-bit (decision 9)
$Rdoc64Actions = @('ProfilesGet','ProfilesSave','SetPassword','ListBackups')

$Jobs = [hashtable]::Synchronized(@{})
$ProfileCache = @{ list = $null }
$Utf8 = New-Object System.Text.UTF8Encoding $false

# ---------------------------------------------------------------- worker (runs inside a runspace)
$Worker = {
    param($Job, $Steps, $LogPath, $JobFile, $Utf8)
    function Write-Log([string]$line) {
        foreach ($s in $script:Secrets) { if ($s) { $line = $line.Replace($s, '***') } }
        [System.IO.File]::AppendAllText($LogPath, $line + "`r`n", $Utf8)
    }
    function Invoke-Step($st) {
        $argsFile = $st.argsFile
        $resultText = $null; $exit = -1
        try {
            [System.IO.File]::WriteAllText($argsFile, $st.argsJson, $Utf8)
            $sq = { param($s) "'" + $s.Replace("'", "''") + "'" }
            $cmd = '[Console]::OutputEncoding=[Text.Encoding]::UTF8; $OutputEncoding=[Text.Encoding]::UTF8; ' +
                   '& ' + (& $sq $st.script) + ' -Action ' + (& $sq $st.action) + ' -ArgsFile ' + (& $sq $argsFile) +
                   ' 2>&1 | ForEach-Object { "$_" }; exit $LASTEXITCODE'
            $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = $st.exe
            $psi.Arguments = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand $enc"
            $psi.UseShellExecute = $false
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
            $psi.StandardErrorEncoding = [Text.Encoding]::UTF8
            $psi.CreateNoWindow = $true
            $psi.WorkingDirectory = Split-Path -Parent $st.script
            Write-Log ("[server] step {0}/{1}: {2} {3} | exe={4} | bitness={5}" -f $st.idx, $st.total, $st.tool, $st.action, $st.exe, $st.bits)
            $p = [System.Diagnostics.Process]::Start($psi)
            $Job.pid = $p.Id
            $errTask = $p.StandardError.ReadToEndAsync()
            while ($null -ne ($line = $p.StandardOutput.ReadLine())) {
                if ($line.StartsWith('##RESULT##')) { $resultText = $line.Substring(10).Trim() }
                elseif ($line.StartsWith('##ITEM##')) {
                    $it = $line.Substring(8).Trim()
                    foreach ($s in $script:Secrets) { if ($s) { $it = $it.Replace($s, '***') } }
                    try { $null = $it | ConvertFrom-Json } catch { $it = ($it | ConvertTo-Json) }
                    [void]$Job.items.Add($it)
                }
                Write-Log $line
            }
            $p.WaitForExit()
            $exit = $p.ExitCode
            $err = $errTask.Result
            if ($err) { foreach ($l in ($err -split "`r?`n")) { if ($l) { Write-Log ("[stderr] " + $l) } } }
            Write-Log ("[server] exit code {0}" -f $exit)
        } catch {
            Write-Log ("[server] launch error: " + $_.Exception.Message)
        } finally {
            if (Test-Path -LiteralPath $argsFile) { Remove-Item -LiteralPath $argsFile -Force -ErrorAction SilentlyContinue }
        }
        $ok = $false
        if ($resultText) {
            try { $o = $resultText | ConvertFrom-Json; $ok = ($o.ok -eq $true) } catch { $resultText = $null }
        }
        if (-not $resultText) {
            $resultText = '{"ok":false,"error":"no valid ##RESULT## line (exit ' + $exit + ')","data":{}}'
        }
        foreach ($s in $script:Secrets) { if ($s) { $resultText = $resultText.Replace($s, '***') } }
        return @{ ok = ($ok -and $exit -eq 0); text = $resultText; exit = $exit }
    }

    $script:Secrets = @()
    foreach ($st in $Steps) { $script:Secrets += $st.secrets }
    $final = $null
    try {
        if ($Steps.Count -eq 1) {
            $r = Invoke-Step $Steps[0]
            $final = $r.text
            $Job.status = $(if ($r.ok) { 'done' } else { 'failed' })
        } else {
            $parts = @(); $allOk = $true; $err = ''
            foreach ($st in $Steps) {
                if ($Job.cancel) { break }
                $r = Invoke-Step $st
                $parts += ('{"tool":"' + $st.tool + '","action":"' + $st.action + '","result":' + $r.text + '}')
                if (-not $r.ok) { $allOk = $false; $err = "step $($st.idx) ($($st.tool) $($st.action)) failed - pipeline stopped"; Write-Log "[server] $err"; break }
            }
            $final = '{"ok":' + $allOk.ToString().ToLower() + ',"error":' + ($err | ConvertTo-Json) + ',"data":{"steps":[' + ($parts -join ',') + ']}}'
            $Job.status = $(if ($allOk) { 'done' } else { 'failed' })
        }
    } catch {
        $final = '{"ok":false,"error":' + ($_.Exception.Message | ConvertTo-Json) + ',"data":{}}'
        $Job.status = 'failed'
    } finally {
        foreach ($st in $Steps) { if (Test-Path -LiteralPath $st.argsFile) { Remove-Item -LiteralPath $st.argsFile -Force -ErrorAction SilentlyContinue } }
    }
    if ($Job.cancel) {
        Write-Log "[server] CANCELLED by user"
        $Job.status = 'cancelled'
        $final = '{"ok":false,"error":"cancelled by user","data":{"cancelled":true,"completedItems":[' + (@($Job.items) -join ',') + ']}}'
    }
    $Job.result = $final
    $Job.ended = (Get-Date).ToString('s')
    $json = '{"id":"' + $Job.id + '","tool":"' + $Job.tool + '","action":"' + $Job.action + '","status":"' + $Job.status +
            '","started":"' + $Job.started + '","ended":"' + $Job.ended + '","cancelledAt":"' + $Job.cancelledAt +
            '","completedItems":[' + (@($Job.items) -join ',') + '],"result":' + $final + '}'
    [System.IO.File]::WriteAllText($JobFile, $json, $Utf8)
}

$Pool = [RunspaceFactory]::CreateRunspacePool(1, 8)
$Pool.Open()
$Handles = New-Object System.Collections.ArrayList

# ---------------------------------------------------------------- helpers
function Get-Secrets($o) {
    $out = @()
    if ($null -eq $o) { return $out }
    if ($o -is [System.Collections.IEnumerable] -and $o -isnot [string]) {
        foreach ($i in $o) { $out += Get-Secrets $i }
    } elseif ($o -is [psobject] -and $o.PSObject.Properties.Count -gt 0 -and $o -isnot [string] -and $o -isnot [ValueType]) {
        foreach ($p in $o.PSObject.Properties) {
            if ($p.Name -match '^(password|pwd)$' -and $p.Value -is [string] -and $p.Value) { $out += $p.Value }
            else { $out += Get-Secrets $p.Value }
        }
    }
    return $out
}

function New-JobId { (Get-Date).ToString('yyyyMMdd_HHmmss') + '_' + ([guid]::NewGuid().ToString('N').Substring(0, 6)) }

function Get-ProfileEngine([string]$name) {
    if (-not $name) { return $null }
    if (-not $ProfileCache.list) { Update-ProfileCache | Out-Null }
    foreach ($p in @($ProfileCache.list)) { if ($p.name -eq $name) { return $p.engine } }
    return $null
}

function New-Step([string]$tool, [string]$action, $argsObj, [int]$idx, [int]$total) {
    if (-not $ToolScript.ContainsKey($tool)) { throw "unknown tool '$tool' (rdoc|map|setloc)" }
    if (-not $action -or $action -notmatch '^[A-Za-z]+$') { throw "invalid action" }
    $script = Join-Path $LibDir $ToolScript[$tool]
    if (-not (Test-Path -LiteralPath $script)) { throw "missing script: $script" }
    if ($null -eq $argsObj) { $argsObj = New-Object psobject }
    $exe = $PS64; $bits = 64
    if ($tool -eq 'rdoc' -and $Rdoc64Actions -notcontains $action) {
        $eng = Get-ProfileEngine $argsObj.profile
        if (-not $eng) { throw "profile '$($argsObj.profile)' not found (needed to pick bitness)" }
        if ($eng -eq 'HANA') { $exe = $PS32; $bits = 32 }
    }
    return @{
        tool = $tool; action = $action; script = $script; exe = $exe; bits = $bits; idx = $idx; total = $total
        argsJson = ($argsObj | ConvertTo-Json -Depth 30 -Compress)
        argsFile = Join-Path $TmpDir ([guid]::NewGuid().ToString('N') + '.json')
        secrets  = @(Get-Secrets $argsObj)
    }
}

function Start-Job2($steps, [string]$tool, [string]$action) {
    $id = New-JobId
    $job = [hashtable]::Synchronized(@{ id = $id; tool = $tool; action = $action; status = 'running'; result = $null; pid = 0; cancel = $false; cancelledAt = ''; items = [System.Collections.ArrayList]::Synchronized((New-Object System.Collections.ArrayList)); started = (Get-Date).ToString('s'); ended = '' })
    $Jobs[$id] = $job
    $log = Join-Path $JobsDir "$id.log"
    [System.IO.File]::WriteAllText($log, '', $Utf8)
    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $Pool
    [void]$ps.AddScript($Worker).AddArgument($job).AddArgument(@($steps)).AddArgument($log).AddArgument((Join-Path $JobsDir "$id.json")).AddArgument($Utf8)
    $h = $ps.BeginInvoke()
    [void]$Handles.Add(@{ ps = $ps; h = $h })
    return $job
}

function Wait-Job2($job) {
    while ($job.status -eq 'running') { Start-Sleep -Milliseconds 150 }
}

function Clear-Handles {
    foreach ($x in @($Handles)) {
        if ($x.h.IsCompleted) { try { $x.ps.EndInvoke($x.h) | Out-Null } catch {} ; $x.ps.Dispose(); if ($x.rs) { $x.rs.Dispose() }; $Handles.Remove($x) }
    }
}

function Invoke-Sync([string]$tool, [string]$action, $argsObj) {
    $job = Start-Job2 @(New-Step $tool $action $argsObj 1 1) $tool $action
    Wait-Job2 $job
    return $job
}

function Update-ProfileCache {
    $job = Invoke-Sync 'rdoc' 'ProfilesGet' (New-Object psobject)
    try {
        $o = $job.result | ConvertFrom-Json
        if ($o.ok) { $ProfileCache.list = @($o.data.profiles) }
    } catch {}
    return $job
}

function Job-Json($j, [bool]$withResult = $true) {
    $r = if ($withResult -and $j.result) { $j.result } else { 'null' }
    '{"id":"' + $j.id + '","tool":"' + $j.tool + '","action":"' + $j.action + '","status":"' + $j.status +
    '","pid":' + [int]$j.pid + ',"started":"' + $j.started + '","ended":"' + $j.ended + '","cancelledAt":"' + $j.cancelledAt +
    '","completedItems":[' + (@($j.items) -join ',') + '],"result":' + $r + '}'
}

function Send([System.Net.HttpListenerResponse]$res, [int]$code, [string]$body, [string]$ctype = 'application/json; charset=utf-8') {
    $b = $Utf8.GetBytes($body)
    $res.StatusCode = $code
    $res.ContentType = $ctype
    $res.Headers['Cache-Control'] = 'no-store'
    $res.ContentLength64 = $b.Length
    $res.OutputStream.Write($b, 0, $b.Length)
    $res.OutputStream.Close()
}
function Send-Err($res, [int]$code, [string]$msg) { Send $res $code ('{"ok":false,"error":' + ($msg | ConvertTo-Json) + ',"data":{}}') }

function Read-Body($req) {
    $sr = New-Object System.IO.StreamReader($req.InputStream, $Utf8)
    $t = $sr.ReadToEnd(); $sr.Close()
    if (-not $t) { return New-Object psobject }
    return $t | ConvertFrom-Json
}

function Get-Browse([string]$path) {
    $items = @()
    if (-not $path) {
        $dirs = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root } | ForEach-Object { @{ name = $_.Root; path = $_.Root } })
        return (@{ path = ''; parent = $null; dirs = $dirs; files = @() } | ConvertTo-Json -Depth 5 -Compress)
    }
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { throw "folder not found: $path" }
    $full = (Resolve-Path -LiteralPath $path).Path
    $parent = Split-Path -Parent $full
    $dirs = @(Get-ChildItem -LiteralPath $full -Directory -ErrorAction SilentlyContinue | Sort-Object Name | ForEach-Object { @{ name = $_.Name; path = $_.FullName } })
    $files = @(Get-ChildItem -LiteralPath $full -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in '.rpt', '.xlsx' } | Sort-Object Name |
        ForEach-Object { @{ name = $_.Name; path = $_.FullName; size = $_.Length; mtime = $_.LastWriteTime.ToString('s') } })
    $o = @{ path = $full; parent = $(if ($parent) { $parent } else { '' }); dirs = $dirs; files = $files }
    return ($o | ConvertTo-Json -Depth 5 -Compress)
}

# ---------------------------------------------------------------- native pick dialogs (own STA runspace each, top-most owner)
$StagingDir = Join-Path $Root 'staging'
if (-not (Test-Path $StagingDir)) { New-Item -ItemType Directory -Path $StagingDir | Out-Null }
$StagingDir = (Resolve-Path -LiteralPath $StagingDir).Path
$MaxUpload = 50MB
$Picks = [hashtable]::Synchronized(@{})
$PickScript = {
    param($Pick, $Kind)
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Application]::EnableVisualStyles()
        $owner = New-Object System.Windows.Forms.Form
        $owner.TopMost = $true; $owner.ShowInTaskbar = $true; $owner.Text = 'RPT Studio'
        $owner.StartPosition = 'CenterScreen'; $owner.Size = New-Object System.Drawing.Size(1, 1); $owner.Opacity = 0
        $owner.Show(); $owner.Activate()
        if ($Kind -eq 'files') {
            $d = New-Object System.Windows.Forms.OpenFileDialog
            $d.Title = 'RPT Studio - เลือกไฟล์ .rpt'; $d.Filter = 'Crystal Reports (*.rpt)|*.rpt'; $d.Multiselect = $true; $d.CheckFileExists = $true
            $rv = $d.ShowDialog($owner); $Pick.dialog = [string]$rv
            if ($rv -eq [System.Windows.Forms.DialogResult]::OK) { $Pick.paths = @($d.FileNames) }
        } else {
            $d = New-Object System.Windows.Forms.FolderBrowserDialog
            $d.Description = 'RPT Studio - เลือกโฟลเดอร์ (รวมโฟลเดอร์ย่อย)'; $d.ShowNewFolderButton = $false
            $rv = $d.ShowDialog($owner); $Pick.dialog = [string]$rv
            if ($rv -eq [System.Windows.Forms.DialogResult]::OK) { $Pick.paths = @($d.SelectedPath) }
        }
        $owner.Close(); $owner.Dispose()
        $Pick.status = 'done'
    } catch { $Pick.error = $_.Exception.Message; $Pick.status = 'error' }
}
function Start-Pick([string]$kind) {
    if ($PickTestDir) {
        $id = [guid]::NewGuid().ToString('N')
        $p = if ($kind -eq 'files') { @(Get-ChildItem -LiteralPath $PickTestDir -File -Filter *.rpt | ForEach-Object FullName) } else { @($PickTestDir) }
        $Picks[$id] = [hashtable]::Synchronized(@{ status = 'done'; paths = $p; error = ''; dialog = 'TEST' })
        return $id
    }
    $id = [guid]::NewGuid().ToString('N')
    $pk = [hashtable]::Synchronized(@{ status = 'pending'; paths = @(); error = '' })
    $Picks[$id] = $pk
    $rs = [RunspaceFactory]::CreateRunspace()
    $rs.ApartmentState = 'STA'; $rs.ThreadOptions = 'ReuseThread'; $rs.Open()
    $ps = [PowerShell]::Create(); $ps.Runspace = $rs
    [void]$ps.AddScript($PickScript).AddArgument($pk).AddArgument($kind)
    $h = $ps.BeginInvoke()
    [void]$Handles.Add(@{ ps = $ps; h = $h; rs = $rs })
    return $id
}

# ---------------------------------------------------------------- routing
function Handle($ctx) {
    $req = $ctx.Request; $res = $ctx.Response
    # loopback only + reject cross-site browser calls
    if (-not [System.Net.IPAddress]::IsLoopback($req.RemoteEndPoint.Address)) { Send-Err $res 403 'loopback only'; return }
    $origin = $req.Headers['Origin']
    if ($origin -and $origin -notmatch "^http://(localhost|127\.0\.0\.1):$Port$") { Send-Err $res 403 'bad origin'; return }

    $path = $req.Url.AbsolutePath
    $m = $req.HttpMethod
    if ($m -eq 'GET' -and ($path -eq '/' -or $path -eq '/index.html')) {
        if (-not (Test-Path $UiFile)) { Send $res 404 'ui\index.html not found' 'text/plain; charset=utf-8'; return }
        Send $res 200 ([System.IO.File]::ReadAllText($UiFile, $Utf8)) 'text/html; charset=utf-8'; return
    }
    if (-not $path.StartsWith('/api/')) { Send $res 404 'not found' 'text/plain'; return }

    if ($path -eq '/api/profiles' -and $m -eq 'GET') {
        $j = Update-ProfileCache; Send $res 200 $j.result; return
    }
    if ($path -eq '/api/profiles' -and $m -eq 'POST') {
        $b = Read-Body $req
        $a = New-Object psobject -Property @{ profiles = @($b.profiles) }
        $j = Invoke-Sync 'rdoc' 'ProfilesSave' $a
        $ProfileCache.list = $null
        Send $res 200 $j.result; return
    }
    if ($path -eq '/api/profiles/password' -and $m -eq 'POST') {
        $b = Read-Body $req
        if (-not $b.profile -or -not $b.password) { Send-Err $res 400 'profile and password required'; return }
        $a = New-Object psobject -Property @{ profile = [string]$b.profile; password = [string]$b.password }
        $j = Invoke-Sync 'rdoc' 'SetPassword' $a
        Send $res 200 $j.result; return
    }
    if ($path -match '^/api/pick/(files|folder)$' -and $m -eq 'POST') {
        $id = Start-Pick $Matches[1]
        Send $res 200 ('{"pickId":"' + $id + '"}'); return
    }
    if ($path -match '^/api/pick/([A-Za-z0-9]+)$' -and $m -eq 'GET') {
        $pk = $Picks[$Matches[1]]
        if (-not $pk) { Send-Err $res 404 'pick not found'; return }
        $body = '{"status":"' + $pk.status + '","error":' + ([string]$pk.error | ConvertTo-Json) + ',"paths":' + (ConvertTo-Json -InputObject @($pk.paths) -Compress) + ',"dialog":"' + $pk.dialog + '"}'
        if ($pk.status -ne 'pending') { $Picks.Remove($Matches[1]) }
        Send $res 200 $body; return
    }
    if ($path -eq '/api/upload/begin' -and $m -eq 'POST') {
        $batch = (Get-Date).ToString('yyyyMMdd_HHmmss') + '_' + ([guid]::NewGuid().ToString('N').Substring(0, 4))
        $dir = Join-Path $StagingDir $batch
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Send $res 200 ('{"ok":true,"batch":"' + $batch + '","dir":' + ($dir | ConvertTo-Json) + '}'); return
    }
    if ($path -eq '/api/upload' -and $m -eq 'POST') {
        $batch = [string]$req.QueryString['batch']; $rel = [string]$req.QueryString['rel']
        if ($batch -notmatch '^\d{8}_\d{6}_[0-9a-f]{4}$') { Send-Err $res 400 'bad batch'; return }
        $bdir = Join-Path $StagingDir $batch
        if (-not (Test-Path -LiteralPath $bdir -PathType Container)) { Send-Err $res 400 'batch not started'; return }
        $segs = @($rel -split '[\\/]')
        $bad = [IO.Path]::GetInvalidFileNameChars()
        foreach ($s in $segs) { if (-not $s -or $s -eq '.' -or $s -eq '..' -or $s.IndexOfAny($bad) -ge 0 -or $s.EndsWith('.') -or $s.EndsWith(' ')) { Send-Err $res 400 "bad path: $rel"; return } }
        if ($segs.Count -gt 20) { Send-Err $res 400 'path too deep'; return }
        if ([IO.Path]::GetExtension($segs[-1]) -ne '.rpt') { Send-Err $res 400 'only .rpt allowed'; return }
        if ($req.ContentLength64 -lt 0 -or $req.ContentLength64 -gt $MaxUpload) { Send-Err $res 413 "file too large (max $([int]($MaxUpload/1MB)) MB)"; return }
        $target = [IO.Path]::GetFullPath((Join-Path $bdir ($segs -join '\')))
        if (-not $target.StartsWith($bdir + '\', [StringComparison]::OrdinalIgnoreCase)) { Send-Err $res 400 'path traversal'; return }
        if (Test-Path -LiteralPath $target) { Send-Err $res 409 "duplicate: $rel"; return }
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        $fs = [IO.File]::Create($target)
        try {
            $buf = New-Object byte[] 65536; $total = 0
            while (($n = $req.InputStream.Read($buf, 0, $buf.Length)) -gt 0) {
                $total += $n
                if ($total -gt $MaxUpload) { throw 'file too large' }
                $fs.Write($buf, 0, $n)
            }
        } catch { $fs.Close(); Remove-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue; Send-Err $res 413 $_.Exception.Message; return }
        $fs.Close()
        Send $res 200 ('{"ok":true,"path":' + ($target | ConvertTo-Json) + ',"size":' + $total + '}'); return
    }
    if ($path -eq '/api/run' -and $m -eq 'POST') {
        $b = Read-Body $req
        $step = New-Step ([string]$b.tool) ([string]$b.action) $b.args 1 1
        $j = Start-Job2 @($step) ([string]$b.tool) ([string]$b.action)
        if ($b.async -eq $true) { Send $res 200 ('{"jobId":"' + $j.id + '"}'); return }
        Wait-Job2 $j
        Send $res 200 $j.result; return
    }
    if ($path -eq '/api/pipeline' -and $m -eq 'POST') {
        $b = Read-Body $req
        $steps = @($b.steps)
        if ($steps.Count -lt 1) { Send-Err $res 400 'steps required'; return }
        $built = @(); $i = 0
        foreach ($s in $steps) {
            $i++
            $a = $s.args; if ($null -eq $a) { $a = New-Object psobject }
            if ($b.profile -and -not $a.profile) { $a | Add-Member -NotePropertyName profile -NotePropertyValue ([string]$b.profile) -Force }
            $built += New-Step ([string]$s.tool) ([string]$s.action) $a $i $steps.Count
        }
        $j = Start-Job2 $built 'pipeline' ("{0} steps" -f $steps.Count)
        if ($b.async -eq $false) { Wait-Job2 $j; Send $res 200 $j.result; return }
        Send $res 200 ('{"jobId":"' + $j.id + '"}'); return
    }
    if ($path -eq '/api/jobs' -and $m -eq 'GET') {
        $list = @($Jobs.Values | Sort-Object { $_.id } -Descending | ForEach-Object { Job-Json $_ $false })
        Send $res 200 ('{"jobs":[' + ($list -join ',') + ']}'); return
    }
    if ($path -match '^/api/jobs/([A-Za-z0-9_]+)/cancel$' -and $m -eq 'POST') {
        $j = $Jobs[$Matches[1]]
        if (-not $j) { Send-Err $res 404 'job not found'; return }
        if ($j.status -ne 'running') { Send-Err $res 409 "job is not running (status=$($j.status))"; return }
        $j.cancel = $true; $j.cancelledAt = (Get-Date).ToString('s')
        $killed = $false
        if ($j.pid) {
            # kill the whole child process tree (taskkill /T /F returns quickly; listener not held)
            & taskkill.exe /PID $j.pid /T /F 2>&1 | Out-Null
            $killed = ($LASTEXITCODE -eq 0)
        }
        Send $res 200 ('{"ok":true,"jobId":"' + $j.id + '","killedPid":' + $j.pid + ',"taskkill":' + $killed.ToString().ToLower() + '}'); return
    }
    if ($path -match '^/api/jobs/([A-Za-z0-9_]+)(/log)?$' -and $m -eq 'GET') {
        $id = $Matches[1]; $isLog = [bool]$Matches[2]
        $j = $Jobs[$id]
        if (-not $j) {
            $f = Join-Path $JobsDir "$id.json"
            if (-not (Test-Path $f)) { Send-Err $res 404 'job not found'; return }
            if (-not $isLog) { Send $res 200 ([System.IO.File]::ReadAllText($f, $Utf8)); return }
            $st = 'done'
        } else { $st = $j.status }
        if (-not $isLog) { Send $res 200 (Job-Json $j); return }
        $from = 0; [void][int]::TryParse($req.QueryString['from'], [ref]$from)
        $logf = Join-Path $JobsDir "$id.log"
        $lines = @()
        if (Test-Path $logf) {
            $fs = New-Object System.IO.FileStream($logf, 'Open', 'Read', 'ReadWrite')
            $sr = New-Object System.IO.StreamReader($fs, $Utf8)
            $all = $sr.ReadToEnd(); $sr.Close()
            # only complete lines
            $cut = $all.LastIndexOf("`n")
            $all = if ($cut -ge 0) { $all.Substring(0, $cut + 1) } else { '' }
            $lines = @($all -split "`r?`n" | Select-Object -SkipLast 1)
        }
        $new = if ($from -lt $lines.Count) { @($lines[$from..($lines.Count - 1)]) } else { @() }
        $body = '{"status":"' + $st + '","from":' + $from + ',"next":' + $lines.Count + ',"lines":' + (ConvertTo-Json -InputObject @($new) -Compress) + '}'
        Send $res 200 $body; return
    }
    if ($path -eq '/api/browse' -and $m -eq 'GET') {
        Send $res 200 (Get-Browse ([string]$req.QueryString['path'])); return
    }
    Send-Err $res 404 "no route $m $path"
}

# ---------------------------------------------------------------- main loop
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "RPT Studio server: http://localhost:$Port/  (lib=$LibDir, 64bit=$([Environment]::Is64BitProcess))"
Write-Host "Ctrl+C to stop."
if (-not $NoBrowser) { Start-Process "http://localhost:$Port/" }
try {
    while ($listener.IsListening) {
        $ar = $listener.BeginGetContext($null, $null)
        while (-not $ar.AsyncWaitHandle.WaitOne(500)) { Clear-Handles }
        $ctx = $listener.EndGetContext($ar)
        try { Handle $ctx }
        catch { try { Send-Err $ctx.Response 500 $_.Exception.Message } catch {} }
        Clear-Handles
    }
} finally {
    $listener.Stop(); $Pool.Close()
}
