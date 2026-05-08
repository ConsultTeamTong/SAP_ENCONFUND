-- ============================================================
-- Report: A0050001__Withholding Tax certificate (53) v28.rpt
Path:   A0050001__Withholding Tax certificate (53) v28.rpt
Extracted: 2026-05-07 18:02:34
-- Source: Subreport [WhtDetail]
-- Table:  Command
-- ============================================================

WITH FTTV AS(
SELECT 
  ROW_NUMBER() OVER (
    Partition By "B"."TransId", "WHTDate",
    "CardCode" 
    ORDER BY 
      "B"."TransId", 
      "CardCode"
  ) As "Row", 
  "B"."TransId", 
  Sum("B"."TaxbleAmnt") As "TaxbleAmnt", 
  Sum("B"."WTAmnt") As "WTAmnt", 
  LEFT(TO_VARCHAR(ADD_YEARS("B"."TaxDate", 543),'YYYYMMDD'),4) AS "WHTDate",
  "B"."TaxDate",
  "B"."WTCode", 
  "B"."WTName", 
  "B"."CardCode", 
  "B"."LicTradNum" ,
  "B"."RunNo"
FROM 
  (
    SELECT  '"OVPM"' AS TYPE, 
    (SELECT MAX("U_DocWht" ) FROM {?Schema@}."@SLDT_WTS_TST" WHERE "U_Status" = 'Y' AND  "U_TransID" = "OVPM"."TransId" ) AS "RunNo",
      "OVPM"."TransId", 
      "OVPM"."CardCode", 
      CASE WHEN "CHWTH"."WTCode" IS NULL THEN "VPM6"."TaxbleAmnt" ELSE "WTH"."TaxbleAmnt" END AS "TaxbleAmnt",
      CASE WHEN "CHWTH"."WTCode" IS NULL THEN "VPM6"."WTSum" ELSE "WTH"."WTAmnt" END AS "WTAmnt",
      "OVPM"."TaxDate" as "WHTDate",
      "OVPM"."TaxDate", 
      "OCRD"."LicTradNum", 
      "OWHT"."WTCode", 
      "OWHT"."WTName" 
    FROM 
      {?Schema@}."OVPM" 
      LEFT JOIN {?Schema@}."VPM6" ON "OVPM"."DocEntry" = "VPM6"."DocNum" 
      LEFT JOIN {?Schema@}."OWHT" ON "VPM6"."WTCode" = "OWHT"."WTCode" 
      LEFT JOIN {?Schema@}."OCRD" ON "OCRD"."CardCode" = "OVPM"."CardCode" 
      LEFT JOIN (SELECT DISTINCT "DocNum", "WTCode" 
      				FROM {?Schema@}."VPM6" 
			        WHERE "VPM6"."WTSum" < 0 
		) AS "CHWTH" ON "OVPM"."DocEntry" = "CHWTH"."DocNum" 
      LEFT JOIN (SELECT "VPM6"."DocNum",
                        "VPM6"."WTCode",
                        "VPM6"."Line",
                        SUM("VPM6"."WTSum") AS "WTAmnt" ,
                        ((SUM("VPM6"."WTSum")*100)/"OWHT"."Rate") AS "TaxbleAmnt" 
                 FROM {?Schema@}."VPM6"
                 LEFT JOIN {?Schema@}."OWHT" ON "OWHT"."WTCode" = "VPM6"."WTCode"
                 GROUP BY "VPM6"."DocNum","VPM6"."WTCode","OWHT"."Rate","VPM6"."Line"
		) AS "WTH" ON "OVPM"."DocEntry" = "WTH"."DocNum" AND "WTH"."WTCode" = "VPM6"."WTCode" AND "WTH"."Line" = "VPM6"."Line"
    WHERE 
      "OVPM"."TransId" IN (
        SELECT 
          "TransId" 
        FROM 
          {?Schema@}."JDT1" 
        WHERE 
          "JDT1"."ShortName" = (
            SELECT 
              "AcctCode" 
            FROM 
              {?Schema@}."OACT" 
            WHERE 
              "FormatCode" = (
                SELECT 
                  "Name" 
                FROM 
                  {?Schema@}."@SLDT_SET_ACCWH" 
                WHERE 
                  "U_SLD_TypeWH" = '53'
              )
          )
      )
-----------------------------------------------   
    UNION ALL 
-------------------------------------------------    
    SELECT 
      '"OPCH"' AS TYPE, 
      (	SELECT MAX("U_DocWht" )FROM {?Schema@}."@SLDT_WTS_TST" WHERE "U_Status" = 'Y' AND "U_TransID" = "OPCH"."TransId") AS "RunNo",
      "OPCH"."TransId", 
      "OPCH"."CardCode", 
      "PCH5"."TaxbleAmnt", 
      "PCH5"."WTAmnt" AS "WTAmnt", 
      "OPCH"."TaxDate" as "WHTDate", 
      "OPCH"."TaxDate",
      "OPCH"."LicTradNum", 
      "OWHT"."WTCode", 
      "OWHT"."WTName" 
    FROM 
      {?Schema@}."OPCH" 
      JOIN {?Schema@}."PCH5" ON "OPCH"."DocEntry" = "PCH5"."AbsEntry" 
      JOIN {?Schema@}."OWHT" ON "PCH5"."WTCode" = "OWHT"."WTCode" 
    WHERE 
      "OPCH"."TransId" IN (
        SELECT 
          "TransId" 
        FROM 
          {?Schema@}."JDT1" 
        WHERE 
          "JDT1"."ShortName" = (
            SELECT 
              "AcctCode" 
            FROM 
              {?Schema@}."OACT" 
            WHERE 
              "FormatCode" = (
                SELECT 
                  "Name" 
                FROM 
                  {?Schema@}."@SLDT_SET_ACCWH" 
                WHERE 
                  "U_SLD_TypeWH" = '53'
              )
          )
      ) 
----------------------------------------------------------      
    UNION ALL 
----------------------------------------------------------    
    SELECT 
      '"OJDT"' AS "TYPE",
      (	SELECT MAX("U_DocWht" ) FROM {?Schema@}."@SLDT_WTS_TST" WHERE "U_Status" = 'Y' AND "U_TransID" = "OJDT"."TransId") AS "RunNo", 
      "JDT1"."TransId", 
      "JDT1"."U_SLD_SuppCode", 
      "JDT2"."TaxbleAmnt" AS "TaxbleAmnt", 
      "JDT2"."WTAmnt", 
      "JDT1"."TaxDate" as "WHTDate",
      "JDT1"."TaxDate",
      IFNULL(
        "JDT1"."LicTradNum", "JDT1"."U_SLD_LBPTaxID"
      ) AS "LicTradNum", 
      "JDT2"."WTCode", 
      (
        SELECT 
          "WTName" 
        FROM 
          {?Schema@}."OWHT" 
        WHERE 
          "WTCode" = "JDT2"."WTCode"
      ) AS "WTName" 
    FROM 
      {?Schema@}."JDT1" 
      INNER JOIN {?Schema@}."OJDT" ON "JDT1"."TransId" = "OJDT"."TransId" 
      INNER JOIN {?Schema@}."JDT2" ON "JDT2"."AbsEntry" = "OJDT"."TransId" 
      AND "JDT2"."Account" = (
        SELECT 
          "AcctCode" 
        FROM 
          {?Schema@}."OACT" 
        WHERE 
          "FormatCode" = (
            SELECT 
              "Name" 
            FROM 
              {?Schema@}."@SLDT_SET_ACCWH" 
            WHERE 
              "U_SLD_TypeWH" = '53'
          )
      ) 
    WHERE 
      "JDT1"."Credit" > 0 
-------------------------------------------------------------------      
    UNION ALL 
-------------------------------------------------------------------    
    SELECT 
      '"OJDT"' AS "TYPE", 
      (Select MAX("U_DocWht") from {?Schema@}."@SLDT_WTS_TST" where "U_Status" = 'Y' And  "U_TransID" = "OJDT"."TransId" AND "U_Date_Wht" = "JDT1"."U_SLD_WHdate") AS "RunNo",
      "JDT1"."TransId", 
      "JDT1"."U_SLD_SuppCode", 
      "JDT1"."U_SLD_WTBaseAmt" AS "TaxbleAmnt", 
      (
        (
          "JDT1"."U_SLD_WTBaseAmt" * (
            SELECT 
              "OWHT"."Rate" 
            FROM 
              {?Schema@}."OWHT" 
            WHERE 
              "OWHT"."WTCode" = "JDT1"."U_SLD_WTCode" 
              AND "JDT1"."ShortName" = (
                SELECT 
                  "AcctCode" 
                FROM 
                  {?Schema@}."OACT" 
                WHERE 
                  "FormatCode" = (
                    SELECT 
                      "Name" 
                    FROM 
                      {?Schema@}."@SLDT_SET_ACCWH" 
                    WHERE 
                      "U_SLD_TypeWH" = '53'
                  )
              )
          )
        ) / 100.0
      ) AS "WTAmnt", 
      "JDT1"."U_SLD_WHdate" as "WHTDate",
      "JDT1"."TaxDate",
      IFNULL(
        "JDT1"."LicTradNum", "JDT1"."U_SLD_LBPTaxID"
      ) AS "LicTradNum", 
      (
        SELECT 
          "OWHT"."WTCode" 
        FROM 
          {?Schema@}."OWHT" 
        WHERE 
          "OWHT"."WTCode" = "JDT1"."U_SLD_WTCode" 
          AND "JDT1"."ShortName" = (
            SELECT 
              "AcctCode" 
            FROM 
              {?Schema@}."OACT" 
            WHERE 
              "FormatCode" = (
                SELECT 
                  "Name" 
                FROM 
                  {?Schema@}."@SLDT_SET_ACCWH" 
                WHERE 
                  "U_SLD_TypeWH" = '53'
              )
          )
      ) "WTCode", 
      (
        SELECT 
          "OWHT"."WTName" 
        FROM 
          {?Schema@}."OWHT" 
        WHERE 
          "OWHT"."WTCode" = "JDT1"."U_SLD_WTCode" 
          AND "JDT1"."ShortName" = (
            SELECT 
              "AcctCode" 
            FROM 
              {?Schema@}."OACT" 
            WHERE 
              "FormatCode" = (
                SELECT 
                  "Name" 
                FROM 
                  {?Schema@}."@SLDT_SET_ACCWH" 
                WHERE 
                  "U_SLD_TypeWH" = '53'
              )
          )
      ) "WTName" 
    FROM 
      {?Schema@}."JDT1" 
      JOIN {?Schema@}."OJDT" ON "JDT1"."TransId" = "OJDT"."TransId" 
    WHERE 
      (
        "JDT1"."ShortName" = (
          SELECT 
            "AcctCode" 
          FROM 
            {?Schema@}."OACT" 
          WHERE 
            "FormatCode" = (
              SELECT 
                "Name" 
              FROM 
                {?Schema@}."@SLDT_SET_ACCWH" 
              WHERE 
                "U_SLD_TypeWH" = '53'
            )
        )
      )
  ) AS "B" 
WHERE 
  "B"."WTCode" IS NOT NULL 
Group by 
  "B"."TransId", 
  "B"."WHTDate",
  "B"."TaxDate",
  "B"."WTCode", 
  "B"."WTName", 
  "CardCode", 
  "B"."LicTradNum" ,
  "B"."RunNo"
ORDER BY 
  "B"."TransId"
  )
  -------------------------------------------------------
  SELECT FTTV.*,"CROW"."CRunNo" FROM FTTV LEFT JOIN (SELECT COUNT(FTTV."RunNo") AS "CRunNo" , FTTV."RunNo" FROM FTTV GROUP BY FTTV."RunNo") AS "CROW" ON "CROW"."RunNo" = FTTV."RunNo"
