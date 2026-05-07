-- ============================================================
-- Report: QUT10002__AR Sales Quotation (Service) - CR (GB) (System).rpt
Path:   QUT10002__AR Sales Quotation (Service) - CR (GB) (System).rpt
Extracted: 2026-05-07 18:03:29
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT "Account", "IBAN" FROM DSC1 WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM) AND "Account" = (SELECT "DflBnkAcct" FROM OADM) 

