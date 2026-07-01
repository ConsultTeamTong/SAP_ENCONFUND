-- ============================================================
-- Report: Barcode Fixasset.rpt
Path:   FORM\Barcode\Barcode Fixasset.rpt
Extracted: 2026-07-01 09:28:05
-- Source: Main Report
-- Table:  Command
-- ============================================================

Select 
oitm."ItemCode" || '-' || '01' || '-' ||T1."Name",
oitm."ItemName", 
oitm."ItemCode" AS "BarCode"
from {?Schema@}.oitm 
LEFT JOIN {?Schema@}."@SLD_FIXED_ASSETS_Y" T1 ON oitm."U_SLD_Y" = T1."Code"
LEFT JOIN {?Schema@}.OITB ON oitm."ItmsGrpCod" = OITB."ItmsGrpCod"
WHERE oitm."ItemType" = 'F'
AND oitm."AsstStatus" <> 'I'
AND (CAST(OITB."ItmsGrpNam" AS VARCHAR) = '{?ItmsGrpNam@}' OR '{?ItmsGrpNam@}' = '')
AND oitm."ItemCode" BETWEEN '{?Itemfrom@}' AND '{?Itemto@}'
