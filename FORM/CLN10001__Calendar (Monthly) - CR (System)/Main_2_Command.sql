-- ============================================================
-- Report: CLN10001__Calendar (Monthly) - CR (System).rpt
Path:   CLN10001__Calendar (Monthly) - CR (System).rpt
Extracted: 2026-05-07 18:02:51
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT T0."LogoFile", T0."LogoImage", T0."MnhlNote", T1."DecSep", T1."DateSep", T1."TimeFormat", T1."DateFormat", T1."ThousSep", T1."CurOnRight", T1."CompnyName", T1."MainCurncy", T1."SumDec", T1."CharMonth" 
FROM OADP T0, OADM T1
