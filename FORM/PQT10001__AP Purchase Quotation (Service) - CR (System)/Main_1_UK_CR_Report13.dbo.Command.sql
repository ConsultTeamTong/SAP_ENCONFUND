-- ============================================================
-- Report: PQT10001__AP Purchase Quotation (Service) - CR (System).rpt
Path:   PQT10001__AP Purchase Quotation (Service) - CR (System).rpt
Extracted: 2026-05-07 18:03:21
-- Source: Main Report
-- Table:  UK_CR_Report13.dbo.Command
-- ============================================================

SELECT "BankCode", "BankName", "SwiftNum" FROM ODSC WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM)
