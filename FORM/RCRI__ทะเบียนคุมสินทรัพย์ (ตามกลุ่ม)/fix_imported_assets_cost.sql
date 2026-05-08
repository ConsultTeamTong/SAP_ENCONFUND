-- ============================================================
-- Fix: เติมราคาทุน + AcqDate ให้ Fixed Asset 8 ตัวที่ import เข้ามา
--      โดยไม่มี Capitalization document → OITM.LastPurPrc=0,
--      ACQ3 ไม่มี row → รายงานทะเบียนคุมสินทรัพย์โชว์ 0
--
-- ⚠️ ข้อจำกัดของวิธี SQL UPDATE
--    1. แก้ "ราคาที่โชว์ในรายงาน" ได้ (เพราะรายงาน fallback ไป LastPurPrc)
--    2. ❌ ไม่สร้าง ODPV (Depreciation Plan) → คอลัมน์ "ค่าเสื่อม Yn" จะยังว่าง
--    3. ❌ ไม่ post Journal Entry สำหรับ APC → งบดุลไม่อัปเดต
--
--    ถ้าต้องให้ค่าเสื่อมและบัญชีเดินด้วย → ต้องไป "Fixed Assets >
--    Capitalization" ใน B1 GUI แล้ว post เอกสาร capitalization 1 ใบ
--    ระบบจะอัปเดตทุกอย่างให้พร้อมกัน (OITM, ACQ1/ACQ3, ODPV, JDT1)
--
-- 🔍 ก่อนรัน:
--    - ตรวจสอบรายการและจำนวนเงินกับเอกสารต้นทาง (ใบสั่งซื้อ / ใบโอน)
--    - แทน <RAW_PRICE_xxxxx> ด้วยตัวเลขจริง
--    - แทน <ACQ_DATE_xxxxx> ด้วยวันที่ได้มาจริง (รูปแบบ YYYY-MM-DD)
--    - รันใน SBO_ENCONFUND_TEST ก่อน prod เสมอ
-- ============================================================

-- ตรวจรายการก่อน UPDATE
SELECT "ItemCode", "ItemName", "AcqDate", "LastPurPrc", "AssetClass",
       "U_SLD_FIX_01", "U_SLD_Y", "U_SLD_Work_Group"
FROM SBO_ENCONFUND_TEST."OITM"
WHERE "ItemType" = 'F'
  AND "AcqDate" IS NULL
ORDER BY "ItemCode";

-- เติมราคา + วันที่ได้มา (เปลี่ยนตัวเลข/วันที่ก่อนรัน)
UPDATE SBO_ENCONFUND_TEST."OITM"
   SET "LastPurPrc" = <RAW_PRICE_7105_0603_0001>,
       "AcqDate"    = TO_DATE('<ACQ_DATE_7105_0603_0001>','YYYY-MM-DD')
 WHERE "ItemCode" = '7105-0603-0001';

UPDATE SBO_ENCONFUND_TEST."OITM"
   SET "LastPurPrc" = <RAW_PRICE_7440_0118_0001>,
       "AcqDate"    = TO_DATE('<ACQ_DATE_7440_0118_0001>','YYYY-MM-DD')
 WHERE "ItemCode" = '7440-0118-0001';

UPDATE SBO_ENCONFUND_TEST."OITM"
   SET "LastPurPrc" = <RAW_PRICE_7440_0602_0001>,
       "AcqDate"    = TO_DATE('<ACQ_DATE_7440_0602_0001>','YYYY-MM-DD')
 WHERE "ItemCode" = '7440-0602-0001';

UPDATE SBO_ENCONFUND_TEST."OITM"
   SET "LastPurPrc" = <RAW_PRICE_7440_0602_0002>,
       "AcqDate"    = TO_DATE('<ACQ_DATE_7440_0602_0002>','YYYY-MM-DD')
 WHERE "ItemCode" = '7440-0602-0002';

UPDATE SBO_ENCONFUND_TEST."OITM"
   SET "LastPurPrc" = <RAW_PRICE_7440_0602_0003>,
       "AcqDate"    = TO_DATE('<ACQ_DATE_7440_0602_0003>','YYYY-MM-DD')
 WHERE "ItemCode" = '7440-0602-0003';

UPDATE SBO_ENCONFUND_TEST."OITM"
   SET "LastPurPrc" = <RAW_PRICE_7440_0602_0004>,
       "AcqDate"    = TO_DATE('<ACQ_DATE_7440_0602_0004>','YYYY-MM-DD')
 WHERE "ItemCode" = '7440-0602-0004';

UPDATE SBO_ENCONFUND_TEST."OITM"
   SET "LastPurPrc" = <RAW_PRICE_7440_0602_0005>,
       "AcqDate"    = TO_DATE('<ACQ_DATE_7440_0602_0005>','YYYY-MM-DD')
 WHERE "ItemCode" = '7440-0602-0005';

UPDATE SBO_ENCONFUND_TEST."OITM"
   SET "LastPurPrc" = <RAW_PRICE_7440_0901_0018>,
       "AcqDate"    = TO_DATE('<ACQ_DATE_7440_0901_0018>','YYYY-MM-DD')
 WHERE "ItemCode" = '7440-0901-0018';

-- ตรวจหลัง UPDATE
SELECT "ItemCode", "ItemName", "AcqDate", "LastPurPrc"
FROM SBO_ENCONFUND_TEST."OITM"
WHERE "ItemCode" IN (
  '7105-0603-0001','7440-0118-0001',
  '7440-0602-0001','7440-0602-0002','7440-0602-0003',
  '7440-0602-0004','7440-0602-0005','7440-0901-0018'
)
ORDER BY "ItemCode";

-- COMMIT;   -- ถ้ามั่นใจค่อย uncomment
-- ROLLBACK; -- ถ้าไม่ถูก
