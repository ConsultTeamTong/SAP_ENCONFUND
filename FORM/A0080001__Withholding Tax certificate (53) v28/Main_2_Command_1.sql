-- ============================================================
-- Report: A0080001__Withholding Tax certificate (53) v28.rpt
Path:   A0080001__Withholding Tax certificate (53) v28.rpt
Extracted: 2026-05-07 18:02:36
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT 
  SUM("TaxbleAmnt") AS "TaxbleAmnt", 
  SUM("WTAmnt") AS "WTAmnt", 
  "C"."Branch" AS "Branch" 
    ,(SELECT DISTINCT ROW_NUMBER() OVER ( ORDER BY "U_DocNum") AS Row
			FROM 
			(SELECT DISTINCT
			"U_DocNum","Name"
			FROM  {?Schema@}."@SLDT_RT_TST" 
			where "U_DocNum" IS NOT NULL AND "U_TaxType" = '5' and "Name"  IN ({?Dockey@}) 
			) AS "YearMount"
			ORDER BY Row DESC LIMIT 1) AS Row
			  ,(SELECT DISTINCT Year
			FROM 
			(SELECT DISTINCT
			CAST((Left("U_Date", 4)) AS INT) + 543 AS Year
			FROM  {?Schema@}."@SLDT_RT_TST" 
			where "U_DocNum" IS NOT NULL AND "U_TaxType" = '5' and "Name"  IN ({?Dockey@}) 
			LIMIT 1
			) AS "YearMount") AS Year
			,(SELECT DISTINCT "Mount"
			FROM 
			(SELECT DISTINCT
			RIGHT(LEFT("U_Date", 6),2) AS "Mount"

			FROM  {?Schema@}."@SLDT_RT_TST" 
			where "U_DocNum" IS NOT NULL AND "U_TaxType" = '5' and "Name"   IN ({?Dockey@}) 
			LIMIT 1
			) AS "YearMount") AS "Mount"
FROM 
  (
    SELECT DISTINCT
      ROW_NUMBER() OVER (ORDER BY  "B"."TransId") AS "Row", 
      "B"."TransId", 
      SUM("B"."TaxbleAmnt") AS "TaxbleAmnt", 
      SUM("B"."WTAmnt") AS "WTAmnt", 
      "B"."Branch" AS "Branch"

    FROM 
      (
        SELECT 
          'OVPM' AS "TYPE", 
          "OVPM"."TransId", 
			CASE WHEN "CHWTH"."WTCode" IS NULL THEN "VPM6"."TaxbleAmnt" ELSE "WTH"."TaxbleAmnt" END AS "TaxbleAmnt", 
      		CASE WHEN "CHWTH"."WTCode" IS NULL THEN "VPM6"."WTSum" ELSE "WTH"."WTAmnt" END AS "WTAmnt",
          "OVPM"."TaxDate" AS "WHTDate", 
          "OWHT"."WTCode", 
          "OWHT"."WTName", 
          "OVPM"."U_SLD_VatBranch" AS "Branch" 
        FROM 
          {?Schema@}."OVPM" 
          INNER JOIN {?Schema@}."VPM6" ON {?Schema@}."OVPM"."DocEntry" = "VPM6"."DocNum" 
          INNER JOIN {?Schema@}."OWHT" ON {?Schema@}."VPM6"."WTCode" = "OWHT"."WTCode"
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
-------------------------------------------------------------------------------------------------------------------------------
        UNION ALL
-------------------------------------------------------------------------------------------------------------------------------
        SELECT DISTINCT
          'OPCH' AS "TYPE", 
          "OPCH"."TransId", 
          "PCH5"."TaxbleAmnt", 
          "PCH5"."WTAmnt" AS "WTAmnt", 
          "OPCH"."TaxDate" AS "WHTDate", 
          "OWHT"."WTCode", 
          "OWHT"."WTName", 
          "OPCH"."U_SLD_LVatBranch" AS "Branch" 
        FROM 
          {?Schema@}."OPCH" 
          INNER JOIN {?Schema@}."PCH5" ON {?Schema@}."OPCH"."DocEntry" = "PCH5"."AbsEntry" 
          INNER JOIN {?Schema@}."OWHT" ON {?Schema@}."PCH5"."WTCode" = "OWHT"."WTCode" 
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
-------------------------------------------------------------------------------------------------------------------------------
        UNION ALL
-------------------------------------------------------------------------------------------------------------------------------
        SELECT 
          'OJDT' AS "TYPE", 
          "JDT1"."TransId", 
          "JDT2"."TaxbleAmnt" AS "TaxbleAmnt", 
          "JDT2"."WTAmnt", 
          "JDT1"."TaxDate" AS "WHTdate", 
          "JDT2"."WTCode", 
          (
            SELECT 
              "WTName" 
            FROM 
              {?Schema@}."OWHT" 
            WHERE 
              "WTCode" = "JDT2"."WTCode"
          ) AS "WTName", 
          "OJDT"."U_S_ComVatB" AS "Branch" 
        FROM 
          {?Schema@}."JDT1" 
          INNER JOIN {?Schema@}."OJDT" ON {?Schema@}."JDT1"."TransId" = "OJDT"."TransId" 
          INNER JOIN {?Schema@}."JDT2" ON {?Schema@}."JDT2"."AbsEntry" = "OJDT"."TransId" 
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
-------------------------------------------------------------------------------------------------------------------------------
        UNION ALL
-------------------------------------------------------------------------------------------------------------------------------
        SELECT 
          'OJDT' AS "TYPE", 
          "JDT1"."TransId", 
          "JDT1"."U_SLD_WTBaseAmt" AS "TaxbleAmnt", 
          (
            (
              "JDT1"."U_SLD_WTBaseAmt" * (
                SELECT 
                  MAX("OWHT"."Rate") AS "Rate" 
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
          "JDT1"."U_SLD_WHdate" AS "WHTDate", 
          (
            SELECT 
              MAX("OWHT"."WTCode") AS "WTCode" 
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
          ) AS "WTCode", 
          (
            SELECT 
              MAX("OWHT"."WTName") AS "WTName" 
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
          ) AS "WTName", 
          CASE WHEN "OJDT"."TransType" = '46' THEN 
          		(SELECT {?Schema@}."OVPM"."U_SLD_VatBranch" FROM {?Schema@}."OVPM" WHERE {?Schema@}."OVPM"."TransId" = {?Schema@}."OJDT"."TransId") 
          ELSE {?Schema@}."OJDT"."U_S_ComVatB" END AS "Branch" 
        FROM 
          {?Schema@}."JDT1" 
          INNER JOIN {?Schema@}."OJDT" ON {?Schema@}."JDT1"."TransId" = "OJDT"."TransId" 
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
      ) AS B 
    WHERE 
      "B"."WTCode" IS NOT NULL 
      AND "B"."TransId" IN ({?Dockey@})       
    GROUP BY 
      "B"."TransId", 
      "B"."Branch"
  ) AS C 
GROUP BY C."Branch";
