<#
.SYNOPSIS
    Add a User-Defined Field (UDF) to SAP B1 table OCRB (Business Partner Bank Accounts)
    via the DI API. Required because B1's "User-Defined Fields - Management" UI does not
    expose the OCRB node, so UDFs cannot be added through the client.

.DESCRIPTION
    Connects to SAP Business One company SBO_ENCONFUND_BUDGET (HANA) using the DI API
    (SAPbobsCOM) and creates a UserFieldsMD record on table OCRB.

    Must be run on a Windows host that has the SAP B1 Client Tools installed (DI API
    assemblies registered). In the SLD/Enconfund environment, that host is the RDP box
    10.21.100.32 (user sldsupport01).

    DO NOT modify the HANA schema directly with ALTER TABLE — DI API is the supported
    path. (See CINF.Version incident on SBO_FIXEDASSET for why direct DDL is dangerous.)

.PARAMETER FieldName
    Logical UDF name WITHOUT the "U_" prefix. B1 will store it as U_<FieldName>.
    Max 18 chars, [A-Za-z0-9_].

.PARAMETER Description
    Human-readable label shown in the B1 UI. Thai text supported.

.PARAMETER Type
    Field type. One of: Alpha | Numeric | Date | Memo | Float | Price | Quantity
    (Alpha covers most string fields, Memo for long text > 254 chars.)

.PARAMETER Size
    EditSize in characters (Alpha) or precision/length (Numeric). Ignored for Date.
    Default: 100 for Alpha, 11 for Numeric.

.PARAMETER Server
    HANA server:port. Default 10.21.100.31:30015.

.PARAMETER CompanyDB
    Target company DB. Default SBO_ENCONFUND_BUDGET.

.PARAMETER DbUser
    HANA DB user. Default SYSTEM.

.PARAMETER DbPassword
    HANA DB password. Default Enc0nfund.

.PARAMETER B1User
    B1 application user. Default manager.

.PARAMETER B1Password
    B1 application user password. ASK USER — script will prompt if not supplied.

.EXAMPLE
    .\Add-UDF-OCRB.ps1 -FieldName "RemarkAP" -Description "หมายเหตุ AP" -Type Alpha -Size 100

.EXAMPLE
    .\Add-UDF-OCRB.ps1 -FieldName "ApproveDate" -Description "วันที่อนุมัติ" -Type Date

.NOTES
    Author       : Khim (SLD เลขา) for waranchit@sala-daeng.com
    Target host  : 10.21.100.32 (sldsupport01) — RDP box with B1 Client Tools
    Target DB    : SBO_ENCONFUND_BUDGET on HANA 10.21.100.31
    Date         : 2026-05-17
    Reference    : SAPbobsCOM.UserFieldsMD, BoFieldTypes / BoFldSubTypes enums.

    Verify after run:
      1. Login to B1, open Business Partner > Business Partner Master Data
      2. Open any BP, go to "Payment Terms" tab, click "Bank Accounts"
      3. Right-click row header > Form Settings > "Table Format" tab
      4. U_<FieldName> should be listed and toggleable as visible
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^[A-Za-z][A-Za-z0-9_]{0,17}$')]
    [string]$FieldName,

    [Parameter(Mandatory=$true)]
    [string]$Description,

    [ValidateSet('Alpha','Numeric','Date','Memo','Float','Price','Quantity')]
    [string]$Type = 'Alpha',

    [int]$Size = 0,

    [string]$Server      = '10.21.100.31:30015',
    [string]$CompanyDB   = 'SBO_ENCONFUND_BUDGET',
    [string]$DbUser      = 'SYSTEM',
    [string]$DbPassword  = 'Enc0nfund',
    [string]$B1User      = 'manager',
    [string]$B1Password
)

$ErrorActionPreference = 'Stop'

function Write-Step($msg) { Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-OK  ($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Err ($msg) { Write-Host "[X] $msg" -ForegroundColor Red }

# ---------------------------------------------------------------
# 1. Pre-flight: SAPbobsCOM assembly
# ---------------------------------------------------------------
Write-Step "Pre-flight: locate SAPbobsCOM assembly"

$sapbobscom = $null
$gacRoots = @(
    "$env:WINDIR\assembly\GAC_MSIL\SAPbobsCOM",
    "$env:WINDIR\Microsoft.NET\assembly\GAC_MSIL\SAPbobsCOM"
)
foreach ($root in $gacRoots) {
    if (Test-Path $root) {
        $found = Get-ChildItem -Path $root -Recurse -Filter 'Interop.SAPbobsCOM.dll' -ErrorAction SilentlyContinue |
                 Select-Object -First 1
        if ($found) { $sapbobscom = $found.FullName; break }
    }
}

if (-not $sapbobscom) {
    # Fallback: try common SAP install paths
    $candidates = @(
        'C:\Program Files (x86)\SAP\SAP Business One DI API\Interop.SAPbobsCOM.dll',
        'C:\Program Files\SAP\SAP Business One DI API\Interop.SAPbobsCOM.dll',
        'C:\Program Files (x86)\SAP\SAP Business One Client\Interop.SAPbobsCOM.dll',
        'C:\Program Files\SAP\SAP Business One Client\Interop.SAPbobsCOM.dll'
    )
    foreach ($c in $candidates) { if (Test-Path $c) { $sapbobscom = $c; break } }
}

if (-not $sapbobscom) {
    Write-Err "Interop.SAPbobsCOM.dll not found. Install SAP B1 Client Tools / DI API on this host."
    Write-Err "Expected on: 10.21.100.32 (sldsupport01)."
    exit 2
}
Write-OK "SAPbobsCOM at: $sapbobscom"

Add-Type -Path $sapbobscom

# ---------------------------------------------------------------
# 2. Prompt for B1 password if missing
# ---------------------------------------------------------------
if (-not $B1Password) {
    $sec = Read-Host -Prompt "Enter B1 password for user '$B1User'" -AsSecureString
    $B1Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}

# ---------------------------------------------------------------
# 3. Map -Type to BoFieldTypes / BoFldSubTypes
# ---------------------------------------------------------------
# Enum reference (SAPbobsCOM):
#   db_Alpha    = 0
#   db_Memo     = 1
#   db_Numeric  = 2  (integer)
#   db_Date     = 3
#   db_Float    = 4  (subtypes: st_None / st_Price / st_Quantity / st_Rate / st_Sum / st_Measurement / st_Percentage)
$typeMap = @{
    'Alpha'    = @{ FieldType = 0; SubType = 0; DefaultSize = 100 }   # db_Alpha
    'Memo'     = @{ FieldType = 1; SubType = 0; DefaultSize = 0   }   # db_Memo (size ignored)
    'Numeric'  = @{ FieldType = 2; SubType = 0; DefaultSize = 11  }   # db_Numeric (integer)
    'Date'     = @{ FieldType = 3; SubType = 0; DefaultSize = 0   }   # db_Date
    'Float'    = @{ FieldType = 4; SubType = 0; DefaultSize = 0   }   # db_Float / st_None
    'Price'    = @{ FieldType = 4; SubType = 4; DefaultSize = 0   }   # db_Float / st_Price
    'Quantity' = @{ FieldType = 4; SubType = 2; DefaultSize = 0   }   # db_Float / st_Quantity
}
$tm = $typeMap[$Type]
if ($Size -le 0) { $Size = $tm.DefaultSize }

# ---------------------------------------------------------------
# 4. Connect to company
# ---------------------------------------------------------------
Write-Step "Connect to SAP B1 company: $CompanyDB @ $Server"

$company = New-Object -ComObject SAPbobsCOM.Company
$company.Server          = $Server
$company.CompanyDB       = $CompanyDB
$company.DbServerType    = [SAPbobsCOM.BoDataServerTypes]::dst_HANADB  # = 10
$company.DbUserName      = $DbUser
$company.DbPassword      = $DbPassword
$company.UserName        = $B1User
$company.Password        = $B1Password
$company.UseTrusted      = $false
$company.language        = [SAPbobsCOM.BoSuppLangs]::ln_English

$rc = $company.Connect()
if ($rc -ne 0) {
    $errCode = 0; $errMsg = ''
    $company.GetLastError([ref]$errCode, [ref]$errMsg)
    Write-Err "Connect failed. rc=$rc code=$errCode msg=$errMsg"
    exit 3
}
Write-OK "Connected. SessionID=$($company.GetCompanyService().GetType().Name)"

try {
    # ---------------------------------------------------------------
    # 5. Build UserFieldsMD record
    # ---------------------------------------------------------------
    Write-Step "Define UDF: OCRB.U_$FieldName  ($Type, size=$Size)"

    $udf = $company.GetBusinessObject([SAPbobsCOM.BoObjectTypes]::oUserFields)
    $udf.TableName   = 'OCRB'
    $udf.Name        = $FieldName          # B1 prepends "U_" automatically
    $udf.Description = $Description
    $udf.Type        = [int]$tm.FieldType
    if ($tm.SubType -ne 0) { $udf.SubType = [int]$tm.SubType }
    if ($Size -gt 0)       { $udf.EditSize = [int]$Size }

    # ---------------------------------------------------------------
    # 6. Add — handle "already exists"
    # ---------------------------------------------------------------
    Write-Step "Add UDF via DI API..."
    $addRc = $udf.Add()
    if ($addRc -ne 0) {
        $errCode = 0; $errMsg = ''
        $company.GetLastError([ref]$errCode, [ref]$errMsg)
        if ($errMsg -match 'exists' -or $errCode -eq -2035) {
            Write-Warn "UDF U_$FieldName already exists on OCRB — nothing to do."
            exit 0
        }
        Write-Err "Add() failed. rc=$addRc code=$errCode msg=$errMsg"
        exit 4
    }

    Write-OK "Created OCRB.U_$FieldName  ($Description)"
    Write-Host ""
    Write-Host "Verify in B1:" -ForegroundColor White
    Write-Host "  BP Master Data > Payment Terms tab > Bank Accounts > Form Settings"
    Write-Host "  U_$FieldName should appear and be toggleable as visible."
}
finally {
    if ($company.Connected) { $null = $company.Disconnect() }
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($company) | Out-Null
    [GC]::Collect(); [GC]::WaitForPendingFinalizers()
}
