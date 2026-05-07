-- ============================================================
-- Report: RCT10003__Incoming Payment Draft - CR (GB) (System).rpt
Path:   RCT10003__Incoming Payment Draft - CR (GB) (System).rpt
Extracted: 2026-05-07 18:03:45
-- Source: Main Report
-- Table:  Command
-- ============================================================

select "Account", "IBAN" from dsc1 where "BankCode" = (select "DflBnkCode" from OADM) and "Account" = (select "DflBnkAcct" from OADM) 
