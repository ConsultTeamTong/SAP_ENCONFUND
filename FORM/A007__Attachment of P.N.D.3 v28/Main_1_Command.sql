-- ============================================================
-- Report: A0070001__Attachment of P.N.D.3 v28.rpt
Path:   A0070001__Attachment of P.N.D.3 v28.rpt
Extracted: 2026-05-07 18:02:36
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT ROW_NUMBER() OVER (
        ORDER BY TaxDate
    ) AS Row,
    *
From (
---------------------- START GUP Table -----------------------------------------------------------------------------------------------------------------------------------------------
        SELECT DISTINCT B.*,
            SumW.TaxbleAmntA,
            SumW.WTAmntA
        FROM (
---------------------- Start B Table ----------------------------------------------------------------------------------------------------------------------------------------
                SELECT 'OVPM' AS TYPE,  
                    (
                        SELECT TOP 1 OJDT.TransType
                        FROM OJDT
                        WHERE OJDT.TransId = OVPM.TransId
                    ) AS TransType,
                    (
                        Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
                        from [@SLDT_WTS_TST]
                        where [@SLDT_WTS_TST].[U_Status] = 'Y'
                            And [@SLDT_WTS_TST].[U_TransID] = OVPM.TransId
                            AND [U_Date_Wht] = FORMAT(OVPM.TaxDate, 'yyyyMMdd')
                    ) AS RunNo,
                    OVPM.DocNum,
                    '' AS NumAtCard,
                    OVPM.TransId,
                    OVPM.CardCode,
                    (
                    CONCAT(
                    ISNULL((SELECT MAX(OCRD.U_SLD_Title)
                        	FROM OCRD
                            JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode
                        WHERE OCRD.CardCode = OVPM.CardCode),''),' ',
			                       REPLACE((SELECT MAX(OCRD.U_SLD_FullName)
			                        FROM OCRD
			                            JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode
			                        WHERE OCRD.CardCode = OVPM.CardCode),'  ',' ')	
                        	)
     
                    ) AS CardName,
                    (
                        SELECT TOP 1 OCRD.U_SLD_Title
                        FROM OCRD
                            JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode
                        WHERE OCRD.CardCode = OVPM.CardCode
                    ) AS U_SLD_Title,
                    (
                        SELECT TOP 1 OCRD.U_SLD_FullName
                        FROM OCRD
                            JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode
                        WHERE OCRD.CardCode = OVPM.CardCode
                    ) AS U_SLD_CardName,
                    OVPM.Address,
                    OVPM.TaxDate,
                    (
                        SELECT TOP 1 OCRD.LicTradNum
                        FROM OCRD
                            JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode
                        WHERE OCRD.CardCode = OVPM.CardCode
                    ) AS TaxId,
                    OVPM.U_SLD_VatBranch,
                    (
                        Select TOP 1 CRD1.GlblLocNum
                        From CRD1
                        where CRD1.CardCode = OVPM.CardCode
                            And OVPM.PayToCode = CRD1.Address
                    ) AS U_SLD_VBPBranch,
                    CASE WHEN (
                            SELECT TOP 1 OPCH.U_SLD_WhPayBy
                            FROM OPCH
                            WHERE OPCH.DocNum = OVPM.DocNum
                        ) IS NOT NULL
						THEN
                        (
                            SELECT OPCH.U_SLD_WhPayBy
                            FROM OPCH
                            WHERE OPCH.DocNum = OVPM.DocNum
                        )
                        ELSE
							(
                            SELECT TOP 1 JDT1.U_SLD_WhPayBy
                            FROM JDT1
                            WHERE JDT1.TransId = OVPM.TransId
                                AND JDT1.ShortName IN (
                                    SELECT OACT.AcctCode
                                    FROM OACT
                                    WHERE OACT.FormatCode = (
                                            SELECT [@SLDT_SET_ACCWH].[Name]
                                            FROM [@SLDT_SET_ACCWH]
                                            WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                                        )
                                )
                        )
                    END  AS U_SLD_WhPayBy
                FROM OVPM
                    JOIN VPM6 ON OVPM.DocEntry = VPM6.DocNum
                    JOIN OWHT ON VPM6.WTCode = OWHT.WTCode
                WHERE OVPM.TransId IN (
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
               ----------------------------------------------------------------------------------
                UNION ALL
               ----------------------------------------------------------------------------------         
                SELECT 'OPCH' AS TYPE,
                    (
                        SELECT TOP 1 OJDT.TransType
                        FROM OJDT
                        WHERE OJDT.TransId = OPCH.TransId
                    ) AS TransType,
                    (
                        Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
                        from [@SLDT_WTS_TST]
                        where [@SLDT_WTS_TST].[U_Status] = 'Y'
                            And [@SLDT_WTS_TST].[U_TransID] = OPCH.TransId
                            AND [@SLDT_WTS_TST].[U_Date_Wht] = FORMAT(OPCH.TaxDate, 'yyyyMMdd')
                    ) AS RunNo,
                    OPCH.DocNum,
                    OPCH.NumAtCard,
                    OPCH.TransId,
                    OPCH.CardCode,
                    '' AS CardName,
                    '' AS U_SLD_Title,
                    '' AS U_SLD_CardName,
                    OPCH.Address,
                    OPCH.TaxDate,
                    OPCH.LicTradNum AS TaxId,
                    OPCH.U_SLD_LVatBranch AS U_SLD_VatBranch,
                    '' AS U_SLD_VBPBranch,
                    OPCH.U_SLD_WhPayBy
                FROM OPCH
                    JOIN PCH5 ON OPCH.DocEntry = PCH5.AbsEntry
                    JOIN OWHT ON PCH5.WTCode = OWHT.WTCode
                WHERE OPCH.TransId IN (
                        SELECT TOP 1 JDT1.TransId
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
               ----------------------------------------------------------------------------------
                UNION ALL
               ----------------------------------------------------------------------------------  
                SELECT 'OJDT' AS TYPE,
                    JDT1.TransType AS TransType,
                    (
                        Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
                        from [@SLDT_WTS_TST] 
                        where [@SLDT_WTS_TST].[U_Status] = 'Y'
                            And [@SLDT_WTS_TST].[U_TransID] = OJDT.TransId
                            AND [U_Date_Wht] = FORMAT(JDT1.U_SLD_WHdate, 'yyyyMMdd')
                    ) AS RunNo,
                    JDT1.BaseRef AS DocNum,
                    '' AS NumAtCard,
                    JDT1.TransId,
                    JDT1.U_SLD_SuppCode AS CardCode,
                    CASE WHEN (JDT1.U_SLD_LPBranch IS NOT NULL AND JDT1.U_SLD_LPBranch <> '')  
                    		THEN CONCAT(JDT1.U_SLD_CardName, N' (สาขาที่ ', JDT1.U_SLD_LPBranch, ')')
                        ELSE (JDT1.U_SLD_CardName)
                    	END AS CardName,
                    '' AS U_SLD_Title,
                    '' AS U_SLD_CardName,
                    JDT1.U_SLD_BPAds AS Address,
                    JDT1.TaxDate AS TaxDate,
                    JDT1.LicTradNum AS TaxId,
                    OJDT.U_S_ComVatB AS U_SLD_VatBranch,
                    JDT1.U_SLD_LPBranch AS U_SLD_VBPBranch,
                    JDT1.U_SLD_WhPayBy AS U_SLD_WhPayBy
                FROM JDT1
                    INNER JOIN OJDT ON JDT1.TransId = OJDT.TransId
                    INNER JOIN JDT2 ON JDT2.AbsEntry = OJDT.TransId
                    AND JDT2.Account = (
                        SELECT TOP 1 OACT.AcctCode
                        FROM OACT
                        WHERE OACT.FormatCode = (
                                SELECT [@SLDT_SET_ACCWH].[Name]
                                FROM [@SLDT_SET_ACCWH]
                                WHERE [@SLDT_SET_ACCWH].[U_SLD_TypeWH] = '03'
                            )
                    )
                WHERE JDT1.Credit > 0 
               ----------------------------------------------------------------------------------
                UNION ALL
               ----------------------------------------------------------------------------------    
                SELECT 'OJDT' AS TYPE,
                    JDT1.TransType AS TransType,
                    (
                        Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
                        from [@SLDT_WTS_TST]
                        where [@SLDT_WTS_TST].[U_Status] = 'Y'
                            And [@SLDT_WTS_TST].[U_TransID] = OJDT.TransId
                            AND [@SLDT_WTS_TST].[U_Date_Wht] = FORMAT(JDT1.U_SLD_WHdate, 'yyyyMMdd')
                    ) AS RunNo,
                    JDT1.BaseRef AS DocNum,
                    '' AS NumAtCard,
                    JDT1.TransId,
                    JDT1.U_SLD_SuppCode AS CardCode,
                    CONCAT(U_SLD_Title, CONCAT(' ', U_SLD_CardName)) AS CardName,
                    U_SLD_Title,
                    U_SLD_CardName,
                    JDT1.U_SLD_BPAds AS Address,
                    JDT1.U_SLD_WHdate AS TaxDate,
                    JDT1.U_SLD_LBPTaxID AS TaxId,
                    OJDT.U_S_ComVatB AS U_SLD_VatBranch,
                    JDT1.U_SLD_LPBranch AS U_SLD_VBPBranch,
                    JDT1.U_SLD_WhPayBy AS U_SLD_WhPayBy
                    
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
------------------------------------END B Table--------------------------------------------------------------------------------------------------------------------------
            LEFT JOIN
------------------------------------ START SumW Table--------------------------------------------------------------------------------------------------------------------------            
            	(SELECT DISTINCT B.TransId AS TransIdA,
                    B.TaxId,
                    Sum(B.TaxbleAmnt) As TaxbleAmntA,
                    Sum(B.WTAmnt) As WTAmntA,
                    B.RunNo
                FROM (
                        SELECT DISTINCT 'OVPM' AS TYPE,
                            OVPM.TransId,
                            '' AS U_SLD_WHdate,
                            (
								Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
								from [@SLDT_WTS_TST]
								where [@SLDT_WTS_TST].[U_Status] = 'Y'
                            And [@SLDT_WTS_TST].[U_TransID] = OVPM.TransId
                            AND [U_Date_Wht] = FORMAT(OVPM.TaxDate, 'yyyyMMdd')
							) AS RunNo,
                            (SELECT TOP 1 OCRD.LicTradNum
                                FROM OCRD
                                JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode
                                WHERE OCRD.CardCode = OVPM.CardCode
                            ) AS TaxId,
                            CASE WHEN CHWTH.WTCode IS NULL THEN VPM6.TaxbleAmnt ELSE WTH.TaxbleAmnt END AS TaxbleAmnt,
							CASE WHEN CHWTH.WTCode IS NULL THEN VPM6.WTSum ELSE WTH.WTAmnt END AS WTAmnt,
                            OVPM.TaxDate AS WHTDate,
                            OWHT.WTCode,
                            OWHT.WTName,
                            OWHT.Rate
                        FROM OVPM
                            JOIN VPM6 ON OVPM.DocEntry = VPM6.DocNum
                            JOIN OWHT ON VPM6.WTCode = OWHT.WTCode
                            LEFT JOIN (SELECT DISTINCT DocNum, WTCode 
      									FROM VPM6 
										WHERE VPM6.WTSum < 0 
							) AS CHWTH ON OVPM.DocEntry = CHWTH.DocNum
							LEFT JOIN (SELECT VPM6.DocNum,
											VPM6.WTCode,
											SUM(VPM6.WTSum) AS WTAmnt ,
											((SUM(VPM6.WTSum)*100)/OWHT.Rate) AS TaxbleAmnt 
									 FROM VPM6
									 LEFT JOIN OWHT ON OWHT.WTCode = VPM6.WTCode
									 GROUP BY VPM6.DocNum,VPM6.WTCode,OWHT.Rate
							) AS WTH ON OVPM.DocEntry = WTH.DocNum AND WTH.WTCode = VPM6.WTCode
                        
                        WHERE OVPM.TransId IN (
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
                        ----------------------------------------------------------------------------------    
                        UNION ALL
                        ----------------------------------------------------------------------------------
                        SELECT DISTINCT 'OPCH' AS TYPE,
                            OPCH.TransId,
                            '' AS U_SLD_WHdate,
                            (
								Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
								from [@SLDT_WTS_TST]
								where [@SLDT_WTS_TST].[U_Status] = 'Y'
								And [@SLDT_WTS_TST].[U_TransID] = OPCH.TransId
								AND [@SLDT_WTS_TST].[U_Date_Wht] = FORMAT(OPCH.TaxDate, 'yyyyMMdd')
							) AS RunNo,
                            OPCH.LicTradNum AS TaxId,
                            PCH5.TaxbleAmnt,
                            PCH5.WTAmnt AS WTAmnt,
                            OPCH.TaxDate AS WHTDate,
                            OWHT.WTCode,
                            OWHT.WTName,
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
                            
                        ----------------------------------------------------------------------------------    
                        UNION ALL
                        ----------------------------------------------------------------------------------
                        SELECT DISTINCT 'OJDT' AS TYPE,
                            JDT1.TransId,
                            JDT1.U_SLD_WHdate,
                            (
								Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
								from [@SLDT_WTS_TST] 
								where [@SLDT_WTS_TST].[U_Status] = 'Y'
									And [@SLDT_WTS_TST].[U_TransID] = OJDT.TransId
									AND [U_Date_Wht] = FORMAT(JDT1.U_SLD_WHdate, 'yyyyMMdd')
							) AS RunNo,
                            JDT1.LicTradNum AS TaxId,
                            JDT2.TaxbleAmnt AS TaxbleAmnt,
							JDT2.WTAmnt,
                            JDT1.TaxDate AS WHTDate,
                            JDT2.WTCode,
                            (
                                SELECT OWHT.WTName
                                FROM OWHT
                                WHERE OWHT.WTCode = JDT2.WTCode
                            ) AS WTName,
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
                        ----------------------------------------------------------------------------------    
                        UNION ALL
                        ----------------------------------------------------------------------------------
                        SELECT DISTINCT 'OJDT' AS TYPE,
                            JDT1.TransId,
                            JDT1.U_SLD_WHdate,
                            (
								Select TOP 1 [@SLDT_WTS_TST].[U_DocWht]
								from [@SLDT_WTS_TST]
								where [@SLDT_WTS_TST].[U_Status] = 'Y'
									And [@SLDT_WTS_TST].[U_TransID] = OJDT.TransId
									AND [@SLDT_WTS_TST].[U_Date_Wht] = FORMAT(JDT1.U_SLD_WHdate, 'yyyyMMdd')
							) AS RunNo,
                            JDT1.U_SLD_LBPTaxID AS TaxId,
                            JDT1.U_SLD_WTBaseAmt AS TaxbleAmnt,
                            (
                                (
                                    JDT1.U_SLD_WTBaseAmt * (
                                        SELECT OWHT.Rate
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
                WHERE B.WTCode IS NOT NULL
                Group by B.TransId,
                    B.TaxId,
                    B.RunNo
            ) AS SumW On SumW.TransIdA = B.TransId
            AND SumW.TaxId = B.TaxId
            AND SumW.RunNo = B.RunNo --WHERE B.CardCode IS NOT NULL --ORDER BY B.TaxDate, B.TransId 
------------------------------------ End SumW Table --------------------------------------------------------------------------------------------------------------------------            

----------------------------------------------------------------------------------------------------------------------------------------------------------------
        UNION ALL
----------------------------------------------------------------------------------------------------------------------------------------------------------------                
        SELECT '' AS TYPE,
            '' AS TransType,
            '' AS RunNo,
            null AS DocNum,
            '' AS NumAtCard,
            '0' AS TransId,
            '' AS CardCode,
            '' AS CardName,
            '' AS U_SLD_Title,
            '' AS U_SLD_CardName,
            '' AS Address,
            '2099-01-20 00:00:00.000' AS TaxDate,
            '' AS TaxId,
            '' AS U_SLD_VatBranch,
            '' AS U_SLD_VBPBranch,
            '' AS U_SLD_WhPayBy,
            0 AS TaxbleAmntA,
            0 AS WTAmntA
        UNION ALL
        SELECT '' AS TYPE,
            '' AS TransType,
            '' AS RunNo,
            null AS DocNum,
            '' AS NumAtCard,
            '0' AS TransId,
            '' AS CardCode,
            '' AS CardName,
            '' AS U_SLD_Title,
            '' AS U_SLD_CardName,
            '' AS Address,
            '2099-01-20 00:00:00.000' AS TaxDate,
            '' AS TaxId,
            '' AS U_SLD_VatBranch,
            '' AS U_SLD_VBPBranch,
            '' AS U_SLD_WhPayBy,
            0 AS TaxbleAmntA,
            0 AS WTAmntA
        UNION ALL
        SELECT '' AS TYPE,
            '' AS TransType,
            '' AS RunNo,
            null AS DocNum,
            '' AS NumAtCard,
            '0' AS TransId,
            '' AS CardCode,
            '' AS CardName,
            '' AS U_SLD_Title,
            '' AS U_SLD_CardName,
            '' AS Address,
            '2099-01-20 00:00:00.000' AS TaxDate,
            '' AS TaxId,
            '' AS U_SLD_VatBranch,
            '' AS U_SLD_VBPBranch,
            '' AS U_SLD_WhPayBy,
            0 AS TaxbleAmntA,
            0 AS WTAmntA
        UNION ALL
        SELECT '' AS TYPE,
            '' AS TransType,
            '' AS RunNo,
            null AS DocNum,
            '' AS NumAtCard,
            '0' AS TransId,
            '' AS CardCode,
            '' AS CardName,
            '' AS U_SLD_Title,
            '' AS U_SLD_CardName,
            '' AS Address,
            '2099-01-20 00:00:00.000' AS TaxDate,
            '' AS TaxId,
            '' AS U_SLD_VatBranch,
            '' AS U_SLD_VBPBranch,
            '' AS U_SLD_WhPayBy,
            0 AS TaxbleAmntA,
            0 AS WTAmntA
        UNION ALL
        SELECT '' AS TYPE,
            '' AS TransType,
            '' AS RunNo,
            null AS DocNum,
            '' AS NumAtCard,
            '0' AS TransId,
            '' AS CardCode,
            '' AS CardName,
            '' AS U_SLD_Title,
            '' AS U_SLD_CardName,
            '' AS Address,
            '2099-01-20 00:00:00.000' AS TaxDate,
            '' AS TaxId,
            '' AS U_SLD_VatBranch,
            '' AS U_SLD_VBPBranch,
            '' AS U_SLD_WhPayBy,
            0 AS TaxbleAmntA,
            0 AS WTAmntA
    ) AS Gup
WHERE Gup.TaxDate IS NOT NULL  AND TaxbleAmntA IS NOT NULL
    AND Gup.TransId In ({?DocKey@},0)
ORDER BY Gup.TaxDate,
    Gup.TransId 
