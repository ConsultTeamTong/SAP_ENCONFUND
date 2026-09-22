@echo off
chcp 65001 >nul
REM ============================================================
REM  Export Crystal Layouts FROM SAP B1 RDOC -> .rpt files
REM  Reverse of RunImport.bat. Pulls RDOC.Template blobs out of
REM  SAP and writes them as <DocName>.rpt on disk, so you have
REM  source files to edit (e.g. Set-DatasourceLocation) and then
REM  re-import.
REM
REM  Connection settings are in _settings.bat (shared, gitignored).
REM ============================================================
if not exist "%~dp0_settings.bat" (
    echo ERROR: _settings.bat not found.
    echo Copy _settings.bat.example to _settings.bat and edit it.
    pause
    exit /b 1
)
call "%~dp0_settings.bat"

REM ============================================================
REM  OUTDIR: where the .rpt files are written.
REM  A separate subfolder is created per Database (COMPANYDB), e.g.
REM    C:\Tool\ExportedFromSAP\SBO_SDA_key
REM  If that folder already exists it is REPLACED (wiped) before the
REM  export so each run is a clean snapshot of that database.
REM ============================================================
set OUTBASE=C:\Tool\ExportedFromSAP
set OUTDIR=%OUTBASE%\%COMPANYDB%

if exist "%OUTDIR%" (
    echo Folder for %COMPANYDB% already exists -- replacing:
    echo   %OUTDIR%
    rd /s /q "%OUTDIR%"
)
mkdir "%OUTDIR%" >nul 2>&1

REM ============================================================
REM  SYSTEMTOO: include SAP system layouts too?
REM    (leave empty) = skip system layouts (only user-edited)
REM    -SystemToo    = include everything
REM ============================================================
set SYSTEMTOO=

if "%DBENGINE%"=="" set DBENGINE=MSSQL

REM HANA ODBC driver is 32-bit -> use 32-bit PowerShell for HANA
set "PS=powershell.exe"
if /I "%DBENGINE%"=="HANA" set "PS=%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"

echo ============================================
echo  Export SAP B1 Layouts -> .rpt
echo  Engine   : %DBENGINE%
echo  Server   : %SERVER%
echo  Database : %COMPANYDB%
echo  OutDir   : %OUTDIR%
echo ============================================
echo.

set "FILTERDOC="
set /p FILTERDOC=Filter by DocName keyword (empty = ALL):

set "FILTERTYPE="
set /p FILTERTYPE=Filter by TypeCode e.g. INV2 (empty = ALL):

set "FARG="
if not "%FILTERDOC%"==""  set FARG=%FARG% -FilterDocName "%FILTERDOC%"
if not "%FILTERTYPE%"=="" set FARG=%FARG% -FilterTypeCode "%FILTERTYPE%"

echo.
echo Exporting ...
echo.

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Scripts\Export-RDOCToRpt.ps1" ^
    -Server "%SERVER%" ^
    -CompanyDB "%COMPANYDB%" ^
    -DBUser "%DBUSER%" ^
    -DBPassword "%DBPASSWORD%" ^
    -DBEngine "%DBENGINE%" ^
    -OutDir "%OUTDIR%" ^
    %FARG% %SYSTEMTOO%

echo.
echo ============================================
echo  Done. Files in: %OUTDIR%
echo  Index map     : %OUTDIR%\_ExportIndex.csv
echo ============================================
pause
