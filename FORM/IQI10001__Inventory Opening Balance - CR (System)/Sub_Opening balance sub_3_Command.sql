-- ============================================================
-- Report: IQI10001__Inventory Opening Balance - CR (System).rpt
Path:   IQI10001__Inventory Opening Balance - CR (System).rpt
Extracted: 2026-05-07 18:03:08
-- Source: Subreport [Opening balance sub]
-- Table:  Command
-- ============================================================

select count(*) as "Count" from "IQI1" where "DocEntry"={?DOCKEY}  and "BinEntry" is not null
