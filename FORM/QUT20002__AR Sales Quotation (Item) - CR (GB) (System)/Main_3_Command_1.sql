-- ============================================================
-- Report: QUT20002__AR Sales Quotation (Item) - CR (GB) (System).rpt
Path:   QUT20002__AR Sales Quotation (Item) - CR (GB) (System).rpt
Extracted: 2026-05-07 18:03:30
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT "Account", "IBAN" FROM DSC1 WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM) AND "Account" = (SELECT "DflBnkAcct" FROM OADM)
