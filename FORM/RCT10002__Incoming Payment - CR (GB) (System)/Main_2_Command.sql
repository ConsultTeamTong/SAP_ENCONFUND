-- ============================================================
-- Report: RCT10002__Incoming Payment - CR (GB) (System).rpt
Path:   RCT10002__Incoming Payment - CR (GB) (System).rpt
Extracted: 2026-05-07 18:03:45
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT "Account", "IBAN" FROM DSC1 WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM) AND "Account" = (SELECT "DflBnkAcct" FROM OADM)
