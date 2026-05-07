-- ============================================================
-- Report: VPM10002__Outgoing Payment - CR (GB) (System).rpt
Path:   VPM10002__Outgoing Payment - CR (GB) (System).rpt
Extracted: 2026-05-07 18:04:04
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT "BankCode", "BankName", "SwiftNum" FROM ODSC WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM)
