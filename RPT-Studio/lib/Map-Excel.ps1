# ============================================================
# Map-Excel.ps1 - RPT_Import_Map.xlsx actions (no DB, no Excel COM; unzip + XML)
#   powershell -NoProfile -ExecutionPolicy Bypass -File lib\Map-Excel.ps1 -Action Read|Scan|Save -ArgsFile <json>
# Sheet names and header row are never changed. Only RPT_MAP sheetData rows 2..N are rewritten.
# Columns are located by header name in row 1 (A..K = No,Module,RPT_FileName,RPT_FolderPath,
# SAP_Document,Header_Table,Line_Table,Object_Type,Form_MenuUID,LayoutName_Suggest,Note);
# a column missing from the header (e.g. Note) is read as "" and not written.
# ============================================================
param([Parameter(Mandatory=$true)][string]$Action, [string]$ArgsFile = "")
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch {}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$COLS = @('No','Module','RPT_FileName','RPT_FolderPath','SAP_Document','Header_Table','Line_Table','Object_Type','Form_MenuUID','LayoutName_Suggest','Note')
$NS_MAIN = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
$NS_REL  = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
$UTF8NB  = New-Object System.Text.UTF8Encoding $false

# same keys as Import-RDOC $TypeCodeMap (162 intentionally unmapped)
$MappedObjTypes = @('30','23','17','15','16','203','13','14','1470000113','540000405','22','20','21','204','18','19','69','24','46','59','60','67','1250000001','1470000065','202')

# file-name keyword -> ObjectType / Module / SAP_Document / tables (first match wins; order matters)
$Guess = @(
  @('Journal Entry','30','Financials','Journal Entry','OJDT','JDT1'),
  @('Quotation','23','Sales - AR','Sales Quotation','OQUT','QUT1'),
  @('Sale Order|Sales Order','17','Sales - AR','Sales Order','ORDR','RDR1'),
  @('Delivery','15','Sales - AR','Delivery','ODLN','DLN1'),
  @('Return','16','Sales - AR','Return','ORDN','RDN1'),
  @('Down Payment|DownPayment','203','Sales - AR','A/R Down Payment','ODPI','DPI1'),
  @('Credit','14','Sales - AR','A/R Credit Memo','ORIN','RIN1'),
  @('Invoice|Tax Inv','13','Sales - AR','A/R Invoice','OINV','INV1'),
  @('Purchase Request','1470000113','Purchasing - AP','Purchase Request','OPRQ','PRQ1'),
  @('Purchase Order|\bPO\b','22','Purchasing - AP','Purchase Order','OPOR','POR1'),
  @('Goods Receipt PO|GRPO','20','Purchasing - AP','Goods Receipt PO','OPDN','PDN1'),
  @('Incoming','24','Banking','Incoming Payment','ORCT','RCT1'),
  @('Outgoing|Payment Voucher','46','Banking','Outgoing Payment','OVPM','VPM1'),
  @('Goods Receipt','59','Inventory','Goods Receipt','OIGN','IGN1'),
  @('Goods Issue','60','Inventory','Goods Issue','OIGE','IGE1'),
  @('Transfer Request','1250000001','Inventory','Inventory Transfer Request','OWTQ','WTQ1'),
  @('Transfer','67','Inventory','Inventory Transfer','OWTR','WTR1'),
  @('Production','202','Production','Production Order','OWOR','WOR1')
)

function Write-Result([bool]$ok, $data, [string]$err = "") {
    if ($null -eq $data) { $data = @{} }
    Write-Output ("##RESULT## " + ([ordered]@{ ok=$ok; error=$err; data=$data } | ConvertTo-Json -Depth 10 -Compress))
    if ($ok) { exit 0 } else { exit 1 }
}

function ColToIdx([string]$letters) { $n = 0; foreach ($c in $letters.ToUpper().ToCharArray()) { $n = $n * 26 + ([int][char]$c - 64) }; $n }
function IdxToCol([int]$i) { $s = ""; while ($i -gt 0) { $m = ($i - 1) % 26; $s = [char](65 + $m) + $s; $i = [int](($i - $m - 1) / 26) }; $s }
function XmlEsc([string]$s) { [Security.SecurityElement]::Escape($s) }

function Read-Entry($zip, [string]$name) {
    $e = $zip.GetEntry($name); if (-not $e) { return $null }
    $sr = New-Object IO.StreamReader($e.Open(), $UTF8NB); try { $sr.ReadToEnd() } finally { $sr.Close() }
}
function Write-Entry($zip, [string]$name, [string]$text) {
    $old = $zip.GetEntry($name); if ($old) { $old.Delete() }
    $e = $zip.CreateEntry($name, [IO.Compression.CompressionLevel]::Optimal)
    $sw = New-Object IO.StreamWriter($e.Open(), $UTF8NB); try { $sw.Write($text) } finally { $sw.Close() }
}

function Get-MapSheetPath($zip) {
    [xml]$wb = Read-Entry $zip 'xl/workbook.xml'
    $ns = New-Object Xml.XmlNamespaceManager($wb.NameTable); $ns.AddNamespace('x', $NS_MAIN)
    $sh = $wb.SelectSingleNode("//x:sheet[@name='RPT_MAP']", $ns); if (-not $sh) { throw "Sheet 'RPT_MAP' not found" }
    $rid = $sh.GetAttribute('id', $NS_REL)
    [xml]$rels = Read-Entry $zip 'xl/_rels/workbook.xml.rels'
    $t = ($rels.Relationships.Relationship | Where-Object { $_.Id -eq $rid }).Target
    if ($t -match '^/') { $t.TrimStart('/') } else { "xl/$t" }
}

function Read-Map([string]$Path) {
    $zip = [IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $shared = @()
        $ssText = Read-Entry $zip 'xl/sharedStrings.xml'
        if ($ssText) {
            [xml]$ss = $ssText; $ns = New-Object Xml.XmlNamespaceManager($ss.NameTable); $ns.AddNamespace('x', $NS_MAIN)
            foreach ($si in $ss.SelectNodes('//x:si', $ns)) { $t = ""; foreach ($n in $si.SelectNodes('.//x:t', $ns)) { $t += $n.InnerText }; $shared += ,$t }
        }
        [xml]$sh = Read-Entry $zip (Get-MapSheetPath $zip)
        $ns = New-Object Xml.XmlNamespaceManager($sh.NameTable); $ns.AddNamespace('x', $NS_MAIN)
        $header = @{}; $rows = @()
        foreach ($row in $sh.SelectNodes('//x:sheetData/x:row', $ns)) {
            $cells = @{}
            foreach ($c in $row.SelectNodes('x:c', $ns)) {
                $ci = ColToIdx ($c.GetAttribute('r') -replace '[0-9]', '')
                $v = $c.SelectSingleNode('x:v', $ns); $is = $c.SelectSingleNode('x:is', $ns); $t = $c.GetAttribute('t'); $val = ""
                if ($t -eq 's' -and $v) { $val = $shared[[int]$v.InnerText] }
                elseif ($t -eq 'inlineStr' -and $is) { foreach ($n in $is.SelectNodes('.//x:t', $ns)) { $val += $n.InnerText } }
                elseif ($v) { $val = $v.InnerText }
                $cells[$ci] = [string]$val
            }
            if ([int]$row.GetAttribute('r') -eq 1) { foreach ($k in $cells.Keys) { $header[$cells[$k].Trim()] = $k }; continue }
            $o = [ordered]@{}
            foreach ($col in $COLS) { $o[$col] = if ($header.ContainsKey($col) -and $cells.ContainsKey($header[$col])) { $cells[$header[$col]] } else { "" } }
            if ($o.RPT_FileName) { $rows += $o }
        }
        foreach ($need in 'RPT_FileName','Object_Type') { if (-not $header.ContainsKey($need)) { throw "header '$need' not found in RPT_MAP row 1" } }
        return @{ rows = $rows; header = $header }
    } finally { $zip.Dispose() }
}

# Rewrites RPT_MAP rows 2..N of $Path in place with $Rows (header row XML kept verbatim).
function Write-MapRows([string]$Path, $Rows, $Header) {
    $zip = [IO.Compression.ZipFile]::Open($Path, 'Update')
    try {
        $sp = Get-MapSheetPath $zip
        $xml = Read-Entry $zip $sp
        $m = [regex]::Match($xml, '<sheetData>(.*?)</sheetData>', 'Singleline')
        if (-not $m.Success) { throw "sheetData not found" }
        $hdr = [regex]::Match($m.Groups[1].Value, '<row [^>]*r="1"[^>]*>.*?</row>', 'Singleline').Value
        $maxCol = ($Header.Values | Measure-Object -Maximum).Maximum
        $sb = New-Object Text.StringBuilder; [void]$sb.Append($hdr)
        $r = 1
        foreach ($row in $Rows) {
            $r++; [void]$sb.Append("<row r=`"$r`">")
            foreach ($col in $COLS) {
                if (-not $Header.ContainsKey($col)) { continue }
                $val = [string]$row.$col; if ($val -eq '') { continue }
                $ref = (IdxToCol $Header[$col]) + $r
                if ($col -eq 'No' -and $val -match '^\d+$') { [void]$sb.Append("<c r=`"$ref`"><v>$val</v></c>") }
                else { [void]$sb.Append("<c r=`"$ref`" t=`"inlineStr`"><is><t xml:space=`"preserve`">" + (XmlEsc $val) + "</t></is></c>") }
            }
            [void]$sb.Append('</row>')
        }
        $new = $xml.Substring(0, $m.Groups[1].Index) + $sb.ToString() + $xml.Substring($m.Groups[1].Index + $m.Groups[1].Length)
        $new = [regex]::Replace($new, '<dimension ref="[^"]*"/>', ('<dimension ref="A1:' + (IdxToCol $maxCol) + $r + '"/>'))
        Write-Entry $zip $sp $new
    } finally { $zip.Dispose() }
}

function Guess-Row([string]$fileName) {
    foreach ($g in $Guess) { if ($fileName -match $g[0]) { return $g } }
    return $null
}

$A = $null
try {
    if ($ArgsFile) { $A = Get-Content -LiteralPath $ArgsFile -Raw -Encoding UTF8 | ConvertFrom-Json } else { throw "ArgsFile required" }
    if (-not $A.mapPath) { throw "args.mapPath missing" }
    if (-not (Test-Path -LiteralPath $A.mapPath)) { throw "map not found: $($A.mapPath)" }
    $mapPath = (Resolve-Path -LiteralPath $A.mapPath).Path

    switch ($Action) {
        'Read' {
            $m = Read-Map $mapPath
            Write-Host "rows: $($m.rows.Count)"
            Write-Result $true @{ rows = $m.rows }
        }
        'Scan' {
            $m = Read-Map $mapPath
            $root = if ($A.rptRoot) { [string]$A.rptRoot } else { "" }
            $haveName = @{}; $havePath = @{}
            foreach ($r in $m.rows) {
                $haveName[$r.RPT_FileName.ToLower()] = $true
                $f = [string]$r.RPT_FolderPath
                if ($f) {
                    $abs = if ([IO.Path]::IsPathRooted($f)) { $f } elseif ($root) { Join-Path $root $f } else { $null }
                    if ($abs) { $havePath[(Join-Path $abs $r.RPT_FileName).ToLower()] = $true }
                }
            }
            # collect candidates: folder (recursive) + explicit files
            $cand = New-Object System.Collections.ArrayList
            if ($A.folder) {
                if (-not (Test-Path -LiteralPath $A.folder)) { throw "folder not found: $($A.folder)" }
                Get-ChildItem -LiteralPath $A.folder -Filter *.rpt -Recurse -File | ForEach-Object { [void]$cand.Add($_.FullName) }
            }
            foreach ($f in @($A.files)) {
                if (-not $f) { continue }
                if (-not (Test-Path -LiteralPath $f)) { Write-Host "WARN missing file: $f"; continue }
                if ([IO.Path]::GetExtension($f) -ne '.rpt') { Write-Host "WARN not .rpt: $f"; continue }
                [void]$cand.Add((Resolve-Path -LiteralPath $f).Path)
            }
            if (-not $A.folder -and @($A.files).Count -eq 0) { throw "args.folder or args.files required" }
            # index CSVs: explicit + _ExportIndex.csv next to each file
            $idxCache = @{}
            function Get-Idx([string]$csv) {
                if (-not $idxCache.ContainsKey($csv)) { $h = @{}; if ($csv -and (Test-Path -LiteralPath $csv)) { foreach ($x in (Import-Csv -LiteralPath $csv -Encoding UTF8)) { $h[$x.RPT_FileName.ToLower()] = $x } }; $idxCache[$csv] = $h }
                $idxCache[$csv]
            }
            $added = @(); $seen = @{}; $dupSkipped = 0
            $no = 0; foreach ($r in $m.rows) { if ($r.No -match '^\d+$' -and [int]$r.No -gt $no) { $no = [int]$r.No } }
            foreach ($full in $cand) {
                $key = $full.ToLower(); if ($seen[$key]) { continue }; $seen[$key] = $true
                $name = [IO.Path]::GetFileName($full); $dir = [IO.Path]::GetDirectoryName($full)
                if ($havePath[$key] -or $haveName[$name.ToLower()]) { $dupSkipped++; continue }
                $haveName[$name.ToLower()] = $true
                $folderVal = $dir
                if ($root -and $dir.ToLower().StartsWith($root.TrimEnd('\').ToLower() + '\')) { $folderVal = $dir.Substring($root.TrimEnd('\').Length + 1) }
                $no++
                $o = [ordered]@{}; foreach ($c in $COLS) { $o[$c] = "" }
                $o.No = [string]$no; $o.RPT_FileName = $name; $o.RPT_FolderPath = $folderVal
                $o.LayoutName_Suggest = [IO.Path]::GetFileNameWithoutExtension($name)
                $src = "guess"
                $hit = $null
                if ($A.indexCsv) { $hit = (Get-Idx ([string]$A.indexCsv))[$name.ToLower()] }
                if (-not $hit) { $hit = (Get-Idx (Join-Path $dir '_ExportIndex.csv'))[$name.ToLower()] }
                if ($hit) { $o.Object_Type = [string]$hit.ObjectType; if ($hit.LayoutName) { $o.LayoutName_Suggest = [string]$hit.LayoutName }; $o.Module = [string]$hit.Module; $src = "indexCsv" }
                else {
                    $g = Guess-Row $name
                    if ($g) { $o.Object_Type = $g[1]; $o.Module = $g[2]; $o.SAP_Document = $g[3]; $o.Header_Table = $g[4]; $o.Line_Table = $g[5] } else { $o.Object_Type = '-' }
                }
                $ot = [string]$o.Object_Type
                $o.flagged = ($ot -eq '' -or $ot -eq '-' -or $MappedObjTypes -notcontains $ot)
                $o.source = $src
                $added += $o
                Write-Host ("ADD {0} [{1}] OT={2} flagged={3} ({4})" -f $name, $folderVal, $ot, $o.flagged, $src)
            }
            Write-Result $true ([ordered]@{ added = $added; existing = $m.rows.Count; duplicatesSkipped = $dupSkipped })
        }
        'Save' {
            if ($null -eq $A.rows) { throw "args.rows missing" }
            $m = Read-Map $mapPath
            $ts = Get-Date -Format 'yyyyMMdd_HHmm'
            $bak = "$mapPath.bak_$ts"
            if (Test-Path -LiteralPath $bak) { $bak = "$mapPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')" }
            $rows = @($A.rows)
            # ticked key = "RPT_FolderPath|RPT_FileName" (exact row); a bare file name is accepted only if unique in rows.
            # Validated BEFORE anything is written.
            $ticked = @{}
            foreach ($t in @($A.ticked)) { if ($t) { $ticked[(([string]$t).Trim() -replace '\\+\|', '|').ToLower()] = $true } }
            $nameCount = @{}; foreach ($r in $rows) { $k = ([string]$r.RPT_FileName).ToLower(); $nameCount[$k] = 1 + [int]$nameCount[$k] }
            foreach ($k in @($ticked.Keys)) { if ($k -notmatch '\|' -and [int]$nameCount[$k] -gt 1) { throw "ticked '$k' is ambiguous (same file name in several folders); use 'RPT_FolderPath|RPT_FileName'" } }
            Copy-Item -LiteralPath $mapPath -Destination $bak
            Write-MapRows $mapPath $rows $m.header
            Write-Host "master saved ($($rows.Count) rows), backup $bak"
            $roundFile = ""
            if ($ticked.Count -gt 0) {
                $rd = if ($A.roundDir) { [string]$A.roundDir } else { Split-Path $mapPath }
                if (-not (Test-Path -LiteralPath $rd)) { New-Item -ItemType Directory -Force $rd | Out-Null }
                $roundFile = Join-Path $rd "Round_$ts.xlsx"
                Copy-Item -LiteralPath $mapPath -Destination $roundFile -Force
                $sel = @($rows | Where-Object {
                    $fn = ([string]$_.RPT_FileName).ToLower(); $fk = (([string]$_.RPT_FolderPath).TrimEnd('\') + '|' + ([string]$_.RPT_FileName)).ToLower()
                    $ticked[$fk] -or $ticked[$fn] })
                Write-MapRows $roundFile $sel $m.header
                Write-Host "round file $roundFile ($($sel.Count) rows)"
            }
            Write-Result $true ([ordered]@{ masterBackup = $bak; masterPath = $mapPath; roundFile = $roundFile })
        }
        default { throw "unknown Action: $Action" }
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)"
    Write-Result $false @{} $_.Exception.Message
}
