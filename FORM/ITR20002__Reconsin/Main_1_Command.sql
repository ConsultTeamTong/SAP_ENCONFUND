-- ============================================================
-- Report: ITR20002__Reconsin.rpt
Path:   ITR20002__Reconsin.rpt
Extracted: 2026-05-07 18:03:10
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT *
FROM {?Schema@}.ITR1
WHERE "ReconNum" = {?DocKey@}
AND "SrcObjTyp" = {?ObjectId@}
