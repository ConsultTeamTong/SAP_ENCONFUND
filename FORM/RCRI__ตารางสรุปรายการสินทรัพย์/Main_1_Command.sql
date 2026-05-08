-- ============================================================
-- Report: RCRI0018__ตารางสรุปรายการสินทรัพย์.rpt
Path:   RCRI0018__ตารางสรุปรายการสินทรัพย์.rpt
Extracted: 2026-05-07 18:03:36
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT
    /* 1. คำนวณปีงบประมาณ (พ.ศ.) จาก DateTo: ถ้าเดือน >= 10 ให้ปัดเป็นปีหน้า */
    CASE 
        WHEN MONTH({?2dateTo@}) >= 10 THEN (YEAR({?2dateTo@}) + 543 + 1)
        ELSE (YEAR({?2dateTo@}) + 543)
    END AS "PeriodYear",

    /* 2. สร้างข้อความโชว์ช่วงวันที่ (เอาไปแปะหัวรายงาน) */
    TO_VARCHAR({?1dateFrom@}, 'dd/MM/yyyy') || ' - ' || TO_VARCHAR({?2dateTo@}, 'dd/MM/yyyy') AS "DateRangeShow",

    /* +++++ ข้อมูลเดิม +++++ */
    G."ItmsGrpCod"                    AS "รหัสประเภทครุภัณฑ์",
    B."ItmsGrpNam"                    AS "ประเภทครุภัณฑ์",

    /* ===== จำนวน (Count) : นับทั้งหมดที่มีในระบบ ===== */
    IFNULL(G."Cnt_Under", 0)          AS "จำนวนต่ำกว่าเกณฑ์",
    IFNULL(G."Cnt_Over", 0)           AS "จำนวนตามเกณฑ์",
    (IFNULL(G."Cnt_Under", 0) + IFNULL(G."Cnt_Over", 0)) AS "จำนวนรวม",

    /* ===== ยอดยกมา (BF) : สะสมก่อนวันที่เลือก ===== */
    IFNULL(M."BF_Under",0)            AS "ยอดยกมา_ต่ำกว่าเกณฑ์",
    IFNULL(M."BF_Over",0)             AS "ยอดยกมา_ตามเกณฑ์",
    (IFNULL(M."BF_Under",0) + IFNULL(M."BF_Over",0)) AS "ยอดยกมา_รวม",

    /* ===== ซื้อเพิ่ม (ADD) : ในช่วงวันที่เลือก ===== */
    IFNULL(M."ADD_Under",0)           AS "ซื้อเพิ่ม_ต่ำกว่าเกณฑ์",
    IFNULL(M."ADD_Over",0)            AS "ซื้อเพิ่ม_ตามเกณฑ์",
    (IFNULL(M."ADD_Under",0) + IFNULL(M."ADD_Over",0)) AS "ซื้อเพิ่ม_รวม",

    /* ===== สุทธิปลายงวด (BF + ADD) ===== */
    (IFNULL(M."BF_Under",0) + IFNULL(M."ADD_Under",0)) AS "สุทธิปลายงวด_ต่ำกว่าเกณฑ์",
    (IFNULL(M."BF_Over",0)  + IFNULL(M."ADD_Over",0))  AS "สุทธิปลายงวด_ตามเกณฑ์",
    
    (IFNULL(M."BF_Under",0) + IFNULL(M."ADD_Under",0) + 
     IFNULL(M."BF_Over",0)  + IFNULL(M."ADD_Over",0))  AS "สุทธิปลายงวด_รวม"

FROM
/* ================= 1. ส่วนนับจำนวน (G) ================= */
(
    SELECT
        O."ItmsGrpCod",
        COUNT(CASE WHEN I8."APC" < 10000 THEN 1 END)  AS "Cnt_Under",
        COUNT(CASE WHEN I8."APC" >= 10000 THEN 1 END) AS "Cnt_Over"
    FROM {?Schema@}."OITM" O
    LEFT JOIN (
        SELECT "ItemCode", MAX("APC") AS "APC"
        FROM {?Schema@}."ITM8"
        GROUP BY "ItemCode"
    ) I8 ON O."ItemCode" = I8."ItemCode"
    WHERE O."ItemType" = 'F'
      AND O."AsstStatus" <> 'I' 
      
    GROUP BY O."ItmsGrpCod"
) G

/* ================= 2. ส่วนมูลค่า (M) ================= */
LEFT JOIN
(
    SELECT
        O."ItmsGrpCod",

        /* --- ยอดยกมา (BF) --- */
        SUM( CASE
                WHEN T."PostDate" < {?1dateFrom@}
                 AND I8."APC" < 10000 THEN Q."TotalSys" ELSE 0
            END ) AS "BF_Under",

        SUM(CASE
                WHEN T."PostDate" < {?1dateFrom@}
                 AND I8."APC" >= 10000 THEN Q."TotalSys" ELSE 0
            END ) AS "BF_Over",

        /* --- ซื้อเพิ่ม (ADD) --- */
        SUM( CASE
                WHEN T."PostDate" >= {?1dateFrom@} AND T."PostDate" <= {?2dateTo@}
                 AND I8."APC" < 10000 THEN Q."TotalSys" ELSE 0
            END) AS "ADD_Under",

        SUM(CASE 
                WHEN T."PostDate" >= {?1dateFrom@} AND T."PostDate" <= {?2dateTo@}
                 AND I8."APC" >= 10000 THEN Q."TotalSys" ELSE 0 
            END ) AS "ADD_Over"

    FROM {?Schema@}."OACQ" T
    JOIN {?Schema@}."ACQ1" Q ON T."DocEntry" = Q."DocEntry"
    JOIN {?Schema@}."OITM" O ON Q."ItemCode" = O."ItemCode"
    JOIN (
        SELECT "ItemCode", MAX("APC") AS "APC"
        FROM {?Schema@}."ITM8"
        GROUP BY "ItemCode"
    ) I8 ON O."ItemCode" = I8."ItemCode"

    WHERE O."ItemType" = 'F'
      AND O."AsstStatus" <> 'I'
      AND T."PostDate" <= {?2dateTo@}

    GROUP BY O."ItmsGrpCod"
) M
    ON G."ItmsGrpCod" = M."ItmsGrpCod"

LEFT JOIN {?Schema@}."OITB" B
    ON G."ItmsGrpCod" = B."ItmsGrpCod"

ORDER BY G."ItmsGrpCod";
