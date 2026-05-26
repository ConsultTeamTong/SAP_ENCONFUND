-- ============================================================
-- Report:   RCRI0014__ทะเบียนคุมค่าใช้จ่ายแผนงานโครงการ.rpt
-- Combined: Main_1_Command.sql  +  Sub_RRRRR_1_Command.sql
-- Combined By: 2026-05-26
-- หมายเหตุ:
--   1) คงคอลัมน์ของ Main ทั้งหมด (รวม DUEDATE และ TotalDebit)
--   2) เพิ่ม FormatCode, AcctName, Category, Debit จาก Sub [RRRRR]
--   3) TotalDebit คำนวณจาก subquery แยก (TOT) เพื่อไม่ให้ค่าซ้ำ
--      เมื่อโครงการเดียวมีหลายแถวรายละเอียด (DET)
--   4) DET ใช้ GROUP BY Project, FormatCode, AcctName, Category
--      เหมือน Sub เดิม เพื่อให้ Debit แยกตามหมวด/งวด ถูกต้องครบถ้วน
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

    CAST(DAYOFMONTH(T1."START") AS NVARCHAR) || ' ' ||
    MAP(MONTH(T1."START"),  1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.',
                            7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
    || ' ' || TO_VARCHAR(ADD_YEARS(T1."START", 543), 'YY')   AS "START",

    CAST(DAYOFMONTH(T1."CLOSING") AS NVARCHAR) || ' ' ||
    MAP(MONTH(T1."CLOSING"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.',
                             7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
    || ' ' || TO_VARCHAR(ADD_YEARS(T1."CLOSING", 543), 'YY') AS "CLOSING",

    CAST(DAYOFMONTH(T1."DUEDATE") AS NVARCHAR) || ' ' ||
    MAP(MONTH(T1."DUEDATE"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.',
                             7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
    || ' ' || TO_VARCHAR(ADD_YEARS(T1."DUEDATE", 543), 'YY') AS "DUEDATE",

    T1."U_SLD_Status",

    -- ----- รายละเอียดแยกหมวดบัญชี/งวด จาก Sub [RRRRR] -----
    DET."FormatCode",
    DET."AcctName",
    DET."Category",
    DET."Debit",

    -- ----- ยอดรวมทั้งโครงการ จาก Main (ไม่ซ้ำตามจำนวนแถว DET) -----
    TOT."TotalDebit"

FROM SBO_ENCONFUND.OPRJ T0
INNER JOIN SBO_ENCONFUND.OPMG T1
    ON T0."PrjCode" = T1."FIPROJECT"

-- ============================================================
-- DET : รายละเอียด Debit แยกตาม Project / หมวดบัญชี / งวด
-- (มาจาก subquery EX ใน Sub_RRRRR_1_Command.sql)
-- ============================================================
LEFT JOIN (
    SELECT
        T1."Project",
        T2."FormatCode",
        T2."AcctName",
        T3."Category",
        SUM(IFNULL(T1."Debit", 0)) AS "Debit"
    FROM SBO_ENCONFUND.OJDT T0
    INNER JOIN SBO_ENCONFUND.JDT1 T1 ON T0."TransId"   = T1."TransId"
    LEFT JOIN  SBO_ENCONFUND.OACT T2 ON T1."Account"   = T2."AcctCode"
    LEFT JOIN  SBO_ENCONFUND.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
    WHERE T2."FormatCode" IN (
            '5107010101','5107010103','5107010105','5107010106',
            '5107020104','5107020105','5107020199'
          )
--      AND T0."RefDate" <= {?StartDate@}
      AND T1."Debit"   <> 0
      AND T0."TransId" NOT IN (
            SELECT "StornoToTr" FROM SBO_ENCONFUND.OJDT
            WHERE "StornoToTr" IS NOT NULL
          )
    GROUP BY
        T1."Project",
        T2."FormatCode",
        T2."AcctName",
        T3."Category"
) AS DET ON T0."PrjCode" = DET."Project"

-- ============================================================
-- TOT : ยอดรวมทั้งโครงการ (มาจาก subquery EX ใน Main_1_Command.sql)
-- คำนวณแยกเพื่อไม่ให้ค่าซ้ำเมื่อ DET มีหลายแถวต่อโครงการ
-- ============================================================
LEFT JOIN (
    SELECT
        T1."Project",
        SUM(IFNULL(T1."Debit", 0)) AS "TotalDebit"
    FROM SBO_ENCONFUND.OJDT T0
    INNER JOIN SBO_ENCONFUND.JDT1 T1 ON T0."TransId"   = T1."TransId"
    LEFT JOIN  SBO_ENCONFUND.OACT T2 ON T1."Account"   = T2."AcctCode"
    LEFT JOIN  SBO_ENCONFUND.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
    WHERE T2."FormatCode" IN (
            '5107010101','5107010103','5107010105','5107010106',
            '5107020104','5107020105','5107020199'
          )
--      AND T0."RefDate" <= {?StartDate@}
      AND T1."Debit"   <> 0
      AND T0."TransId" NOT IN (
            SELECT "StornoToTr" FROM SBO_ENCONFUND.OJDT
            WHERE "StornoToTr" IS NOT NULL
          )
    GROUP BY T1."Project"
) AS TOT ON T0."PrjCode" = TOT."Project"

-- ============================================================
-- WHERE : คงเงื่อนไข Parameter จาก Main เดิม
-- ============================================================
--WHERE
--        (T0."U_SLD_Period"    = '{?Period@}'    OR '{?Period@}'    = '')
--    AND (T0."U_SLD_PlanWork"  = '{?Plan@}'      OR '{?Plan@}'      = '')
--    AND (T0."U_SLD_GroupWork" = '{?WorkGroup@}' OR '{?WorkGroup@}' = '')

ORDER BY
    T0."PrjCode",
    DET."FormatCode",
    DET."Category"
