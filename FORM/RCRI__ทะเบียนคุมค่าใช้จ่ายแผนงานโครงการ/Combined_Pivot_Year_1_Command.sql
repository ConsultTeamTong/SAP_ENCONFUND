-- ============================================================
-- Report:   RCRI0014__ทะเบียนคุมค่าใช้จ่ายแผนงานโครงการ.rpt
-- Combined: Main_1_Command.sql  +  Sub_RRRRR_1_Command.sql
--           แบบ PIVOT ปีงบประมาณ → 1 โครงการ = 1 แถว
-- Combined By: 2026-05-26
--
-- รูปแบบผลลัพธ์ (ตามภาพตัวอย่าง):
--   - 1 แถวต่อ 1 โครงการ
--   - มีคอลัมน์ "30 ก.ย.2548" .. "30 ก.ย.2580" แสดงยอด Debit ของปีนั้นๆ
--   - คอลัมน์ "TotalDebit" = ผลรวมทุกปีของโครงการนั้น
--
-- หมายเหตุ:
--   * OFPR.Category เก็บเป็นปี ค.ศ. (เช่น 2008) → +543 = พ.ศ. (2551)
--   * ครอบคลุมปี ค.ศ. 2005–2037 (พ.ศ. 2548–2580) ปีไหนไม่มีข้อมูลจะเป็น 0
--   * ถ้าต้องการขยายปีเพิ่ม เพิ่มบรรทัด SUM(CASE...) เพิ่มได้ตรงๆ
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

    -- วันที่ฟอร์แมตไทย (ใช้ MAX กันกรณี OPMG มีหลายแถวต่อโครงการ)
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

    -- รวมทุกปีของโครงการ
    SUM(IFNULL(DET."Debit", 0)) AS "TotalDebit",

    -- =====================================================================
    -- PIVOT : ยอดค่าใช้จ่ายต่อปีงบประมาณ (พ.ศ.) — alias = '30 ก.ย.<พ.ศ.>'
    -- =====================================================================
    SUM(CASE WHEN DET."Category" = 2005 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2548",
    SUM(CASE WHEN DET."Category" = 2006 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2549",
    SUM(CASE WHEN DET."Category" = 2007 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2550",
    SUM(CASE WHEN DET."Category" = 2008 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2551",
    SUM(CASE WHEN DET."Category" = 2009 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2552",
    SUM(CASE WHEN DET."Category" = 2010 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2553",
    SUM(CASE WHEN DET."Category" = 2011 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2554",
    SUM(CASE WHEN DET."Category" = 2012 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2555",
    SUM(CASE WHEN DET."Category" = 2013 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2556",
    SUM(CASE WHEN DET."Category" = 2014 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2557",
    SUM(CASE WHEN DET."Category" = 2015 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2558",
    SUM(CASE WHEN DET."Category" = 2016 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2559",
    SUM(CASE WHEN DET."Category" = 2017 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2560",
    SUM(CASE WHEN DET."Category" = 2018 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2561",
    SUM(CASE WHEN DET."Category" = 2019 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2562",
    SUM(CASE WHEN DET."Category" = 2020 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2563",
    SUM(CASE WHEN DET."Category" = 2021 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2564",
    SUM(CASE WHEN DET."Category" = 2022 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2565",
    SUM(CASE WHEN DET."Category" = 2023 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2566",
    SUM(CASE WHEN DET."Category" = 2024 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2567",
    SUM(CASE WHEN DET."Category" = 2025 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2568",
    SUM(CASE WHEN DET."Category" = 2026 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2569",
    SUM(CASE WHEN DET."Category" = 2027 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2570",
    SUM(CASE WHEN DET."Category" = 2028 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2571",
    SUM(CASE WHEN DET."Category" = 2029 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2572",
    SUM(CASE WHEN DET."Category" = 2030 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2573",
    SUM(CASE WHEN DET."Category" = 2031 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2574",
    SUM(CASE WHEN DET."Category" = 2032 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2575",
    SUM(CASE WHEN DET."Category" = 2033 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2576",
    SUM(CASE WHEN DET."Category" = 2034 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2577",
    SUM(CASE WHEN DET."Category" = 2035 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2578",
    SUM(CASE WHEN DET."Category" = 2036 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2579",
    SUM(CASE WHEN DET."Category" = 2037 THEN DET."Debit" ELSE 0 END) AS "30 ก.ย.2580"

FROM {?Schema@}.OPRJ T0
INNER JOIN {?Schema@}.OPMG T1
    ON T0."PrjCode" = T1."FIPROJECT"

-- ============================================================
-- DET : ค่าใช้จ่ายแยกตาม Project + ปีงบประมาณ (Category)
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
      AND T0."RefDate" <= {?StartDate@}
      AND T1."Debit"   <> 0
      AND T0."TransId" NOT IN (
            SELECT "StornoToTr" FROM {?Schema@}.OJDT
            WHERE "StornoToTr" IS NOT NULL
          )
    GROUP BY T1."Project", T3."Category"
) AS DET ON T0."PrjCode" = DET."Project"

-- ============================================================
-- WHERE : คงเงื่อนไข Parameter ของ Main เดิม
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
