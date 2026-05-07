-- ============================================================
-- Report: PQT20001__AP Purchase Quotation  (Items)- CR (System).rpt
Path:   PQT20001__AP Purchase Quotation  (Items)- CR (System).rpt
Extracted: 2026-05-07 18:03:22
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT "Account", "IBAN" FROM DSC1 WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM) AND "Account" = (SELECT "DflBnkAcct" FROM OADM)
