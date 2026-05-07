-- ============================================================
-- Report: ADM30001__Saved Configuration Report (System).rpt
Path:   ADM30001__Saved Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:40
-- Source: Subreport [GL Account Determination]
-- Table:  Command_1
-- ============================================================

SELECT COUNT(*) -1 AS "SalesTaxCount" FROM
(SELECT 30000 AS "LineNo", ' Customer''s Deduction at Source' AS "AcctDesc", "LinkAct_6" AS "AcctCode", "FormatCode", "AcctName", 3 AS "Type"
FROM OACP LEFT JOIN OACT ON "SalDpmInt" = "AcctCode"
UNION
SELECT 30041 AS "LineNo", ' Customer''s Deduction at Source' AS "AcctDesc", "LinkAct_6" AS "AcctCode", "FormatCode", "AcctName", 3 AS "Type"
FROM OACP LEFT JOIN OACT ON "LinkAct_6" = "AcctCode"
WHERE EXISTS(SELECT "CustmrDdct" FROM OADM WHERE "CustmrDdct"='Y')
UNION
SELECT 30042 AS "LineNo", 'Down Payment Tax Offset Acct' AS "AcctDesc", "SaleVatOff" AS "AcctCode", "FormatCode", "AcctName", 3 AS "Type"
FROM OACP LEFT JOIN OACT ON "SaleVatOff" = "AcctCode"
WHERE EXISTS(SELECT "EnblDownP" FROM CINF WHERE "EnblDownP"='Y') AND (NOT EXISTS(SELECT "EnblDownP" FROM CINF WHERE 

"EnblDownP"='Y') OR (NOT EXISTS(SELECT "LawsSet" FROM CINF WHERE "LawsSet"='US') AND NOT EXISTS(SELECT "LawsSet" FROM CINF 

WHERE "LawsSet"='CA') AND NOT EXISTS(SELECT "LawsSet" FROM CINF WHERE "LawsSet"='BR'))) AND (NOT EXISTS(SELECT "EnblDownP" 

FROM CINF WHERE "EnblDownP"='Y') OR (NOT EXISTS(SELECT "LawsSet" FROM CINF WHERE "LawsSet"='CN') AND NOT EXISTS(SELECT 
"LawsSet" FROM CINF WHERE "LawsSet"='JP') AND NOT EXISTS(SELECT "LawsSet" FROM CINF WHERE "LawsSet"='KR'))) 
UNION
SELECT 30043 AS "LineNo", 'Sales Tax "Account" ' AS "AcctDesc", "LinkAct_5" AS "AcctCode", "FormatCode", "AcctName", 3 AS "Type"
FROM OACP LEFT JOIN OACT ON "LinkAct_5" = "AcctCode"
WHERE NOT EXISTS(SELECT "EnblVatGrp" FROM CINF WHERE "EnblVatGrp"='L') AND NOT EXISTS(SELECT "EnblVatGrp" FROM CINF 
WHERE "EnblVatGrp"='C')) T0
