-- ============================================================
-- Report: PRQ10001__AP Purchase Request (Service) - CR (System).rpt
Path:   PRQ10001__AP Purchase Request (Service) - CR (System).rpt
Extracted: 2026-05-07 18:03:25
-- Source: Main Report
-- Table:  UK_CR_Report13.dbo.Command
-- ============================================================

select "BankCode", "BankName", "SwiftNum" from odsc where "BankCode" = (select "DflBnkCode" from OADM)
