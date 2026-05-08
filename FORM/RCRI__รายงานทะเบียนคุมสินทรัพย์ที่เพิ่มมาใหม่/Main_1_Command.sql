-- ============================================================
-- Report: RCRI0032__รายงานทะเบียนคุมสินทรัพย์ที่เพิ่มมาใหม่.rpt
Path:   RCRI0032__รายงานทะเบียนคุมสินทรัพย์ที่เพิ่มมาใหม่.rpt
Extracted: 2026-05-07 18:03:43
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT
    T0."CapDate",
    T0."ItemCode",
    T0."ItemName",
    CASE WHEN T0."ItmsGrpCod" =  175 THEN T1."LineTotal" ELSE 0 END AS "lowGrade",
    CASE WHEN T0."ItmsGrpCod" <> 175 THEN T1."LineTotal" ELSE 0 END AS "InGrade",
    T7."UsefulLife" AS "อายุการใช้งาน(เดือน)",
    T7."PeriodCat",
    GRP."ItmsGrpNam",
  GRP."ItmsGrpCod"
FROM {?Schema@}.OITM T0
INNER JOIN {?Schema@}.OITB GRP ON GRP."ItmsGrpCod" = T0."ItmsGrpCod"    
INNER JOIN {?Schema@}.ACQ1 T1 ON T1."ItemCode" = T0."ItemCode"
INNER JOIN {?Schema@}.OACQ T2 ON T2."DocEntry"  = T1."DocEntry"
                                  AND T2."DocStatus" = 'P'
INNER JOIN {?Schema@}.ITM7 T7 ON T7."ItemCode"  = T0."ItemCode"  
WHERE T0."ItemType" = 'F'
  AND T7."DprType" <> 'NO Depre'
  AND (T0."ItmsGrpCod" = '{?Group@}' OR '{Group@}' = '')
  AND T7."PeriodCat" = ({?Year@}-543)
