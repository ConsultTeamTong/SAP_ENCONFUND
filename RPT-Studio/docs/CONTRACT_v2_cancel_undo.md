# CONTRACT v2 - Cancel job + Undo import (ส่วนเสริมของ CONTRACT.md; ถ้าขัดกัน ให้ยึดไฟล์นี้)

กฎเดิมยังอยู่ทั้งหมด: ห้ามเขียน production DB (SBO_ENCONFUND, SBO_Seoul_Clinic) ตอนทดสอบ -> ทดสอบเขียนจริงได้เฉพาะ disposable target ถ้ามี ไม่งั้นทำ dryRun + unit-level test ของ SQL ที่สร้าง (print/inspect, ไม่ execute) แล้วบอกชัดว่าอะไร unverified; ต้อง log ทุกอย่างลง ACTION_LOG.md; ห้ามพิมพ์ลง Windows Search; stop ทุก process ที่เริ่มเอง

## 1. Progress items (ทุก job ที่วนทีละรายการ: Export, Run-SetLocation, Import, Backup, Rollback, UndoImport)
แต่ละรายการที่เสร็จ (สำเร็จหรือล้มเหลว) พิมพ์ 1 บรรทัดทันที flush: `##ITEM## {"key":"<docCode|file path>","ok":true|false,"msg":"..."}` ก่อนเริ่มรายการถัดไป

## 2. Cancel (webdev: server+UI)
- `POST /api/jobs/{id}/cancel` -> ฆ่า process tree ของ child (taskkill /PID <pid> /T /F หรือเทียบเท่า) ; ถ้า job ไม่ running -> 409
- job json: status = `cancelled`, `completedItems` = รายการ ##ITEM## ที่อ่านจาก log ก่อนถูกฆ่า, `cancelledAt`; log ปิดท้ายด้วย `[server] CANCELLED by user`
- UI: ทุกแท็บที่มี job (Export, Set Location, Import, Map?(ไม่ต้อง), History: Backup/Rollback/Undo) มีปุ่ม "หยุด" (Stop) แสดงเฉพาะตอน running, กดแล้วถามยืนยัน 1 ครั้ง, หลังหยุดแสดงสถานะ "ยกเลิกแล้ว" + ตารางรายการที่เสร็จก่อนยกเลิก (จาก completedItems) + จำนวนที่ยังไม่ทำ
- ห้ามเขียน/ลบไฟล์ใดนอกเหนือจากสถานะ job ตอน cancel; ปุ่ม Stop ต้องไม่ block listener

## 3. Safe-on-kill (sap-b1 lib + crystal-report)
- Import (real): หนึ่งแถว = หนึ่ง transaction (RDOC + RITM/RDC1/RCON ของแถวนั้น) commit ต่อแถว; ถูก kill กลางแถว -> DB rollback เองเมื่อ connection ตาย; ไม่มีสถานะครึ่งแถว. manifest ของ batch (ข้อ 4) ต้องถูกเขียนก่อนเริ่มเขียนแถวแรก และอัปเดตหลังแต่ละแถว commit เพื่อให้ Undo ใช้ได้แม้ถูก cancel
- Set Location (crystal-report): ตรวจ v4 ว่าเขียนไฟล์จริงแบบ temp-then-replace (หรือเทียบเท่า) หากไม่ใช่ ให้เสริมใน wrapper Run-SetLocation.ps1 ได้ (บันทึกเป็นสำเนา temp ในโฟลเดอร์เดียวกัน -> verify -> replace ไฟล์จริง + .bak); ตอนเริ่มรันให้ quarantine/ลบ temp ค้างที่เป็นของ wrapper เองเท่านั้น (ชื่อมี pattern ชัดเจน) ; รายงานตามจริงว่า kill ณ จังหวะใดอาจเหลืออะไร. ทดสอบ: kill ระหว่าง Run บนสำเนา แล้ว md5/เปิดไฟล์ตรวจว่าไม่เสีย (หรือไฟล์เดิมยังครบ)
- Backup/Export: เขียนไฟล์ชั่วคราว (.part) แล้ว rename เมื่อจบ; .json meta เขียนก่อนหรือหลังต้องสอดคล้อง (ไม่ปล่อย .bak ค้างโดยไม่มี meta โดยไม่แจ้ง)

## 4. Import batch + Undo (sap-b1 lib; webdev UI)
ก่อน Import จริง (dryRun=false) อัตโนมัติ:
- สร้าง batch: `backups\<profile>\imports\<batchId>\manifest.json` (batchId = yyyyMMdd_HHmmss) + ไฟล์ Template ของแถวที่จะ UPDATE เก็บเป็นไฟล์ในโฟลเดอร์เดียวกัน (ไม่ฝัง base64 ใน json ถ้าใหญ่)
- manifest: `{batchId,time,profile,engine,companyDb,status:"running|complete|cancelled|failed|undone",inserted:[{docCode,docName,typeCode}],updated:[{docCode,docName,typeCode,before:{templateFile,rptHash,updateDate,<คอลัมน์ RDOC ที่ UPDATE แก้>},after:{rptHash,updateDate}}],undone:false,undoneAt}`
- manifest ต้องเขียนก่อนแตะ DB และอัปเดตหลังแต่ละแถวที่ commit (atomic: เขียน .tmp แล้ว rename)
Actions ใหม่ใน rdoc-cli.ps1:
| Action | args | data |
|---|---|---|
| ListImportBatches | - | {items:[{batchId,time,status,insertedCount,updatedCount,undone}]} |
| GetImportBatch | {batchId} | {manifest} |
| UndoImport | {batchId, dryRun, confirmDb, force?} | {dryRun, plan:[{docCode,action:"delete"|"restore"|"refuse"|"none",reason}], deleted, restored} |
UndoImport:
- dryRun=true (ค่าเริ่มต้นถ้าไม่ส่ง) = แสดงแผน ไม่เขียน; dryRun=false ต้อง confirmDb = companyDb (gate เดียวกับ Import) ตรวจก่อนต่อ DB
- inserted docCode: ลบ DFLT_PRNTING (เฉพาะแถวที่อ้าง DocCode นั้น ตามที่ Rollback เดิม/ต้นฉบับทำ), RITM, RDC1, RCON, RDOC ของ DocCode นั้น
  หมายเหตุ: ผู้ใช้สั่งให้รวม DFLT_PRNTING ในการ undo อย่างชัดเจน (ขยายจากข้อจำกัด "เขียนเฉพาะ RDOC/RITM/RDC1/RCON" เดิม ให้ยึดเฉพาะ DFLT_PRNTING ที่ผูกกับ DocCode ที่ import เอง) - ห้ามแตะตารางอื่น
- updated docCode: restore Template/RptHash/UpdateDate (และคอลัมน์ที่ import แก้ ตาม manifest.before) จากไฟล์ใน batch
- ปฏิเสธ (action "refuse") แถวที่ถูกแก้หลัง import: เทียบ RptHash/UpdateDate ปัจจุบันกับ manifest.after; ข้ามได้เมื่อ force=true (แสดงใน plan ว่า forced); ไม่ทับ System layout เด็ดขาด
- ทั้งหมดอยู่ใน transaction เดียว (all-or-nothing); ล้มเหลว = rollback ไม่มีการเปลี่ยนแปลง; สำเร็จ -> manifest.status="undone"; undo ซ้ำ -> refuse
- engine-aware: HANA ห้าม N'..' ; MSSQL ใส่ได้; identifier ครอบ "..." ตามที่ทำไว้
- ##ITEM## ต่อ docCode ใน UndoImport (แต่ commit รวมครั้งเดียว; ถ้า cancel ก่อน commit = ไม่มีอะไรเปลี่ยน, completedItems ของ undo = [] และ UI ต้องบอกว่าไม่มีการเปลี่ยนแปลง)

## 5. UI (webdev) แท็บ History
- ตาราง "ชุด Import" (ListImportBatches): เวลา, profile, +ใหม่/แก้, สถานะ, ปุ่ม "ดูรายละเอียด" (GetImportBatch) และ "Undo this import" (-> เรียก dryRun ก่อนแสดงแผนเป็นตาราง; ปุ่มยืนยันจริงต้องพิมพ์ชื่อ companyDb; checkbox force พร้อมคำเตือนสีแดง)
- แท็บ Import: หลัง Import จริงแสดง batchId + ลิงก์ไปแท็บ History
- สไตล์ ledgerline เดิม ไม่ใช้ CDN
