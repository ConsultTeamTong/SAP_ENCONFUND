-- ============================================================
-- Report: PCH10002__APInvoice Enconfund.rpt
Path:   FORM\PCH1__AP Invoice Enconfund\PCH10002__APInvoice Enconfund.rpt
Extracted: 2026-07-01 09:28:10
-- Source: Main Report
-- Table:  เลขที่
-- ============================================================

SELECT  "U_SLD_Document_Number"
FROM {?Schema@}."OPCH"
WHERE "DocEntry" = {?DocKey@}
