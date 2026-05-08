-- ============================================================
-- Report: RCRI0014__ทะเบียนคุมค่าใช้จ่ายแผนงานโครงการ.rpt
Path:   RCRI0014__ทะเบียนคุมค่าใช้จ่ายแผนงานโครงการ.rpt
Extracted: 2026-05-07 18:03:35
-- Source: Subreport [ttttttttt]
-- Table:  Command
-- ============================================================

SELECT DISTINCT
EX."Category"
FROM {?Schema@}.OPRJ T0
INNER JOIN {?Schema@}.OPMG T1 ON T0."PrjCode" = T1."FIPROJECT"
LEFT JOIN (								SELECT  T1."Project",
										T2."FormatCode",
										T2."AcctName",
										Concat(N'30 ก.ย.',(T3."Category")+(543)) AS "Category",
					 					SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 					--T1."U_SLD_Remark"
					 			FROM {?Schema@}.OJDT T0 
					 			INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					 			LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			WHERE T2."FormatCode" IN ('5107010101','5107010103','5107010105','5107010106','5107020104','5107020105','5107020199')
					 			AND T0."RefDate" <= {?StartDate@}
AND T0."TransId" NOT IN (SELECT "StornoToTr"
                                                            FROM {?Schema@}.OJDT
                                                            WHERE "StornoToTr" IS NOT NULL)
					 			AND T1."Debit" <> 0
								Group by  T1."Project",T2."FormatCode",T2."AcctName",T3."Category")  AS EX ON T0."PrjCode" = EX."Project"
