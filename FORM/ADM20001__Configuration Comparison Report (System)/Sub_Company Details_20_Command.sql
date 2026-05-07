-- ============================================================
-- Report: ADM20001__Configuration Comparison Report (System).rpt
Path:   ADM20001__Configuration Comparison Report (System).rpt
Extracted: 2026-05-07 18:02:38
-- Source: Subreport [Company Details ]
-- Table:  Command
-- ============================================================

SELECT OCNA.* FROM OCNA INNER JOIN AADM ON AADM."DflTaxCode"=CAST(OCNA."AbsId" AS VARCHAR(10)) WHERE AADM."SnapShotId" = {?SnapshotId1}
