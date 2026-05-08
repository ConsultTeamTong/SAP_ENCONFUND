-- ============================================================
-- Report: RCRI0009__Monthly Customer Status.rpt
Path:   RCRI0009__Monthly Customer Status.rpt
Extracted: 2026-05-07 18:03:33
-- Source: Subreport [BPMonthlySub.rpt]
-- Table:  Command
-- ============================================================

SELECT "MainCurncy", "DateFormat", "CharMonth", "DateSep", "TimeFormat", 
"SumDec", "QtyDec", "PriceDec", "RateDec", "PercentDec", "DecSep", "ThousSep", 
"CompnyName", "LogoFile", "LogoImage" 
FROM "{?Schema}".OADM, "{?Schema}".OADP
