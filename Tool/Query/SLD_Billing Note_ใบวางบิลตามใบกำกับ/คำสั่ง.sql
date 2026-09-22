-- ============================================================
-- Report: SLD_Billing Note_ใบวางบิลตามใบกำกับ.rpt
Path:   SLD_Billing Note_ใบวางบิลตามใบกำกับ.rpt
Extracted: 2026-07-13 10:45:18
-- Source: Main Report
-- Table:  คำสั่ง
-- ============================================================

SELECT 
T0.[CompnyName]
, T1.[Street]
, T1.[StreetNo]
, T1.[Block]
, T1.[Building]
, T1.[City]
, T1.[County]
, T1.[ZipCode]
, T0.[Phone1]
, T0.[Phone2]
, T0.[Fax]
, T0.[E_Mail]
, T0.[TaxIdNum]
, T0.[PrintHeadr]
, T0.[PrintHdrF]
, T1.[StreetF]
, T1.[StreetNoF]
, T1.[BlockF]
, T1.[BuildingF]
, T1.[CityF]
, T1.[CountyF]
, T1.[ZipCodeF]
,T1.[IntrntAdrs]
, T0.[E_Mail] 
, T0.[Phone1]
, T0.[Phone2]
, T0.[Fax]
, T0.[TaxIdNum]
, T0.[PrintHeadr]
, T0.[PrintHdrF] 
FROM OADM T0 , ADM1 T1
