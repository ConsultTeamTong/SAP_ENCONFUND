-- ============================================================
-- Report: ITR20002__Reconsin.rpt
Path:   FORM\ITR2__Reconsin\ITR20002__Reconsin.rpt
Extracted: 2026-07-01 09:28:07
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT *
FROM {?Schema@}.ITR1
WHERE "ReconNum" = {?DocKey@}
AND "SrcObjTyp" = {?ObjectId@}
