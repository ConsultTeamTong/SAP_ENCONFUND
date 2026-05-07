-- ============================================================
-- Report: VPM10003__Outgoing Payment Draft - CR (GB) (System).rpt
Path:   VPM10003__Outgoing Payment Draft - CR (GB) (System).rpt
Extracted: 2026-05-07 18:04:05
-- Source: Main Report
-- Table:  Command
-- ============================================================

select "BankCode", "BankName", "SwiftNum" from odsc where "BankCode" = (select "DflBnkCode" from OADM)
