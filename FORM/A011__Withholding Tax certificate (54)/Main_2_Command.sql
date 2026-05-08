-- ============================================================
-- Report: A0110001__Withholding Tax certificate (54).rpt
Path:   A0110001__Withholding Tax certificate (54).rpt
Extracted: 2026-05-07 18:02:37
-- Source: Main Report
-- Table:  Command
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
