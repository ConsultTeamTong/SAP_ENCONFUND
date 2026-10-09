# ============================================================
# Sql-RDOC.ps1 - engine-aware SQL text builders + shared helpers (dot-sourced after DB-<engine>.ps1)
# All SQL passes through Convert-DBSql; identifiers double-quoted; no N'..' (HANA forbids it,
# MSSQL does not need it because every value is a bound parameter).
# Builders only RETURN text, so they can be inspected without executing (see tests).
# ============================================================

$RDOC_INSERT_COLS = 'DocCode,DocName,Author,Notes,Width,Height,LMargin,RMargin,TMargin,BMargin,CanChange,PaperSize,Oreint,GridSize,GridType,ShowGrid,SnapGrid,TypeCode,FrgnReport,CanSort,LeaderCode,FollowCode,SwapOnScrn,ScreenFont,ScrFOffset,SwpInEmail,EmailFont,EmFOffset,QString,QType,RobjCode,ExtName,ExtOnErr,NumRepArs,AlgnFooter,TimeFormat,DateFormat,NumCopy,GbiSupport,Use1stPrtr,Shading,Template,Category,CreateDate,Status,B1Version,CRVersion,Local,UseSysPref,ForMobile,TypeDetail,IsIMCE,CsUrl,RptHash'
$NOT_SYSTEM = 'UPPER(COALESCE("Author",'''')) NOT IN ('''',''SYSTEM'')'

# Param order (positional on HANA): DocCode, DocName, Author, TypeCode, Template, RptHash
function Get-SqlInsertRdoc {
    $p = $DB_PARAM
    $qcols = ($RDOC_INSERT_COLS.Split(',') | ForEach-Object { '"' + $_ + '"' }) -join ','
    $vals = "${p}DocCode,${p}DocName,${p}Author,'',595,842,10,30,10,10,'Y','A4','P',10,'1','Y','Y',${p}TypeCode,'N','Y','','','N','Arial',-1,'N','Arial',-1,'','R',0,'','S',-1,'N','0','0',1,'N','N','Y',${p}Template,'C',$DB_NOW,'A','','','','Y','Y','','N','',${p}RptHash"
    Convert-DBSql "INSERT INTO `"RDOC`" ($qcols) VALUES ($vals)"
}
# Param order: Template, RptHash, DocCode
function Get-SqlUpdateRdocTemplate {
    $p = $DB_PARAM
    Convert-DBSql "UPDATE `"RDOC`" SET `"Template`"=${p}Template, `"RptHash`"=${p}RptHash, `"UpdateDate`"=$DB_NOW WHERE `"DocCode`"=${p}DocCode AND $NOT_SYSTEM"
}
# Param order: Template, RptHash, UpdateDate, DocCode [, GuardHash]   (restore exact before-values)
# -Guard: optimistic check, row must still carry the post-import RptHash (0 rows => caller throws => rollback)
function Get-SqlRestoreRdoc([switch]$Guard) {
    $p = $DB_PARAM
    $g = if ($Guard) { " AND `"RptHash`"=${p}GuardHash" } else { "" }
    Convert-DBSql "UPDATE `"RDOC`" SET `"Template`"=${p}Template, `"RptHash`"=${p}RptHash, `"UpdateDate`"=${p}UpdateDate WHERE `"DocCode`"=${p}DocCode AND $NOT_SYSTEM$g"
}
# Param order: DocCode
function Get-SqlDeleteChild([string]$Table) {
    if ($Table -notin 'RITM','RDC1','RCON','DFLT_PRNTING') { throw "table not allowed: $Table" }
    Convert-DBSql "DELETE FROM `"$Table`" WHERE `"DocCode`"=${DB_PARAM}DocCode"
}
# Param order: DocCode [, GuardHash]
function Get-SqlDeleteRdoc([switch]$Guard) {
    $g = if ($Guard) { " AND `"RptHash`"=${DB_PARAM}GuardHash" } else { "" }
    Convert-DBSql "DELETE FROM `"RDOC`" WHERE `"DocCode`"=${DB_PARAM}DocCode AND $NOT_SYSTEM$g"
}
function Get-SqlRdocState { Convert-DBSql "SELECT `"DocCode`", `"Author`", `"RptHash`", `"UpdateDate`" FROM `"RDOC`" WHERE `"DocCode`"=${DB_PARAM}DocCode" }
function Get-SqlRdocBefore { Convert-DBSql "SELECT `"Template`", `"RptHash`", `"UpdateDate`", `"Author`" FROM `"RDOC`" WHERE `"DocCode`"=${DB_PARAM}DocCode" }
function Get-SqlTableHasDocCode([string]$Table) {
    if ($DB_ENGINE -eq 'HANA') { "SELECT COUNT(*) FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME=CURRENT_SCHEMA AND TABLE_NAME='$Table' AND COLUMN_NAME='DocCode'" }
    else { "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='$Table' AND COLUMN_NAME='DocCode'" }
}

function Format-DbDate($v) { if ($null -eq $v -or $v -is [DBNull]) { return $null }; ([datetime]$v).ToString('yyyy-MM-ddTHH:mm:ss.fff') }

# Current state of one RDOC row: $null if missing
function Get-RdocState($Conn, [string]$DocCode, $Tran = $null) {
    $c = $Conn.CreateCommand(); if ($Tran) { $c.Transaction = $Tran }
    $c.CommandText = Get-SqlRdocState; Add-DBParam $c "${DB_PARAM}DocCode" $DocCode
    $r = $c.ExecuteReader()
    try { if ($r.Read()) { return [ordered]@{ docCode=$DocCode; author=[string]$r["Author"]; rptHash=[string]$r["RptHash"]; updateDate=(Format-DbDate $r["UpdateDate"]) } } else { return $null } }
    finally { $r.Close() }
}

function Test-TableHasDocCode($Conn, [string]$Table, $Tran = $null) {
    $c = $Conn.CreateCommand(); if ($Tran) { $c.Transaction = $Tran }
    $c.CommandText = Get-SqlTableHasDocCode $Table
    return ([int]$c.ExecuteScalar() -gt 0)
}

function Write-JsonAtomic([string]$Path, $Obj) {
    $tmp = "$Path.tmp"
    [IO.File]::WriteAllText($tmp, ($Obj | ConvertTo-Json -Depth 10), (New-Object System.Text.UTF8Encoding $false))
    if (Test-Path -LiteralPath $Path) { [IO.File]::Replace($tmp, $Path, [NullString]::Value) } else { [IO.File]::Move($tmp, $Path) }
}

function Move-PartFile([string]$Part, [string]$Final) {
    if (Test-Path -LiteralPath $Final) { [IO.File]::Replace($Part, $Final, [NullString]::Value) } else { [IO.File]::Move($Part, $Final) }
}
