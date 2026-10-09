# RPT Studio - Interface Contract (shared by webdev / sap-b1 / crystal-report)

Plan: C:\Users\User\.claude\plans\c-users-user-desktop-set-datasourcelocat-cheerful-umbrella.md
**v2 addendum (overrides this file where they differ): docs\CONTRACT_v2_cancel_undo.md** - ##ITEM## progress lines, cancel, safe-on-kill, Import batch + UndoImport.
rdoc-cli v2 additions (implemented by sap-b1): Actions `ListImportBatches` {} -> {items:[{batchId,time,status,insertedCount,updatedCount,pendingDocCode,undone,profile}]}, `GetImportBatch` {batchId} -> {manifest (+effectiveStatus)}, `UndoImport` {batchId,dryRun,confirmDb,force?} -> {dryRun,plan,deleted,restored[,refused]};
Import (real) result adds `batchId`; ListBackups items add `complete` (false = .bak without .json, plus `warning`); status "running" whose process is gone is reported as "cancelled".
UndoImport real write is refused as a whole if any plan row is "refuse" (force only lifts the changed-after-import refusal; system layouts/already-undone are never forced).
Root: C:\Users\User\Documents\GitHub\RPT-Studio\  (originals in Desktop\Set-DatasourceLocation, Enconfund\Tool\Scripts, SBO_Seoul\Form-Layout\ImportLayouts are READ-ONLY sources; copy, never edit)

## Layout
```
RPT-Studio\
  Start-RPTStudio.bat        (webdev)  ASCII+CRLF, no BOM, no chcp
  server.ps1                 (webdev)  64-bit HttpListener http://localhost:8765/ (localhost only)
  ui\index.html              (webdev)  single file, Thai labels, no CDN
  lib\rdoc-cli.ps1           (sap-b1)  entry for all DB actions
  lib\DB-HANA.ps1 DB-MSSQL.ps1 Export-RDOCToRpt.ps1 Import-RDOC.ps1 Backup-RDOC.ps1 Rollback-RDOC.ps1   (sap-b1)
  lib\Map-Excel.ps1          (sap-b1)  entry for Excel map actions (64-bit, no DB)
  lib\Secrets.ps1            (sap-b1)  DPAPI helpers
  lib\Run-SetLocation.ps1    (crystal-report) entry, 64-bit
  lib\Set-DatasourceLocation.ps1, lib\CrConnections.ps1   (crystal-report; copied from Desktop v4)
  config\profiles.json       (sap-b1 owns schema)  NO passwords
  config\secrets\<profile>.dpapi   DPAPI (CurrentUser) encrypted password; folder gitignored
  jobs\<jobId>.log / <jobId>.json  (server creates)
  .gitignore                 config\secrets\, jobs\, *.bak_*
```

## Universal CLI convention (all lib entry scripts)
- Invoked: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File lib\<entry>.ps1 -Action <A> -ArgsFile <path-to-json>`
- Input = JSON file (UTF-8). stdout = human log lines (UTF-8). Last line MUST be: `##RESULT## <single-line JSON>` with at least `{"ok":true|false,"error":"...","data":{...}}`.
- Exit code 0 on ok, 1 on failure. Never prompt interactively. Never print passwords.
- Server picks bitness: rdoc-cli on HANA profile -> C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe ; MSSQL profile -> 64-bit ; Run-SetLocation -> 64-bit ; Map-Excel -> 64-bit.

## profiles.json (sap-b1 defines final; server/UI read via rdoc-cli Action ProfilesGet/ProfilesSave to avoid divergence)
```
{ "profiles":[ { "name":"Enconfund","engine":"HANA|MSSQL","server":"10.21.100.31","port":30015,
   "companyDb":"SBO_ENCONFUND","user":"SYSTEM","hasPassword":true,"author":"...","rptRoot":"...",
   "mapPath":"...xlsx","onDuplicate":"Update|Skip|Insert","dryRun":true,
   "locationTarget":{"engine":"HANA|MSSQL","server":"","database":"","user":"","dsn":""} } ] }
```
Passwords only via Action SetPassword (ArgsFile has plaintext transiently; the server deletes the file right after) -> stored DPAPI. profiles.json never has a password.

## rdoc-cli.ps1 -Action values (args JSON includes "profile":"<name>")
| Action | extra args | data returned |
|---|---|---|
| ProfilesGet | - | {profiles:[...]} |
| ProfilesSave | {profiles:[...]} | {} |
| SetPassword | {password} | {} |
| TestConnection | - | {server, db, rdocCount} |
| ListRdoc | {typeCode?, q?, includeSystem?:false} | {rows:[{DocCode,DocName,TypeCode,Author,IsSystem,Size}]} |
| Export | {docCodes:[...], outDir?} | {outDir, files:[{docCode,file,ok,msg}], indexCsv} (writes _ExportIndex.csv) |
| Precheck | {rows:[{file,folder,objectType,layoutName}]} | {rows:[{..., status:"New|Update|Skip|Error", reason}]} |
| Import | {rows:[...], onDuplicate, dryRun, backup:true} | {backupId, rows:[{..., result}], inserted, updated, skipped, errors} |
| Backup | - | {backupId, path} |
| ListBackups | - | {items:[...]} |
| Rollback | {backupId, docCodes:[...]} | {restored, deleted} |
Safety: Import/Rollback with dryRun=false requires args `"confirmDb":"<companyDb>"` equal to profile companyDb, else refuse. System layouts never touched.

## Map-Excel.ps1 -Action values
| Action | args | data |
|---|---|---|
| Read | {mapPath} | {rows:[{No,Module,RPT_FileName,RPT_FolderPath,SAP_Document,Header_Table,Line_Table,Object_Type,Form_MenuUID,LayoutName_Suggest,Note}]} |
| Scan | {mapPath, folder, indexCsv?} | {added:[rows with auto-filled Object_Type/LayoutName; flagged:true when '-' or unmapped], existing:n} |
| Save | {mapPath, rows:[...], ticked:["RPT_FolderPath\|RPT_FileName"...], roundDir} | {masterBackup, masterPath, roundFile} (Round_yyyyMMdd_HHmm.xlsx only ticked rows) |

Save `ticked` key = `RPT_FolderPath + "|" + RPT_FileName` exactly as in the row (case-insensitive, trailing `\` on folder ignored). A bare `RPT_FileName` is still accepted only when that name is unique in `rows`; if ambiguous, Save fails (exit 1) before writing anything.

## Run-SetLocation.ps1 -Action values (crystal-report)
| Action | args | data |
|---|---|---|
| Run | {folderOrFiles:[...], target:{engine,server,database,user,password?,dsn?,useHistory?}, testOnly:bool, backup:bool} | {files:[{file,ok,changedTables,msg}], dialectWarning:"..."|null} |
| ListHistory | - | {items:[...]} (Crystal connection history from v4) |

## Server HTTP API (webdev) - JSON, all under /api, bound to 127.0.0.1 only
- GET  /api/profiles -> rdoc-cli ProfilesGet ; POST /api/profiles -> ProfilesSave ; POST /api/profiles/password
- POST /api/run {tool:"rdoc"|"map"|"setloc", action, args, async:bool} -> async=false: waits & returns RESULT json; async=true: {jobId}
- GET  /api/jobs ; GET /api/jobs/{id} (status running|done|failed, result) ; GET /api/jobs/{id}/log?from=N (incremental lines)
- POST /api/pipeline {steps:[...]} optional chain
- GET  /api/browse?path= (list folders/files for pickers, .rpt/.xlsx only)
- Static: / -> ui\index.html
- Server chooses bitness from profile.engine; deletes ArgsFile containing passwords right after the child starts reading (or passes via temp file ACL'd to user and deleted in finally).

## Encoding rules
.bat = ASCII + CRLF, no BOM, no chcp. .ps1 containing Thai = UTF-8 BOM. HANA SQL: no N'...'. MSSQL SQL: N'...' OK. No password in any repo file, log, or API response.
