-- ============================================================
-- Report: PRQ20001__AP Purchase Request (Items)- CR (System).rpt
Path:   PRQ20001__AP Purchase Request (Items)- CR (System).rpt
Extracted: 2026-05-07 18:03:27
-- Source: Main Report
-- Table:  UK_CR_Report13.dbo.Command
-- ============================================================

select "BankCode", "BankName", "SwiftNum" from odsc where "BankCode" = (select "DflBnkCode" from OADM)
