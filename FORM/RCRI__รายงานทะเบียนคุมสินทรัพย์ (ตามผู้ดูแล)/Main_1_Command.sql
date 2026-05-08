-- ============================================================
-- Report: RCRI0020__รายงานทะเบียนคุมสินทรัพย์ (ตามผู้ดูแล).rpt
Path:   RCRI0020__รายงานทะเบียนคุมสินทรัพย์ (ตามผู้ดูแล).rpt
Extracted: 2026-05-07 18:03:37
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
    CONCAT(CONCAT(CONCAT(CONCAT(A1."ItemCode",'-'),A6."Name"),'-'),A5."Name") AS "ItemCode",
    A1."ItemName", 
    A2."firstName", 
    A2."lastName", 
    A1."UserText",
    A2."dept",    
    A3."Name",
 	CASE WHEN (A3."Remarks" IS NULL OR A3."Remarks" = '') THEN A7."PrcName"
 		ELSE A3."Remarks"
 	END AS "Remarks",
	CASE WHEN (A1."U_SLD_Vendor" IS NULL OR A1."U_SLD_Vendor" = '') THEN IFNULL(A2."firstName", '') || ' ' || IFNULL(A2."lastName", '')
		 ELSE A1."U_SLD_Vendor"
	END AS "full name",
	A4."Location"
	
FROM {?Schema@}."OITM" A1
LEFT JOIN {?Schema@}."OHEM" A2 ON A1."Employee" = A2."empID"
LEFT JOIN {?Schema@}."OUDP" A3 ON A2."dept" = A3."Code"
LEFT JOIN {?Schema@}."OLCT" A4 ON A1."Location" = A4."Code"
LEFT JOIN {?Schema@}."@SLD_FIX_01" A5 ON A1."U_SLD_FIX_01" = A5."Code"
LEFT JOIN {?Schema@}."@SLD_FIXED_ASSETS_Y" A6 ON A1."U_SLD_Y" = A6."Code"
LEFT JOIN {?Schema@}.OPRC A7 ON A1."U_SLD_Work_Group" = A7."PrcCode"
WHERE A1."ItemType" = 'F'
AND A1."validFor" = 'Y'
AND A1."ItemCode" >= '{?StartItem@}'
AND A1."ItemCode" <= '{?EndItem@}'


