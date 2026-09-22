@echo off
chcp 65001 >nul
REM ============================================================
REM  Test SQL connection to SAP B1 Company DB
REM  Connection settings are in _settings.bat (shared, gitignored).
REM ============================================================
if not exist "%~dp0_settings.bat" (
    echo ERROR: _settings.bat not found.
    echo Copy _settings.bat.example to _settings.bat and edit it.
    pause
    exit /b 1
)
call "%~dp0_settings.bat"
if "%DBENGINE%"=="" set DBENGINE=MSSQL

REM HANA ODBC driver is 32-bit -> use 32-bit PowerShell for HANA
set "PS=powershell.exe"
if /I "%DBENGINE%"=="HANA" set "PS=%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Scripts\Test-SQLConnect.ps1" ^
    -Server "%SERVER%" ^
    -CompanyDB "%COMPANYDB%" ^
    -DBUser "%DBUSER%" ^
    -DBPassword "%DBPASSWORD%" ^
    -DBEngine "%DBENGINE%"

echo.
pause
