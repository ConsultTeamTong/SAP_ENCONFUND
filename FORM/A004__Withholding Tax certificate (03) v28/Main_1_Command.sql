-- ============================================================
-- Report: A0040001__Withholding Tax certificate (03) v28.rpt
Path:   A0040001__Withholding Tax certificate (03) v28.rpt
Extracted: 2026-05-07 18:02:34
-- Source: Main Report
-- Table:  Command
-- ============================================================

WITH FTTV AS(
---------------------------------------------------------------------START No 1 ----------------------------------------------------------------------------
		SELECT DISTINCT  "B"."TYPE",
						"B"."TransType",
						"B"."RunNo",
						"B"."DocNum",
						"B"."NumAtCard",
						"B"."TransId",
						"B"."CardCode",
						"B"."CardName",
						"B"."U_SLD_Title",
						"B"."U_SLD_CardName",
						"B"."Address",
						"B"."TaxDate",
						"B"."TaxId",
						"B"."U_SLD_VatBranch",
						"B"."U_SLD_VBPBranch",
						"B"."WHTType"
		FROM (
				SELECT DISTINCT	'"OVPM"' AS "TYPE",
						(	SELECT "TransType" 
							FROM {?Schema@}."OJDT" 
							WHERE "TransId" = "OVPM"."TransId"
						) AS "TransType",
						(	SELECT MAX("U_DocWht" )
							FROM {?Schema@}."@SLDT_WTS_TST" 
							WHERE "U_Status" = 'Y' AND  "U_TransID" = "OVPM"."TransId"
						) AS "RunNo",
						"OVPM"."DocNum",
						"OVPM"."CounterRef" as "NumAtCard",
						"OVPM"."TransId",
						"OVPM"."CardCode",
						(	SELECT "OCRD"."U_SLD_FullName" 
							FROM {?Schema@}."OCRD" 
							JOIN {?Schema@}."CRD1" ON "OCRD"."CardCode" = "CRD1"."CardCode" 
							WHERE "OCRD"."CardCode" = "OVPM"."CardCode" 
								AND "OVPM"."PayToCode" = "CRD1"."Address" 
								AND "CRD1"."AdresType" = 'B'  
								AND "OVPM"."PayToCode" = "CRD1"."Address" 
								AND "CRD1"."AdresType" = 'B'
							) AS "CardName",
							
						(	SELECT "OCRD"."U_SLD_Title" 
							FROM {?Schema@}."OCRD" 
							JOIN {?Schema@}."CRD1" ON "OCRD"."CardCode" = "CRD1"."CardCode" 
							WHERE "OCRD"."CardCode" = "OVPM"."CardCode" 
								AND "OVPM"."PayToCode" = "CRD1"."Address" 
								AND "CRD1"."AdresType" = 'B'  
								AND "OVPM"."PayToCode" = "CRD1"."Address" 
								AND "CRD1"."AdresType" = 'B'
							) AS "U_SLD_Title",
							
						(	SELECT "OCRD"."U_SLD_FullName" 
							FROM {?Schema@}."OCRD" 
							JOIN {?Schema@}."CRD1" ON "OCRD"."CardCode" = "CRD1"."CardCode" 
							WHERE "OCRD"."CardCode" = "OVPM"."CardCode" 
								AND "OVPM"."PayToCode" = "CRD1"."Address" 
								AND "CRD1"."AdresType" = 'B'  
								AND "OVPM"."PayToCode" = "CRD1"."Address" 
								AND "CRD1"."AdresType" = 'B'
							) AS "U_SLD_CardName",
							
						"OVPM"."Address",
						"OVPM"."TaxDate",
						(	SELECT "OCRD"."LicTradNum" 
							FROM {?Schema@}."OCRD" 
							JOIN {?Schema@}."CRD1" ON "OCRD"."CardCode" = "CRD1"."CardCode" 
							WHERE "OCRD"."CardCode" = "OVPM"."CardCode" 
								AND "OVPM"."PayToCode" = "CRD1"."Address" 
								AND "CRD1"."AdresType" = 'B' 
								AND "OVPM"."PayToCode" = "CRD1"."Address" 
								AND "CRD1"."AdresType" = 'B'
							)AS "TaxId",
						"OVPM"."U_SLD_VatBranch",
						(
                                Select "CRD1"."GlblLocNum"
                                From {?Schema@}."CRD1"
                                where "CRD1"."CardCode" = "OVPM"."CardCode" AND "OVPM"."PayToCode" = "CRD1"."Address" AND "CRD1"."AdresType" = 'B'
                            ) AS "U_SLD_VBPBranch",
						CASE WHEN "VPM2"."InvType" = 18 THEN "OPCH"."U_SLD_WhPayBy"
							WHEN "VPM2"."InvType" = 19 THEN "ORPC"."U_SLD_WhPayBy"
							WHEN "VPM2"."InvType" = 204 THEN "ODPO"."U_SLD_WhPayBy"
							WHEN "VPM2"."InvType" = 30 THEN "JDT1"."U_SLD_WhPayBy"
						END AS "WHTType",
						"OWHT"."WTCode"
						
				FROM {?Schema@}."OVPM"
				LEFT JOIN {?Schema@}."VPM2" ON "OVPM"."DocEntry" = "VPM2"."DocNum" 
				LEFT JOIN {?Schema@}."VPM6" ON "OVPM"."DocEntry" = "VPM6"."DocNum" 
				LEFT JOIN {?Schema@}."OWHT" ON "VPM6"."WTCode" = "OWHT"."WTCode" 
				LEFT JOIN {?Schema@}."OPCH" ON "VPM2"."DocEntry" = "OPCH"."DocEntry"
				LEFT JOIN {?Schema@}."ODPO" ON "VPM2"."DocEntry" = "ODPO"."DocEntry"
				LEFT JOIN {?Schema@}."ORPC" ON "VPM2"."DocEntry" = "ORPC"."DocEntry"
				LEFT JOIN {?Schema@}."JDT1" ON "OVPM"."TransId" = "JDT1"."TransId"
				WHERE "OVPM"."TransId" IN (SELECT "TransId" FROM {?Schema@}."JDT1" WHERE "JDT1"."ShortName"
											= (SELECT "AcctCode" FROM {?Schema@}."OACT" WHERE "FormatCode"
											 	= (SELECT "Name" FROM {?Schema@}."@SLDT_SET_ACCWH" WHERE "U_SLD_TypeWH" = '03'
											 		)
											 	)
											)
				----------------------------------------------------------------------------------------------------------------------
				UNION ALL 
				----------------------------------------------------------------------------------------------------------------------
				SELECT DISTINCT 	'"OPCH"' AS "TYPE",
						(	SELECT "TransType" 
							FROM {?Schema@}."OJDT" 
							WHERE "TransId" = "OPCH"."TransId"
						) AS "TransType",
						(	SELECT MAX("U_DocWht" )
							FROM {?Schema@}."@SLDT_WTS_TST" 
							WHERE "U_Status" = 'Y' 
								AND "U_TransID" = "OPCH"."TransId"
						) AS "RunNo",
						"OPCH"."DocNum",
						"OPCH"."NumAtCard",
						"OPCH"."TransId",
						"OPCH"."CardCode",
						'' AS "CardName",
						'' AS "U_SLD_Title",
						'' AS "U_SLD_CardName",
						"OPCH"."Address",
						"OPCH"."TaxDate",
						"OPCH"."LicTradNum" AS "TaxId",
						"OPCH"."U_SLD_LVatBranch" AS "U_SLD_VatBranch",
						'' AS "U_SLD_VBPBranch",
						"OPCH"."U_SLD_WhPayBy" AS "WHTType",
						"OWHT"."WTCode"
						
				FROM {?Schema@}."OPCH" 
				JOIN {?Schema@}."PCH5" ON "OPCH"."DocEntry" = "PCH5"."AbsEntry" 
				JOIN {?Schema@}."OWHT" ON "PCH5"."WTCode" = "OWHT"."WTCode" 
				WHERE "OPCH"."TransId" IN (SELECT "TransId" FROM {?Schema@}."JDT1" WHERE "JDT1"."ShortName" 
											= (SELECT "AcctCode" FROM {?Schema@}."OACT" WHERE "FormatCode" 
												= (SELECT "Name" FROM {?Schema@}."@SLDT_SET_ACCWH" WHERE "U_SLD_TypeWH" = '03'
												)
											)
										)  
				----------------------------------------------------------------------------------------------------------------------
				UNION ALL 
				----------------------------------------------------------------------------------------------------------------------
                SELECT DISTINCT	'"OJDT"' AS "TYPE",
						"JDT1"."TransType" AS "TransType",
						(	SELECT MAX("U_DocWht" )
							FROM {?Schema@}."@SLDT_WTS_TST" 
							WHERE "U_Status" = 'Y' 
								AND "U_TransID" = "OJDT"."TransId"
						) AS "RunNo",
						"JDT1"."BaseRef" AS "DocNum",
						"OJDT"."Ref2" as "NumAtCard",
						"JDT1"."TransId",
						"JDT1"."U_SLD_SuppCode" AS "CardCode",
						CASE WHEN "JDT1"."U_SLD_LPBranch" IS NOT NULL AND "JDT1"."U_SLD_LPBranch" <> '' THEN 
								CONCAT("JDT1"."U_SLD_CardName" , CONCAT('(สาขาที่ ', CONCAT("JDT1"."U_SLD_LPBranch", ')'))) 
							ELSE "JDT1"."U_SLD_CardName" END AS "CardName",
						'' AS "U_SLD_Title",
						'' AS "U_SLD_CardName",
						"JDT1"."U_SLD_BPAds" AS "Address",
						"JDT1"."TaxDate" AS "TaxDate",
						"JDT1"."LicTradNum" AS "TaxId",
						"OJDT"."U_S_ComVatB" AS "U_SLD_VatBranch",
						"JDT1"."U_SLD_LPBranch" AS "U_SLD_VBPBranch",
						"JDT1"."U_SLD_WhPayBy",
						"JDT2"."WTCode"
				FROM
				{?Schema@}."JDT1" 
				INNER JOIN {?Schema@}."OJDT" ON "JDT1"."TransId" = "OJDT"."TransId"
				INNER JOIN {?Schema@}."JDT2" ON "JDT2"."AbsEntry" = "OJDT"."TransId" 
				AND "JDT2"."Account" = (SELECT "AcctCode" FROM {?Schema@}."OACT" WHERE "FormatCode" = (SELECT "Name" FROM {?Schema@}."@SLDT_SET_ACCWH" WHERE "U_SLD_TypeWH" = '03'))
				WHERE "JDT1"."Credit" > 0 				
				----------------------------------------------------------------------------------------------------------------------
				UNION ALL 
				----------------------------------------------------------------------------------------------------------------------
				SELECT DISTINCT	'"OJDT"' AS "TYPE",
						"JDT1"."TransType" AS "TransType",
						(Select MAX("U_DocWht") from {?Schema@}."@SLDT_WTS_TST" where "U_Status" = 'Y' And  "U_TransID" = "OJDT"."TransId" AND "U_Date_Wht" = "JDT1"."U_SLD_WHdate") AS "RunNo",
						"JDT1"."BaseRef" AS "DocNum",
						"OJDT"."Ref2" as "NumAtCard",
						"JDT1"."TransId",
						"JDT1"."U_SLD_SuppCode" AS "CardCode",
						CONCAT("U_SLD_Title", "U_SLD_CardName") AS "CardName",
						"U_SLD_Title",
						"U_SLD_CardName",
						"JDT1"."U_SLD_BPAds" AS "Address",
						"JDT1"."U_SLD_WHdate" AS "TaxDate",
						"JDT1"."U_SLD_LBPTaxID" AS "TaxId",
						CASE WHEN "OJDT"."TransType" = '46' THEN 
								(SELECT {?Schema@}."OVPM"."U_SLD_VatBranch" FROM {?Schema@}."OVPM" WHERE {?Schema@}."OVPM"."TransId" = {?Schema@}."OJDT"."TransId") 
							ELSE {?Schema@}."OJDT"."U_S_ComVatB" END  AS "U_SLD_VatBranch",
						"JDT1"."U_SLD_LPBranch" AS "U_SLD_VBPBranch",
						"JDT1"."U_SLD_WhPayBy",
						(SELECT "OWHT"."WTCode" FROM  {?Schema@}."OWHT" WHERE "OWHT"."WTCode" = "JDT1"."U_SLD_WTCode" AND "JDT1"."ShortName" = (SELECT "AcctCode" FROM  {?Schema@}."OACT" WHERE "FormatCode" = (SELECT "Name" FROM  {?Schema@}."@SLDT_SET_ACCWH" WHERE "U_SLD_TypeWH" = '03'))) "WTCode"
						
				FROM {?Schema@}."JDT1" 
				LEFT JOIN {?Schema@}."OJDT"  ON "JDT1"."TransId" = "OJDT"."TransId"
				WHERE "JDT1"."ShortName" = (SELECT "AcctCode" FROM {?Schema@}."OACT" WHERE "FormatCode" = (SELECT "Name" FROM {?Schema@}."@SLDT_SET_ACCWH" WHERE "U_SLD_TypeWH" = '03'))                                           
			) AS "B" WHERE "B"."TaxDate" IS NOT NULL AND "B"."WTCode" IS NOT NULL
--------------------------------------------------------------------- END WITH FTTV ----------------------------------------------------------------------------
)

SELECT ROW_NUMBER() OVER (ORDER BY "TaxDate") As "Row", * 
From (
			SELECT 
			N'ฉบับที่ 1 (สำหรับผู้ถูกหักภาษี ณ ที่จ่าย ใช้แนบแบบแสดงรายการภาษี)'  AS "TypeWht",
			FTTV.*
			FROM FTTV
		UNION ALL
			SELECT 
			N'ฉบับที่ 2 (สำหรับผู้ถูกหักภาษี ณ ที่จ่าย เก็บไว้เป็นหลักฐาน)'  AS "TypeWht",
			FTTV.*
			FROM FTTV
		UNION ALL
			SELECT 
			N'ฉบับที่ 3 (สำหรับฝ่ายบัญชี นำส่งภาษี)' AS "TypeWht",
			FTTV.*
			FROM FTTV
		UNION ALL
			SELECT 
			N'ฉบับที่ 4 (สำหรับฝ่ายบัญชี เก็บไว้เป็นหลักฐาน)'  AS "TypeWht",
			FTTV.*
			FROM FTTV
) "Gup"
WHERE  "Gup"."TaxDate" Is Not Null  And "Gup"."TransId" In ({?DocKey@})  

ORDER BY "Gup"."TaxDate", "Gup"."TransId" ,"Gup"."TypeWht"
