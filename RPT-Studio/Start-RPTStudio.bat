@echo off
rem RPT Studio launcher - starts server.ps1 (64-bit) and opens the browser
set "PSEXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe" set "PSEXE=%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
cd /d "%~dp0"
"%PSEXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1" %*
if errorlevel 1 pause
