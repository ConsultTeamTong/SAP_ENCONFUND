-- ============================================================
-- Report: RCT10003__Incoming Payment Draft - CR (GB) (System).rpt
Path:   RCT10003__Incoming Payment Draft - CR (GB) (System).rpt
Extracted: 2026-05-07 18:03:45
-- Source: Main Report
-- Table:  Command
-- ============================================================

select "BankCode", "BankName", "SwiftNum" from odsc where "BankCode" = (select "DflBnkCode" from OADM)
