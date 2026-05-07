-- ============================================================
-- Report: ADM30001__Saved Configuration Report (System).rpt
Path:   ADM30001__Saved Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:40
-- Source: Subreport [GL Account Determination]
-- Table:  Command_1
-- ============================================================

SELECT COUNT(*) -1 AS "SalesTaxCount" FROM
(SELECT 50000 AS "LineNo", 'Withholding Tax' AS "AcctDesc", "LinkAct_16" AS "AcctCode", "FormatCode", "AcctName", 5 AS "Type"
FROM OACP LEFT JOIN OACT ON "LinkAct_16" = "AcctCode"
UNION
SELECT 50040 AS "LineNo", 'Withholding Tax' AS "AcctDesc", "LinkAct_16" AS "AcctCode", "FormatCode", "AcctName", 5 AS "Type"
FROM OACP LEFT JOIN OACT ON "LinkAct_16" = "AcctCode"
WHERE EXISTS(SELECT "CustmrDdct" FROM OADM WHERE "CustmrDdct"='Y')
UNION
SELECT 50041 AS "LineNo", 'Purchase Tax' AS "AcctDesc", "LinkAct_8" AS "AcctCode", "FormatCode", "AcctName", 5 AS "Type"
FROM OACP LEFT JOIN OACT ON "LinkAct_8" = "AcctCode"
WHERE EXISTS (SELECT "EnblVatGrp" FROM CINF WHERE "EnblVatGrp" <> 'L' AND "EnblVatGrp" <> 'C')
AND NOT EXISTS (SELECT "VatCharge" FROM OADM, CINF WHERE ("VatCharge" = 'Y' OR "LawsSet" = 'PL') AND "EnblSlfPCH" = 'Y')
UNION
SELECT 50042 AS "LineNo", 'Down Payment Tax Offset Acct' AS "AcctDesc", "PurcVatOff" AS "AcctCode", "FormatCode", "AcctName", 5 AS "Type"
FROM OACP LEFT JOIN OACT ON "PurcVatOff" = "AcctCode"
WHERE EXISTS (SELECT "EnblDownP" FROM CINF WHERE "EnblDownP" = 'Y' AND "LawsSet" <> 'RU' AND "LawsSet" <> 'US' AND "LawsSet" <> 'CA' AND "LawsSet" <> 'BR' AND "LawsSet" <> 'CN' AND "LawsSet" <> 'JP' AND "LawsSet" <> 'KR' )
UNION
SELECT 50043 AS "LineNo", 'Capital Goods ON Hold "Account"' AS "AcctDesc", "OnHoldAct" AS "AcctCode", "FormatCode", "AcctName", 5 AS "Type"
FROM OACP LEFT JOIN OACT ON "OnHoldAct" = "AcctCode"
WHERE EXISTS (SELECT "LawsSet" FROM CINF WHERE "LawsSet" = 'IN')
UNION
SELECT 50044 AS "LineNo", 'Self Invoice Revenue "Account"' AS "AcctDesc", "SlfInvIncm" AS "AcctCode", "FormatCode", "AcctName", 5 AS "Type"
FROM OACP LEFT JOIN OACT ON "SlfInvIncm" = "AcctCode"
WHERE EXISTS (SELECT "VatCharge" FROM OADM, CINF WHERE ("VatCharge" = 'Y' OR "LawsSet" = 'PL') AND "EnblSlfPCH" = 'Y')
UNION
SELECT 50045 AS "LineNo", 'Self Invoice Expense "Account"' AS "AcctDesc", "SlfInvExpn" AS "AcctCode", "FormatCode", "AcctName", 5 AS "Type"
FROM OACP LEFT JOIN OACT ON "SlfInvExpn" = "AcctCode"
WHERE EXISTS (SELECT "VatCharge" FROM OADM, CINF WHERE ("VatCharge" = 'Y' OR "LawsSet" = 'PL') AND "EnblSlfPCH" = 'Y')) T0
