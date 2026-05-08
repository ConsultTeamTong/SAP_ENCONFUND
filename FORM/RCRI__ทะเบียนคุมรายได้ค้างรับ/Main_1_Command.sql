-- ============================================================
-- Report: RCRI0035__ทะเบียนคุมรายได้ค้างรับ.rpt
Path:   RCRI0035__ทะเบียนคุมรายได้ค้างรับ.rpt
Extracted: 2026-05-07 18:03:44
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
T0."PrjCode",
T0."U_SLD_ProjectName",
T0."U_SLD_PlanWork",
T0."U_SLD_GroupWork",
T0."U_SLD_Period",
T0."U_SLD_REQ",
T0."U_SLD_REC",
T0."U_SLD_Vendor",
----------------------------------------------------------
OB."OB01",
OB."OB02",
OB."OB03",
----------------------------------------------------------
IFNULL(RE1."Credit",0) * (-1) AS "Cr_Re01",
IFNULL(RE2."Credit",0) * (-1) AS "Cr_Re02",
IFNULL(RE3."Credit",0) * (-1) AS "Cr_Re03",
IFNULL(AP1."Debit",0) AS "Dr_Ap01",
IFNULL(AP2."Debit",0) AS "Dr_Ap02",
IFNULL(AP3."Debit",0) AS "Dr_Ap03",
DN."DocNum"
----------------------------------------------------------
FROM {?Schema@}.OPRJ T0
LEFT JOIN ( SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit",
 					T1."U_SLD_Remark"
			FROM {?Schema@}.OJDT T0 
			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
 			 --AND T3."Category" = TO_VARCHAR( TO_INT({?Year@}) - 543 )
 			 AND T0."RefDate" = {?1DStart@}
 			 AND T1."Credit" <> 0
 			 AND T1."U_SLD_Remark" = '4303010101'
 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
 			 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark"
 			) AS RE1 ON T0."PrjCode" = RE1."Project"
 			
 LEFT JOIN ( SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit",
 					T1."U_SLD_Remark"
			FROM {?Schema@}.OJDT T0 
			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
 			 --AND T3."Category" = TO_VARCHAR( TO_INT({?Year@}) - 543 )
 			 AND T0."RefDate" = {?1DStart@}
 			 AND T1."Credit" <> 0
 			 AND T1."U_SLD_Remark" = '4313010103'
 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
 			 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark"	
 			) AS RE2 ON T0."PrjCode" = RE2."Project"
 			
 LEFT JOIN ( SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit",
 					T1."U_SLD_Remark"
			FROM {?Schema@}.OJDT T0 
			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
 			 --AND T3."Category" = TO_VARCHAR( TO_INT({?Year@}) - 543 )
 			 AND T0."RefDate" = {?1DStart@}
 			 AND T1."Credit" <> 0
 			 AND T1."U_SLD_Remark" = '4313010199'
 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
 			 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark"
 			) AS RE3 ON T0."PrjCode" = RE3."Project"
 			
  LEFT JOIN ( SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					SUM(IFNULL(T1."Debit",0)) AS "Debit",
 					T1."U_SLD_Remark"
			FROM {?Schema@}.OJDT T0 
			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
 			 --AND T3."Category" = TO_VARCHAR( TO_INT({?Year@}) - 543 )
 			 AND T0."RefDate" = {?1DStart@}
 			 AND T1."Debit" <> 0
 			 AND T1."U_SLD_Remark" = N'4303010101'
 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
 			 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark"
 			) AS AP1 ON T0."PrjCode" = AP1."Project"
 			
  LEFT JOIN ( SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					SUM(IFNULL(T1."Debit",0)) AS "Debit",
 					T1."U_SLD_Remark"
			FROM {?Schema@}.OJDT T0 
			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
 			 --AND T3."Category" = TO_VARCHAR( TO_INT({?Year@}) - 543 )
 			 AND T0."RefDate" = {?1DStart@}
 			 AND T1."Debit" <> 0
 			 AND T1."U_SLD_Remark" = '4313010103'
 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
 			 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark"
 			) AS AP2 ON T0."PrjCode" = AP2."Project"
 			
   LEFT JOIN ( SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					SUM(IFNULL(T1."Debit",0)) AS "Debit",
 					T1."U_SLD_Remark"
			FROM {?Schema@}.OJDT T0 
			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
 			 --AND T3."Category" = TO_VARCHAR( TO_INT({?Year@}) - 543 )
 			 AND T0."RefDate" = {?1DStart@}
 			 AND T1."Debit" <> 0
 			 AND T1."U_SLD_Remark" = '4313010199'
 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
 			 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark"
 			) AS AP3 ON T0."PrjCode" = AP3."Project"	

	LEFT JOIN (		SELECT 	T0."PrjCode",
							(IFNULL(AP1."Debit",0)) - (IFNULL(RE1."Credit",0)) AS "OB01",
							(IFNULL(AP2."Debit",0)) - (IFNULL(RE2."Credit",0)) AS "OB02",
							(IFNULL(AP3."Debit",0)) - (IFNULL(RE3."Credit",0)) AS "OB03"
					FROM {?Schema@}.OPRJ T0
					LEFT JOIN ( SELECT  T1."Project",
										T2."FormatCode",
										T2."AcctName",
	 									SUM(IFNULL(T1."Credit",0)) AS "Credit",
	 									T1."U_SLD_Remark"
					 			FROM {?Schema@}.OJDT T0 
					 			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
	 							LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
	 							LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
	 							 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
					 			-- AND T3."Category" < TO_VARCHAR( TO_INT({?Year@}) - 543 )
					 			 AND T0."RefDate" < {?1DStart@}
	 			 				 AND T1."Credit" <> 0
	 							 AND T1."U_SLD_Remark" = '4303010101'
	 							 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
	 							 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 					 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
								Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."U_SLD_Remark"
	 							) AS RE1 ON T0."PrjCode" = RE1."Project"
 			
					 LEFT JOIN ( SELECT  T1."Project",
										T2."FormatCode",
										T2."AcctName",
					 					SUM(IFNULL(T1."Credit",0)) AS "Credit",
					 					T1."U_SLD_Remark"
					 			FROM {?Schema@}.OJDT T0 
					 			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
					 			-- AND T3."Category" < TO_VARCHAR( TO_INT({?Year@}) - 543 )
					 			 AND T0."RefDate" < {?1DStart@}
					 			 AND T1."Credit" <> 0
					 			 AND T1."U_SLD_Remark" = '4313010103'
					 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
	 							 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 					 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
								Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."U_SLD_Remark"	
					 			) AS RE2 ON T0."PrjCode" = RE2."Project"
					 			
					 LEFT JOIN ( SELECT  T1."Project",
										T2."FormatCode",
										T2."AcctName",
					 					SUM(IFNULL(T1."Credit",0)) AS "Credit",
					 					T1."U_SLD_Remark"
					 			FROM {?Schema@}.OJDT T0 
					 			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
					 			-- AND T3."Category" < TO_VARCHAR( TO_INT({?Year@}) - 543 )
					 			 AND T0."RefDate" < {?1DStart@}
					 			 AND T1."Credit" <> 0
					 			 AND T1."U_SLD_Remark" =  '4313010199'
					 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
	 							 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 					 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
								Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."U_SLD_Remark"
					 			) AS RE3 ON T0."PrjCode" = RE3."Project"
					 			
					  LEFT JOIN ( SELECT  T1."Project",
										T2."FormatCode",
										T2."AcctName",
										SUM(IFNULL(T1."Debit",0)) AS "Debit",
					 					T1."U_SLD_Remark"
					 			FROM {?Schema@}.OJDT T0 
					 			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
					 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
					 			-- AND T3."Category" < TO_VARCHAR( TO_INT({?Year@}) - 543 )
					 			 AND T0."RefDate" < {?1DStart@}
					 			 AND T1."Debit" <> 0
					 			 AND T1."U_SLD_Remark" = '4303010101'
					 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
	 							 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 					 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
								Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."U_SLD_Remark"
					 			) AS AP1 ON T0."PrjCode" = AP1."Project"
					 			
					  LEFT JOIN ( SELECT  T1."Project",
										T2."FormatCode",
										T2."AcctName",
										SUM(IFNULL(T1."Debit",0)) AS "Debit",
					 					T1."U_SLD_Remark"
					 			FROM {?Schema@}.OJDT T0 
					 			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
					 			-- AND T3."Category" < TO_VARCHAR( TO_INT({?Year@}) - 543 )
					 			 AND T0."RefDate" < {?1DStart@}
					 			 AND T1."Debit" <> 0
					 			 AND T1."U_SLD_Remark" = '4313010103'
					 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
	 							 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 					 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
								Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."U_SLD_Remark"
					 			) AS AP2 ON T0."PrjCode" = AP2."Project"
					 			
					   LEFT JOIN ( SELECT  T1."Project",
										T2."FormatCode",
										T2."AcctName",
										SUM(IFNULL(T1."Debit",0)) AS "Debit",
					 					T1."U_SLD_Remark"
					 			FROM {?Schema@}.OJDT T0 
					 			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			 WHERE T2."FormatCode" IN ( '1102050106','1102050107')
					 			-- AND T3."Category" < TO_VARCHAR( TO_INT({?Year@}) - 543 )
					 			 AND T0."RefDate" < {?1DStart@}
					 			 AND T1."Debit" <> 0
					 			 AND T1."U_SLD_Remark" = '4313010199'
					 			 -- ป้องกันเอกสารที่ถูกยกเลิก และเอกสารที่เป็นตัวยกเลิก
	 							 AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 					 AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
								Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."U_SLD_Remark"
					 			) AS AP3 ON T0."PrjCode" = AP3."Project" 
		   ) AS OB ON T0."PrjCode" = OB."PrjCode"
 	LEFT JOIN (	SELECT  STRING_AGG(TO_VARCHAR(DB."DocNum"), ', ') as "DocNum",
	   					DB."Project"
				FROM (
						SELECT  CONCAT(IFNULL(T4."BeginStr",'TT'), T0."Number") AS "DocNum",
								IFNULL(T4."BeginStr",'TT') AS  "BeginStr",
								T0."Number",
						        T1."Project"
						FROM {?Schema@}.OJDT T0
						INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
						LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
						LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
						LEFT JOIN {?Schema@}.NNM1 T4 ON T0."Series" = T4."Series"
						WHERE T2."FormatCode" IN ( '1102050106','1102050107')
 			 			--AND T3."Category" = TO_VARCHAR( TO_INT({?Year@}) - 543 )
 			 			  AND T0."RefDate" = {?1DStart@}
						  AND T1."Credit" <> 0
						  AND T1."U_SLD_Remark" IN ('4303010101', '4313010103', '4313010199')
 			 			  AND T1."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 			  AND T1."TransId" NOT IN (SELECT "TransId" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			 		
					  ) AS DB
				Group by DB."Project"
 			) AS DN ON T0."PrjCode" = DN."Project"
 			WHERE 	   (T0."U_SLD_PlanWork" = '{?Plan@}' OR '{?Plan@}' = '')
						  AND (T0."U_SLD_GroupWork" = '{?WorkGroup@}' OR '{?WorkGroup@}' = '')
 			
 			
 			
 			

