-- ============================================================
-- Report: A0060001__Withholding Income Tax Return (P.N.D.3)v28.rpt
Path:   FORM\A006__Withholding Income Tax Return (P.N.D.3)v28\A0060001__Withholding Income Tax Return (P.N.D.3)v28.rpt
Extracted: 2026-07-01 09:28:02
-- Source: Main Report
-- Table:  ContactDetail
-- ============================================================

Select "Code",
"U_SLD_VTAXID",
"U_SLD_VComAddress",
"U_SLD_VComName"  
From "{?Schema@}"."@SLDT_SET_BRANCH"
