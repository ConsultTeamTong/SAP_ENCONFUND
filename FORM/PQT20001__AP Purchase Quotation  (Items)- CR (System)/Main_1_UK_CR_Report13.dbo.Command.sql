-- ============================================================
-- Report: PQT20001__AP Purchase Quotation  (Items)- CR (System).rpt
Path:   PQT20001__AP Purchase Quotation  (Items)- CR (System).rpt
Extracted: 2026-05-07 18:03:22
-- Source: Main Report
-- Table:  UK_CR_Report13.dbo.Command
-- ============================================================

SELECT "BankCode", "BankName", "SwiftNum" FROM ODSC WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM)
