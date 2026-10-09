# Secrets.ps1 - DPAPI (CurrentUser) helpers for RPT Studio. Dot-source this file.
# Passwords live in config\secrets\<profile>.dpapi ; never print them.
Add-Type -AssemblyName System.Security

$script:RPTS_Root = Split-Path -Parent $PSScriptRoot
$script:RPTS_SecretDir = Join-Path $script:RPTS_Root 'config\secrets'

function Get-SecretPath([string]$Name) {
    if ([string]::IsNullOrWhiteSpace($Name)) { throw 'profile name is empty' }
    if ($Name -match '[\/:*?"<>|]') { throw "invalid profile name: $Name" }
    Join-Path $script:RPTS_SecretDir ($Name + '.dpapi')
}

function Set-ProfilePassword {
    param([Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)][AllowEmptyString()][string]$Password)
    if (-not (Test-Path $script:RPTS_SecretDir)) { New-Item -ItemType Directory -Force $script:RPTS_SecretDir | Out-Null }
    $bytes = [Text.Encoding]::UTF8.GetBytes($Password)
    $enc = [Security.Cryptography.ProtectedData]::Protect($bytes, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
    [IO.File]::WriteAllText((Get-SecretPath $Name), [Convert]::ToBase64String($enc))
}

function Test-ProfilePassword([string]$Name) { Test-Path (Get-SecretPath $Name) }

# Returns plaintext string. Throws if missing / cannot decrypt (other user).
function Get-ProfilePassword {
    param([Parameter(Mandatory)][string]$Name)
    $p = Get-SecretPath $Name
    if (-not (Test-Path $p)) { throw "no stored password for profile '$Name'" }
    $enc = [Convert]::FromBase64String(([IO.File]::ReadAllText($p)).Trim())
    $bytes = [Security.Cryptography.ProtectedData]::Unprotect($enc, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
    [Text.Encoding]::UTF8.GetString($bytes)
}

function Remove-ProfilePassword([string]$Name) { $p = Get-SecretPath $Name; if (Test-Path $p) { Remove-Item $p -Force } }
