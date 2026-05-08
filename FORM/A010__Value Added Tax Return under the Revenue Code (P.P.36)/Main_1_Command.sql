-- ============================================================
-- Report: A0100001__Value Added Tax Return under the Revenue Code (P.P.36).rpt
Path:   A0100001__Value Added Tax Return under the Revenue Code (P.P.36).rpt
Extracted: 2026-05-07 18:02:37
-- Source: Main Report
-- Table:  Command
-- ============================================================

 					SELECT '' AS "#",
                          ROW_NUMBER() OVER (ORDER BY "TransId", "TaxDate") AS "ROW",
                          "TransId",
                          "SubmitDate",
                          "U_SLD_WhenPP36",
                          "CardCode",
                          "CardName",
                          "OwnerBranch",
                          "LicTradNum",
                          "BuildingB","Street","StreetNoB","CityB","CountyB","CountryB","ZipcodeB",
                          "RefDate",
                          "NumAtCard",
                          "JrnlMemo",
                          "U_SLD_BPStatus",
                          "BaseSum",
                          "DocCur",
                          "DocRate",
                          CASE WHEN "Origin" = 'PS' THEN "TaxbleAmnt1" ELSE
                          	(CASE WHEN "DocRate" = 0 OR "DocRate" IS NULL THEN "BaseSum" ELSE "BaseSum" * "DocRate" END)
                          END AS "TaxbleAmnt",
                          (CASE WHEN "Origin" = 'PS' THEN "TaxbleAmnt1" ELSE
                          	(CASE WHEN "DocRate" = 0 OR "DocRate" IS NULL THEN "BaseSum" ELSE "BaseSum" * "DocRate" END)
                          END)*("VatRate"/100)  AS "VatSum",
                          "Origin",
                          "OutgoingDocNum",                  
                          "Line_ID",
                          "TransType",   
                          "Ref1",
                          "TaxDate",
                          "BaseRef",
                          "DebCred",
                          "Credit",
                          "Debit",
                          "VatGroup",
                          "VatAmount",
                          "U_SLD_SuppCode",
                          "StaType",
                          "JDT1BaseSum",
                          "VatRate",                      
                          "AutoVAT",     
                          "Ref2",
                          "DocStatus",
                          "Ref3Line",
                          "Series",
                          "SeriesName",
                          "SeriesPrefix",
                          "DocNum",
                          "U_SLD_OutvatRef",
                          "U_SLD_LVatBranch",
                          "U_SLD_NameVat",
                          "U_SLD_FullTax",
                          "U_SLD_AbbRef",
                          "U_SLD_VBPBranch", 
                          "DeferrTax", 
                          "CANCELED"
                          
                        FROM
                          (SELECT
                              JDT1."TransId",
                              JDT1."Line_ID",
                              JDT1."TransType",
                              JDT1."RefDate",
                              JDT1."Ref1",
                              JDT1."TaxDate",
                              JDT1."BaseRef",
                              JDT1."DebCred",
                              (JDT1."Credit") AS "Credit",
                              (JDT1."Debit") AS "Debit",
                              JDT1."VatGroup",
                              JDT1."VatAmount",
                              JDT1."U_SLD_SuppCode",
                              JDT1."StaType",
                              (JDT1."BaseSum") AS "JDT1BaseSum",
                              (VAT."U_SLD_Rate") AS "VatRate", 
                              (OPCH."U_SLD_WhenPP36") AS "U_SLD_WhenPP36", 
                              (CRD1."Building") AS "BuildingB", 
                              (CRD1."Street") AS "Street", 
                              (CRD1."StreetNo") AS "StreetNoB", 
                              (CRD1."City") AS "CityB", 
                              (CRD1."County") AS "CountyB", 
                              (CRD1."Country") AS "CountryB", 
                              (CRD1."ZipCode") AS "ZipcodeB",      
                              IFNULL(OPCH."JrnlMemo", JDT1."LineMemo") AS "JrnlMemo",	 
                              0 AS "TaxbleAmnt1",
                              IFNULL(VPM2."DocRate",0) AS "DocRate", 
                              (OCRD."U_SLD_BPStatus") AS "U_SLD_BPStatus", 
                              (OJDT."AutoVAT") AS "AutoVAT", 
                              ("TS_TST"."U_SubmitDate") AS "SubmitDate", 
                              CASE WHEN "FCCurrency" IS NULL THEN (JDT1."BaseSum")
                              ELSE (OPCH."DocTotalFC" - OPCH."VatSumFC") END AS "BaseSum", 
                              JDT1."Ref2", 
                              (OPCH."NumAtCard") AS "NumAtCard", 
                              (CASE WHEN JDT1."TransType" = '18' THEN (OPCH."DocStatus") ELSE 'C' END) AS "DocStatus",
                              JDT1."Ref3Line",
                              IFNULL(OPCH."Series", OJDT."Series") AS "Series", 
                              (SELECT "SeriesName" FROM {?Schema@}."NNM1" WHERE "Series" = (OPCH."Series")) AS "SeriesName", 
                              (SELECT "BeginStr" FROM {?Schema@}."NNM1" WHERE "Series" = (OPCH."Series")) AS "SeriesPrefix", 
                              IFNULL(OPCH."DocNum", JDT1."DocNum") AS "DocNum", 
                              (OPCH."U_SLD_OutvatRef") AS "U_SLD_OutvatRef", 
                              (CRD1."GlblLocNum") AS "U_SLD_LVatBranch", 
                              REPLACE(
                              IFNULL(JDT1."U_SLD_CardName"
                              ,(CONCAT(IFNULL(OCRD."U_SLD_Title", ''), CONCAT(' ',IFNULL(OCRD."U_SLD_FullName", ''))))
                              ), '  ', '') AS "CardName", 
                              (OPCH."U_SLD_NameVat") AS "U_SLD_NameVat", 
                              (OPCH."U_SLD_FullTax") AS "U_SLD_FullTax", 
                              (OPCH."U_SLD_AbbRef") AS "U_SLD_AbbRef", 
                              IFNULL((OPCH."U_SLD_VBPBranch"), JDT1."U_SLD_LPBranch") AS "U_SLD_VBPBranch", 
                              IFNULL((OPCH."DeferrTax"), OJDT."DeferedTax") AS "DeferrTax", 
                              (CASE WHEN JDT1."TransType" = '18' AND OPCH."DocStatus" <> 'O' 
      		                        THEN CAST(OVPM."DocNum" AS VARCHAR) ELSE '' END) AS "OutgoingDocNum", 
                              IFNULL(JDT1."U_SLD_SuppCode",(OPCH."CardCode")) AS "CardCode", 
                              IFNULL((OPCH."LicTradNum"), JDT1."U_SLD_LBPTaxID") AS "LicTradNum", 
                              CASE WHEN JDT1."TransType" = 18 THEN 'PU' WHEN JDT1."TransType" = 30 THEN 'JE' ELSE '' END AS "Origin", 
                              IFNULL((OPCH."U_SLD_LVatBranch"), OJDT."U_S_ComVatB") AS "OwnerBranch", 
                              (OPCH."CANCELED") AS "CANCELED",
                              IFNULL(OPCH."DocCur",OADM."SysCurrncy") AS "DocCur"
      
                        FROM {?Schema@}."JDT1" JDT1
                         LEFT JOIN {?Schema@}."OJDT" OJDT ON JDT1."TransId" = OJDT."TransId"
                         LEFT JOIN {?Schema@}."OPCH" OPCH ON JDT1."TransId" = OPCH."TransId"
                         LEFT JOIN {?Schema@}."VPM2" VPM2 ON VPM2."DocTransId" = JDT1."TransId"
                         LEFT JOIN {?Schema@}."OVPM" OVPM ON OVPM."DocEntry" = VPM2."DocNum"
                         LEFT JOIN {?Schema@}."CRD1" CRD1 ON (OVPM."CardCode" = CRD1."CardCode" AND OVPM."PayToCode" = CRD1."Address")
                         					OR (JDT1."U_SLD_SuppCode" = CRD1."CardCode" AND CRD1."Address" = '00000')
                         LEFT JOIN {?Schema@}."OCRD" OCRD ON (OPCH."CardCode" = OCRD."CardCode") OR (JDT1."U_SLD_SuppCode" = OCRD."CardCode")
                         LEFT JOIN {?Schema@}."@SLDT_SET_VAT" VAT ON JDT1."VatGroup" = VAT."Code"
                         CROSS JOIN {?Schema@}."OADM" OADM
                         LEFT JOIN (SELECT DISTINCT "U_SubmitDate","U_TransID"
      	                        	FROM {?Schema@}."@SLDT_TS_TST" 
      	                        	WHERE "U_Type" = 'PP' AND "U_SubmitDate" <> ''
      	                        	)AS "TS_TST" ON JDT1."TransId" = "TS_TST"."U_TransID"

                        WHERE  JDT1."TransType" IN (18, 30)
                         AND JDT1."VatLine" = 'Y'
                         AND (CASE WHEN JDT1."TransType" = '18' THEN (OPCH."DocStatus") ELSE 'C' END) = 'C'
                         AND JDT1."VatGroup" IN (SELECT "Code" FROM {?Schema@}."@SLDT_SET_VAT" WHERE "U_SLD_Category" = 'Input' AND "U_SLD_TYPE" = 'X' AND "U_SLD_ActiveVat" = 1)
                         AND (JDT1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE (OJDT."StornoToTr" IS NOT NULL))) 
                         AND (JDT1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)) 
                         AND JDT1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OPCH WHERE "CANCELED" IN ('Y', 'C')) 
                         
                            UNION ALL
                            SELECT
                              JDT1."TransId", 
                              JDT1."Line_ID", 
                              JDT1."TransType", 
                              JDT1."RefDate", 
                              JDT1."Ref1", 
                              JDT1."TaxDate", 
                              JDT1."BaseRef", 
                              JDT1."DebCred", 
                              JDT1."Credit" AS "Credit", 
                              JDT1."Debit" AS "Debit", 
                              JDT1."VatGroup", 
                              JDT1."VatAmount", 
                              JDT1."U_SLD_SuppCode", 
                              JDT1."StaType", 
                              JDT1."BaseSum" AS "JDT1BaseSum", 
                              (VAT."U_SLD_Rate") AS "VatRate",
                              OPCH."U_SLD_WhenPP36" AS "U_SLD_WhenPP36", 
                              (CRD1."Building") AS "BuildingB", 
                              (CRD1."Street") AS "Street", 
                              (CRD1."StreetNo") AS "StreetNoB", 
                              (CRD1."City") AS "CityB", 
                              (CRD1."County") AS "CountyB", 
                              (CRD1."Country") AS "CountryB", 
                              (CRD1."ZipCode") AS "ZipcodeB", 
                              OPCH."JrnlMemo" AS "JrnlMemo", 
                              (CASE WHEN(
                                  SELECT COUNT(*)
                                  FROM {?Schema@}.VPM6
                                  WHERE "DocNum" = (OVPM."DocEntry")) = 0 THEN (VPM2."AppliedSys") 
                               ELSE (VPM6."WTSum"+VPM6."PymAmount") END) AS "TaxbleAmnt1", 
                              (OVPM."DocRate") AS "DocRate", 
                              (SELECT "U_SLD_BPStatus" FROM {?Schema@}.OCRD WHERE "CardCode" = (OPCH."CardCode")) AS "U_SLD_BPStatus", 
                              OJDT."AutoVAT" AS "AutoVAT", 
                              "TS_TST"."U_SubmitDate" AS "SubmitDate", 
                              (CASE WHEN JDT1."TransType" = '46' THEN (
         	                        CASE WHEN JDT1."Credit" > 0 THEN JDT1."Credit" ELSE JDT1."Debit" END)
                                 WHEN(OJDT."AutoVAT") = 'N' THEN (JDT1."BaseSum") 
                               END) AS "BaseSum", 
                              JDT1."Ref2", 
                              '' AS "NumAtCard", 
                              (CASE WHEN JDT1."TransType" = '18' THEN(OPCH."DocStatus") ELSE 'C' END) AS "DocStatus", 
                              JDT1."Ref3Line", 
                              "OVPM_BR"."Series" AS "Series", 
                              (SELECT "SeriesName" FROM {?Schema@}.NNM1 WHERE "Series" = (OVPM."Series")) AS "SeriesName", 
                              (SELECT "BeginStr" FROM {?Schema@}.NNM1 WHERE "Series" = (OVPM."Series")) AS "SeriesPrefix", 
                              "OVPM_BR"."DocNum" AS "DocNum", 
                              '' AS "U_SLD_OutvatRef", 
                              (CRD1."GlblLocNum") AS "U_SLD_LVatBranch", 
                              REPLACE(
                                (CASE WHEN (OPCH."DeferrTax") = 'Y' AND (OJDT."AutoVAT") = 'N' THEN CONCAT("U_SLD_Title",CONCAT(' ', JDT1."U_SLD_CardName")) 
        	                        ELSE (SELECT CONCAT(IFNULL("U_SLD_Title", ''), CONCAT(' ',IFNULL("U_SLD_FullName", ''))) 
        			                        FROM {?Schema@}.OCRD
        			                        WHERE "CardCode" = (OVPM."CardCode")) END)
                                ,'  ', '') AS "CardName", 
                              '' AS "U_SLD_NameVat", 
                              '' AS "U_SLD_FullTax", 
                              '' AS "U_SLD_AbbRef", 
                              '' AS "U_SLD_VBPBranch", 
                              (CASE WHEN JDT1."TransType" = '46' THEN (OPCH."DeferrTax") ELSE 'N' END) AS "DeferrTax", 
                              (CASE WHEN JDT1."TransType" = '204' AND (SELECT "DocStatus" FROM {?Schema@}.ODPO WHERE "TransId" = JDT1."TransId" ) <> 'O' 
      				                        THEN CAST((SELECT "DocNum" 
      							                        FROM {?Schema@}.OVPM 
      							                        WHERE "DocEntry" = 
      								                        (SELECT MAX("DocNum") 
      								                        FROM {?Schema@}.VPM2 
      								                        WHERE "InvType" = 204 And "baseAbs" = 
      									                        (SELECT MAX("DocEntry")
      									                        FROM {?Schema@}.ODPO
      									                        WHERE "TransId" = JDT1."TransId"))) 
      					                         AS VARCHAR) 
      	                        ELSE '' END) AS "OutgoingDocNum", 
                              "OVPM_BR"."CardCode" AS "CardCode", 
                              (CASE WHEN (OPCH."DeferrTax") = 'Y' AND (OJDT."AutoVAT") = 'N' THEN (JDT1."U_SLD_LBPTaxID") 
                               ELSE (SELECT "LicTradNum" FROM {?Schema@}.OCRD WHERE "CardCode" = (OVPM."CardCode")) END
                              ) AS "LicTradNum", 
                              'PS' AS "Origin", 
                              "OVPM_BR"."U_SLD_VatBranch" AS "OwnerBranch", 
                              "OVPM_BR"."Canceled" AS "CANCELED",
                              "OVPM_BR"."DocCurr" AS "DocCur"
                              
                        FROM {?Schema@}."JDT1" JDT1
                            LEFT JOIN {?Schema@}."@SLDT_SET_VAT" VAT ON JDT1."VatGroup" = VAT."Code"
                            LEFT JOIN {?Schema@}."OPCH" OPCH ON JDT1."TransId" = OPCH."TransId"
                            LEFT JOIN {?Schema@}."OJDT" OJDT ON JDT1."TransId" = OJDT."TransId"
                            LEFT JOIN {?Schema@}."VPM2" VPM2 ON VPM2."DocTransId" = JDT1."TransId"
                            LEFT JOIN {?Schema@}."OVPM" OVPM ON OVPM."DocEntry" = VPM2."DocNum"
                            LEFT JOIN {?Schema@}."CRD1" CRD1 ON OVPM."CardCode" = CRD1."CardCode" AND OVPM."PayToCode" = CRD1."Address"
                            LEFT JOIN {?Schema@}."VPM6" VPM6 ON VPM6."DocNum" = OVPM."DocEntry"
                            LEFT JOIN (SELECT DISTINCT "U_SubmitDate","U_TransID"
    			                        FROM {?Schema@}."@SLDT_TS_TST"
    			                        WHERE "U_Type" = 'PP' AND "U_SubmitDate" <> ''
    			                        ) AS "TS_TST" ON JDT1."TransId" = "TS_TST"."U_TransID"
                            LEFT JOIN {?Schema@}.OVPM "OVPM_BR" ON JDT1."BaseRef" = "OVPM_BR"."DocNum"

                        WHERE  (CASE WHEN JDT1."TransType" = '18' THEN (OPCH."DeferrTax") 
		                        WHEN JDT1."TransType" = '46' THEN 
			                        (SELECT ("DeferrTax") FROM {?Schema@}.OPCH WHERE "TransId" = 
				                        (SELECT MAX("DocTransId") 
					                        FROM {?Schema@}.VPM2 
					                        WHERE "DocNum" = 
					                        (SELECT MAX("DocEntry") FROM {?Schema@}.OVPM WHERE "TransId" = JDT1."TransId"))) 
		                        ELSE 'N' END) = 'Y' 
                        AND JDT1."TransType" IN (46)
                        AND JDT1."VatLine" = 'Y'
                        AND JDT1."VatGroup" IN (SELECT "Code" FROM {?Schema@}."@SLDT_SET_VAT" WHERE "U_SLD_Category" = 'Input' AND "U_SLD_ActiveVat" = 1 AND "U_SLD_TYPE" = 'X')
                        AND (JDT1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE  (OJDT."StornoToTr" IS NOT NULL))) 
                        AND (JDT1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE OJDT."StornoToTr" IS NOT NULL)) 
                        AND JDT1."TransId" NOT IN(SELECT "TransId" FROM {?Schema@}.OPCH WHERE "CANCELED" IN ('Y', 'C')) 
                        
                        ) AS "B" 
                        WHERE "B"."TransId" IN ({?DocKey@})
                        ORDER BY "B"."TransId","B"."TaxDate" 
