-- ============================================================
-- Report: ADM20001__Configuration Comparison Report (System).rpt
Path:   ADM20001__Configuration Comparison Report (System).rpt
Extracted: 2026-05-07 18:02:38
-- Source: Subreport [Company Details ]
-- Table:  Command
-- ============================================================

SELECT "Name" FROM OCST RIGHT JOIN AADM ON OCST."Code" = AADM."State" AND
OCST."Country" = AADM."Country" WHERE AADM."SnapShotId" = {?SnapshotId2}
