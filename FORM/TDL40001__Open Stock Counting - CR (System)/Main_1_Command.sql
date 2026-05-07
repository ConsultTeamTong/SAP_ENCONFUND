-- ============================================================
-- Report: TDL40001__Open Stock Counting - CR (System).rpt
Path:   TDL40001__Open Stock Counting - CR (System).rpt
Extracted: 2026-05-07 18:04:03
-- Source: Main Report
-- Table:  Command
-- ============================================================

Select "T0"."DocEntry", "T0"."CountDate", "T0"."Time", "T0"."CountType", "T0"."IndvCount", "T0"."TeamCount", "T0"."Ref2" from "OINC" "T0" where "T0"."Status" = 'O'
