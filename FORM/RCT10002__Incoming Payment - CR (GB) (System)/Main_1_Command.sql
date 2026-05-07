-- ============================================================
-- Report: RCT10002__Incoming Payment - CR (GB) (System).rpt
Path:   RCT10002__Incoming Payment - CR (GB) (System).rpt
Extracted: 2026-05-07 18:03:45
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT "BankCode", "BankName", "SwiftNum" FROM ODSC WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM)
