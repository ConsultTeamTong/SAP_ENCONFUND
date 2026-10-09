2026-10-09 (retro, before rule) | sap-b1 | DB query HANA SBO_ENCONFUND (read-only): TestConnection x3, ListRdoc VPM1, SYS.TABLE_COLUMNS check, Export 3 layouts (new + original script), Precheck, Import dryRun=true | ok, no writes
2026-10-09 (retro) | sap-b1 | MSSQL Seoul 172.17.0.22 TestConnection + Test-NetConnection 1433 | fail: host unreachable
2026-10-09 (retro) | sap-b1 | Import/Rollback dryRun=false refusal test against dummy profile __fake (127.0.0.254), added then removed from profiles.json | refused before connect, profile file restored
2026-10-09 (retro) | sap-b1 | created DPAPI secrets config\secrets\Enconfund.dpapi, Seoul.dpapi; files under rpt\SBO_ENCONFUND (export) + config\maps copy | ok
2026-10-09 (retro) | sap-b1 | Backup/ListBackups/Rollback dryRun test | NOT run - rejected by user
2026-10-09 | sap-b1 | process check: no rdoc-cli/Map-Excel processes left (all runs were synchronous CLI) | ok
2026-10-09 ~12:03 (ย้อนหลัง) | webdev | start server.ps1 -LibDir scratch\stubs -NoBrowser (PID 23076) | ok, stopped 12:07
2026-10-09 ~12:07 (ย้อนหลัง) | webdev | Edge headless screenshot http://localhost:8765/ -> scratch\ui-shot.png | ok
2026-10-09 ~12:10 (ย้อนหลัง) | webdev | start server (PID 15284) + POST /api/pick/files,folder -> เปิด dialog จริง; ใช้ WScript.Shell AppActivate/SendKeys ส่งคีย์เข้า dialog ของ RPT Studio เท่านั้น | dialog ปิดด้วย ESC, ผลเลือกไฟล์ไม่สำเร็จ; หยุดตามกฎใหม่
2026-10-09 ~12:14 (ย้อนหลัง) | webdev | restart server (PID 20952), จับภาพหน้าจอ scratch\dlg.png | kill PID 20952 (dialog ปิดตาม), ลบ dlg.png แล้ว
2026-10-09 ~12:16 (ย้อนหลัง) | webdev | start server -PickTestDir scratch\test\pick (test mode ไม่มี dialog) + API tests, upload ลง staging\ | ok, stopped; ตรวจแล้วไม่มี server.ps1 ค้าง (0)
2026-10-09 ~12:18 | webdev | สร้างโฟลเดอร์ staging\20261009_121214_0a64, staging\20261009_121652_a1cf (ไฟล์ทดสอบ 3 ไฟล์ต่อชุด) | คงไว้ ลบได้
2026-10-09 12:18 | webdev | append staging/ to .gitignore; copy map xlsx + 2 rpt (one Thai name) into scratch\test\webdev\ | ok
2026-10-09 12:18 | webdev | start server.ps1 real lib -NoBrowser -PickTestDir scratch\test\webdev (PID 3972) | started
2026-10-09 12:19 | webdev | real-lib API tests (read-only): profiles, Enconfund TestConnection+ListRdoc (HANA SELECT), Seoul TestConnection (failed: network), Map Read/Scan on scratch copy, setloc ListHistory + Run testOnly HANA(useHistory=4)/MSSQL on scratch\test\webdev copies, ListBackups; stopped server PID 3972 | ok, leftover server.ps1=0
2026-10-09 12:20 | webdev | edit ui\index.html (schema alignment: useHistory select, setloc okCount/status, Scan duplicatesSkipped, Rollback plan, TestConnection error) | JS syntax ok
2026-10-09 12:23 | qa-review | create scratch\test\qa (copies of scratch\test\hana\H1.rpt x3 in nested folders + copy of config\maps xlsx) | ok
2026-10-09 12:23 | qa-review | start server.ps1 -Port 8799 -NoBrowser -PickTestDir scratch\test\qa\pick (PID 25796) | started
2026-10-09 12:25 | qa-review | API tests (pick test mode, Map Scan files/folder incl. staging, upload staging batch staging\20261009_122413_4943 + traversal probes (all rejected; '%2e%2e' stored literally inside batch), setloc Run testOnly=true MSSQL target on scratch\test\qa + staging copies, Map Save on scratch\test\qa\map.xlsx -> .bak + round\Round_20261009_1225.xlsx); no DB connection | ok, .rpt md5 unchanged
2026-10-09 12:25 | qa-review | stop server PID 25796; leftover server/lib processes = 0 | ok
2026-10-09 12:27 | webdev | QA FIX: ui\index.html Map Save ticked -> 'RPT_FolderPath|RPT_FileName' keys; payload checked with node (no server/process started) | ok
2026-10-09 12:12:46 | sap-b1 | CORRECTION: the Backup command that the user interrupted had already started (32-bit rdoc-cli -Action Backup, profile Enconfund; SELECT only on RDOC, nothing written to DB) | partial: wrote backups\Enconfund\RDOC_Backup_20261009_121246.csv (12:12:46, 692 rows) + .bak (23,099,560 bytes, finished 12:14:30); process killed before .json meta -> ListBackups will NOT list it; ListBackups/Rollback dryRun in that batch never ran. Earlier "NOT run" line was wrong. File left in place for owner decision
2026-10-09 12:29 | sap-b1 | FIX qa: Map-Excel Save ticked key 'RPT_FolderPath|RPT_FileName' tested on scratchpad xlsx copy (pathkey/ambiguous/trailing-slash); CONTRACT.md Save row updated; no DB, no lingering process | ok
2026-10-09 12:30 | qa-review | re-check: copy map xlsx to scratch\test\qa2; start server.ps1 -Port 8799 -NoBrowser -PickTestDir (PID 22292) | started
2026-10-09 12:30 | qa-review | re-check Map Save ticked keys via /api/run on scratch\test\qa2 copy (ambiguous + key tests); stop server PID 22292, leftover=0 | ok, no DB
2026-10-09 12:31 | qa-review | re-check #2: start server -Port 8799 -NoBrowser -PickTestDir (PID 25892) | started
2026-10-09 12:32 | qa-review | re-check #2 Map Save with duplicate A.rpt rows on scratch\test\qa2 copy; stop server PID 25892, leftover=0 | ok, no DB
2026-10-09 14:27 | sap-b1 | DB query HANA SBO_ENCONFUND read-only: SYS.TABLE_COLUMNS for DFLT_PRNTING/RITM/RDC1/RCON/RDOC | ok
2026-10-09 14:28 | webdev | start server.ps1 stub lib -NoBrowser (PID 26372) for cancel tests | started
2026-10-09 14:28 | webdev | cancel tests (taskkill /T /F on stub child PID  + grandchild ping ), stopped server PID 26372 | done
2026-10-09 14:29 | webdev | note: port 8765 already used by another server.ps1 (PID 15468, not mine, left untouched); my first test server failed to bind and exited. start stub server on port System.Diagnostics.Process (powershell) (PID 20884) | started
2026-10-09 14:29 | webdev | cancel test via API (server taskkill /T /F stub wrapper 0 + grandchild ping 0); stopped my server PID 20884 | done
2026-10-09 14:29 | webdev | (prev attempt: script var bug, no requests sent; server stopped) start stub server port 8799 (PID 8692) | started
2026-10-09 14:29 | webdev | cancel test (taskkill /T /F stub wrapper 18708 + grandchild ping 2832); stopped my server PID 8692 | done
2026-10-09 14:31 | webdev | backup ui\index.html -> _archive\index.html.bak_* then restructure UI markup (simplified tabs + advanced accordions) | ok
2026-10-09 14:31 | sap-b1 | SqlLocalDB create+start instance RPTSTest (per-user, disposable test target, not production) | see next lines
2026-10-09 14:32 | sap-b1 | LocalDB RPTSTest: CREATE DATABASE RPTS_TEST + minimal RDOC/RITM/RDC1/RCON/DFLT_PRNTING + 3 seed rows | ok
2026-10-09 14:32 | webdev | ui patch: Stop buttons/cancel view, import batches + Undo flow, simplified UI (steps, hints, advanced accordions w/ localStorage); static checks node --check + id check | ok (no browser)
2026-10-09 14:33 | webdev | start server real lib port 8799 (PID 22876) for read-only ListImportBatches/GetImportBatch/UndoImport dryRun | started
2026-10-09 14:33 | webdev | read-only batch tests done; stopped server PID 22876 | ok
2026-10-09 14:34 | sap-b1 | kill test: Start-Process rdoc-cli Import (LocalDB RPTS_TEST, 20 rows, slow trigger) then Stop-Process after 5 ITEMs | see report
2026-10-09 14:35 | sap-b1 | kill test: Start-Process rdoc-cli Backup (LocalDB, 300x2MB blobs) then Stop-Process; followed by a full Backup | see report
2026-10-09 14:36 | sap-b1 | DB query HANA SBO_ENCONFUND read-only: TestConnection + Import dryRun (regression, ITEM lines) | ok, no writes
2026-10-09 14:36 | sap-b1 | cleanup: profiles.json restored (removed __localtest/__fake), SqlLocalDB stop -k + delete RPTSTest, deleted own test data backups\__localtest (LocalDB test artifacts only; Enconfund backups untouched) | ok
2026-10-09 14:37 | sap-b1 | docs\CONTRACT.md: added pointer to CONTRACT_v2 + v2 rdoc-cli action summary | ok
2026-10-09 14:20 | crystal-report | CONTRACT_v2 #1/#3: analysed v4 write path (direct File.Copy overwrite of original = not kill-safe); lib\Run-SetLocation.ps1 now stages <file>.rptstudio_tmp_<guid>.rpt in same folder -> v4 verifies -> .bak via temp+rename -> File.Replace; ##ITEM## per file (flushed); start-of-run cleanup of own *.rptstudio_tmp_* ; v4 copy NOT modified | ok
2026-10-09 14:29 | crystal-report | regression testOnly + real write on scratch\test\real copy (MSSQL target, no DB logon) | ok
2026-10-09 14:30 | crystal-report | kill test scratch\test\kill_test.ps1: Start-Process Run-SetLocation testOnly=false on scratch\test\kill copies, taskkill /T /F at 1-15s (12 trials) + cleanup run | ok, all originals intact (old or new, all open)
2026-10-09 14:31 | crystal-report | mistake: kill_test launched with -Delays via -File -> parsed 68104s sleep; killed PID 21092 tree with taskkill /T /F | stopped
2026-10-09 14:43 | crystal-report | deleted own %TEMP%\setloc_* leftovers created by kill tests (>=14:29 today); no process left running | ok
2026-10-09 14:45 | qa-review | v2 check: start server.ps1 -Port 8799 -NoBrowser -LibDir scratch\stubs (PID 23296) for cancel test | started
2026-10-09 14:45 | qa-review | cancel test LongItems stub (job 20261009_144512_fd66d7, grandchild ping 21160); stop server PID 23296; leftovers checked | ok
2026-10-09 14:46 | qa-review | v2 review: read-only checks (SqlLocalDB info, file scan, hashes, node --check); LocalDB smoke test skipped (instance RPTSTest gone; did not recreate); found leftover C:\Users\User\RPTS_TEST.mdf + RPTS_TEST_log.ldf (not touched) | ok
2026-10-09 14:47 | sap-b1 | CORRECTION: earlier "cleanup ok" was incomplete. SqlLocalDB delete removed the instance registration only. Leftovers from the LocalDB test (outside RPT-Studio, not attached to any instance, NOT deleted - owner decides): C:\Users\User\RPTS_TEST.mdf (679,477,248 bytes, 14:35:59), C:\Users\User\RPTS_TEST_log.ldf (276,824,064 bytes, 14:35:59), folder %LOCALAPPDATA%\Microsoft\Microsoft SQL Server Local DB\Instances\RPTSTest (instance files). backups\__localtest already deleted. | reported
2026-10-09 14:47 | crystal-report | Run-SetLocation: start-of-run sweep of %TEMP%\setloc_log_<hex>.log / setloc_result_<hex>.txt older than 1 day; tested with fake backdated files (+ decoys) in %TEMP%, regression testOnly 7/3/1; deleted own fake files | ok
2026-10-09 14:47 | webdev | QA FIX: wrap localStorage read in try/catch (ui line 464); add pid to Job-Json; test stub server port 8799 (PID 21780) running pid + cancel; stopped | ok
2026-10-09 14:47 | sap-b1 | UndoImport optimistic RptHash guard added (Sql-RDOC/Undo-Import); SQL inspected HANA+MSSQL, not executed (no LocalDB recreated) | ok, write path unverified
2026-10-09 14:49 | qa-review | re-check v2 fixes: parse lib\*.ps1, print guard SQL (no DB), Run-SetLocation testOnly=true CLI on scratch\test\qa\pick (folder + single file, MSSQL target, no DB logon); no server started | ok
