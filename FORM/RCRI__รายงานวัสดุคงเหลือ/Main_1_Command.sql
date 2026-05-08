-- ============================================================
-- Report: RCRI0029__รายงานวัสดุคงเหลือ.rpt
Path:   RCRI0029__รายงานวัสดุคงเหลือ.rpt
Extracted: 2026-05-07 18:03:42
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT

    T0."ItemCode",
    T0."ItemName" AS "รายการวัสดุ", 
    T0."SalUnitMsr" AS "หน่วยนับ", 
      T1."ItmsGrpNam",
          --T2."DocDate" ,
    -- *** เพิ่มคอลัมน์ราคาตรงนี้ เพื่อให้โชว์ในรายงาน ***
    T2."CalcPrice" AS "ราคาต่อหน่วย",

    -- 1. ยอดยกมา
    SUM(CASE WHEN T2."DocDate" < {?STARTDATE@} THEN T2."InQty" - T2."OutQty" ELSE 0 END) AS "ยอดยกมา",

    -- 2. รายการเคลื่อนไหว
    SUM(CASE WHEN T2."DocDate" >= {?STARTDATE@} AND T2."DocDate" <= {?ENDDATE@} THEN T2."InQty" ELSE 0 END) AS "ซื้อ",
    SUM(CASE WHEN T2."DocDate" >= {?STARTDATE@} AND T2."DocDate" <= {?ENDDATE@} THEN T2."OutQty" ELSE 0 END) AS "เบิกใช้",

    -- 3. ยอดคงเหลือ
    SUM(CASE WHEN T2."DocDate" <= {?ENDDATE@} THEN T2."InQty" - T2."OutQty" ELSE 0 END) AS "คงเหลือ",
    
    -- 4. มูลค่าเงิน
    SUM(T2."TransValue") AS "จำนวนเงินคงเหลือ"

FROM {?Schema@}.OITM T0
INNER JOIN {?Schema@}.OITB T1 ON T0."ItmsGrpCod" = T1."ItmsGrpCod"
LEFT JOIN {?Schema@}.OINM T2 ON T0."ItemCode" = T2."ItemCode"

WHERE (T2."DocDate" >= {?STARTDATE@} and T2."DocDate" <= {?ENDDATE@})

GROUP BY 
    T1."ItmsGrpNam", 
    T0."ItemCode", 
    T0."ItemName", 
    T0."SalUnitMsr",
    T2."CalcPrice"
    --T2."DocDate" 

ORDER BY T0."ItemCode", T2."CalcPrice"
