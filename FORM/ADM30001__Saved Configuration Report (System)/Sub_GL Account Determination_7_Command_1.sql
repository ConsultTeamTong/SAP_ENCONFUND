-- ============================================================
-- Report: ADM30001__Saved Configuration Report (System).rpt
Path:   ADM30001__Saved Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:40
-- Source: Subreport [GL Account Determination]
-- Table:  Command_1
-- ============================================================

SELECT "Name" FROM OVTG T0 RIGHT JOIN AADM T1 ON T0."Code" = T1."DfSVatServ" WHERE T1."SnapShotId" ={?SnapshotID}
