@echo off
chcp 65001 >nul
REM ============================================================
REM  Import Crystal Layouts to SAP B1 (SQL Direct)
REM  Reads the per-database export index directly:
REM      %RPTROOT%\_ExportIndex.csv   (no .xlsx map needed)
REM  Connection settings are in _settings.bat (shared).
REM
REM  Choose at runtime:
REM    1 = Import ALL rows from the index
REM    2 = Import by KEYWORD (filter by RPT_FileName, loop)
REM ============================================================
if not exist "%~dp0_settings.bat" (
    echo ERROR: _settings.bat not found.
    pause
    exit /b 1
)
call "%~dp0_settings.bat"

REM AUTHOR: stored on NEW rows only (INSERT). Updates keep original Author.
set AUTHOR=manager

REM MODE: -DryRun = preview only / (empty) = real import
set MODE=

REM ONDUP: Update (overwrite) | Skip (insert new only) | Insert (allow dup)
set ONDUP=Update

setlocal enabledelayedexpansion
REM Resolve RPTROOT to absolute, then point at its export index
set "RPT=!RPTROOT!"
if not "!RPT:~1,1!"==":" set "RPT=%~dp0!RPT!"
set "MAPFILE=!RPT!\_ExportIndex.csv"

if not exist "!MAPFILE!" (
    echo ERROR: export index not found:
    echo   !MAPFILE!
    echo Run RunExport.bat for database %COMPANYDB% first.
    pause
    endlocal
    exit /b 1
)

echo ============================================
echo  SAP B1 Layout Import
echo  Server   : %SERVER%
echo  Database : %COMPANYDB%
echo  RptRoot  : !RPT!
echo  Index    : !MAPFILE!
echo  Mode     : %MODE% (empty=real run)
echo  OnDup    : %ONDUP%
echo ============================================
echo.
echo  Choose import mode:
echo    1. Import ALL rows
echo    2. Import by KEYWORD (filter by RPT_FileName, loop)
echo ============================================
set /p MODECHOICE=Enter 1 or 2:

if "%MODECHOICE%"=="1" goto IMPORT_ALL
if "%MODECHOICE%"=="2" goto IMPORT_KEYWORD
echo Invalid selection.
pause
endlocal
exit /b

:IMPORT_ALL
echo.
pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Scripts\Import_SQL_Direct.ps1" ^
    -Server "%SERVER%" ^
    -CompanyDB "%COMPANYDB%" ^
    -DBUser "%DBUSER%" ^
    -DBPassword "%DBPASSWORD%" ^
    -Author "%AUTHOR%" ^
    -MapFile "!MAPFILE!" ^
    -RptRoot "!RPT!" ^
    -UseFileNameAsDocName ^
    -OnDuplicate %ONDUP% ^
    %MODE%
goto END

:IMPORT_KEYWORD
echo.
:KEYWORD_LOOP
echo.
set "FILTER="
set /p FILTER=Type keyword (e.g. Sale Order) -- empty Enter to quit:
if "%FILTER%"=="" goto END
echo.
echo Importing rows matching "%FILTER%" ...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Scripts\Import_SQL_Direct.ps1" ^
    -Server "%SERVER%" ^
    -CompanyDB "%COMPANYDB%" ^
    -DBUser "%DBUSER%" ^
    -DBPassword "%DBPASSWORD%" ^
    -Author "%AUTHOR%" ^
    -MapFile "!MAPFILE!" ^
    -RptRoot "!RPT!" ^
    -FilterFileName "%FILTER%" ^
    -UseFileNameAsDocName ^
    -OnDuplicate %ONDUP% ^
    %MODE%
echo.
echo  Done. Type next keyword, or empty Enter to quit.
goto KEYWORD_LOOP

:END
endlocal
echo.
echo ============================================
echo  Done. Check log: %~dp0Import_SQL_Log.txt
echo ============================================
pause
