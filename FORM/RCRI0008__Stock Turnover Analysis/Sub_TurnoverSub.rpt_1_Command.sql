-- ============================================================
-- Report: RCRI0008__Stock Turnover Analysis.rpt
Path:   RCRI0008__Stock Turnover Analysis.rpt
Extracted: 2026-05-07 18:03:33
-- Source: Subreport [TurnoverSub.rpt]
-- Table:  Command
-- ============================================================

	Select	"MainCurncy",
			"DateFormat",
			"CharMonth",
			"DateSep",
			"TimeFormat",
			"SumDec",
			"QtyDec",
			"PriceDec",
			"RateDec",
			"PercentDec",
			"DecSep",
			"ThousSep",
			"CompnyName",
			"LogoFile",
			"LogoImage",
			"MnhlNote"
	From "{?Schema}"."OADM", "{?Schema}"."OADP"
