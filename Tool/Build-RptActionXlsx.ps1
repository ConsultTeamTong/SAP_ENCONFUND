#requires -Version 5.1
# Build RPT_Action_Frequency.xlsx from the git-derived TSV datasets.
# Uses Excel COM (same approach as ImportUDV\Tools\Scripts\Convert-CsvToAnnotatedXlsx.ps1).

param(
    [string]$DataDir = $PSScriptRoot,
    [string]$OutFile = 'C:\GitHub\RPT_Action_Frequency.xlsx'
)

$ErrorActionPreference = 'Stop'

$headers = @('Rank','Repo','Module','Sub-Module','Report Folder','RPT File',
             'Total Commits','Focused Commits','First Edit','Last Edit')

# PowerShell's COM adapter caches each property setter's signature from its first
# use, so a Value2 that first received a string can never accept an int afterwards.
# Keep both setters String-typed: text goes through Value2, numbers and dates go
# through Formula (Excel parses the string and stores a real number / date).
function Set-Cell {
    param($Sheet, [int]$Row, [int]$Col, $Value)
    if ($Value -is [int] -or $Value -is [double] -or $Value -is [decimal]) {
        $Sheet.Cells.Item($Row, $Col).Formula = [string]$Value
    }
    elseif ($Value -is [string] -and $Value -match '^\d{4}-\d{2}-\d{2}$') {
        $Sheet.Cells.Item($Row, $Col).Formula = $Value
    }
    else {
        $Sheet.Cells.Item($Row, $Col).Value2 = [string]$Value
    }
}

function Read-Dataset {
    param([string]$Path)
    $rows = @()
    $rank = 0
    foreach ($line in (Get-Content -LiteralPath $Path -Encoding UTF8)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $p = $line -split "`t"
        $rank++
        $rows += ,@($rank, $p[0], $p[1], $p[2], $p[3], $p[4], [int]$p[5], [int]$p[6], $p[7], $p[8])
    }
    return ,$rows
}

function Write-Sheet {
    param($Sheet, [string]$Title, $Rows)

    for ($c = 0; $c -lt $headers.Count; $c++) { Set-Cell $Sheet 1 ($c + 1) $headers[$c] }
    $hdr = $Sheet.Range($Sheet.Cells.Item(1,1), $Sheet.Cells.Item(1,$headers.Count))
    $hdr.Font.Bold = $true
    $hdr.Interior.Color = 15921906
    $hdr.HorizontalAlignment = -4108

    $n = $Rows.Count
    for ($r = 0; $r -lt $n; $r++) {
        for ($c = 0; $c -lt $headers.Count; $c++) { Set-Cell $Sheet ($r + 2) ($c + 1) $Rows[$r][$c] }
    }

    $last = $n + 1
    $Sheet.Range("A1:J$last").AutoFilter() | Out-Null
    $Sheet.Activate()
    $Sheet.Application.ActiveWindow.FreezePanes = $false
    $Sheet.Range('A2').Select() | Out-Null
    $Sheet.Application.ActiveWindow.FreezePanes = $true

    foreach ($col in 'G','H') {
        $rng = $Sheet.Range("$col`2:$col$last")
        $db = $rng.FormatConditions.AddDatabar()
        $db.BarColor.Color = 15773696
        $db.BarFillType = 1
    }

    $Sheet.Range("I2:J$last").NumberFormat = 'yyyy-mm-dd'
    $Sheet.Columns.AutoFit() | Out-Null
    $Sheet.Columns.Item(5).ColumnWidth = 42   # Report Folder
    $Sheet.Columns.Item(6).ColumnWidth = 62   # RPT File
    $Sheet.Range("G2:H$last").HorizontalAlignment = -4108
    $Sheet.Name = $Title
}

$sboRows = Read-Dataset (Join-Path $DataDir 'SBO_Warit.full.tsv')
$sdaRows = Read-Dataset (Join-Path $DataDir 'SDA.full.tsv')
Write-Host "SBO_Warit rows: $($sboRows.Count)   SDA rows: $($sdaRows.Count)"

$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xl.DisplayAlerts = $false
$wb = $null

try {
    $wb = $xl.Workbooks.Add()
    while ($wb.Worksheets.Count -gt 1) { $wb.Worksheets.Item($wb.Worksheets.Count).Delete() }

    $ws1 = $wb.Worksheets.Item(1)
    Write-Sheet -Sheet $ws1 -Title 'SBO_Warit' -Rows $sboRows

    $ws2 = $wb.Worksheets.Add([System.Reflection.Missing]::Value, $ws1)
    Write-Sheet -Sheet $ws2 -Title 'SDA' -Rows $sdaRows

    # ---- Summary by module ----
    $ws3 = $wb.Worksheets.Add([System.Reflection.Missing]::Value, $ws2)
    $ws3.Name = 'Summary by Module'
    $sHead = @('Repo','Module','RPT Files','Total Commits','Focused Commits','Avg Commits / File')
    for ($c = 0; $c -lt $sHead.Count; $c++) { Set-Cell $ws3 1 ($c + 1) $sHead[$c] }
    $h3 = $ws3.Range($ws3.Cells.Item(1,1), $ws3.Cells.Item(1,$sHead.Count))
    $h3.Font.Bold = $true
    $h3.Interior.Color = 15921906
    $h3.HorizontalAlignment = -4108

    $r = 2
    foreach ($set in @(@{N='SBO_Warit';R=$sboRows}, @{N='SDA';R=$sdaRows})) {
        $agg = @{}
        foreach ($row in $set.R) {
            $m = $row[2]
            if (-not $agg.ContainsKey($m)) { $agg[$m] = @{Files=0; Total=0; Focused=0} }
            $agg[$m].Files++
            $agg[$m].Total   += $row[6]
            $agg[$m].Focused += $row[7]
        }
        foreach ($m in ($agg.Keys | Sort-Object { -$agg[$_].Total })) {
            Set-Cell $ws3 $r 1 $set.N
            Set-Cell $ws3 $r 2 $m
            Set-Cell $ws3 $r 3 $agg[$m].Files
            Set-Cell $ws3 $r 4 $agg[$m].Total
            Set-Cell $ws3 $r 5 $agg[$m].Focused
            Set-Cell $ws3 $r 6 ([math]::Round($agg[$m].Total / $agg[$m].Files, 1))
            $r++
        }
        $r++
    }
    $ws3.Columns.AutoFit() | Out-Null

    # ---- Notes ----
    $ws4 = $wb.Worksheets.Add([System.Reflection.Missing]::Value, $ws3)
    $ws4.Name = 'Notes'
    $notes = @(
        'RPT Action Frequency  -  derived from git history',
        '',
        'Source repos:',
        '    C:\GitHub\SBO_Warit\Form-Layout   (75 .rpt, 401 commits on the repo)',
        '    C:\GitHub\SDA\Form-Layout         (78 .rpt, 483 commits on the repo)',
        '',
        'Column meanings:',
        '    Total Commits    = git log --follow count for that .rpt (rename-aware).',
        '    Focused Commits  = commits that touched 5 or fewer .rpt files at once.',
        '                       This filters out bulk/batch commits (single commits touched',
        '                       75-88 .rpt files and inflate Total for everything equally),',
        '                       so Focused is the better proxy for "this file was worked on".',
        '    First / Last Edit = first and most recent commit date touching the file.',
        '',
        'Caveats:',
        '    - There is NO "Action" column for .rpt anywhere in either repo. The Action',
        '      column (ADD/UPSERT/DELETE) exists only in ImportUDV\Config\UDV_*.csv, which',
        '      is keyed by FormID and never references .rpt files.',
        '    - Only .rpt files present in HEAD are listed; deleted layouts are excluded.',
        '    - An alternative signal is ImportLayouts\Import_SQL_Log.txt (UPDATE/INSERT/',
        '      SKIP/FAIL per import run); this workbook uses git history instead.'
    )
    for ($i = 0; $i -lt $notes.Count; $i++) { Set-Cell $ws4 ($i + 1) 1 $notes[$i] }
    $ws4.Range('A1').Font.Bold = $true
    $ws4.Range('A1').Font.Size = 14
    $ws4.Columns.Item(1).ColumnWidth = 100

    $ws1.Activate()
    $ws1.Range('A1').Select() | Out-Null

    $dir = Split-Path -Parent $OutFile
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (Test-Path $OutFile) { Remove-Item -LiteralPath $OutFile -Force }
    $wb.SaveAs($OutFile, 51)
    Write-Host "Saved: $OutFile"
}
finally {
    if ($wb) { $wb.Close($false) }
    $xl.Quit()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
    [GC]::Collect(); [GC]::WaitForPendingFinalizers()
}
