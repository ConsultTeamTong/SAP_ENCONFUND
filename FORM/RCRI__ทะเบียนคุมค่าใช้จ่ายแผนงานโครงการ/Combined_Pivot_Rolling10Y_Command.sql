-- ============================================================
-- Report:   RCRI0014__ทะเบียนคุมค่าใช้จ่ายแผนงานโครงการ.rpt
-- Combined: Main + Sub_RRRRR แบบ PIVOT ROLLING 10 ปี
-- Combined By: 2026-05-26
--
-- ใส่ Parameter {?StartYearBE@} เป็นปี พ.ศ. เริ่มต้น (เช่น 2569)
--   → ได้คอลัมน์ Y01..Y10 ตามปีงบประมาณ 10 ปีติดต่อกัน
--   → ตัวอย่าง 2569 → Y01=ปี 2569, Y02=2570, ..., Y10=2578
--
-- การแสดงผลใน Crystal Report:
--   สร้าง Formula Field สำหรับ Header แต่ละคอลัมน์:
--     {@H01} = "30 ก.ย." & ToText({?StartYearBE} + 0, "0000")
--     {@H02} = "30 ก.ย." & ToText({?StartYearBE} + 1, "0000")
--     ...
--     {@H10} = "30 ก.ย." & ToText({?StartYearBE} + 9, "0000")
--   แล้ววาง Formula Field เหล่านี้ใน Page Header แทน header ตายตัว
--
-- หมายเหตุ:
--   * OFPR.Category เก็บเป็น ค.ศ. → ต้องลบ 543 ก่อนเทียบ
--   * BETWEEN ใน DET subquery ช่วย optimize ไม่ดึงปีนอกช่วง
--   * TotalDebit = ผลรวม "เฉพาะ 10 ปีในช่วง" (ถ้าต้องการรวมทุกปี
--     ตลอดอายุโครงการ ให้เพิ่ม TOT subquery แบบไม่ filter ปี)
-- ============================================================

SELECT
    T0."PrjCode",
    T0."U_SLD_ProjectName",
    T0."U_SLD_PlanWork",
    T0."U_SLD_GroupWork",
    T0."U_SLD_Period",
    T0."U_SLD_REQ",
    T0."U_SLD_REC",
    T0."U_SLD_Vendor",

    CAST(DAYOFMONTH(MAX(T1."START")) AS NVARCHAR) || ' ' ||
    MAP(MONTH(MAX(T1."START")),
        1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.',
        7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
    || ' ' || TO_VARCHAR(ADD_YEARS(MAX(T1."START"), 543), 'YY')   AS "START",

    CAST(DAYOFMONTH(MAX(T1."CLOSING")) AS NVARCHAR) || ' ' ||
    MAP(MONTH(MAX(T1."CLOSING")),
        1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.',
        7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
    || ' ' || TO_VARCHAR(ADD_YEARS(MAX(T1."CLOSING"), 543), 'YY') AS "CLOSING",

    CAST(DAYOFMONTH(MAX(T1."DUEDATE")) AS NVARCHAR) || ' ' ||
    MAP(MONTH(MAX(T1."DUEDATE")),
        1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.',
        7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
    || ' ' || TO_VARCHAR(ADD_YEARS(MAX(T1."DUEDATE"), 543), 'YY') AS "DUEDATE",

    MAX(T1."U_SLD_Status") AS "U_SLD_Status",

    -- รวม 10 ปีในช่วง
    SUM(IFNULL(DET."Debit", 0)) AS "TotalDebit",

    -- ===== PIVOT ROLLING 10 ปี (เลื่อนตาม Parameter) =====
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 0 THEN DET."Debit" ELSE 0 END) AS "Y01",
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 1 THEN DET."Debit" ELSE 0 END) AS "Y02",
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 2 THEN DET."Debit" ELSE 0 END) AS "Y03",
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 3 THEN DET."Debit" ELSE 0 END) AS "Y04",
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 4 THEN DET."Debit" ELSE 0 END) AS "Y05",
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 5 THEN DET."Debit" ELSE 0 END) AS "Y06",
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 6 THEN DET."Debit" ELSE 0 END) AS "Y07",
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 7 THEN DET."Debit" ELSE 0 END) AS "Y08",
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 8 THEN DET."Debit" ELSE 0 END) AS "Y09",
    SUM(CASE WHEN DET."Category" = {?StartYearBE@} - 543 + 9 THEN DET."Debit" ELSE 0 END) AS "Y10"

FROM {?Schema@}.OPRJ T0
INNER JOIN {?Schema@}.OPMG T1
    ON T0."PrjCode" = T1."FIPROJECT"

-- ============================================================
-- DET : Debit แยกตาม Project + ปีงบประมาณ (Category)
-- BETWEEN จะตัดข้อมูลให้เหลือเฉพาะช่วง 10 ปีที่ต้องการ
-- ============================================================
LEFT JOIN (
    SELECT
        T1."Project",
        T3."Category",
        SUM(IFNULL(T1."Debit", 0)) AS "Debit"
    FROM {?Schema@}.OJDT T0
    INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId"    = T1."TransId"
    LEFT JOIN  {?Schema@}.OACT T2 ON T1."Account"    = T2."AcctCode"
    LEFT JOIN  {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
    WHERE T2."FormatCode" IN (
            '5107010101','5107010103','5107010105','5107010106',
            '5107020104','5107020105','5107020199'
          )
      AND T1."Debit" <> 0
      AND T3."Category" BETWEEN {?StartYearBE@} - 543
                            AND {?StartYearBE@} - 543 + 9
      AND T0."TransId" NOT IN (
            SELECT "StornoToTr" FROM {?Schema@}.OJDT
            WHERE "StornoToTr" IS NOT NULL
          )
    GROUP BY T1."Project", T3."Category"
) AS DET ON T0."PrjCode" = DET."Project"

-- ============================================================
-- WHERE : เปิดใช้ได้ถ้าต้องการ filter Period/Plan/WorkGroup
-- ============================================================
WHERE
        (T0."U_SLD_Period"    = '{?Period@}'    OR '{?Period@}'    = '')
    AND (T0."U_SLD_PlanWork"  = '{?Plan@}'      OR '{?Plan@}'      = '')
    AND (T0."U_SLD_GroupWork" = '{?WorkGroup@}' OR '{?WorkGroup@}' = '')

GROUP BY
    T0."PrjCode",
    T0."U_SLD_ProjectName",
    T0."U_SLD_PlanWork",
    T0."U_SLD_GroupWork",
    T0."U_SLD_Period",
    T0."U_SLD_REQ",
    T0."U_SLD_REC",
    T0."U_SLD_Vendor"

ORDER BY
    T0."U_SLD_Period",
    T0."U_SLD_PlanWork",
    T0."U_SLD_GroupWork",
    T0."PrjCode"
