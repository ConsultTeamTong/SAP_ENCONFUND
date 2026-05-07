-- ============================================================
-- Report: PCH10004__AP Invoice Enconfund.rpt
Path:   PCH10004__AP Invoice Enconfund.rpt
Extracted: 2026-05-07 18:03:17
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT  "U_SLD_Document_Number"
FROM {?Schema@}."OPCH"
WHERE "DocEntry" = {?DocKey@}
