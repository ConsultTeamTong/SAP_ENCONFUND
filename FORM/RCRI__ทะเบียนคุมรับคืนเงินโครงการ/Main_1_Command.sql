-- ============================================================
-- Report: RCRI0036__ทะเบียนคุมรับคืนเงินโครงการ.rpt
Path:   RCRI0036__ทะเบียนคุมรับคืนเงินโครงการ.rpt
Extracted: 2026-05-07 18:03:44
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
EX."RefDate",
Concat(EX."BeginStr",EX."Number") AS "DocNum",
T0."PrjCode",
T0."U_SLD_ProjectName",
T0."U_SLD_PlanWork",
T0."U_SLD_GroupWork",
T0."U_SLD_Period",
T0."U_SLD_REQ",
T0."U_SLD_REC",
T0."U_SLD_Vendor",
T1."CLOSING",
T1."U_SLD_Status",
IFNULL(EX."Debit",0) AS "Debit",
IFNULL(RE."Credit",0) AS "RE",
IFNULL(RV."Credit",0) AS "RV",
IFNULL(RO."Credit",0) AS "RO",
IFNULL(RX."Credit",0) AS "RX",
IFNULL(RR01."Credit",0) AS "RR01",
IFNULL(RR02."Credit",0) AS "RR02",
IFNULL(RR03."Credit",0) AS "RR03",
IFNULL(TR."Credit",0) AS "TR"
FROM {?Schema@}.OPRJ T0
INNER JOIN {?Schema@}.OPMG T1 ON T0."PrjCode" = T1."FIPROJECT"
LEFT JOIN (	SELECT  T0."RefDate" ,
					T0."Number",
					T4."BeginStr",
					T1."Project",
					T2."FormatCode",
					T2."AcctName",
					 SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 --T1."U_SLD_Remark"
					 FROM {?Schema@}.OJDT T0 
					 INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
					 LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 LEFT JOIN {?Schema@}.NNM1 T4 ON T0."Series" = T4."Series"
					 WHERE T2."FormatCode" IN ('5107010101','5107010103','5107010105','5107010106','5107020104','5107020105','5107020199')
					 --AND T3."Category" <= '2027'--({?Year@} - 543)
					 AND T0."RefDate" BETWEEN {?1Sdate@} AND {?2Edate@}
					 AND T1."Debit" <> 0
					 AND "U_SLD_DocTyp" = 'RF'
					-- ==========================================
				    -- เพิ่มเงื่อนไขเพื่อตัดรายการ Reversal ทั้งต้นฉบับและตัว Reversal
				    -- ==========================================
				    AND T0."StornoToTr" IS NULL 
				    AND T0."TransId" NOT IN (
				        SELECT "StornoToTr" 
				        FROM {?Schema@}.OJDT 
				        WHERE "StornoToTr" IS NOT NULL)
					 Group by  T1."Project",T2."FormatCode",T2."AcctName",T0."Number",T4."BeginStr",T0."RefDate" 
			) AS EX ON T0."PrjCode" = EX."Project"
LEFT JOIN ( SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					--T1."RefDate",
 					--T1."Debit" AS "Debit",
 					--IFNULL(T1."Credit",0) AS "Credit",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit",
 					T1."U_SLD_Remark"
					 FROM {?Schema@}.OJDT T0 
					 INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			WHERE T2."FormatCode" IN ('1106010103')
 			--AND T3."Category" <= '2027'--({?Year@} - 543)
 			AND T0."RefDate" BETWEEN {?1Sdate@} AND {?2Edate@}
 			AND T1."Credit" <> 0
 			AND T1."U_SLD_Remark" = '9999999999'
 			AND "U_SLD_DocTyp" = 'RF'
					-- ==========================================
				    -- เพิ่มเงื่อนไขเพื่อตัดรายการ Reversal ทั้งต้นฉบับและตัว Reversal
				    -- ==========================================
				    AND T0."StornoToTr" IS NULL 
				    AND T0."TransId" NOT IN (
				        SELECT "StornoToTr" 
				        FROM {?Schema@}.OJDT 
				        WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark"
		) AS RE ON T0."PrjCode" = RE."Project"
LEFT JOIN (SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					--T1."RefDate",
 					--T1."Debit" AS "Debit",
 					--IFNULL(T1."Credit",0) AS "Credit",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit",
 					T1."U_SLD_Remark"
					 FROM {?Schema@}.OJDT T0 
					 INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			WHERE T2."FormatCode" IN ('4313010199')
 			--AND T3."Category" <= '2027'--({?Year@} - 543)
 			AND T0."RefDate" BETWEEN {?1Sdate@} AND {?2Edate@}
 			AND T1."Credit" <> 0
 			AND T1."U_SLD_Remark" = '9999999999'
 			AND "U_SLD_DocTyp" = 'RF'
					-- ==========================================
				    -- เพิ่มเงื่อนไขเพื่อตัดรายการ Reversal ทั้งต้นฉบับและตัว Reversal
				    -- ==========================================
				    AND T0."StornoToTr" IS NULL 
				    AND T0."TransId" NOT IN (
				        SELECT "StornoToTr" 
				        FROM {?Schema@}.OJDT 
				        WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark" 
			) RV ON T0."PrjCode" = RV."Project"
LEFT JOIN (SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					--T1."RefDate",
 					--T1."Debit" AS "Debit",
 					--IFNULL(T1."Credit",0) AS "Credit",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit",
 					T1."U_SLD_Remark"
					 FROM {?Schema@}.OJDT T0 
					 INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			WHERE T2."FormatCode" IN ('4313010199')
 			--AND T3."Category" <= '2027'--({?Year@} - 543)
 			AND T0."RefDate" BETWEEN {?1Sdate@} AND {?2Edate@}
 			AND T1."Credit" <> 0
 			AND T1."U_SLD_Remark" <> '9999999999'
 			AND "U_SLD_DocTyp" = 'RF'
					-- ==========================================
				    -- เพิ่มเงื่อนไขเพื่อตัดรายการ Reversal ทั้งต้นฉบับและตัว Reversal
				    -- ==========================================
				    AND T0."StornoToTr" IS NULL 
				    AND T0."TransId" NOT IN (
				        SELECT "StornoToTr" 
				        FROM {?Schema@}.OJDT 
				        WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark" 
			) RO ON T0."PrjCode" = RO."Project"
LEFT JOIN (SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					--T1."RefDate",
 					--T1."Debit" AS "Debit",
 					--IFNULL(T1."Credit",0) AS "Credit",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit",
 					T1."U_SLD_Remark"
					 FROM {?Schema@}.OJDT T0 
					 INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			WHERE T2."FormatCode" IN ('4313010103')
 			--AND T3."Category" <= '2027'--({?Year@} - 543)
 			AND T0."RefDate" BETWEEN {?1Sdate@} AND {?2Edate@}
 			AND T1."Credit" <> 0
 			--AND T1."U_SLD_Remark" <> '999999999'
 			AND "U_SLD_DocTyp" = 'RF'
					-- ==========================================
				    -- เพิ่มเงื่อนไขเพื่อตัดรายการ Reversal ทั้งต้นฉบับและตัว Reversal
				    -- ==========================================
				    AND T0."StornoToTr" IS NULL 
				    AND T0."TransId" NOT IN (
				        SELECT "StornoToTr" 
				        FROM {?Schema@}.OJDT 
				        WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category",T1."U_SLD_Remark" 
			) RX ON T0."PrjCode" = RX."Project"
LEFT JOIN (SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					--T1."RefDate",
 					--T1."Debit" AS "Debit",
 					--IFNULL(T1."Credit",0) AS "Credit",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit"
 					--T1."U_SLD_Remark"
					 FROM {?Schema@}.OJDT T0 
					 INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			WHERE T2."FormatCode" IN ('1102050106','1102050107')
 			--AND T3."Category" <= '2027'--({?Year@} - 543)
 			AND T0."RefDate" BETWEEN {?1Sdate@} AND {?2Edate@}
 			AND T1."Credit" <> 0
 			AND T1."U_SLD_Remark" = '4313010103'
 			AND "U_SLD_DocTyp" = 'RF'
					-- ==========================================
				    -- เพิ่มเงื่อนไขเพื่อตัดรายการ Reversal ทั้งต้นฉบับและตัว Reversal
				    -- ==========================================
				    AND T0."StornoToTr" IS NULL 
				    AND T0."TransId" NOT IN (
				        SELECT "StornoToTr" 
				        FROM {?Schema@}.OJDT 
				        WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category"--,T1."U_SLD_Remark" 
			) RR01 ON T0."PrjCode" = RR01."Project"
LEFT JOIN (SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					--T1."RefDate",
 					--T1."Debit" AS "Debit",
 					--IFNULL(T1."Credit",0) AS "Credit",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit"
 					--T1."U_SLD_Remark"
					 FROM {?Schema@}.OJDT T0 
					 INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			WHERE T2."FormatCode" IN ('1102050106','1102050107')
 			--AND T3."Category" <= '2027'--({?Year@} - 543)
 			AND T0."RefDate" BETWEEN {?1Sdate@} AND {?2Edate@}
 			AND T1."Credit" <> 0
 			AND T1."U_SLD_Remark" = '4313010199'
 			AND "U_SLD_DocTyp" = 'RF'
					-- ==========================================
				    -- เพิ่มเงื่อนไขเพื่อตัดรายการ Reversal ทั้งต้นฉบับและตัว Reversal
				    -- ==========================================
				    AND T0."StornoToTr" IS NULL 
				    AND T0."TransId" NOT IN (
				        SELECT "StornoToTr" 
				        FROM {?Schema@}.OJDT 
				        WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category"--,T1."U_SLD_Remark" 
			) RR02 ON T0."PrjCode" = RR02."Project"
LEFT JOIN (SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					--T1."RefDate",
 					--T1."Debit" AS "Debit",
 					--IFNULL(T1."Credit",0) AS "Credit",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit"
 					--T1."U_SLD_Remark"
					 FROM {?Schema@}.OJDT T0 
					 INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			WHERE T2."FormatCode" IN ('1102050106','1102050107')
 			--AND T3."Category" <= '2027'--({?Year@} - 543)
 			AND T0."RefDate" BETWEEN {?1Sdate@} AND {?2Edate@}
 			AND T1."Credit" <> 0
 			AND T1."U_SLD_Remark" = '4303010101'
 			AND "U_SLD_DocTyp" = 'RF'
					-- ==========================================
				    -- เพิ่มเงื่อนไขเพื่อตัดรายการ Reversal ทั้งต้นฉบับและตัว Reversal
				    -- ==========================================
				    AND T0."StornoToTr" IS NULL 
				    AND T0."TransId" NOT IN (
				        SELECT "StornoToTr" 
				        FROM {?Schema@}.OJDT 
				        WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category"--,T1."U_SLD_Remark" 
			) RR03 ON T0."PrjCode" = RR03."Project"
LEFT JOIN (SELECT  T1."Project",
					T2."FormatCode",
					T2."AcctName",
					T1."FinncPriod",
					T3."AbsEntry",
					T3."Category",
					--T1."RefDate",
 					--T1."Debit" AS "Debit",
 					--IFNULL(T1."Credit",0) AS "Credit",
 					SUM(IFNULL(T1."Credit",0)) AS "Credit"
 					--T1."U_SLD_Remark"
					 FROM {?Schema@}.OJDT T0 
					 INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
 			--WHERE T2."FormatCode" = '4303010101'
 			WHERE T2."FormatCode" IN ('4303010101')
 			AND T3."Category" = '2027'--({?Year@} - 543)
 			AND T0."RefDate" BETWEEN {?1Sdate@} AND {?2Edate@}
 			AND T1."Credit" <> 0
 			--AND T1."U_SLD_Remark" <> '4303010101'
 			AND "U_SLD_DocTyp" = 'RF'
					-- ==========================================
				    -- เพิ่มเงื่อนไขเพื่อตัดรายการ Reversal ทั้งต้นฉบับและตัว Reversal
				    -- ==========================================
				    AND T0."StornoToTr" IS NULL 
				    AND T0."TransId" NOT IN (
				        SELECT "StornoToTr" 
				        FROM {?Schema@}.OJDT 
				        WHERE "StornoToTr" IS NOT NULL)
			Group by  T1."Project",T2."FormatCode",T2."AcctName",T1."FinncPriod",T3."AbsEntry",T3."Category"--,T1."U_SLD_Remark" 
			) TR ON T0."PrjCode" = TR."Project"
WHERE (EX."RefDate" IS NOT NULL OR EX."RefDate" <> '')
AND (T0."PrjCode" = '{?PrjCode@}' OR '{?PrjCode@}' = '')
AND (T0."U_SLD_Period" = '{?Period@}' OR '{?Period@}' = '')
AND (T1."U_U_SLD_Plan" = '{?Plan@}' OR '{?Plan@}' = '')
AND (T1."U_U_SLD_WorkGroup" = '{?WorkGroup@}' OR '{?WorkGroup@}' = '')
AND (IFNULL(EX."Debit",0) - 
IFNULL(RE."Credit",0) - 
IFNULL(RV."Credit",0) - 
IFNULL(RO."Credit",0) - 
IFNULL(RX."Credit",0) - 
IFNULL(RR01."Credit",0) - 
IFNULL(RR03."Credit",0) - 
IFNULL(TR."Credit",0) ) <> 0

