-- ============================================================
-- Report: RCRI0008__Stock Turnover Analysis.rpt
Path:   RCRI0008__Stock Turnover Analysis.rpt
Extracted: 2026-05-07 18:03:33
-- Source: Subreport [TurnoverSub.rpt]
-- Table:  Command
-- ============================================================

Call "{?Schema}".CRSP_INVENTORY_TURNOVER_RATE('{?FromDate}','{?ToDate}', '{?Items}')
