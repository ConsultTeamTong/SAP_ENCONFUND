-- ============================================================
-- Report: RCRI0004__Payment Orders Report by Payment Run.rpt
Path:   RCRI0004__Payment Orders Report by Payment Run.rpt
Extracted: 2026-05-07 18:03:31
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT "CurOnRight", "MainCurncy", "DateFormat", "CharMonth", "DateSep", "TimeFormat", 
"SumDec", "QtyDec", "PriceDec", "RateDec", "PercentDec", "DecSep", "ThousSep", "ActSep", 
OADM."CompnyName", "LogoFile", "LogoImage", "MnhlNote", "EnbSgmnAct", "ActSegNum"
FROM OADM, OADP, CINF
