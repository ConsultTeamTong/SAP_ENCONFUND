@echo off
chcp 65001 >nul
setlocal

set "SCRIPT=C:\Users\User\Desktop\Extract-CrystalReport.ps1"
set "RPT_FOLDER=%~dp0"
set "OUTPUT_ROOT=%~dp0"
if "%RPT_FOLDER:~-1%"=="\" set "RPT_FOLDER=%RPT_FOLDER:~0,-1%"
if "%OUTPUT_ROOT:~-1%"=="\" set "OUTPUT_ROOT=%OUTPUT_ROOT:~0,-1%"

if not exist "%SCRIPT%" (
    echo [ERROR] Not found: %SCRIPT%
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -RptFolder "%RPT_FOLDER%" -OutputRoot "%OUTPUT_ROOT%" -FlatOutput

echo.
pause
