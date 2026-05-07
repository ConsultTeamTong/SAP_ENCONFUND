-- ============================================================
-- Report: ADM30001__Saved Configuration Report (System).rpt
Path:   ADM30001__Saved Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:40
-- Source: Subreport [GL Account Determination]
-- Table:  Command
-- ============================================================

SELECT "PeriodCat", "DfltCard" 
FROM AACP 
WHERE "SnapShotId" = {?SnapshotID} AND "PeriodCat" = '{?OACPCategory}'
