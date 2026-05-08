-- ============================================================
-- Report: RCT10005__ใบเสร็จ (สำเนา).rpt
Path:   RCT10005__ใบเสร็จ (สำเนา).rpt
Extracted: 2026-05-07 18:03:46
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
 IFNULL(n1."BeginStr", '') || CAST(ORCT."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร"
,TO_VARCHAR(ADD_YEARS(ORCT."DocDate", 543), 'DD.MM.YYYY') AS "วันที่เอกสาร"
,ORCT."U_SLD_Receive" AS "ได้รับเงินจาก"

,RCT4."Descrip" AS "รายการ"
,RCT4."SumApplied" AS "จำนวนเงิน"
,ORCT."U_SLD_Address" || ' ' || ORCT."U_SLD_Block" || ' ' || ORCT."U_SLD_City" || ' ' || ORCT."U_SLD_County" || ' ' || ORCT."U_SLD_Zip" AS "ที่อยู่"
FROM {?Schema@}.ORCT
LEFT JOIN {?Schema@}.RCT4 ON ORCT."DocEntry" = RCT4."DocNum"
LEFT JOIN {?Schema@}.NNM1 n1 ON ORCT."Series" = n1."Series"
WHERE ORCT."DocEntry" = {?DocKey@}
