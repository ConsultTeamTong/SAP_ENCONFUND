-- ============================================================
-- Report: A0060001__Withholding Income Tax Return (P.N.D.3)v28.rpt
Path:   A0060001__Withholding Income Tax Return (P.N.D.3)v28.rpt
Extracted: 2026-05-07 18:02:34
-- Source: Main Report
-- Table:  Command
-- ============================================================

Select "Code",
"U_SLD_VTAXID",
"U_SLD_VComAddress",
"U_SLD_VComName"  
From "{?Schema@}"."@SLDT_SET_BRANCH"
