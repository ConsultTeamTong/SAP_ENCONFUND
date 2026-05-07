-- ============================================================
-- Report: ADM30001__Saved Configuration Report (System).rpt
Path:   ADM30001__Saved Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:40
-- Source: Subreport [Document Settings]
-- Table:  Command
-- ============================================================

SELECT "ListNum", "ListName" FROM OPLN
UNION
SELECT '-1' AS "ListNum", 'Last Purchase Price' AS "ListName" FROM DUMMY
UNION
SELECT '-2' AS "ListNum", 'Last Evaluated Price' AS "ListName" FROM DUMMY
UNION
SELECT '-5' AS "ListNum", 'Item Cost' AS "ListName" FROM DUMMY
