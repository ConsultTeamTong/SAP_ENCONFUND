-- ============================================================
-- Report: QUT10002__AR Sales Quotation (Service) - CR (GB) (System).rpt
Path:   QUT10002__AR Sales Quotation (Service) - CR (GB) (System).rpt
Extracted: 2026-05-07 18:03:29
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT "BankCode", "BankName", "SwiftNum" FROM ODSC WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM)
