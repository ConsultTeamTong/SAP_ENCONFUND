-- ============================================================
-- Report: ADM30001__Saved Configuration Report (System).rpt
Path:   ADM30001__Saved Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:40
-- Source: Subreport [Company Details]
-- Table:  Command
-- ============================================================

SELECT OCNT.* FROM OCNT INNER JOIN AAD1 ON AAD1."County"=CAST(OCNT."AbsId" AS VARCHAR(10)) WHERE AAD1."SnapShotId" = {?SnapshotID}
