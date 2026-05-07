-- ============================================================
-- Report: ADM20001__Configuration Comparison Report (System).rpt
Path:   ADM20001__Configuration Comparison Report (System).rpt
Extracted: 2026-05-07 18:02:38
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT "ConfigEntr", "ConfigName", "ServerName", "Version", "U_NAME" FROM CCFG, AINF, AUSR WHERE CCFG."ConfigEntr" = AINF."SnapShotId" AND CCFG."ConfigEntr" = AUSR."SnapShotId" AND CCFG."UserCode" = AUSR."USERID"
