-- ============================================================
-- Report: A0080001__Withholding Tax certificate (53) v28.rpt
Path:   A0080001__Withholding Tax certificate (53) v28.rpt
Extracted: 2026-05-07 18:02:36
-- Source: Main Report
-- Table:  Command_3
-- ============================================================

SELECT CEIL((COUNT("Name"))/5) AS "Row"

FROM (
SELECT DISTINCT ROW_NUMBER() OVER ( ORDER BY "Name") AS "Row", * 
FROM (
		SELECT  "Name" 
		FROM {?Schema@}."@SLDT_RT_TST" 
		WHERE "U_SubmitDate" IS NOT NULL AND "U_TaxType" = '5'
		) AS CountPage
	) AS CountP
