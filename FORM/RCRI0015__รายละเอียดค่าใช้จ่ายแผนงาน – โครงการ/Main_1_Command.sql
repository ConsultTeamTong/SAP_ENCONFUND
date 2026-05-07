-- ============================================================
-- Report: RCRI0015__รายละเอียดค่าใช้จ่ายแผนงาน – โครงการ.rpt
Path:   RCRI0015__รายละเอียดค่าใช้จ่ายแผนงาน – โครงการ.rpt
Extracted: 2026-05-07 18:03:35
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
T0."U_SLD_PlanWork",
T0."U_SLD_GroupWork",
T0."U_SLD_Period",
/*EX01."Debit"AS "EX01",
EX02."Debit" AS "EX02",
EX03."Debit" AS "EX03",
EX04."Debit" AS "EX04",
EX05."Debit" AS "EX05",
EX06."Debit" AS "EX06",
EX07."Debit" AS "EX07"*/

IFNULL(EX01."Debit",0) AS "EX01",
IFNULL(EX02."Debit",0) AS "EX02",
IFNULL(EX03."Debit",0) AS "EX03",
IFNULL(EX04."Debit",0) AS "EX04",
IFNULL(EX05."Debit",0) AS "EX05",
IFNULL(EX06."Debit",0) AS "EX06",
IFNULL(EX07."Debit",0) AS "EX07"
FROM {?Schema@}.OPRJ T0
LEFT JOIN {?Schema@}.OPMG T1 ON T0."PrjCode" = T1."FIPROJECT"
LEFT JOIN (			SELECT  T0."U_SLD_PlanWork",
					T0."U_SLD_GroupWork",
					T0."U_SLD_Period",
					T2."FormatCode",
					T2."AcctName",
					 SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 --T1."U_SLD_Remark"
					 FROM {?Schema@}.JDT1 T1 
					 LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 LEFT JOIN {?Schema@}.OPRJ T0 ON T1."Project" = T0."PrjCode" 
					 WHERE T2."FormatCode" IN ('5107010101')
					 AND T3."Category" = ({?Year@}-543)
					 AND T1."Debit" <> 0
					 AND T1."TransId" NOT IN (SELECT "StornoToTr"
                                                            FROM {?Schema@}.OJDT
                                                            WHERE "StornoToTr" IS NOT NULL)
					 Group by  T0."U_SLD_PlanWork",T0."U_SLD_GroupWork",T0."U_SLD_Period",T2."FormatCode",T2."AcctName"
		)	AS EX01	ON T0."U_SLD_PlanWork" = EX01."U_SLD_PlanWork" AND T0."U_SLD_GroupWork" = EX01."U_SLD_GroupWork" AND T0."U_SLD_Period" = EX01."U_SLD_Period"
LEFT JOIN (			SELECT  T0."U_SLD_PlanWork",
					T0."U_SLD_GroupWork",
					T0."U_SLD_Period",
					T2."FormatCode",
					T2."AcctName",
					 SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 --T1."U_SLD_Remark"
					 FROM {?Schema@}.JDT1 T1 
					 LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 LEFT JOIN {?Schema@}.OPRJ T0 ON T1."Project" = T0."PrjCode" 
					 WHERE T2."FormatCode" IN ('5107010103')
					 AND T3."Category" = ({?Year@}-543)
					 AND T1."Debit" <> 0
					 AND T1."TransId" NOT IN (SELECT "StornoToTr"
                                                            FROM {?Schema@}.OJDT
                                                            WHERE "StornoToTr" IS NOT NULL)
					 Group by  T0."U_SLD_PlanWork",T0."U_SLD_GroupWork",T0."U_SLD_Period",T2."FormatCode",T2."AcctName"
		)	AS EX02	ON T0."U_SLD_PlanWork" = EX02."U_SLD_PlanWork" AND T0."U_SLD_GroupWork" = EX02."U_SLD_GroupWork" AND T0."U_SLD_Period" = EX02."U_SLD_Period"
LEFT JOIN (			SELECT  T0."U_SLD_PlanWork",
					T0."U_SLD_GroupWork",
					T0."U_SLD_Period",
					T2."FormatCode",
					T2."AcctName",
					 SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 --T1."U_SLD_Remark"
					 FROM {?Schema@}.JDT1 T1 
					 LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 LEFT JOIN {?Schema@}.OPRJ T0 ON T1."Project" = T0."PrjCode" 
					 WHERE T2."FormatCode" IN ('5107010105')
					 AND T3."Category" = ({?Year@}-543)
					 AND T1."Debit" <> 0
					 AND T1."TransId" NOT IN (SELECT "StornoToTr"
                                                            FROM {?Schema@}.OJDT
                                                            WHERE "StornoToTr" IS NOT NULL)
					 Group by  T0."U_SLD_PlanWork",T0."U_SLD_GroupWork",T0."U_SLD_Period",T2."FormatCode",T2."AcctName"
		)	AS EX03	ON T0."U_SLD_PlanWork" = EX03."U_SLD_PlanWork" AND T0."U_SLD_GroupWork" = EX03."U_SLD_GroupWork" AND T0."U_SLD_Period" = EX03."U_SLD_Period"
LEFT JOIN (			SELECT  T0."U_SLD_PlanWork",
					T0."U_SLD_GroupWork",
					T0."U_SLD_Period",
					T2."FormatCode",
					T2."AcctName",
					 SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 --T1."U_SLD_Remark"
					 FROM {?Schema@}.JDT1 T1 
					 LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 LEFT JOIN {?Schema@}.OPRJ T0 ON T1."Project" = T0."PrjCode" 
					 WHERE T2."FormatCode" IN ('5107010106')
					 AND T3."Category" = ({?Year@}-543)
					 AND T1."Debit" <> 0
					 AND T1."TransId" NOT IN (SELECT "StornoToTr"
                                                            FROM {?Schema@}.OJDT
                                                            WHERE "StornoToTr" IS NOT NULL)
					 Group by  T0."U_SLD_PlanWork",T0."U_SLD_GroupWork",T0."U_SLD_Period",T2."FormatCode",T2."AcctName"
		)	AS EX04	ON T0."U_SLD_PlanWork" = EX04."U_SLD_PlanWork" AND T0."U_SLD_GroupWork" = EX04."U_SLD_GroupWork" AND T0."U_SLD_Period" = EX04."U_SLD_Period"
LEFT JOIN (			SELECT  T0."U_SLD_PlanWork",
					T0."U_SLD_GroupWork",
					T0."U_SLD_Period",
					T2."FormatCode",
					T2."AcctName",
					 SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 --T1."U_SLD_Remark"
					 FROM {?Schema@}.JDT1 T1 
					 LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 LEFT JOIN {?Schema@}.OPRJ T0 ON T1."Project" = T0."PrjCode" 
					 WHERE T2."FormatCode" IN ('5107020104')
					 AND T3."Category" = ({?Year@}-543)
					 AND T1."Debit" <> 0
					 AND T1."TransId" NOT IN (SELECT "StornoToTr"
                                                            FROM {?Schema@}.OJDT
                                                            WHERE "StornoToTr" IS NOT NULL)
					 Group by  T0."U_SLD_PlanWork",T0."U_SLD_GroupWork",T0."U_SLD_Period",T2."FormatCode",T2."AcctName"
		)	AS EX05	ON T0."U_SLD_PlanWork" = EX05."U_SLD_PlanWork" AND T0."U_SLD_GroupWork" = EX05."U_SLD_GroupWork" AND T0."U_SLD_Period" = EX05."U_SLD_Period"
LEFT JOIN (			SELECT  T0."U_SLD_PlanWork",
					T0."U_SLD_GroupWork",
					T0."U_SLD_Period",
					T2."FormatCode",
					T2."AcctName",
					 SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 --T1."U_SLD_Remark"
					 FROM {?Schema@}.JDT1 T1 
					 LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 LEFT JOIN {?Schema@}.OPRJ T0 ON T1."Project" = T0."PrjCode" 
					 WHERE T2."FormatCode" IN ('5107020105')
					 AND T3."Category" = ({?Year@}-543)
					 AND T1."Debit" <> 0
					 AND T1."TransId" NOT IN (SELECT "StornoToTr"
                                                            FROM {?Schema@}.OJDT
                                                            WHERE "StornoToTr" IS NOT NULL)
					 Group by  T0."U_SLD_PlanWork",T0."U_SLD_GroupWork",T0."U_SLD_Period",T2."FormatCode",T2."AcctName"
		)	AS EX06	ON T0."U_SLD_PlanWork" = EX06."U_SLD_PlanWork" AND T0."U_SLD_GroupWork" = EX06."U_SLD_GroupWork" AND T0."U_SLD_Period" = EX06."U_SLD_Period"
LEFT JOIN (			SELECT  T0."U_SLD_PlanWork",
					T0."U_SLD_GroupWork",
					T0."U_SLD_Period",
					T2."FormatCode",
					T2."AcctName",
					 SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 --T1."U_SLD_Remark"
					 FROM {?Schema@}.JDT1 T1 
					 LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 LEFT JOIN {?Schema@}.OPRJ T0 ON T1."Project" = T0."PrjCode" 
					 WHERE T2."FormatCode" IN ('5107020199')
					 AND T3."Category" = ({?Year@}-543)
					 AND T1."Debit" <> 0
					 AND T1."TransId" NOT IN (SELECT "StornoToTr"
                                                            FROM {?Schema@}.OJDT
                                                            WHERE "StornoToTr" IS NOT NULL)
					 Group by  T0."U_SLD_PlanWork",T0."U_SLD_GroupWork",T0."U_SLD_Period",T2."FormatCode",T2."AcctName"
		)	AS EX07	ON T0."U_SLD_PlanWork" = EX07."U_SLD_PlanWork" AND T0."U_SLD_GroupWork" = EX07."U_SLD_GroupWork" AND T0."U_SLD_Period" = EX07."U_SLD_Period"
WHERE 
		(IFNULL(EX01."Debit",0) <> 0
OR		IFNULL(EX02."Debit",0) <> 0
OR		IFNULL(EX03."Debit",0) <> 0
OR		IFNULL(EX04."Debit",0) <> 0
OR		IFNULL(EX05."Debit",0) <> 0
OR		IFNULL(EX06."Debit",0) <> 0
OR		IFNULL(EX07."Debit",0) <> 0)
AND (EX07."U_SLD_PlanWork" = '{?Plan@}' OR '{?Plan@}' = '')
AND (EX07."U_SLD_GroupWork" = '{?WorkGroup@}' OR '{?WorkGroup@}' = '')
