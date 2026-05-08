-- ============================================================
-- Report: RCRI0003__Payment Orders Report by Business Partner.rpt
Path:   RCRI0003__Payment Orders Report by Business Partner.rpt
Extracted: 2026-05-07 18:03:31
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT "CurOnRight", "MainCurncy", "DateFormat", "CharMonth", "DateSep", "TimeFormat", 
"SumDec", "QtyDec", "PriceDec", "RateDec", "PercentDec", "DecSep", "ThousSep", 
"CompnyName", "LogoFile", "LogoImage", "MnhlNote"
FROM OADM, OADP
