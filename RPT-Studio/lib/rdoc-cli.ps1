# ============================================================
# rdoc-cli.ps1 - RPT Studio entry for all DB actions (CONTRACT.md)
#   powershell -NoProfile -ExecutionPolicy Bypass -File lib\rdoc-cli.ps1 -Action <A> -ArgsFile <json>
# Last stdout line: ##RESULT## {"ok":..,"error":..,"data":{..}} ; exit 0 ok / 1 fail.
# HANA profile -> run under SysWOW64 (32-bit ODBC). MSSQL -> 64-bit.
# Never prints passwords.
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$Action,
    [string]$ArgsFile = ""
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch {}

$LibDir  = $PSScriptRoot
$Root    = Split-Path -Parent $LibDir
$ProfilesPath = Join-Path $Root 'config\profiles.json'
. (Join-Path $LibDir 'Secrets.ps1')

function Write-Result([bool]$ok, $data, [string]$err = "") {
    if ($null -eq $data) { $data = @{} }
    $json = ([ordered]@{ ok = $ok; error = $err; data = $data } | ConvertTo-Json -Depth 12 -Compress)
    Write-Output ("##RESULT## " + $json)
    if ($ok) { exit 0 } else { exit 1 }
}

function Read-Profiles {
    if (-not (Test-Path $ProfilesPath)) { return @() }
    $o = Get-Content $ProfilesPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return @($o.profiles)
}
function Save-Profiles($list) {
    $clean = @()
    foreach ($p in $list) {
        $h = [ordered]@{}
        foreach ($prop in $p.PSObject.Properties) { if ($prop.Name -notmatch '^(password|pwd|dbPassword)$') { $h[$prop.Name] = $prop.Value } }
        if ($h.Contains('locationTarget') -and $h.locationTarget) {
            $lt = [ordered]@{}; foreach ($prop in $h.locationTarget.PSObject.Properties) { if ($prop.Name -ne 'password') { $lt[$prop.Name] = $prop.Value } }; $h.locationTarget = $lt
        }
        $h.hasPassword = [bool](Test-ProfilePassword ([string]$h.name))
        $clean += $h
    }
    $json = ([ordered]@{ profiles = $clean } | ConvertTo-Json -Depth 8)
    $dir = Split-Path $ProfilesPath; if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    [IO.File]::WriteAllText($ProfilesPath, $json, (New-Object System.Text.UTF8Encoding $false))
}

# CONTRACT_v2 sec.1: one line per finished item, flushed immediately
function Write-Item([string]$Key, [bool]$Ok, [string]$Msg = "") {
    $line = "##ITEM## " + ([ordered]@{ key = $Key; ok = $Ok; msg = $Msg } | ConvertTo-Json -Compress)
    [Console]::Out.WriteLine($line); [Console]::Out.Flush()
}

function Get-Bool($v, [bool]$default) { if ($null -eq $v) { return $default }; return [bool]$v }

$A = $null
try {
    if ($ArgsFile) {
        if (-not (Test-Path -LiteralPath $ArgsFile)) { throw "ArgsFile not found: $ArgsFile" }
        $A = Get-Content -LiteralPath $ArgsFile -Raw -Encoding UTF8 | ConvertFrom-Json
    } else { $A = New-Object PSObject }

    # ---------- actions without DB ----------
    switch ($Action) {
        'ProfilesGet' {
            $list = Read-Profiles
            foreach ($p in $list) { $p | Add-Member -NotePropertyName hasPassword -NotePropertyValue ([bool](Test-ProfilePassword ([string]$p.name))) -Force }
            Write-Result $true @{ profiles = @($list) }
        }
        'ProfilesSave' {
            if ($null -eq $A.profiles) { throw "args.profiles missing" }
            $names = @{}; foreach ($p in $A.profiles) { if (-not $p.name) { throw "profile without name" }; if ($names[$p.name]) { throw "duplicate profile name $($p.name)" }; $names[$p.name] = 1
                if ($p.engine -notin 'HANA','MSSQL') { throw "profile $($p.name): engine must be HANA or MSSQL" } }
            Save-Profiles @($A.profiles)
            Write-Result $true @{}
        }
        'SetPassword' {
            if (-not $A.profile) { throw "args.profile missing" }
            if ($null -eq $A.password) { throw "args.password missing" }
            Set-ProfilePassword -Name ([string]$A.profile) -Password ([string]$A.password)
            $list = Read-Profiles
            if (@($list | Where-Object { $_.name -eq $A.profile }).Count -gt 0) { Save-Profiles $list }
            Write-Host "password stored (DPAPI CurrentUser) for profile $($A.profile)"
            Write-Result $true @{}
        }
        { $_ -in 'ListImportBatches','GetImportBatch' } {
            . (Join-Path $LibDir 'Sql-RDOC.ps1'); . (Join-Path $LibDir 'Backup-RDOC.ps1'); . (Join-Path $LibDir 'Import-RDOC.ps1'); . (Join-Path $LibDir 'Undo-Import.ps1')
            if (-not $A.profile) { throw "args.profile missing" }
            if ($Action -eq 'ListImportBatches') { Write-Result $true @{ items = (Get-ImportBatches ([string]$A.profile)) } }
            if (-not $A.batchId) { throw "args.batchId missing" }
            $m = Read-ImportManifest ([string]$A.profile) ([string]$A.batchId)
            $m | Add-Member -NotePropertyName effectiveStatus -NotePropertyValue (Get-EffectiveStatus $m) -Force
            Write-Result $true @{ manifest = $m }
        }
        'ListBackups' {
            . (Join-Path $LibDir 'Sql-RDOC.ps1')
            . (Join-Path $LibDir 'Backup-RDOC.ps1')
            if (-not $A.profile) { throw "args.profile missing" }
            Write-Result $true @{ items = (Get-RdocBackups ([string]$A.profile)) }
        }
    }

    # ---------- DB actions ----------
    if ($Action -notin 'TestConnection','ListRdoc','Export','Precheck','Import','Backup','Rollback','UndoImport') { throw "unknown Action: $Action" }
    if (-not $A.profile) { throw "args.profile missing" }
    $P = Read-Profiles | Where-Object { $_.name -eq $A.profile } | Select-Object -First 1
    if (-not $P) { throw "profile not found: $($A.profile)" }
    $engine = [string]$P.engine
    if ($engine -notin 'HANA','MSSQL') { throw "bad engine '$engine' in profile" }
    . (Join-Path $LibDir "DB-$engine.ps1")          # fix (b): plugin chosen by engine
    . (Join-Path $LibDir 'Sql-RDOC.ps1')
    . (Join-Path $LibDir 'Export-RDOCToRpt.ps1')
    . (Join-Path $LibDir 'Import-RDOC.ps1')
    . (Join-Path $LibDir 'Backup-RDOC.ps1')
    . (Join-Path $LibDir 'Rollback-RDOC.ps1')
    . (Join-Path $LibDir 'Undo-Import.ps1')
    Write-Host ("profile={0} engine={1} db={2} bitness={3}" -f $P.name, $engine, $P.companyDb, $(if ([Environment]::Is64BitProcess) { '64' } else { '32' }))

    # safety gate BEFORE connecting: real write needs confirmDb == companyDb (case-sensitive)
    $isWrite = $Action -in 'Import','Rollback','UndoImport'
    $dryRun = Get-Bool $A.dryRun $true
    if ($isWrite -and -not $dryRun) {
        if ([string]$A.confirmDb -cne [string]$P.companyDb) { throw "REFUSED: dryRun=false requires args.confirmDb equal to '$($P.companyDb)'" }
    }

    # empty user = Windows integrated auth (MSSQL only, e.g. a local disposable test instance)
    $dbPass = if ([string]::IsNullOrEmpty([string]$P.user)) { "" } else { Get-ProfilePassword -Name ([string]$P.name) }
    $portStr = if ($P.port) { [string]$P.port } else { "" }
    $conn = New-DBConnection -Server ([string]$P.server) -Database ([string]$P.companyDb) -User ([string]$P.user) -Password $dbPass -Port $portStr
    $dbPass = $null
    $rptRoot = [string]$P.rptRoot

    try {
        switch ($Action) {
            'TestConnection' {
                $c = $conn.CreateCommand(); $c.CommandText = 'SELECT COUNT(*) FROM "RDOC"'
                $n = [int]$c.ExecuteScalar()
                Write-Host "connected; RDOC rows = $n"
                Write-Result $true ([ordered]@{ server = [string]$P.server; db = [string]$P.companyDb; rdocCount = $n })
            }
            'ListRdoc' {
                $where = @('1=1')
                if (-not (Get-Bool $A.includeSystem $false)) { $where += 'UPPER(COALESCE("Author",'''')) NOT IN ('''',''SYSTEM'')' }
                $c = $conn.CreateCommand()
                if ($A.typeCode) { $where += "`"TypeCode`" = ${DB_PARAM}tc" }
                if ($A.q) { $where += "(UPPER(`"DocName`") LIKE ${DB_PARAM}q1 OR UPPER(`"DocCode`") LIKE ${DB_PARAM}q2)" }
                $c.CommandText = Convert-DBSql ("SELECT `"DocCode`", `"DocName`", `"TypeCode`", COALESCE(`"Author`",'') AS `"Author`", $DB_BLOBLEN(`"Template`") AS `"Size`" FROM `"RDOC`" WHERE " + ($where -join ' AND ') + ' ORDER BY "TypeCode", "DocName"')
                if ($A.typeCode) { Add-DBParam $c "${DB_PARAM}tc" ([string]$A.typeCode) }
                if ($A.q) { $q = '%' + ([string]$A.q).ToUpper() + '%'; Add-DBParam $c "${DB_PARAM}q1" $q; Add-DBParam $c "${DB_PARAM}q2" $q }
                $r = $c.ExecuteReader(); $rows = @()
                while ($r.Read()) {
                    $au = [string]$r["Author"]
                    $sz = if ($r["Size"] -is [DBNull]) { 0 } else { [long]$r["Size"] }
                    $rows += [ordered]@{ DocCode=[string]$r["DocCode"]; DocName=[string]$r["DocName"]; TypeCode=[string]$r["TypeCode"]; Author=$au; IsSystem=(Test-IsSystemAuthor $au); Size=$sz }
                }
                $r.Close()
                Write-Host "rows: $($rows.Count)"
                Write-Result $true @{ rows = $rows }
            }
            'Export' {
                $out = if ($A.outDir) { [string]$A.outDir } else { Join-Path $rptRoot ([string]$P.companyDb) }   # fix (a)
                $codes = @(); if ($A.docCodes) { $codes = @($A.docCodes | ForEach-Object { [string]$_ }) }
                if ($codes.Count -eq 0) { throw "args.docCodes is empty" }
                $res = Export-Rdoc -Conn $conn -DocCodes $codes -OutDir $out
                $allOk = @($res.files | Where-Object { -not $_.ok }).Count -eq 0
                Write-Result $allOk $res $(if ($allOk) { "" } else { "some layouts were not exported" })
            }
            'Precheck' {
                $od = if ($A.onDuplicate) { [string]$A.onDuplicate } elseif ($P.onDuplicate) { [string]$P.onDuplicate } else { 'Update' }
                $plan = Get-RdocImportPlan -Conn $conn -Rows @($A.rows) -RptRoot $rptRoot -OnDuplicate $od
                foreach ($o in $plan) { Write-Host ("{0,-6} {1} -> {2} {3} ({4})" -f $o.status, $o.file, $o.typeCode, $o.docCode, $o.reason) }
                Write-Result $true @{ rows = $plan }
            }
            'Import' {
                $od = if ($A.onDuplicate) { [string]$A.onDuplicate } elseif ($P.onDuplicate) { [string]$P.onDuplicate } else { 'Update' }
                if ($od -notin 'Update','Skip','Insert') { throw "bad onDuplicate $od" }
                $plan = Get-RdocImportPlan -Conn $conn -Rows @($A.rows) -RptRoot $rptRoot -OnDuplicate $od
                $backupId = ""
                if ($dryRun) {
                    $s = @{ New=0; Update=0; Skip=0; Error=0 }
                    foreach ($o in $plan) { $o.result = "DRYRUN " + $o.status; $s[$o.status]++; Write-Item $(if ($o.docCode) { [string]$o.docCode } else { [string]$o.path }) ($o.status -ne 'Error') ("DRYRUN " + $o.status + ": " + $o.reason); Write-Host ("DRYRUN {0,-6} {1} -> {2} {3} ({4})" -f $o.status, $o.file, $o.typeCode, $o.docCode, $o.reason) }
                    Write-Result $true ([ordered]@{ backupId=""; dryRun=$true; rows=$plan; inserted=$s.New; updated=$s.Update; skipped=$s.Skip; errors=$s.Error })
                }
                if (Get-Bool $A.backup $true) { $b = Backup-Rdoc -Conn $conn -ProfileName $P.name -CompanyDb $P.companyDb -NoItems; $backupId = $b.backupId }
                $author = if ($P.author) { [string]$P.author } else { 'RPTStudio' }
                $sum = Invoke-RdocImportWrite -Conn $conn -Plan $plan -Author $author -Prof $P
                Write-Result ($sum.errors -eq 0) ([ordered]@{ backupId=$backupId; batchId=$sum.batchId; dryRun=$false; rows=$plan; inserted=$sum.inserted; updated=$sum.updated; skipped=$sum.skipped; errors=$sum.errors }) $(if ($sum.errors) { "$($sum.errors) row(s) failed" } else { "" })
            }
            'Backup' {
                Write-Result $true (Backup-Rdoc -Conn $conn -ProfileName $P.name -CompanyDb $P.companyDb)
            }
            'UndoImport' {
                if (-not $A.batchId) { throw "args.batchId missing" }
                $man = Read-ImportManifest ([string]$P.name) ([string]$A.batchId)
                if ($man.companyDb -cne [string]$P.companyDb -or $man.engine -ne $DB_ENGINE) { throw "batch belongs to $($man.engine)/$($man.companyDb), not this profile's DB" }
                if ((Get-EffectiveStatus $man) -eq 'running') { throw "batch $($A.batchId) is still running" }
                $batchDir = Split-Path (Get-ImportManifestPath ([string]$P.name) ([string]$A.batchId))
                $force = Get-Bool $A.force $false
                $plan = Get-UndoPlan -Conn $conn -Man $man -BatchDir $batchDir -Force $force
                foreach ($o in $plan) { Write-Host ("{0,-8} {1} ({2})" -f $o.action, $o.docCode, $o.reason) }
                $pub = @($plan | ForEach-Object { [ordered]@{ docCode=$_.docCode; action=$_.action; reason=$_.reason } })
                $nDel = @($plan | Where-Object { $_.action -eq 'delete' }).Count; $nRes = @($plan | Where-Object { $_.action -eq 'restore' }).Count
                $refused = @($plan | Where-Object { $_.action -eq 'refuse' })
                if ($dryRun) { Write-Result $true ([ordered]@{ dryRun=$true; plan=$pub; deleted=$nDel; restored=$nRes; refused=$refused.Count }) }
                # all-or-nothing: any refused row blocks the whole undo (force lifts only the "changed after import" refusal)
                if ($refused.Count -gt 0) { Write-Result $false ([ordered]@{ dryRun=$false; plan=$pub; deleted=0; restored=0 }) "REFUSED: $($refused.Count) row(s) refused; nothing changed" }
                if (($nDel + $nRes) -eq 0) { Write-Result $false ([ordered]@{ dryRun=$false; plan=$pub; deleted=0; restored=0 }) "nothing to undo" }
                $r = Invoke-UndoWrite -Conn $conn -Plan $plan
                $mf = Get-ImportManifestPath ([string]$P.name) ([string]$A.batchId)
                $m2 = Get-Content -LiteralPath $mf -Raw -Encoding UTF8 | ConvertFrom-Json
                $m2.status = 'undone'; $m2.undone = $true; $m2.undoneAt = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
                if ($force) { $m2 | Add-Member -NotePropertyName undoForced -NotePropertyValue $true -Force }
                Write-JsonAtomic $mf $m2
                Write-Result $true ([ordered]@{ dryRun=$false; plan=$pub; deleted=$r.deleted; restored=$r.restored })
            }
            'Rollback' {
                if (-not $A.backupId) { throw "args.backupId missing" }
                $codes = @($A.docCodes | ForEach-Object { [string]$_ })
                if ($codes.Count -eq 0) { throw "args.docCodes is empty" }
                $pi = Get-RdocRollbackPlan -Conn $conn -ProfileName $P.name -BackupId ([string]$A.backupId) -DocCodes $codes
                foreach ($o in $pi.plan) { Write-Host ("{0,-8} {1} ({2})" -f $o.action, $o.docCode, $o.reason) }
                if ($dryRun) {
                    Write-Result $true ([ordered]@{ dryRun=$true; plan=$pi.plan; restored=@($pi.plan | Where-Object { $_.action -eq 'restore' }).Count; deleted=@($pi.plan | Where-Object { $_.action -eq 'delete' }).Count })
                }
                $r = Invoke-RdocRollbackWrite -Conn $conn -PlanInfo $pi
                Write-Result $true ([ordered]@{ dryRun=$false; plan=$pi.plan; restored=$r.restored; deleted=$r.deleted })
            }
        }
    } finally { try { $conn.Close() } catch {} }
} catch {
    $msg = $_.Exception.Message
    Write-Host "ERROR: $msg"
    Write-Result $false @{} $msg
}
