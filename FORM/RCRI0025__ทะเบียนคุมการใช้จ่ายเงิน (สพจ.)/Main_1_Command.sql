-- ============================================================
-- Report: RCRI0025__ทะเบียนคุมการใช้จ่ายเงิน (สพจ.).rpt
Path:   RCRI0025__ทะเบียนคุมการใช้จ่ายเงิน (สพจ.).rpt
Extracted: 2026-05-07 18:03:40
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
'{?month@}' AS "month",
OPRC."PrcName" AS "จังหวัด",
CASE WHEN IFNULL(OB."เงินคงเหลือยกมา",0) > 0 THEN (IFNULL(OB."เงินคงเหลือยกมา",0) - IFNULL(OBAP."รวมรายจ่ายยกมา",0))
ELSE 0 END AS "เงินคงเหลือยกมา",
IFNULL(AP."รับเงินจากกองทุน",0) AS "รับเงินจากกองทุน",
(IFNULL(OB."เงินคงเหลือยกมา",0) + IFNULL(AP."รับเงินจากกองทุน",0)) AS "รวมรับเงิน",
IFNULL(JE12."ค่าจ้าง",0) AS "ค่าจ้าง",
IFNULL(JE12."ค่าเบี้ยเลี้ยง",0) AS "ค่าเบี้ยเลี้ยง",
IFNULL(JE12."ค่าที่พัก",0) AS "ค่าที่พัก",
IFNULL(JE12."ค่าใช้จ่ายเดินทาง",0) AS "ค่าใช้จ่ายเดินทาง",
IFNULL(JE12."ค่าตอบแทนการปฏิบัติ",0) AS "ค่าตอบแทนการปฏิบัติ",
IFNULL(JE02."ค่าเบี้ยเลี้ยง FROM COA",0) AS "ค่าเบี้ยเลี้ยง FROM COA",
IFNULL(JE03."บัญชีค่าที่พัก FROM COA",0) AS "บัญชีค่าที่พัก FROM COA",
IFNULL(JE99."ค่าใช้จ่ายเดินทาง FROM COA",0) AS "ค่าใช้จ่ายเดินทาง FROM COA",
IFNULL(JE207."ค่าห้องประชุม",0) AS "ค่าห้องประชุม",
IFNULL(JE207."ค่าอาหารว่างและเครื่องดื่ม",0) AS "ค่าอาหารว่างและเครื่องดื่ม",
IFNULL(JE107."บัญชีค่าบริการไปรษณีย์ FROM COA",0) AS "บัญชีค่าบริการไปรษณีย์ FROM COA",
IFNULL(JE041."วัสดุสำนักงาน",0) AS "วัสดุสำนักงาน",
IFNULL(JE042."วัสดุคอมพิวเตอร์",0) AS "วัสดุคอมพิวเตอร์",
IFNULL(JE010."วัสดุเชื้อเพลิง",0) AS "วัสดุเชื้อเพลิง",
IFNULL(JE299."บัญชีค่าใช้สอยอื่นๆ FROM COA",0) AS "บัญชีค่าใช้สอยอื่นๆ FROM COA",
(IFNULL(JE12."ค่าจ้าง",0)+
IFNULL(JE12."ค่าเบี้ยเลี้ยง",0)+
IFNULL(JE12."ค่าที่พัก",0)+
IFNULL(JE12."ค่าใช้จ่ายเดินทาง",0)+
IFNULL(JE12."ค่าตอบแทนการปฏิบัติ",0)+
IFNULL(JE02."ค่าเบี้ยเลี้ยง FROM COA",0)+
IFNULL(JE03."บัญชีค่าที่พัก FROM COA",0)+
IFNULL(JE99."ค่าใช้จ่ายเดินทาง FROM COA",0)+
IFNULL(JE207."ค่าห้องประชุม",0)+
IFNULL(JE207."ค่าอาหารว่างและเครื่องดื่ม",0)+
IFNULL(JE107."บัญชีค่าบริการไปรษณีย์ FROM COA",0)+
IFNULL(JE041."วัสดุสำนักงาน",0)+
IFNULL(JE042."วัสดุคอมพิวเตอร์",0)+
IFNULL(JE010."วัสดุเชื้อเพลิง",0)+
IFNULL(JE299."บัญชีค่าใช้สอยอื่นๆ FROM COA",0)) AS "รวมรายจ่าย"
FROM {?Schema@}.OPRC
LEFT JOIN (	SELECT SUM(AA."รับเงินจากกองทุน") AS "รับเงินจากกองทุน",AA."OcrCode2",AA."PrcName" 
			FROM		(SELECT T1."Debit" AS "รับเงินจากกองทุน",T1."OcrCode2",T2."PrcName"
					FROM {?Schema@}.OJDT T0 
					INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
					LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
					WHERE T3."FormatCode" = '1101020503'
					AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
					AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
					AND T1."Debit" <> 0
					AND T0."StornoToTr" IS  NULL
					AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
							        			FROM {?Schema@}.OJDT 
							       				WHERE "StornoToTr" IS NOT NULL)
					--GROUP BY T1."OcrCode2",T2."PrcName" 
					
					UNION ALL
					
					SELECT (T1."Credit") AS "รับเงินจากกองทุน",T1."OcrCode2",T2."PrcName"
					FROM {?Schema@}.OJDT T0 
					INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
					LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
					WHERE T3."FormatCode" IN ('5104010112','5103010102','5103010103',
					'5103010199','5104030207','5104020107','5104010104','5104010110','5104030299')
					AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
					AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
					AND T1."Credit" <> 0
					AND T0."StornoToTr" IS  NULL
					AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
							        			FROM {?Schema@}.OJDT 
							       				WHERE "StornoToTr" IS NOT NULL)
					--GROUP BY T1."OcrCode2",T2."PrcName" 
					
					UNION ALL
					
					SELECT (-1*T1."Credit") AS "รับเงินจากกองทุน",T1."OcrCode2",T2."PrcName"
					FROM {?Schema@}.OJDT T0 
					INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
					LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
					WHERE T3."FormatCode" = '1101020503'
					AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
					AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
					AND T1."Credit" <> 0
					AND T0."StornoToTr" IS  NULL
					AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
							        			FROM {?Schema@}.OJDT 
							       				WHERE "StornoToTr" IS NOT NULL)
					--GROUP BY T1."OcrCode2",T2."PrcName" 
					) AS AA GROUP BY AA."OcrCode2",AA."PrcName"
		) AS AP ON OPRC."PrcCode" = AP."OcrCode2"
-----------------------------------------------------------------------------------------------
LEFT JOIN (	SELECT SUM(BB."เงินคงเหลือยกมา") AS "เงินคงเหลือยกมา",BB."OcrCode2",BB."PrcName"
			FROM    (SELECT T1."Debit" AS "เงินคงเหลือยกมา",T1."OcrCode2",T2."PrcName"
					FROM {?Schema@}.OJDT T0 
					INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
					LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
					WHERE T3."FormatCode" = '1101020503'
					AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
					AND T0."RefDate" < {?1DStart@}
					AND T1."Debit" <> 0
					AND T0."StornoToTr" IS  NULL
					AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
							        			FROM {?Schema@}.OJDT 
							       				WHERE "StornoToTr" IS NOT NULL)
					--GROUP BY T1."OcrCode2",T2."PrcName" 
					
					UNION ALL
					
					SELECT (T1."Credit") AS "เงินคงเหลือยกมา",T1."OcrCode2",T2."PrcName"
					FROM {?Schema@}.OJDT T0 
					INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
					LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
					WHERE T3."FormatCode" IN ('5104010112','5103010102','5103010103',
					'5103010199','5104030207','5104020107','5104010104','5104010110','5104030299')
					AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
					AND T0."RefDate" < {?1DStart@}
					AND T1."Credit" <> 0
					AND T0."StornoToTr" IS  NULL
					AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
							        			FROM {?Schema@}.OJDT 
							       				WHERE "StornoToTr" IS NOT NULL)
					--GROUP BY T1."OcrCode2",T2."PrcName" 
					
					UNION ALL
					
					SELECT (-1*T1."Credit") AS "เงินคงเหลือยกมา",T1."OcrCode2",T2."PrcName"
					FROM {?Schema@}.OJDT T0 
					INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
					LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
					LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
					WHERE T3."FormatCode" = '1101020503'
					AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
					--AND T0."RefDate" BETWEEN {?2DEnd@} AND {?2DEnd@}
					AND T1."Credit" <> 0
					AND T0."StornoToTr" IS  NULL
					AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
							        			FROM {?Schema@}.OJDT 
							       				WHERE "StornoToTr" IS NOT NULL)
					--GROUP BY T1."OcrCode2",T2."PrcName"  
					) AS BB GROUP BY BB."OcrCode2",BB."PrcName"
					) AS OB ON OPRC."PrcCode" = OB."OcrCode2"
----------------------------------------------------------------------------------------------
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."U_SLD_Wages") AS "ค่าจ้าง",
			SUM(T1."U_SLD_Allowance") AS "ค่าเบี้ยเลี้ยง",
			SUM(T1."U_SLD_Accommodation") AS "ค่าที่พัก",
			SUM(T1."U_SLD_Travel") AS "ค่าใช้จ่ายเดินทาง",
			SUM(T1."U_SLD_Compensation") AS "ค่าตอบแทนการปฏิบัติ"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5104010112'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE12 ON OPRC."PrcCode" = JE12."OcrCode2"
----------------------------------------------------------------------------------------------		
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."Debit") AS "ค่าเบี้ยเลี้ยง FROM COA"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5103010102'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE02 ON OPRC."PrcCode" = JE02."OcrCode2"
----------------------------------------------------------------------------------------------	
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."Debit") AS "บัญชีค่าที่พัก FROM COA"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5103010103'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE03 ON OPRC."PrcCode" = JE03."OcrCode2"
----------------------------------------------------------------------------------------------
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."Debit") AS "ค่าใช้จ่ายเดินทาง FROM COA"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5103010199'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE99 ON OPRC."PrcCode" = JE99."OcrCode2"
----------------------------------------------------------------------------------------------
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."U_SLD_Meeting") AS "ค่าห้องประชุม",
			SUM(T1."U_SLD_Snacks") AS "ค่าอาหารว่างและเครื่องดื่ม"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5104030207'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE207 ON OPRC."PrcCode" = JE207."OcrCode2"
----------------------------------------------------------------------------------------------
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."Debit") AS "บัญชีค่าบริการไปรษณีย์ FROM COA"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5104020107'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE107 ON OPRC."PrcCode" = JE107."OcrCode2"
----------------------------------------------------------------------------------------------
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."Debit") AS "วัสดุสำนักงาน"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5104010104'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T1."U_SLD_Material" LIKE N'ค่าวัสดุสำนักงาน'
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE041 ON OPRC."PrcCode" = JE041."OcrCode2"
----------------------------------------------------------------------------------------------
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."Debit") AS "วัสดุคอมพิวเตอร์"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5104010104'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T1."U_SLD_Material" LIKE N'ค่าวัสดุคอมพิวเตอร์'
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE042 ON OPRC."PrcCode" = JE042."OcrCode2"
----------------------------------------------------------------------------------------------
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."Debit") AS "วัสดุเชื้อเพลิง"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5104010110'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE010 ON OPRC."PrcCode" = JE010."OcrCode2"
----------------------------------------------------------------------------------------------
LEFT JOIN (SELECT 	
			T1."OcrCode2",
			T2."PrcName",
			SUM(T1."Debit") AS "บัญชีค่าใช้สอยอื่นๆ FROM COA"
		FROM {?Schema@}.OJDT T0 
		INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
		LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
		LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
		WHERE T3."FormatCode" = '5104030299'
		AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
		AND T0."RefDate" BETWEEN {?1DStart@} AND {?2DEnd@}
		AND T1."Debit" <> 0
		AND T0."StornoToTr" IS  NULL
		AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
				        			FROM {?Schema@}.OJDT 
				       				WHERE "StornoToTr" IS NOT NULL)
		GROUP BY T1."OcrCode2",T2."PrcName" 
		) AS JE299 ON OPRC."PrcCode" = JE299."OcrCode2"
----------------------------------------------------------------------------------------------
LEFT JOIN (			SELECT 
					OPRC."PrcCode",
					OPRC."PrcName" AS "จังหวัด",
					(IFNULL(JE12."ค่าจ้าง",0)+
					IFNULL(JE12."ค่าเบี้ยเลี้ยง",0)+
					IFNULL(JE12."ค่าที่พัก",0)+
					IFNULL(JE12."ค่าใช้จ่ายเดินทาง",0)+
					IFNULL(JE12."ค่าตอบแทนการปฏิบัติ",0)+
					IFNULL(JE02."ค่าเบี้ยเลี้ยง FROM COA",0)+
					IFNULL(JE03."บัญชีค่าที่พัก FROM COA",0)+
					IFNULL(JE99."ค่าใช้จ่ายเดินทาง FROM COA",0)+
					IFNULL(JE207."ค่าห้องประชุม",0)+
					IFNULL(JE207."ค่าอาหารว่างและเครื่องดื่ม",0)+
					IFNULL(JE107."บัญชีค่าบริการไปรษณีย์ FROM COA",0)+
					IFNULL(JE041."วัสดุสำนักงาน",0)+
					IFNULL(JE042."วัสดุคอมพิวเตอร์",0)+
					IFNULL(JE010."วัสดุเชื้อเพลิง",0)+
					IFNULL(JE299."บัญชีค่าใช้สอยอื่นๆ FROM COA",0)) AS "รวมรายจ่ายยกมา"
					FROM {?Schema@}.OPRC
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."U_SLD_Wages") AS "ค่าจ้าง",
								SUM(T1."U_SLD_Allowance") AS "ค่าเบี้ยเลี้ยง",
								SUM(T1."U_SLD_Accommodation") AS "ค่าที่พัก",
								SUM(T1."U_SLD_Travel") AS "ค่าใช้จ่ายเดินทาง",
								SUM(T1."U_SLD_Compensation") AS "ค่าตอบแทนการปฏิบัติ"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5104010112'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@} 
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE12 ON OPRC."PrcCode" = JE12."OcrCode2"
					----------------------------------------------------------------------------------------------		
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."Debit") AS "ค่าเบี้ยเลี้ยง FROM COA"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5103010102'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@}
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE02 ON OPRC."PrcCode" = JE02."OcrCode2"
					----------------------------------------------------------------------------------------------	
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."Debit") AS "บัญชีค่าที่พัก FROM COA"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5103010103'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@}
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE03 ON OPRC."PrcCode" = JE03."OcrCode2"
					----------------------------------------------------------------------------------------------
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."Debit") AS "ค่าใช้จ่ายเดินทาง FROM COA"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5103010199'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@}
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE99 ON OPRC."PrcCode" = JE99."OcrCode2"
					----------------------------------------------------------------------------------------------
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."U_SLD_Meeting") AS "ค่าห้องประชุม",
								SUM(T1."U_SLD_Snacks") AS "ค่าอาหารว่างและเครื่องดื่ม"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5104030207'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@}
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE207 ON OPRC."PrcCode" = JE207."OcrCode2"
					----------------------------------------------------------------------------------------------
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."Debit") AS "บัญชีค่าบริการไปรษณีย์ FROM COA"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5104020107'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@}
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE107 ON OPRC."PrcCode" = JE107."OcrCode2"
					----------------------------------------------------------------------------------------------
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."Debit") AS "วัสดุสำนักงาน"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5104010104'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@}
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T1."U_SLD_Material" LIKE N'ค่าวัสดุสำนักงาน'
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE041 ON OPRC."PrcCode" = JE041."OcrCode2"
					----------------------------------------------------------------------------------------------
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."Debit") AS "วัสดุคอมพิวเตอร์"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5104010104'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@}
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T1."U_SLD_Material" LIKE N'ค่าวัสดุคอมพิวเตอร์'
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE042 ON OPRC."PrcCode" = JE042."OcrCode2"
					----------------------------------------------------------------------------------------------
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."Debit") AS "วัสดุเชื้อเพลิง"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5104010110'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@}
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE010 ON OPRC."PrcCode" = JE010."OcrCode2"
					----------------------------------------------------------------------------------------------
					LEFT JOIN (SELECT 	
								T1."OcrCode2",
								T2."PrcName",
								SUM(T1."Debit") AS "บัญชีค่าใช้สอยอื่นๆ FROM COA"
							FROM {?Schema@}.OJDT T0 
							INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
							LEFT JOIN {?Schema@}.OPRC T2 ON T1."OcrCode2" = T2."PrcCode"
							LEFT JOIN {?Schema@}.OACT T3 ON T1."Account" = T3."AcctCode"
							WHERE T3."FormatCode" = '5104030299'
							AND (T1."OcrCode2" <> '' OR T1."OcrCode2" IS NOT NULL)
							AND T0."RefDate" < {?1DStart@}
							AND T1."Debit" <> 0
							AND T0."StornoToTr" IS  NULL
							AND T0."TransId" NOT IN (	SELECT "StornoToTr" 
									        			FROM {?Schema@}.OJDT 
									       				WHERE "StornoToTr" IS NOT NULL)
							GROUP BY T1."OcrCode2",T2."PrcName" 
							) AS JE299 ON OPRC."PrcCode" = JE299."OcrCode2"
					----------------------------------------------------------------------------------------------
					WHERE OPRC."DimCode" = 2 
					AND OPRC."PrcName" <> 'General Centre 2'
					ORDER BY OPRC."PrcCode" ) AS OBAP ON OPRC."PrcCode" = OBAP."PrcCode"
----------------------------------------------------------------------------------------------
WHERE OPRC."DimCode" = 2 
AND OPRC."PrcName" <> 'General Centre 2'
ORDER BY OPRC."PrcCode" 
