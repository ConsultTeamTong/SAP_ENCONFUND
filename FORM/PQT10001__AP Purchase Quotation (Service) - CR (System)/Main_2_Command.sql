-- ============================================================
-- Report: PQT10001__AP Purchase Quotation (Service) - CR (System).rpt
Path:   PQT10001__AP Purchase Quotation (Service) - CR (System).rpt
Extracted: 2026-05-07 18:03:21
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT "Account", "IBAN" FROM DSC1 WHERE "BankCode" = (SELECT "DflBnkCode" FROM OADM) AND "Account" = (SELECT "DflBnkAcct" FROM OADM) 

