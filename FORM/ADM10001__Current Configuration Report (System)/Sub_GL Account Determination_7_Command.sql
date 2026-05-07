-- ============================================================
-- Report: ADM10001__Current Configuration Report (System).rpt
Path:   ADM10001__Current Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:38
-- Source: Subreport [GL Account Determination]
-- Table:  Command
-- ============================================================

SELECT "Name" FROM OVTG T0 RIGHT JOIN OADM T1 ON T0."Code" = T1."DfPVatServ"
