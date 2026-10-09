<#
.SYNOPSIS
  Helper (dot-source only). Reads the Crystal Reports Designer "My Connections" list
  of the CURRENT Windows user. READ-ONLY: never writes the registry or the XML files.

  Where Designer keeps "My Connections" (checked 2026-10-08 on CR 2016 SP5):
    HKCU:\Software\SAP BusinessObjects\Suite XI 4.0\Crystal Reports\Crystal Data Source History
      file1 .. fileN = full path of an XML file (usually <My Documents>\History\DataSourceN.xml)
    Each XML file = one serialized RAS ConnectionInfo (CrystalReports.ConnectionInfo).
    The name shown in the list = attribute "DBE_Item_Description" (Designer appends _1, _2 ...
    when the same name already exists).

  Deserialization: RAS XmlSerializer (CrystalDecisions.ReportAppServer.XmlSerialize) with an
  object creator backed by RAS ObjectFactory. If that fails, falls back to plain XML parsing.
#>

$script:CrHistoryKey = 'HKCU:\Software\SAP BusinessObjects\Suite XI 4.0\Crystal Reports\Crystal Data Source History'
$script:CrRasReady   = $null    # $null = not tried, $true / $false

function Initialize-CrRasSerializer {
    if ($null -ne $script:CrRasReady) { return $script:CrRasReady }
    $script:CrRasReady = $false
    try {
        $names = 'CrystalDecisions.ReportAppServer.DataDefModel',
                 'CrystalDecisions.ReportAppServer.XmlSerialize',
                 'CrystalDecisions.ReportAppServer.ObjectFactory'
        $locs = @()
        foreach ($n in $names) {
            $a = [System.Reflection.Assembly]::LoadWithPartialName($n)
            if (-not $a) { throw "assembly not found: $n" }
            $locs += $a.Location
        }
        if (-not ('CrHistObjectCreator' -as [type])) {
            $src = @'
using System; using System.Runtime.InteropServices;
public class CrHistObjectCreator : CrystalDecisions.ReportAppServer.XmlSerialize.ICRXmlObjectCreator {
  CrystalDecisions.ReportAppServer.ObjectFactory.ObjectFactoryClass f =
      new CrystalDecisions.ReportAppServer.ObjectFactory.ObjectFactoryClass();
  public void CreateObject(string name, string ver, ref Guid iid, out IntPtr ppv) {
    object o = f.CreateObject(name);
    IntPtr unk = Marshal.GetIUnknownForObject(o);
    try { int hr = Marshal.QueryInterface(unk, ref iid, out ppv); if (hr != 0) Marshal.ThrowExceptionForHR(hr); }
    finally { Marshal.Release(unk); }
  }
}
'@
            Add-Type -TypeDefinition $src -ReferencedAssemblies $locs -ErrorAction Stop
        }
        $script:CrRasReady = $true
    } catch {
        $script:CrRasLastError = $_.Exception.Message
    }
    return $script:CrRasReady
}

# Returns an ordered dictionary  name -> string value  of the connection attributes,
# plus '__Method' = 'RAS' or 'XML'. Throws if the file cannot be read at all.
function Read-CrConnectionFile([string]$file) {
    $xml = [System.IO.File]::ReadAllText($file)
    $props = [ordered]@{}
    if (Initialize-CrRasSerializer) {
        try {
            $ser = New-Object CrystalDecisions.ReportAppServer.XmlSerialize.XmlSerializerClass
            $ser.ObjectCreater = New-Object CrHistObjectCreator
            $ci = $ser.CreateObjectFromString($xml)
            foreach ($k in $ci.Attributes.PropertyIDs) { $props[[string]$k] = [string]$ci.Attributes.Item($k) }
            $props['__Method'] = 'RAS'
            return $props
        } catch {
            $props = [ordered]@{}
        }
    }
    $doc = New-Object System.Xml.XmlDocument
    $doc.LoadXml($xml)
    $ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
    $ns.AddNamespace('r', 'http://www.crystaldecisions.com/report')
    foreach ($p in $doc.SelectNodes('/r:CrystalReports.ConnectionInfo/r:Attributes/r:Property', $ns)) {
        $n = $p.SelectSingleNode('r:Name', $ns); $v = $p.SelectSingleNode('r:Value', $ns)
        if ($n) { $props[$n.InnerText] = $(if ($v) { $v.InnerText } else { '' }) }
    }
    if ($props.Count -eq 0) { throw "no connection attributes found in $file" }
    $props['__Method'] = 'XML'
    return $props
}

function Get-CrDbTypeForDll([string]$dll) {
    switch ($dll.ToLowerInvariant()) {
        'crdb_odbc.dll' { return 'ODBC (RDO)' }
        'crdb_ado.dll'  { return 'OLE DB (ADO)' }
        default         { return '' }    # not supported by this script (no guessing)
    }
}

# Turn the raw attribute dictionary into a normalized entry.
function ConvertTo-CrConnEntry($props, [string]$file, [int]$histIndex) {
    $g = { param($k) if ($props.Contains($k)) { [string]$props[$k] } else { '' } }
    $dll    = & $g 'Database DLL'
    $type   = Get-CrDbTypeForDll $dll
    $isAdo  = ($dll -ieq 'crdb_ado.dll')
    $server = if ($isAdo) { & $g 'Data Source' } else { $(if (& $g 'Server') { & $g 'Server' } else { & $g 'DSN' }) }
    $db     = if ($isAdo) { & $g 'Initial Catalog' } else { & $g 'Database' }
    $user   = & $g 'User ID'
    $cs     = & $g 'Connection String'
    $driver = ''
    if ($isAdo) { $driver = & $g 'Provider' }
    elseif ($cs -match '(?i)(?:^|;)\s*DRIVER\s*=\s*\{?([^};]*)') { $driver = $Matches[1] }
    elseif (& $g 'DSN') { $driver = 'DSN ' + (& $g 'DSN') }
    $note = ''
    if ($dll -ieq 'crdb_query.dll') { $note = 'Command history entry (not a database connection)' }
    elseif (-not $type)             { $note = "database DLL '$dll' is not supported by this script" }
    elseif (-not $server)           { $note = 'no server in this connection' }
    return [pscustomobject]@{
        HistIndex = $histIndex
        File      = $file
        Name      = & $g 'DBE_Item_Description'
        Dll       = $dll
        DbType    = $type
        Driver    = $driver
        Server    = $server
        Database  = $db
        User      = $user
        Usable    = (-not $note)
        Note      = $note
        Method    = & $g '__Method'
        Props     = $props
    }
}

# All "My Connections" entries of the current Windows user, in registry order (file1, file2 ...).
function Get-CrHistoryEntries {
    $list = New-Object System.Collections.ArrayList
    if (-not (Test-Path -LiteralPath $script:CrHistoryKey)) { return }
    $item = Get-ItemProperty -LiteralPath $script:CrHistoryKey
    $vals = @($item.PSObject.Properties | Where-Object { $_.Name -match '^file(\d+)$' } |
              Sort-Object { [int]($_.Name.Substring(4)) })
    foreach ($v in $vals) {
        $idx  = [int]($v.Name.Substring(4))
        $file = [string]$v.Value
        if (-not $file) { continue }
        if (-not [System.IO.File]::Exists($file)) {
            [void]$list.Add([pscustomobject]@{ HistIndex=$idx; File=$file; Name=''; Dll=''; DbType=''; Driver='';
                Server=''; Database=''; User=''; Usable=$false; Note='file not found'; Method=''; Props=$null })
            continue
        }
        try {
            $p = Read-CrConnectionFile $file
            [void]$list.Add((ConvertTo-CrConnEntry $p $file $idx))
        } catch {
            [void]$list.Add([pscustomobject]@{ HistIndex=$idx; File=$file; Name=''; Dll=''; DbType=''; Driver='';
                Server=''; Database=''; User=''; Usable=$false; Note="cannot read: $($_.Exception.Message)"; Method=''; Props=$null })
        }
    }
    return $list.ToArray()
}
