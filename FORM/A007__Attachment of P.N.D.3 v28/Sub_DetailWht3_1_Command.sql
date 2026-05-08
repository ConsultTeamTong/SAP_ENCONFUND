-- ============================================================
-- Report: A0070001__Attachment of P.N.D.3 v28.rpt
Path:   A0070001__Attachment of P.N.D.3 v28.rpt
Extracted: 2026-05-07 18:02:36
-- Source: Subreport [DetailWht3]
-- Table:  Command
-- ============================================================

SELECT ROW_NUMBER() OVER (
        Partition By B.TransId
        ORDER BY B.TransId
    ) AS Row,
    B.TransId,
    B.TaxId,
    B.RunNo,
    Sum(B.TaxbleAmnt) AS TaxbleAmnt,
    Sum(B.WTAmnt) AS WTAmnt,
    DATEADD(YEAR,543, B.WHTDate) AS WHTDate,
    B.LicTradNum,
    B.WTCode,
    B.WTName,
    B.U_SLD_WhPayBy,
    B.Rate
FROM (
        SELECT DISTINCT 'OVPM' AS TYPE,
            OVPM.TransId,
            (
                SELECT MAX(OCRD.LicTradNum)
                FROM OCRD
                    JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode
                WHERE OCRD.CardCode = OVPM.CardCode
            ) AS TaxId,
            (Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
				from [@SLDT_WTS_TST]
				where [@SLDT_WTS_TST].[U_Status] = 'Y'
                  And [@SLDT_WTS_TST].[U_TransID] = OVPM.TransId
                  AND [U_Date_Wht] = FORMAT(OVPM.TaxDate, 'yyyyMMdd')
			) AS RunNo,
			CASE WHEN CHWTH.WTCode IS NULL THEN VPM6.TaxbleAmnt ELSE WTH.TaxbleAmnt END AS TaxbleAmnt,
			CASE WHEN CHWTH.WTCode IS NULL THEN VPM6.WTSum ELSE WTH.WTAmnt END AS WTAmnt,
            OVPM.TaxDate AS WHTDate,
            OCRD.LicTradNum,
            OWHT.WTCode,
            OWHT.WTName,
            (SELECT TOP 1 ISNULL(OPCH.U_SLD_WhPayBy, ODPO.U_SLD_WhPayBy)
                FROM VPM2
                    LEFT JOIN OPCH ON VPM2.DocEntry = OPCH.DocEntry
                    AND VPM2.InvType = 18
                    LEFT JOIN ODPO ON VPM2.DocEntry = ODPO.DocEntry
                    AND VPM2.InvType = 204
                where VPM2.DocNum = OVPM.DocEntry
            ) AS U_SLD_WhPayBy,
            OWHT.Rate
        FROM OVPM
            JOIN VPM6 ON OVPM.DocEntry = VPM6.DocNum
            JOIN OWHT ON VPM6.WTCode = OWHT.WTCode
            LEFT JOIN OCRD ON OCRD.CardCode = OVPM.CardCode
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
            
        WHERE OVPM.TransId IN (
                SELECT TransId
                FROM JDT1
                WHERE JDT1.ShortName = (
                        SELECT OACT.AcctCode
                        FROM OACT
                        WHERE OACT.FormatCode = (
                                SELECT [@SLDT_SET_ACCWH].[Name]
												FROM [@SLDT_SET_ACCWH]
												WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                            )
                    )
            )
------------------------------------------------------------------------------------------------------------------------------------------------
        UNION ALL
------------------------------------------------------------------------------------------------------------------------------------------------
        SELECT DISTINCT 'OPCH' AS TYPE,
            OPCH.TransId,
            OPCH.LicTradNum AS TaxId,
            (
								Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
								from [@SLDT_WTS_TST]
								where [@SLDT_WTS_TST].[U_Status] = 'Y'
								And [@SLDT_WTS_TST].[U_TransID] = OPCH.TransId
								AND [@SLDT_WTS_TST].[U_Date_Wht] = FORMAT(OPCH.TaxDate, 'yyyyMMdd')
							) AS RunNo,
            PCH5.TaxbleAmnt,
            PCH5.WTAmnt AS WTAmnt,
            OPCH.TaxDate AS WHTDate,
            OPCH.LicTradNum,
            OWHT.WTCode,
            OWHT.WTName,
            OPCH.U_SLD_WhPayBy,
            OWHT.Rate
        FROM OPCH
            JOIN PCH5 ON OPCH.DocEntry = PCH5.AbsEntry
            JOIN OWHT ON PCH5.WTCode = OWHT.WTCode
        WHERE OPCH.TransId IN (
                SELECT JDT1.TransId
                FROM JDT1
                WHERE JDT1.ShortName = (
                        SELECT OACT.AcctCode
                        FROM OACT
                        WHERE OACT.FormatCode = (
                                SELECT [@SLDT_SET_ACCWH].[Name]
												FROM [@SLDT_SET_ACCWH]
												WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                            )
                    )
            )
------------------------------------------------------------------------------------------------------------------------------------------------
        UNION ALL
------------------------------------------------------------------------------------------------------------------------------------------------
        SELECT DISTINCT 'OJDT' AS TYPE,
            JDT1.TransId,
            JDT1.U_SLD_LBPTaxID AS TaxId,
            (
								Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
								from [@SLDT_WTS_TST] 
								where [@SLDT_WTS_TST].[U_Status] = 'Y'
									And [@SLDT_WTS_TST].[U_TransID] = OJDT.TransId
									AND [U_Date_Wht] = FORMAT(JDT1.U_SLD_WHdate, 'yyyyMMdd')
							) AS RunNo,
            JDT2.TaxbleAmnt AS TaxbleAmnt,
            JDT2.WTAmnt,
            JDT1.TaxDate AS WHTDate,
            ISNULL(JDT1.LicTradNum, JDT1.U_SLD_LBPTaxID) AS LicTradNum,
            JDT2.WTCode,
            (
                SELECT WTName
                FROM OWHT
                WHERE WTCode = JDT2.WTCode
            ) AS WTName,
            JDT1.U_SLD_WhPayBy AS  U_SLD_WhPayBy ,
            JDT2.Rate AS Rate
        FROM JDT1
            INNER JOIN OJDT ON JDT1.TransId = OJDT.TransId
            INNER JOIN JDT2 ON JDT2.AbsEntry = OJDT.TransId
            AND JDT2.Account = (
                SELECT OACT.AcctCode
                FROM OACT
                WHERE OACT.FormatCode = (
                        SELECT [@SLDT_SET_ACCWH].[Name]
												FROM [@SLDT_SET_ACCWH]
												WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                    )
            )
        WHERE JDT1.Credit > 0
------------------------------------------------------------------------------------------------------------------------------------------------
        UNION ALL
------------------------------------------------------------------------------------------------------------------------------------------------
        SELECT DISTINCT 'OJDT' AS TYPE,
            JDT1.TransId,
            JDT1.U_SLD_LBPTaxID AS TaxId,
            (
								Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
								from [@SLDT_WTS_TST]
								where [@SLDT_WTS_TST].[U_Status] = 'Y'
									And [@SLDT_WTS_TST].[U_TransID] = OJDT.TransId
									AND [@SLDT_WTS_TST].[U_Date_Wht] = FORMAT(JDT1.U_SLD_WHdate, 'yyyyMMdd')
							) AS RunNo,
            JDT1.U_SLD_WTBaseAmt AS TaxbleAmnt,
            (
                (
                    JDT1.U_SLD_WTBaseAmt * (
                        SELECT MAX(OWHT.Rate)
                        FROM OWHT
                        WHERE OWHT.WTCode = JDT1.U_SLD_WTCode
                            AND JDT1.ShortName = (
                                SELECT OACT.AcctCode
                                FROM OACT
                                WHERE OACT.FormatCode = (
                                        SELECT [@SLDT_SET_ACCWH].[Name]
												FROM [@SLDT_SET_ACCWH]
												WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                                    )
                            )
                    )
                ) / 100.0
            ) AS WTAmnt,
            JDT1.U_SLD_WHdate AS WHTDate,
            ISNULL(JDT1.LicTradNum, JDT1.U_SLD_LBPTaxID) AS LicTradNum,
            (
                SELECT MAX(OWHT.WTCode)
                FROM OWHT
                WHERE OWHT.WTCode = JDT1.U_SLD_WTCode
                    AND JDT1.ShortName = (
                        SELECT OACT.AcctCode
                        FROM OACT
                        WHERE OACT.FormatCode = (
                                SELECT [@SLDT_SET_ACCWH].[Name]
												FROM [@SLDT_SET_ACCWH]
												WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                            )
                    )
            ) AS WTCode,
            (
                SELECT MAX(OWHT.WTName)
                FROM OWHT
                WHERE OWHT.WTCode = JDT1.U_SLD_WTCode
                    AND JDT1.ShortName = (
                        SELECT OACT.AcctCode
                        FROM OACT
                        WHERE OACT.FormatCode = (
                                SELECT [@SLDT_SET_ACCWH].[Name]
												FROM [@SLDT_SET_ACCWH]
												WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                            )
                    )
            ) AS WTName,
            JDT1.U_SLD_WhPayBy AS U_SLD_WhPayBy,
            (
                SELECT MAX(OWHT.Rate)
                FROM OWHT
                WHERE OWHT.WTCode = JDT1.U_SLD_WTCode
                    AND JDT1.ShortName = (
                        SELECT OACT.AcctCode
                        FROM OACT
                        WHERE OACT.FormatCode = (
                                SELECT [@SLDT_SET_ACCWH].[Name]
												FROM [@SLDT_SET_ACCWH]
												WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                            )
                    )
            ) AS Rate
        FROM JDT1
            JOIN OJDT ON JDT1.TransId = OJDT.TransId
        WHERE(
                JDT1.ShortName = (
                    SELECT OACT.AcctCode
                    FROM OACT
                    WHERE OACT.FormatCode = (
                            SELECT [@SLDT_SET_ACCWH].[Name]
		FROM [@SLDT_SET_ACCWH]
		WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                        )
                )
            )
    ) AS B
WHERE B.WTCode IS NOT NULL AND WTAmnt > 0
Group by B.TransId,
    B.TaxId,
    B.WHTDate,
    B.WTCode,
    B.WTName,
    B.Rate,
    B.LicTradNum,
    B.RunNo,
    B.U_SLD_WhPayBy
ORDER BY B.TransId
