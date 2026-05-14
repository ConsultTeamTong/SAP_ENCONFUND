SELECT
    /* 1. ปีงบประมาณ (พ.ศ.) จาก DateTo: เดือน >= 10 ปัดเป็นปีหน้า */
    CASE
        WHEN MONTH({?2dateTo@}) >= 10 THEN (YEAR({?2dateTo@}) + 543 + 1)
        ELSE (YEAR({?2dateTo@}) + 543)
    END AS "PeriodYear",

    /* 2. ข้อความช่วงวันที่ (แปะหัวรายงาน) */
    TO_VARCHAR({?1dateFrom@}, 'dd/MM/yyyy') || ' - ' || TO_VARCHAR({?2dateTo@}, 'dd/MM/yyyy') AS "DateRangeShow",

    G."ItmsGrpCod"                       AS "รหัสประเภทครุภัณฑ์",
    B."ItmsGrpNam"                       AS "ประเภทครุภัณฑ์",

    /* ===== จำนวน (Count) : นับ item ครุภัณฑ์ทั้งหมดที่ยัง active ===== */
    IFNULL(G."Cnt_Under", 0)             AS "จำนวนต่ำกว่าเกณฑ์",
    IFNULL(G."Cnt_Over", 0)              AS "จำนวนตามเกณฑ์",
    (IFNULL(G."Cnt_Under", 0) + IFNULL(G."Cnt_Over", 0)) AS "จำนวนรวม",

    /* ===== ยอดยกมา (BF) : CapDate ก่อนวันที่เริ่ม (รวม CapDate ว่าง) ===== */
    IFNULL(G."BF_Under", 0)              AS "ยอดยกมา_ต่ำกว่าเกณฑ์",
    IFNULL(G."BF_Over", 0)               AS "ยอดยกมา_ตามเกณฑ์",
    (IFNULL(G."BF_Under", 0) + IFNULL(G."BF_Over", 0)) AS "ยอดยกมา_รวม",

    /* ===== ซื้อเพิ่ม (ADD) : CapDate อยู่ในช่วงที่เลือก ===== */
    IFNULL(G."ADD_Under", 0)             AS "ซื้อเพิ่ม_ต่ำกว่าเกณฑ์",
    IFNULL(G."ADD_Over", 0)              AS "ซื้อเพิ่ม_ตามเกณฑ์",
    (IFNULL(G."ADD_Under", 0) + IFNULL(G."ADD_Over", 0)) AS "ซื้อเพิ่ม_รวม",

    /* ===== สุทธิปลายงวด (BF + ADD) ===== */
    (IFNULL(G."BF_Under", 0) + IFNULL(G."ADD_Under", 0)) AS "สุทธิปลายงวด_ต่ำกว่าเกณฑ์",
    (IFNULL(G."BF_Over", 0)  + IFNULL(G."ADD_Over", 0))  AS "สุทธิปลายงวด_ตามเกณฑ์",
    (IFNULL(G."BF_Under", 0) + IFNULL(G."ADD_Under", 0) +
     IFNULL(G."BF_Over", 0)  + IFNULL(G."ADD_Over", 0))  AS "สุทธิปลายงวด_รวม"

FROM
/* ============ รวมทุก measure จาก OITM + ITM8 ในชุดเดียว ============ */
(
    SELECT
        O."ItmsGrpCod",

        /* --- จำนวน : นับทุก item ที่ active (ไม่ผูกวันที่) --- */
        COUNT(CASE WHEN O."AssetClass" LIKE '%-0' THEN 1 END) AS "Cnt_Under",
        COUNT(CASE WHEN O."AssetClass" NOT LIKE '%-0'
                     OR O."AssetClass" IS NULL  THEN 1 END)   AS "Cnt_Over",

        /* --- ยอดยกมา (BF) : CapDate < dateFrom หรือ CapDate ว่าง --- */
        SUM(CASE
                WHEN (O."CapDate" < {?1dateFrom@} OR O."CapDate" IS NULL)
                 AND O."AssetClass" LIKE '%-0'
                THEN IFNULL(I8."APC", 0) ELSE 0
            END) AS "BF_Under",
        SUM(CASE
                WHEN (O."CapDate" < {?1dateFrom@} OR O."CapDate" IS NULL)
                 AND (O."AssetClass" NOT LIKE '%-0' OR O."AssetClass" IS NULL)
                THEN IFNULL(I8."APC", 0) ELSE 0
            END) AS "BF_Over",

        /* --- ซื้อเพิ่ม (ADD) : dateFrom <= CapDate <= dateTo --- */
        SUM(CASE
                WHEN O."CapDate" >= {?1dateFrom@} AND O."CapDate" <= {?2dateTo@}
                 AND O."AssetClass" LIKE '%-0'
                THEN IFNULL(I8."APC", 0) ELSE 0
            END) AS "ADD_Under",
        SUM(CASE
                WHEN O."CapDate" >= {?1dateFrom@} AND O."CapDate" <= {?2dateTo@}
                 AND (O."AssetClass" NOT LIKE '%-0' OR O."AssetClass" IS NULL)
                THEN IFNULL(I8."APC", 0) ELSE 0
            END) AS "ADD_Over"

    FROM {?Schema@}."OITM" O
    LEFT JOIN (
        /* APC ต่อ item — ITM8 เป็น 1:1 ต่อ ItemCode อยู่แล้ว
           แต่ MAX กันเหนียวเผื่อมีหลาย DprArea */
        SELECT "ItemCode", MAX("APC") AS "APC"
        FROM {?Schema@}."ITM8"
        GROUP BY "ItemCode"
    ) I8 ON O."ItemCode" = I8."ItemCode"
    WHERE O."ItemType" = 'F'
      AND O."AsstStatus" <> 'I'
    GROUP BY O."ItmsGrpCod"
) G

LEFT JOIN {?Schema@}."OITB" B
    ON G."ItmsGrpCod" = B."ItmsGrpCod"

ORDER BY G."ItmsGrpCod";
