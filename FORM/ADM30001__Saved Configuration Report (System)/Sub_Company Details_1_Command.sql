-- ============================================================
-- Report: ADM30001__Saved Configuration Report (System).rpt
Path:   ADM30001__Saved Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:40
-- Source: Subreport [Company Details]
-- Table:  Command
-- ============================================================

SELECT "CurrName" FROM AADM LEFT JOIN OCRN ON "SysCurrncy" = "CurrCode" WHERE AADM."SnapShotId" = {?SnapshotID}
