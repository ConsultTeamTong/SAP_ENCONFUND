-- ============================================================
-- Report: A0110001__Withholding Tax certificate (54).rpt
Path:   A0110001__Withholding Tax certificate (54).rpt
Extracted: 2026-05-07 18:02:37
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT ROW_NUMBER() OVER (
        ORDER BY "TaxDate"
    ) AS "ROW",
    C.*
FROM (
 SELECT DISTINCT 
  '' AS "#", 
  "TYPE",
  "TransType","RunNo","DocEntry","DocNum","Canceled","NumAtCard","TransId",
  "CardCode","CardName","U_SLD_Title","U_SLD_CardName","Address","TaxDate",
  "TaxId","U_SLD_VatBranch","U_SLD_VBPBranch",
   "BuildingB","Street","StreetNoB","CityB","CountyB","CountryB","ZipcodeB",
   SUM("TaxbleAmnt")OVER(PARTITION BY "WTCode","DocEntry") AS "TaxbleAmnt",
   SUM("WTAmnt")OVER(PARTITION BY "WTCode","DocEntry") AS "WTAmnt",
   "WHTDate","WTCode","WTName","Rate","U_SLD_WhPayBy","Account","TypWTReprt"
    
FROM (
	SELECT DISTINCT 'OVPM' AS "TYPE",
            (SELECT "TransType" 
                FROM {?Schema@}."OJDT"
                WHERE "TransId" = "OVPM"."TransId" 
            ) AS "TransType",
            '' AS "RunNo",
            "OVPM"."DocEntry",
            "OVPM"."DocNum",
            "OVPM"."Canceled",
            "OVPM"."CounterRef" AS "NumAtCard",
            "OVPM"."TransId",
            CASE WHEN "OVPM"."DocType" = 'A' THEN "JDT1"."U_SLD_SuppCode" ELSE "OVPM"."CardCode" END AS "CardCode",
            REPLACE(CASE WHEN "OVPM"."DocType" = 'A' THEN CONCAT(IFNULL("JDT1"."U_SLD_Title",''), IFNULL("JDT1"."U_SLD_CardName",''))
            ELSE (CONCAT(CONCAT(IFNULL("OCRD"."U_SLD_Title",''),' '),IFNULL("OCRD"."U_SLD_FullName", "OCRD"."CardName" )) )END
            ,'  ','') AS "CardName",
            "JDT1"."U_SLD_Title" AS "U_SLD_Title",
            "JDT1"."U_SLD_CardName" AS "U_SLD_CardName",
            "OVPM"."Address",
            "OVPM"."TaxDate",
            CASE WHEN "OVPM"."DocType" = 'A' THEN "JDT1"."U_SLD_LBPTaxID" ELSE "OCRD"."LicTradNum" END AS "TaxId",
            "OVPM"."U_SLD_VatBranch",
            CASE WHEN "OVPM"."DocType" = 'A' THEN "JDT1"."U_SLD_LPBranch" ELSE "OPCH"."U_SLD_VBPBranch" END AS "U_SLD_VBPBranch", 
            CAST("CRD1"."Building" AS NVARCHAR)  AS "BuildingB",
            "CRD1"."Street"  AS "Street",
            "CRD1"."StreetNo" AS "StreetNoB",
            "CRD1"."City" AS "CityB",
            "CRD1"."County" AS "CountyB",
            "CRD1"."Name" AS "CountryB",
            "CRD1"."ZipCode" AS "ZipcodeB",
            CASE WHEN "OVPM"."DocType" = 'A' THEN "JDT1"."U_SLD_WTBaseAmt" ELSE "VPM6"."TaxbleAmnt" END AS "TaxbleAmnt",
            CASE WHEN "OVPM"."DocType" = 'A' THEN (("JDT1"."U_SLD_WTBaseAmt" * "JDT1"."Rate" )/100) ELSE "VPM6"."WTSum" END AS "WTAmnt",
            "OVPM"."TaxDate" AS "WHTDate",
            IFNULL("OWHT"."WTCode","JDT1"."WTCode") AS "WTCode",
            IFNULL("OWHT"."WTName","JDT1"."WTName") AS "WTName",
            IFNULL("OWHT"."Rate","JDT1"."Rate") AS "Rate",
            CASE WHEN "OPCH"."U_SLD_WhPayBy" IS NULL THEN
            (SELECT MAX("JDT1"."U_SLD_WhPayBy" )
                    FROM {?Schema@}.JDT1 "JDT1"
                    WHERE "JDT1"."TransId" = "OVPM"."TransId" 
                        AND "JDT1"."ShortName" IN (
                            SELECT "AcctCode" 
                            FROM {?Schema@}."OACT"
                            WHERE "FormatCode" = (
                                    SELECT "Name" 
                                    FROM {?Schema@}."@SLDT_SET_ACCWH"
                                    WHERE "U_SLD_TypeWH" = '54')))
            ELSE "OPCH"."U_SLD_WhPayBy" END AS "U_SLD_WhPayBy",

            (SELECT MAX("JDT1"."ShortName" )
                FROM {?Schema@}.JDT1 "JDT1"
                WHERE "JDT1"."TransId" = "OVPM"."TransId" 
                    AND "JDT1"."ShortName" IN (
                        SELECT "AcctCode" 
                        FROM {?Schema@}.OACT "OACT"
                        WHERE "FormatCode" = (
                                SELECT "Name" 
                                FROM {?Schema@}."@SLDT_SET_ACCWH"
                                WHERE "U_SLD_TypeWH" = '54'))) AS "Account",
            "OCRD"."TypWTReprt" AS "TypWTReprt" 
            
        FROM {?Schema@}.OVPM "OVPM"
            LEFT JOIN {?Schema@}.VPM6 "VPM6" ON "OVPM"."DocEntry" = "VPM6"."DocNum"
            LEFT JOIN (SELECT "JDT1".*,"OWHT"."WTCode","OWHT"."WTName","OWHT"."Rate" 
            			FROM {?Schema@}.JDT1 "JDT1" 
            			INNER JOIN {?Schema@}.OWHT "OWHT" ON "JDT1"."U_SLD_WTCode" = "OWHT"."WTCode"
            ) AS "JDT1" ON "OVPM"."TransId" = "JDT1"."TransId"
            LEFT JOIN {?Schema@}.OWHT "OWHT" ON "VPM6"."WTCode" = "OWHT"."WTCode"
            LEFT JOIN {?Schema@}.VPM2 "VPM2" ON "OVPM"."DocEntry" = "VPM2"."DocNum" 
            LEFT JOIN {?Schema@}.OPCH "OPCH" ON "VPM2"."DocEntry" = "OPCH"."DocEntry"
            LEFT JOIN {?Schema@}.OCRD "OCRD" ON "OVPM"."CardCode" = "OCRD"."CardCode" 
            LEFT JOIN (SELECT "CRD1".*,"OCRY"."Name" 
                FROM {?Schema@}.CRD1 "CRD1"
                LEFT JOIN {?Schema@}.OCRY "OCRY" ON "CRD1"."Country" = "OCRY"."Code" 
                WHERE "CRD1"."AdresType" = 'B'
            ) AS "CRD1" ON ("OVPM"."CardCode" = "CRD1"."CardCode" AND "OVPM"."PayToCode" = "CRD1"."Address") OR ("JDT1"."U_SLD_SuppCode" = "CRD1"."CardCode")
        WHERE "OVPM"."TransId" IN (
                SELECT "TransId" 
                FROM {?Schema@}.JDT1 "JDT1"
                WHERE "JDT1"."ShortName" = (
                        SELECT "AcctCode" 
                        FROM {?Schema@}."OACT"
                        WHERE "FormatCode" = (
                                SELECT "Name" 
                                FROM {?Schema@}."@SLDT_SET_ACCWH"
                                WHERE "U_SLD_TypeWH" = '54')))
UNION ALL
	SELECT 'OPCH' AS "TYPE",
            (SELECT "TransType" 
                FROM {?Schema@}."OJDT"
                WHERE "TransId" = "OPCH"."TransId" 
            ) AS "TransType",
            '' AS "RunNo",
            "OPCH"."DocEntry",
            "OPCH"."DocNum",
            "OPCH"."CANCELED",
            "OPCH"."NumAtCard",
            "OPCH"."TransId",
            "OPCH"."CardCode",
            REPLACE((CONCAT(IFNULL("OCRD"."U_SLD_Title",'')
                ,CONCAT(' ',IFNULL("OCRD"."U_SLD_FullName", "OCRD"."CardName" )))
         	),'  ','') AS "CardName",
            '' AS "U_SLD_Title",
            '' AS "U_SLD_CardName",
            "OPCH"."Address",
            "OPCH"."TaxDate",
            "OPCH"."LicTradNum" AS "TaxId",
            "OPCH"."U_SLD_LVatBranch" AS "U_SLD_VatBranch",
            "OPCH"."U_SLD_VBPBranch",
            CAST("CRD1"."Building" AS NVARCHAR) AS "BuildingB",
            "CRD1"."Street"  AS "Street",
            "CRD1"."StreetNo" AS "StreetNoB",
            "CRD1"."City" AS "CityB",
            "CRD1"."County" AS "CountyB",
            "CRD1"."Name" AS "CountryB",
            "CRD1"."ZipCode" AS "ZipcodeB",
            "PCH5"."TaxbleAmnt",
            "PCH5"."WTAmnt" AS "WTAmnt",
            "OPCH"."TaxDate" AS "WHTDate",
            "OWHT"."WTCode",
            "OWHT"."WTName",
            "OWHT"."Rate",
            "OPCH"."U_SLD_WhPayBy",
            (SELECT "JDT1"."ShortName" 
                FROM {?Schema@}.JDT1 "JDT1"
                WHERE "JDT1"."TransId" = "OPCH"."TransId" 
                    AND "JDT1"."ShortName" IN (
                        SELECT "AcctCode" 
                        FROM {?Schema@}."OACT"
                        WHERE "FormatCode" = (
                                SELECT "Name" 
                                FROM {?Schema@}."@SLDT_SET_ACCWH"
                                WHERE "U_SLD_TypeWH" = '54'))
            ) AS "Account",
            "OCRD"."TypWTReprt" AS "TypWTReprt" 
        FROM {?Schema@}.OPCH "OPCH"
            LEFT JOIN {?Schema@}.PCH5 "PCH5" ON "OPCH"."DocEntry" = "PCH5"."AbsEntry" 
            LEFT JOIN {?Schema@}.OWHT "OWHT" ON "PCH5"."WTCode" = "OWHT"."WTCode" 
            LEFT JOIN {?Schema@}.OCRD "OCRD" ON "OPCH"."CardCode" = "OCRD"."CardCode" 
            LEFT JOIN (SELECT "CRD1".*,"OCRY"."Name" 
                		FROM {?Schema@}.CRD1 "CRD1"
                		LEFT JOIN {?Schema@}.OCRY "OCRY" ON "CRD1"."Country" = "OCRY"."Code" 
                		WHERE "CRD1"."AdresType" = 'B'
            ) AS "CRD1" ON "OPCH"."CardCode" = "CRD1"."CardCode" AND "OPCH"."PayToCode" = "CRD1"."Address" 
        WHERE "OPCH"."TransId" IN (
                SELECT "TransId" 
                FROM {?Schema@}.JDT1 "JDT1"
                WHERE "JDT1"."ShortName" = (
                        SELECT "AcctCode" 
                        FROM {?Schema@}.OACT "OACT"
                        WHERE "FormatCode" = (
                                SELECT "Name" 
                                FROM {?Schema@}."@SLDT_SET_ACCWH"
                                WHERE "U_SLD_TypeWH" = '54')))
UNION ALL
	SELECT 'OJDT1' AS "TYPE",
            "JDT1"."TransType" AS "TransType",
            '' AS "RunNo",
            "JDT1"."Line_ID" AS "DocEntry",
            "JDT1"."BaseRef" AS "DocNum",
            '' AS "CANCELED",
            "OJDT"."Ref1" AS "NumAtCard",
            "JDT1"."TransId",
            "JDT1"."U_SLD_SuppCode" AS "CardCode",
            REPLACE((CASE WHEN "JDT1"."U_SLD_LPBranch" IS NOT NULL AND "JDT1"."U_SLD_LPBranch" <> '' THEN
                		CONCAT(CONCAT(IFNULL("JDT1"."U_SLD_Title",''), N' (สาขาที่ '),CONCAT(IFNULL("JDT1"."U_SLD_LPBranch",''),')'))
                	ELSE
                		IFNULL("JDT1"."U_SLD_Title",'')
                	END),'  ','') AS "CardName",
            '' AS "U_SLD_Title",
            '' AS "U_SLD_CardName",
            "JDT1"."U_SLD_BPAds" AS "Address",
            "JDT1"."TaxDate" AS "TaxDate",
            "JDT1"."LicTradNum" AS "TaxId",
            "OJDT"."U_S_ComVatB" AS "U_SLD_VatBranch",
            "JDT1"."U_SLD_LPBranch" AS "U_SLD_VBPBranch",
            CAST("CRD1"."Building" AS NVARCHAR) AS "BuildingB",
            "CRD1"."Street"  AS "Street",
            "CRD1"."StreetNo" AS "StreetNoB",
            "CRD1"."City" AS "CityB",
            "CRD1"."County" AS "CountyB",
            "CRD1"."Name" AS "CountryB",
            "CRD1"."ZipCode" AS "ZipcodeB",
            "JDT2"."TaxbleAmnt" AS "TaxbleAmnt",
            "JDT2"."WTAmnt",
            "JDT1"."TaxDate" AS "WHTDate",
            "JDT2"."WTCode",
            (SELECT "WTName" 
                FROM {?Schema@}."OWHT"
                WHERE "WTCode" = "JDT2"."WTCode" 
            ) AS "WTName",
            "JDT2"."Rate" AS "Rate",
            "JDT1"."U_SLD_WhPayBy" AS "U_SLD_WhPayBy",
            "JDT1"."ShortName" AS "Account",
            "OCRD"."TypWTReprt" AS "TypWTReprt" 
        FROM {?Schema@}.JDT1 "JDT1"
            INNER JOIN {?Schema@}.OJDT "OJDT" ON "JDT1"."TransId" = "OJDT"."TransId" 
            INNER JOIN {?Schema@}.JDT2 "JDT2" ON "JDT2"."AbsEntry" = "OJDT"."TransId" 
            AND "JDT2"."Account" = (
                SELECT "AcctCode" 
                FROM {?Schema@}."OACT"
                WHERE "FormatCode" = (
                        SELECT "Name" 
                        FROM {?Schema@}."@SLDT_SET_ACCWH"
                        WHERE "U_SLD_TypeWH" = '54'
                    )
            )
            LEFT JOIN {?Schema@}.OCRD "OCRD" ON "JDT1"."U_SLD_SuppCode" = "OCRD"."CardCode" 
            LEFT JOIN (SELECT "CRD1".*,"OCRY"."Name" 
                		FROM {?Schema@}.CRD1 "CRD1"
                		LEFT JOIN {?Schema@}.OCRY "OCRY" ON "CRD1"."Country" = "OCRY"."Code" 
                		WHERE "CRD1"."AdresType" = 'B') AS "CRD1" ON "JDT1"."U_SLD_SuppCode" = "CRD1"."CardCode" 
        WHERE "JDT1"."Credit" > 0 AND "JDT1"."TransType" = '30'
 UNION ALL
 SELECT 'OJDT' AS "TYPE",
            "JDT1"."TransType" AS "TransType",
            '' AS "RunNo",
            "JDT1"."Line_ID" AS "DocEntry",
            "JDT1"."BaseRef" AS "DocNum",
            '' AS "CANCELED",
            "OJDT"."Ref1"  AS "NumAtCard",
            "JDT1"."TransId",
            "JDT1"."U_SLD_SuppCode" AS "CardCode",
            REPLACE(CONCAT(IFNULL("JDT1"."U_SLD_Title",''), IFNULL("JDT1"."U_SLD_CardName",'')),'  ','') AS "CardName",
            "JDT1"."U_SLD_Title",
            "JDT1"."U_SLD_CardName",
            "JDT1"."U_SLD_BPAds" AS "Address",
            "JDT1"."U_SLD_WHdate" AS "TaxDate",
            "JDT1"."U_SLD_LBPTaxID" AS "TaxId",
            "OJDT"."U_S_ComVatB" AS "U_SLD_VatBranch",
            "JDT1"."U_SLD_LPBranch" AS "U_SLD_VBPBranch",
            CAST("CRD1"."Building" AS NVARCHAR) AS "BuildingB",
            "CRD1"."Street"  AS "Street",
            "CRD1"."StreetNo" AS "StreetNoB",
            "CRD1"."City" AS "CityB",
            "CRD1"."County" AS "CountyB",
            "CRD1"."Name" AS "CountryB",
            "CRD1"."ZipCode" AS "ZipcodeB",
            "JDT1"."U_SLD_WTBaseAmt" AS "TaxbleAmnt",
            (("JDT1"."U_SLD_WTBaseAmt" * "OWHT"."Rate" ) / 100.0) AS "WTAmnt",
            "JDT1"."U_SLD_WHdate" AS "WHTDate",
            "OWHT"."WTCode",
            "OWHT"."WTName",
            "OWHT"."Rate",
            "JDT1"."U_SLD_WhPayBy" AS "U_SLD_WhPayBy",
            "JDT1"."ShortName" AS "Account",
            "OCRD"."TypWTReprt" AS "TypWTReprt" 
        FROM {?Schema@}.JDT1 "JDT1"
            LEFT JOIN {?Schema@}.OJDT "OJDT" ON "JDT1"."TransId" = "OJDT"."TransId" 
            LEFT JOIN {?Schema@}.OWHT "OWHT" ON "JDT1"."U_SLD_WTCode" = "OWHT"."WTCode" 
            LEFT JOIN {?Schema@}.OCRD "OCRD" ON "JDT1"."U_SLD_SuppCode" = "OCRD"."CardCode" 
            LEFT JOIN (SELECT "CRD1".*,"OCRY"."Name" 
                	FROM {?Schema@}.CRD1 "CRD1"
                	LEFT JOIN {?Schema@}.OCRY "OCRY" ON "CRD1"."Country" = "OCRY"."Code" 
                	WHERE "CRD1"."AdresType" = 'B') AS "CRD1" ON "JDT1"."U_SLD_SuppCode" = "CRD1"."CardCode" 
        WHERE ("JDT1"."ShortName" = (
                    SELECT "AcctCode" 
                    FROM {?Schema@}."OACT"
                    WHERE "FormatCode" = (
                            SELECT "Name" 
                            FROM {?Schema@}."@SLDT_SET_ACCWH"
                            WHERE "U_SLD_TypeWH" = '54')))
        AND "JDT1"."TransType" = '30'
) AS "B"
) AS "C"
WHERE "C"."TransId" IN ({?DocKey@})
ORDER BY "C"."TaxDate","C"."TransId" 
