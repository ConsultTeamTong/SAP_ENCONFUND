@echo off
REM ============================================================
REM  SHARED CONNECTION SETTINGS  (single file for Export + Import)
REM ------------------------------------------------------------
REM  Used by ALL wrappers in C:\Tool:
REM    RunExport.bat  RunImport.bat  RunRollback.bat
REM    RunDeleteNonSystem.bat  TestConnect.bat
REM ============================================================

REM  DBENGINE: MSSQL or HANA  (selects Scripts\DB-<engine>.ps1)
REM    MSSQL -> SERVER = host (or host\instance), COMPANYDB = database name
REM    HANA  -> SERVER = host:port (port = 3<inst>15, e.g. 30015),
REM             COMPANYDB = HANA schema (CASE-SENSITIVE, usually UPPERCASE),
REM             requires SAP HANA Client (hdbclient) installed.
set DBENGINE=HANA

set SERVER=10.21.100.31
set COMPANYDB=SBO_ENCONFUND
set DBUSER=SYSTEM
set DBPASSWORD=Enc0nfund

REM ------------------------------------------------------------
REM  RPTROOT: root folder of the .rpt files for IMPORT.
REM  Export writes to  ExportedFromSAP\<COMPANYDB>  (one folder per
REM  database, replaced on each export), and Import reads back from
REM  the SAME per-database folder -- so both stay in sync via COMPANYDB.
REM ------------------------------------------------------------
set RPTROOT=C:\Users\User\Documents\GitHub\Enconfund\Tool\ExportedFromSAP\%COMPANYDB%
