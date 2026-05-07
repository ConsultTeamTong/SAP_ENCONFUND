-- ============================================================
-- Report: RCRI0010__บัญชีวัสดุคงเหลือ.rpt
Path:   RCRI0010__บัญชีวัสดุคงเหลือ.rpt
Extracted: 2026-05-07 18:03:33
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
    T1."ItemCode" AS "รหัสสินค้า",
    T1."ItemName" AS "ชื่อและชนิดวัสดุ",
    T1."LastPurPrc" AS "ราคาต่อหน่วย",
    T1."InvntryUom" AS "หน่วยนับ",
    T2."WhsCode" AS "Warehouse",
    T2."MinStock" AS "จำนวนอย่างต่ำ",
    T2."MaxStock" AS "จำนวนอย่างสูง",
    T3."WhsName" AS "ที่เก็บ",
    T4."ItmsGrpNam" AS "ประเภท",
    IFNULL("รับ"."รวมรับ", 0) AS "รายรับ",
    IFNULL("จ่าย"."รวมจ่าย", 0) AS "รายจ่าย",
    (IFNULL("รับ"."รวมรับ", 0) - IFNULL("จ่าย"."รวมจ่าย", 0)) AS "ยอดคงเหลือ",
    ((IFNULL("รับ"."รวมรับ", 0) - IFNULL("จ่าย"."รวมจ่าย", 0)) * T1."LastPurPrc") AS "มูลค่าคงเหลือรวม"
FROM  {?Schema@}."OITM" T1
INNER JOIN  {?Schema@}."OITW" T2 ON T1."ItemCode" = T2."ItemCode"
INNER JOIN  {?Schema@}."OWHS" T3 ON T2."WhsCode" = T3."WhsCode"
INNER JOIN  {?Schema@}."OITB" T4 ON T1."ItmsGrpCod" = T4."ItmsGrpCod"
LEFT JOIN (
    SELECT "ItemCode", "WhsCode", SUM("Quantity") AS "รวมรับ"
    FROM  {?Schema@}."PDN1"
    GROUP BY "ItemCode","WhsCode"
) "รับ" ON T1."ItemCode" = "รับ"."ItemCode" AND T2."WhsCode" = "รับ"."WhsCode"
LEFT JOIN (
    SELECT "ItemCode", "WhsCode", SUM("Quantity") AS "รวมจ่าย"
    FROM  {?Schema@}."DLN1"
    GROUP BY "ItemCode", "WhsCode"
) "จ่าย" ON T1."ItemCode" = "จ่าย"."ItemCode" AND T2."WhsCode" = "จ่าย"."WhsCode"
WHERE T2."WhsCode" IS NOT NULL 
AND T4."ItmsGrpCod" = '{?Code@}'
AND T1."ItemCode" ='{?ItemCode@}'
ORDER BY T4."ItmsGrpCod" , T1."ItemCode"

