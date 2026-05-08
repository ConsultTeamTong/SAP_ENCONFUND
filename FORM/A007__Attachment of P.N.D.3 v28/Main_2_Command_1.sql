-- ============================================================
-- Report: A0070001__Attachment of P.N.D.3 v28.rpt
Path:   A0070001__Attachment of P.N.D.3 v28.rpt
Extracted: 2026-05-07 18:02:36
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT 	Sum(C.TaxbleAmnt) TaxbleAmnt,
		Sum(C.WTAmnt) WTAmnt FROM (
SELECT 
		B.TaxbleAmnt,
		B.WTAmnt
FROM (
		SELECT DISTINCT 	'OVPM' AS TYPE,
							OVPM.TransId,
							CASE WHEN CHWTH.WTCode IS NULL THEN VPM6.TaxbleAmnt ELSE WTH.TaxbleAmnt END AS TaxbleAmnt,
							CASE WHEN CHWTH.WTCode IS NULL THEN VPM6.WTSum ELSE WTH.WTAmnt END AS WTAmnt
		FROM  OVPM 
		LEFT JOIN VPM6 ON OVPM.DocEntry = VPM6.DocNum 
		LEFT JOIN OWHT ON VPM6.WTCode = OWHT.WTCode 
		LEFT JOIN  OCRD ON OCRD.CardCode = OVPM.CardCode
		LEFT JOIN (SELECT DISTINCT DocNum, WTCode 
      				FROM VPM6 
			        WHERE VPM6.WTSum < 0 
		) AS CHWTH ON OVPM.DocEntry = CHWTH.DocNum
		LEFT JOIN (SELECT VPM6.DocNum,
                        VPM6.WTCode,
						VPM6.Line,
                        SUM(VPM6.WTSum) AS WTAmnt ,
                        ((SUM(VPM6.WTSum)*100)/OWHT.Rate) AS TaxbleAmnt 
                 FROM VPM6
                 LEFT JOIN OWHT ON OWHT.WTCode = VPM6.WTCode
                 GROUP BY VPM6.DocNum,VPM6.WTCode,OWHT.Rate,VPM6.Line
		) AS WTH ON OVPM.DocEntry = WTH.DocNum AND WTH.WTCode = VPM6.WTCode AND VPM6.Line = WTH.Line 

		WHERE OVPM.TransId IN (SELECT TransId FROM  JDT1 WHERE JDT1.ShortName = 
															(SELECT AcctCode FROM  OACT WHERE FormatCode = 
																	(SELECT [Name] FROM  [@SLDT_SET_ACCWH] WHERE [U_SLD_TypeWH] = '03')))
							
							                                
		UNION ALL
		SELECT 				'OPCH' AS TYPE,
							OPCH.TransId,
							PCH5.TaxbleAmnt,
							PCH5.WTAmnt AS WTAmnt
		FROM  OPCH 
		JOIN PCH5 ON OPCH.DocEntry = PCH5.AbsEntry 
		JOIN OWHT ON PCH5.WTCode = OWHT.WTCode 
		WHERE OPCH.TransId IN (SELECT TransId FROM  JDT1 WHERE JDT1.ShortName = 
														(SELECT AcctCode FROM  OACT WHERE FormatCode = 
																(SELECT [Name] FROM  [@SLDT_SET_ACCWH] WHERE [U_SLD_TypeWH] = '03')))
							
							                                
		UNION ALL
		SELECT 				'OJDT' AS TYPE,
							JDT1.TransId,
							JDT2.TaxbleAmnt AS TaxbleAmnt,
							JDT2.WTAmnt
		FROM JDT1 
		INNER JOIN OJDT ON JDT1.TransId = OJDT.TransId
		INNER JOIN JDT2 ON JDT2.AbsEntry = OJDT.TransId AND JDT2.Account = 
					(SELECT AcctCode FROM  OACT WHERE FormatCode = (SELECT [Name] FROM  [@SLDT_SET_ACCWH] WHERE [U_SLD_TypeWH] = '03'))
		WHERE JDT1.Credit > 0
							
							
		UNION ALL
		SELECT 				'OJDT' AS TYPE,
							JDT1.TransId,
							JDT1.U_SLD_WTBaseAmt AS TaxbleAmnt,
							((JDT1.U_SLD_WTBaseAmt * (SELECT OWHT.Rate FROM  OWHT WHERE OWHT.WTCode = JDT1.U_SLD_WTCode AND JDT1.ShortName = (SELECT AcctCode FROM  OACT WHERE FormatCode = (SELECT [Name] FROM  [@SLDT_SET_ACCWH] WHERE [U_SLD_TypeWH] = '03')))) / 100.0 )AS WTAmnt
							FROM  JDT1 
		JOIN OJDT  ON JDT1.TransId = OJDT.TransId
		WHERE(JDT1.ShortName = (SELECT AcctCode FROM  OACT WHERE FormatCode = (SELECT [Name] FROM  [@SLDT_SET_ACCWH] WHERE [U_SLD_TypeWH] = '03')))
							                                             
)
AS B 
WHERE  B.WTAmnt IS NOT NULL AND B.TransId In ({?DocKey@},'0')
)C
