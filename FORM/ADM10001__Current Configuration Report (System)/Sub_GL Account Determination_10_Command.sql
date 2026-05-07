-- ============================================================
-- Report: ADM10001__Current Configuration Report (System).rpt
Path:   ADM10001__Current Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:38
-- Source: Subreport [GL Account Determination]
-- Table:  Command
-- ============================================================

SELECT "PeriodCat", "DfltCard" 
FROM OACP 
WHERE "PeriodCat" = '{?OACPCategory}'
