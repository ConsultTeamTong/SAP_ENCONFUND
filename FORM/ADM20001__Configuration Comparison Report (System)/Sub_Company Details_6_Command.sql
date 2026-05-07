-- ============================================================
-- Report: ADM20001__Configuration Comparison Report (System).rpt
Path:   ADM20001__Configuration Comparison Report (System).rpt
Extracted: 2026-05-07 18:02:38
-- Source: Subreport [Company Details ]
-- Table:  Command
-- ============================================================

Select "Name" from OCRY T0 right join AADM T1 on T0."Code" = T1."BankCountr" where T1."SnapShotId"= {?SnapshotId2}
