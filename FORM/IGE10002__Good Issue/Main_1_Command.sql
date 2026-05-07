-- ============================================================
-- Report: IGE10002__Good Issue.rpt
Path:   IGE10002__Good Issue.rpt
Extracted: 2026-05-07 18:03:02
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
    T1."ItemCode" AS "รหัสสินค้า",
    T4."ItmsGrpNam" AS "กลุ่มวัสดุ",
    T1."ItemName" AS "รายการวัสดุ",
    T6."DocNum" AS "เลขที่จ่าย",
    
TO_VARCHAR(ADD_YEARS(T6."DocDate", 543), 'DD.MM.YYYY') AS Z,
    T1."LastPurPrc" AS "ราคาต่อหน่วย",
    T1."InvntryUom" AS "หน่วยนับ",
    T7."OcrCode" AS "กลุ่มงาน",
    T7."U_SLD_SR" AS "ขอเบิก"
    ,T6."U_SLD_Requester"
    ,NNM1."BeginStr"||T6."DocNum"
    
    ,T7."Quantity" AS "จ่ายให้"
    ,OHEM."firstName" || ' ' || "lastName" ,
    IFNULL("รับ"."รวมรับ", 0) AS "รายรับ",
    IFNULL(T7."Quantity", 0) AS "จำนวนที่จ่าย (ครั้งนี้)",
    (IFNULL("รับ"."รวมรับ", 0) - IFNULL("จ่าย"."รวมจ่าย", 0)) AS "ยอดคงเหลือรวม",
    ((IFNULL("รับ"."รวมรับ", 0) - IFNULL("จ่าย"."รวมจ่าย", 0)) * T1."LastPurPrc") AS "มูลค่าคงเหลือรวม"

FROM "{?Schema@}"."OIGE" T6

LEFT JOIN "{?Schema@}"."IGE1" T7 ON T6."DocEntry" = T7."DocEntry"
LEFT JOIN "{?Schema@}"."OITM" T1 ON T7."ItemCode"=T1."ItemCode"
LEFT JOIN "{?Schema@}"."OITB" T4 ON T1."ItmsGrpCod" = T4."ItmsGrpCod"
LEFT JOIN "{?Schema@}"."OUDP" T5 ON T7."OcrCode" = T5."Name"
LEFT JOIN "{?Schema@}"."OHEM"  ON T6."U_SLD_EMP" = OHEM."empID"
LEFT JOIN "{?Schema@}"."NNM1"  ON T6."Series" = NNM1."Series"
LEFT JOIN (
    SELECT "ItemCode", SUM("Quantity") AS "รวมรับ"
    FROM "{?Schema@}"."PDN1"
    GROUP BY "ItemCode"
) "รับ" ON T1."ItemCode" = "รับ"."ItemCode"

LEFT JOIN (
    SELECT "ItemCode", SUM("Quantity") AS "รวมจ่าย"
    FROM "{?Schema@}"."DLN1"
    GROUP BY "ItemCode"
) "จ่าย" ON T1."ItemCode" = "จ่าย"."ItemCode"
WHERE  T6."DocEntry"= {?Dockey@}
