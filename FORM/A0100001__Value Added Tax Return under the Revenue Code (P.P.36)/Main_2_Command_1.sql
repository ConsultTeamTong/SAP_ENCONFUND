-- ============================================================
-- Report: A0100001__Value Added Tax Return under the Revenue Code (P.P.36).rpt
Path:   A0100001__Value Added Tax Return under the Revenue Code (P.P.36).rpt
Extracted: 2026-05-07 18:02:37
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

Select "Code",
	"U_SLD_VTAXID",
	"U_SLD_VComName",
	"U_SLD_Building",
	"U_SLD_Steet",
	"U_SLD_Block",
	"U_SLD_City",
	"U_SLD_County",
	"U_SLD_ZipCode",
	"U_SLD_Tel",
	"U_SLD_VComAddress"
	 
From {?Schema@}."@SLDT_SET_BRANCH"
