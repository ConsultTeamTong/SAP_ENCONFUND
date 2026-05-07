-- ============================================================
-- Report: ADM10001__Current Configuration Report (System).rpt
Path:   ADM10001__Current Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:38
-- Source: Subreport [Chart of Accounts]
-- Table:  Command
-- ============================================================

SELECT 1 AS "Type", "AcctCode", "AcctName", "Postable", "Levels", "ExportCode", "GrpLine", "GroupMask", "RateTrans", "FrgnName", "Details", "Project", "FormatCode", "ExchRate", "DfltVat", "VatChange", "TransCode", "DfltTax", "TaxPostAcc", "PlngLevel", "Budget" FROM oact 
UNION 
SELECT 2 AS "Type", "AcctCode", "AcctName", "Postable", "Levels", "ExportCode", "GrpLine", "GroupMask", "RateTrans", "FrgnName", "Details", "Project", "FormatCode", "ExchRate", "DfltVat", "VatChange", "TransCode", "DfltTax", "TaxPostAcc", "PlngLevel", "Budget" FROM oact
