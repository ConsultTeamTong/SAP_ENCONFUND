-- ============================================================
-- Report: RCRI0009__Monthly Customer Status.rpt
Path:   RCRI0009__Monthly Customer Status.rpt
Extracted: 2026-05-07 18:03:33
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT "MainCurncy", "DateFormat", "CharMonth", "DateSep", "TimeFormat", 
"SumDec", "QtyDec", "PriceDec", "RateDec", "PercentDec", "DecSep", "ThousSep", 
"CompnyName", "LogoFile", "LogoImage", "MnhlNote" 
FROM "{?Schema@}".OADM, "{?Schema@}".OADP
