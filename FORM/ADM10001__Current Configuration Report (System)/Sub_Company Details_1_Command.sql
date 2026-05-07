-- ============================================================
-- Report: ADM10001__Current Configuration Report (System).rpt
Path:   ADM10001__Current Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:38
-- Source: Subreport [Company Details]
-- Table:  Command
-- ============================================================

SELECT OSTC.* FROM OSTC INNER JOIN OADM ON OADM."DflTaxCode"=OSTC."Code"
