-- ============================================================
-- Report: A0060001__Withholding Income Tax Return (P.N.D.3)v28.rpt
Path:   FORM\A006__Withholding Income Tax Return (P.N.D.3)v28\A0060001__Withholding Income Tax Return (P.N.D.3)v28.rpt
Extracted: 2026-07-01 09:28:02
-- Source: Main Report
-- Table:  RowCount
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
