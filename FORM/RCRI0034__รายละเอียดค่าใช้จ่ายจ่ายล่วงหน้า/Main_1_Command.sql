-- ============================================================
-- Report: RCRI0034__รายละเอียดค่าใช้จ่ายจ่ายล่วงหน้า.rpt
Path:   RCRI0034__รายละเอียดค่าใช้จ่ายจ่ายล่วงหน้า.rpt
Extracted: 2026-05-07 18:03:43
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT
T0."PrjCode",
T0."U_SLD_ProjectName",
T0."U_SLD_PlanWork",
T0."U_SLD_GroupWork",
T0."U_SLD_Period",
T0."U_SLD_REQ",
T0."U_SLD_REC",
T0."U_SLD_Vendor",
T1."START"  AS "START",
T1."CLOSING" AS "CLOSING",
T1."DUEDATE" AS "DUEDATE",
T1."U_SLD_Status",
IFNULL(OB."OB1",0) AS "OB1",
IFNULL(AP."APtotal",0) AS "APtotal",
IFNULL(EX."Debit",0) AS "EX01",
IFNULL(RE."Credit",0) AS "RE01",
(IFNULL(OB."OB1",0) + IFNULL(AP."APtotal",0) - IFNULL(EX."Debit",0) - IFNULL(RE."Credit",0)) AS "OA01"
FROM {?Schema@}.OPRJ T0
INNER JOIN {?Schema@}.OPMG T1 ON T0."PrjCode" = T1."FIPROJECT"
LEFT JOIN ( SELECT 	--T2."DocEntry",
					--T2."DocDate",
					T2."Project",
					T2."CANCELED",
					--T3."Category",
					--T2."NumAtCard",
					-- T2."DocTotal"
					SUM(T2."DocTotal") AS "APtotal"
			FROM {?Schema@}.OPCH T2
			LEFT JOIN {?Schema@}.OFPR T3 ON T2."FinncPriod" = T3."AbsEntry"
			WHERE T2."CANCELED" = 'N'
			AND T2."DocDate" BETWEEN {?StrDate@} AND {?EndDate@}
AND T2."NumAtCard" LIKE '%งวดที่%'
			Group by --T2."DocDate",
					T2."Project",
					T2."CANCELED"
					--T3."Category"
					--T2."NumAtCard" 
			) AS AP ON T0."PrjCode" = AP."Project"

LEFT JOIN (	SELECT  T1."Project",
 					SUM(IFNULL(T1."Debit",0)) AS "Debit"
 			FROM {?Schema@}.OJDT T0
 			LEFT JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			 WHERE T2."FormatCode" IN ('5107010101','5107010103','5107010105','5107010106','5107020104','5107020105','5107020199')
 			AND T0."RefDate" BETWEEN {?StrDate@} AND {?EndDate@}
 			AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			AND T1."Debit" <> 0
 			AND T1."Project" NOT IN (                          
								      'กทอ.65-07-0078',
								      'กทอ.65-07-0152',                                                
								      'กทอ.65-07-0155',
								      'กทอ.65-07-0156',                                                
								      'กทอ.65-07-0157',                                     
								      'กทอ.65-07-0158',
								      'กทอ.65-07-0159',
								      'กทอ.65-07-0160',
								      'กทอ.65-07-0161',
								      'กทอ.61-01-94-0001',
								      'กทอ.61-01-82-0002'
								  )
 			-- AND T1."U_SLD_Remark" = '4303010101'
			Group by  T1."Project"
			)  AS EX ON T0."PrjCode" = EX."Project"
LEFT JOIN (	SELECT  
				T1."Project",
				T1."TransId",	
 					SUM(IFNULL(T1."Credit",0)) AS "Credit"
 			FROM {?Schema@}.OJDT T0
 			LEFT JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			 WHERE T2."FormatCode" IN ('1106010103')
 			AND T0."RefDate" BETWEEN {?StrDate@} AND {?EndDate@}
 			AND T1."Credit" <> 0
 			AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
 			AND T1."U_SLD_Remark" = '9999999999'
 			AND T1."Project" NOT IN (                          
								      'กทอ.65-07-0078',
								      'กทอ.65-07-0152',                                                
								      'กทอ.65-07-0155',
								      'กทอ.65-07-0156',                                                
								      'กทอ.65-07-0157',                                     
								      'กทอ.65-07-0158',
								      'กทอ.65-07-0159',
								      'กทอ.65-07-0160',
								      'กทอ.65-07-0161',
								      'กทอ.61-01-94-0001',
								      'กทอ.61-01-82-0002'
								  )
			Group by  T1."Project",T1."TransId"
		) AS RE ON T0."PrjCode" = RE."Project"
LEFT JOIN ( 	SELECT
					T0."PrjCode",
					T0."U_SLD_ProjectName",
					T0."U_SLD_PlanWork",
					T0."U_SLD_GroupWork",
					T0."U_SLD_Period",
					T0."U_SLD_REQ",
					T0."U_SLD_REC",
					T0."U_SLD_Vendor",
					T1."START",
					T1."CLOSING",
					(IFNULL(CR."Debit",0) + (IFNULL(AP."APtotal",0) - IFNULL(EX."Debit",0) - IFNULL(RE."Credit",0))) AS "OB1"
					FROM {?Schema@}.OPRJ T0
					INNER JOIN {?Schema@}.OPMG T1 ON T0."PrjCode" = T1."FIPROJECT"
					LEFT JOIN ( SELECT 	T2."Project",
										SUM(T2."DocTotal") AS "APtotal"
								FROM {?Schema@}.OPCH T2
								LEFT JOIN {?Schema@}.OFPR T3 ON T2."FinncPriod" = T3."AbsEntry"
								WHERE T2."CANCELED" = 'N'
								AND T2."DocDate" < {?StrDate@}
								--AND T3."Category" < {?StrDate@}
								AND T2."NumAtCard" LIKE '%งวดที่%'
								Group by --T2."DocDate",
										T2."Project"
								) AS AP ON T0."PrjCode" = AP."Project"
---------------------------------------------------------------------------------------------------------------------------								
					LEFT JOIN (	SELECT  T1."Project",
					 			SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 			FROM {?Schema@}.OJDT T0
 								LEFT JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			 WHERE T2."FormatCode" IN ('1106010103')
					 			AND T0."RefDate" < {?StrDate@}
					 			AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
					 			AND T1."Debit" <> 0
					 			AND T1."Project" NOT IN (                          
								      'กทอ.65-07-0078',
								      'กทอ.65-07-0152',                                                
								      'กทอ.65-07-0155',
								      'กทอ.65-07-0156',                                                
								      'กทอ.65-07-0157',                                     
								      'กทอ.65-07-0158',
								      'กทอ.65-07-0159',
								      'กทอ.65-07-0160',
								      'กทอ.65-07-0161',
								      'กทอ.61-01-94-0001',
								      'กทอ.61-01-82-0002'
								  )
								Group by  T1."Project"
								)  AS CR ON T0."PrjCode" = CR."Project"
---------------------------------------------------------------------------------------------------------------------------								
					LEFT JOIN (	SELECT  T1."Project",
					 					SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 			FROM {?Schema@}.OJDT T0
 								LEFT JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			 WHERE T2."FormatCode" IN ('5107010101','5107010103','5107010105','5107010106','5107020104','5107020105','5107020199')
					 			AND T0."RefDate" < {?StrDate@}
					 			AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
					 			AND T1."Debit" <> 0
					 			AND T1."Project" NOT IN (                          
								      'กทอ.65-07-0078',
								      'กทอ.65-07-0152',                                                
								      'กทอ.65-07-0155',
								      'กทอ.65-07-0156',                                                
								      'กทอ.65-07-0157',                                     
								      'กทอ.65-07-0158',
								      'กทอ.65-07-0159',
								      'กทอ.65-07-0160',
								      'กทอ.65-07-0161',
								      'กทอ.61-01-94-0001',
								      'กทอ.61-01-82-0002'
								  )
								Group by  T1."Project"
								)  AS EX ON T0."PrjCode" = EX."Project"
					LEFT JOIN (	SELECT  T1."Project",
					 					SUM(IFNULL(T1."Credit",0)) AS "Credit"
					 			FROM {?Schema@}.OJDT T0
 								LEFT JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
					 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			--WHERE T2."FormatCode" = '4303010101'
					 			 WHERE T2."FormatCode" IN ('1106010103')
								AND T1."Project" NOT IN (                          
								      'กทอ.65-07-0078',
								      'กทอ.65-07-0152',                                                
								      'กทอ.65-07-0155',
								      'กทอ.65-07-0156',                                                
								      'กทอ.65-07-0157',                                     
								      'กทอ.65-07-0158',
								      'กทอ.65-07-0159',
								      'กทอ.65-07-0160',
								      'กทอ.65-07-0161',
								      'กทอ.61-01-94-0001',
								      'กทอ.61-01-82-0002'
								  )
					 			AND T0."RefDate" < {?StrDate@}
					 			AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL)
					 			AND T1."Credit" <> 0
					 			AND T1."U_SLD_Remark" = '9999999999'
								Group by  T1."Project"
								,T1."U_SLD_Remark"
							) AS RE ON T0."PrjCode" = RE."Project" 
				) AS OB ON T0."PrjCode" = OB."PrjCode"
WHERE (T0."PrjCode" = '{?PrjCode@}' OR '{?PrjCode@}' = '')
AND (T0."U_SLD_Period" = '{?Period@}' OR '{?Period@}' = '')
AND	
(	 	IFNULL(OB."OB1",0) <> 0
	  OR 	IFNULL(AP."APtotal",0) <> 0
	  OR		IFNULL(EX."Debit",0) <> 0
	  OR		IFNULL(RE."Credit",0) <> 0
	)
--AND (OINV."CardName" =  '{?Cname@}' OR '{?Cname@}' = '')
