-- ============================================================
-- Report: RCRI0027__ทะเบียนคุมหลักประกันสัญญา (หนังสือค้ำประกัน).rpt
Path:   RCRI0027__ทะเบียนคุมหลักประกันสัญญา (หนังสือค้ำประกัน).rpt
Extracted: 2026-05-07 18:03:41
-- Source: Main Report
-- Table:  Command
-- ============================================================

  SELECT
      OOAT."StartDate",
      OOAT."Descript",
      OAT2."U_SLD_Receipt_Number",
      OOAT."U_SLD_Contract_Number",
      OAT2."FromDate",
      OAT2."U_SLD_Amount",
      OOAT."BpName",
      OAT2."U_SLD_Bank",
      OAT2."U_SLD_Type",
      OAT2."U_SLD_Start_Date",
      OAT2."U_SLD_End_Date",
      OAT2."U_SLD_Remark",
      LEFT(OFPR."Indicator", 4) AS Indicator
  FROM "{?Schema@}".OOAT
  LEFT JOIN "{?Schema@}".OAT2
         ON OOAT."AbsID" = OAT2."AgrNo"
  LEFT JOIN "{?Schema@}".OFPR
         ON OOAT."StartDate" BETWEEN OFPR."F_RefDate" AND
  OFPR."T_RefDate"
  WHERE 1=1
    AND LEFT(OFPR."Indicator", 4) = TO_VARCHAR(TO_INT({?Period@}) -
  543)
    AND OAT2."U_SLD_Type" = 02;
