-- ============================================================
-- Report: ADM20001__Configuration Comparison Report (System).rpt
Path:   ADM20001__Configuration Comparison Report (System).rpt
Extracted: 2026-05-07 18:02:38
-- Source: Subreport [Company Details ]
-- Table:  Command
-- ============================================================

SELECT "Code", "LocCode", "Name" FROM {?commonDBName}.SLSC
UNION
SELECT 'U' AS "Code", 'XX' AS "LocCode", 'User-Defined' AS "Name" FROM DUMMY
