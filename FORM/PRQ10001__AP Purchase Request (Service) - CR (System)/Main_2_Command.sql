-- ============================================================
-- Report: PRQ10001__AP Purchase Request (Service) - CR (System).rpt
Path:   PRQ10001__AP Purchase Request (Service) - CR (System).rpt
Extracted: 2026-05-07 18:03:25
-- Source: Main Report
-- Table:  Command
-- ============================================================

select "Account", "IBAN" from dsc1 where "BankCode" = (select "DflBnkCode" from OADM) and "Account" = (select "DflBnkAcct" from OADM) 

