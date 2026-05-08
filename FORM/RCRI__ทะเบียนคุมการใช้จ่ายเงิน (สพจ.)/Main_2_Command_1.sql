-- ============================================================
-- Report: RCRI0025__ทะเบียนคุมการใช้จ่ายเงิน (สพจ.).rpt
Path:   RCRI0025__ทะเบียนคุมการใช้จ่ายเงิน (สพจ.).rpt
Extracted: 2026-05-07 18:03:40
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT DISTINCT (OFPR."Category"+543) AS "Category"
FROM {?Schema@}.OFPR
WHERE {?1DStart@} BETWEEN "F_RefDate" AND "T_RefDate"
