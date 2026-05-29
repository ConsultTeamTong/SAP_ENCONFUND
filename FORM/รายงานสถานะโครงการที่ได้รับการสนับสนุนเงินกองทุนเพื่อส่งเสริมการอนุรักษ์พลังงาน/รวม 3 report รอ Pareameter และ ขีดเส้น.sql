SELECT distinct
     T0."PrjCode" AS "เลขที่หนังสือยืนยัน"
    ,T0."U_SLD_ProjectName" AS "ชื่อโครงการ"
    ,T0."U_SLD_PlanWork" AS "แผนงาน"
    ,T0."U_SLD_GroupWork" AS "กลุ่มงาน"
    ,T0."U_SLD_Period" AS "ปีงบ"
    ,T0."U_SLD_REQ" AS "ผู้เบิกกองทุน"
    ,T0."U_SLD_REC" AS "ผู้ได้รับจัดสรร"
    ,T0."U_SLD_Vendor" AS "ผู้ได้รับสนับสนุน" 
    ,T1."START"  AS "START"
    ,T1."CLOSING" AS "CLOSING"
    ,T1."DUEDATE" AS "วันที่ขยาย"
	,STRING_AGG ( 
        'งวดที่ ' || PMG1."StageID" || ' ' || 
        CASE 
            WHEN IFNULL(OPCH."PaidToDate", 0) > 0 THEN 'จ่ายแล้ว' 
            ELSE 'ยังไม่จ่าย' 
        END || ' ' ,
        CHAR(13) || CHAR(10) ORDER BY PMG1."StageID" ASC 
    ) AS "สถานะงวดการเบิกจ่ายโครงการ"
    ,SUM(PMG1."EXPCOSTS") AS "จำนวนเงินตามหนังสือยืนยัน"
    ,SUM(PMG2."U_U_SLD_InstAmt") AS "วงเงินตามสัญญาจ้าง"
    , SUM(CASE
            WHEN PMG1."StageID" IS NULL THEN 0
            WHEN IFNULL(PMG2."U_U_SLD_InstAmt",0) <= 0 AND IFNULL(OPCH."PaidToDate",0) > 0 THEN (IFNULL(PMG1."EXPCOSTS",0) - OPCH."PaidToDate")
            WHEN IFNULL(PMG2."U_U_SLD_InstAmt",0) > 0 AND IFNULL(OPCH."PaidToDate",0) <= 0 THEN (IFNULL(PMG1."EXPCOSTS",0) - IFNULL(PMG2."U_U_SLD_InstAmt",0))
            WHEN IFNULL(PMG2."U_U_SLD_InstAmt",0) > 0 AND IFNULL(OPCH."PaidToDate",0) > 0 THEN (IFNULL(PMG1."EXPCOSTS",0) - OPCH."PaidToDate")
            WHEN IFNULL(PMG2."U_U_SLD_InstAmt",0) > IFNULL(PMG1."EXPCOSTS",0) THEN 0
            ELSE 0
        END) AS "ไม่ขอเบิกจ่าย"
    , SUM(CASE
            WHEN PMG1."StageID" IS NULL THEN 0
            WHEN IFNULL(OPCH."PaidToDate",0) <= 0 AND IFNULL(PMG2."U_U_SLD_InstAmt",0) <= 0 THEN IFNULL(PMG1."EXPCOSTS",0)
            WHEN IFNULL(OPCH."PaidToDate",0) <= 0 AND IFNULL(PMG2."U_U_SLD_InstAmt",0) > 0 THEN IFNULL(PMG2."U_U_SLD_InstAmt",0)
            WHEN IFNULL(OPCH."PaidToDate",0) > 0 THEN 0
            ELSE IFNULL(PMG1."EXPCOSTS",0)
        END) AS "คงเหลือเบิกจ่าย"
    ,SUM(IFNULL(OPCH."PaidToDate",0)) AS "เบิกจ่ายจริง"
    ,Ex."Debit" AS "จำนวนเงินใช้จ่ายจริง"
    ,SUM(OPCH."PaidToDate") 
    ,MoneyTree."Credit" AS "เงินต้น"
    ,Flowercoin."Credit" AS "ดอกเบี้ย"
    ,Fee."Credit" AS "ค่าปรับ"
	,othr."Credit" AS "เงินรับอื่น"
 	,IFNULL(MoneyTree."Credit",0) + IFNULL(Flowercoin."Credit",0) + IFNULL(Fee."Credit",0) + IFNULL(othr."Credit",0) AS "รวมส่งคืนเงิน"
 	,CASE 
 		WHEN  	SUM(IFNULL(OPCH."PaidToDate",0)) - IFNULL(Ex."Debit",0) - IFNULL(MoneyTree."Credit",0) < 0 THEN '0'
		ELSE  	SUM(IFNULL(OPCH."PaidToDate",0)) - IFNULL(Ex."Debit",0) - IFNULL(MoneyTree."Credit",0) 
 	END AS "จำนวนเงินคงเหลือ"
 	,Unitplz."PaidToDate" AS "หน่วยงานขอเงินคืน"
 	,T1."U_SLD_Status" AS "สถานะโครงการ"
FROM SBO_ENCONFUND.OPRJ T0
INNER JOIN SBO_ENCONFUND.OPMG T1 ON T0."PrjCode" = T1."FIPROJECT"
LEFT JOIN SBO_ENCONFUND.PMG1 ON T1."AbsEntry" = PMG1."AbsEntry"
LEFT JOIN SBO_ENCONFUND.PMG4 ON PMG1."AbsEntry" = PMG4."AbsEntry"
    AND PMG4."TYP" = 18
    AND PMG4."StageID" = PMG1."LineID"
LEFT JOIN SBO_ENCONFUND.PMG2 ON PMG1."AbsEntry" = PMG2."AbsEntry" 
    AND PMG1."StageID" = PMG2."PRIORITY"
LEFT JOIN SBO_ENCONFUND.OPCH ON PMG4."DocEntry" = OPCH."DocEntry"
    AND OPCH."CANCELED" = 'N'
    
 LEFT JOIN (	SELECT  T1."Project" , T0."PaidToDate" , T0."NumAtCard"
				FROM  SBO_ENCONFUND.OPCH T0
				LEFT JOIN SBO_ENCONFUND.PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
 				WHERE T0."NumAtCard" IS NULL AND T0."PaidToDate" <> 0
 				) AS Unitplz ON T0."PrjCode"  = Unitplz."Project"  
 				
 				
    LEFT JOIN (	SELECT  T1."Project",
					 					SUM(IFNULL(T1."Debit",0)) AS "Debit"
					 			FROM SBO_ENCONFUND.OJDT T0
 								LEFT JOIN SBO_ENCONFUND.JDT1 T1 ON T0."TransId" = T1."TransId"
					 			LEFT JOIN SBO_ENCONFUND.OACT T2 ON T1."Account" = T2."AcctCode"
					 			LEFT JOIN SBO_ENCONFUND.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
					 			 WHERE T2."FormatCode" IN ('5107010101','5107010103','5107010105','5107010106','5107020104','5107020105','5107020199')
					 			AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM SBO_ENCONFUND.OJDT WHERE "StornoToTr" IS NOT NULL)
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
    
LEFT JOIN ( 

    SELECT T1."Project", SUM(IFNULL(T1."Credit",0)) AS "Credit"
    FROM SBO_ENCONFUND.OJDT T0 
    INNER JOIN SBO_ENCONFUND.JDT1 T1 ON T0."TransId" = T1."TransId" 
    LEFT JOIN SBO_ENCONFUND.OACT T2 ON T1."Account" = T2."AcctCode"
    WHERE T2."FormatCode" IN ('1106010103' , '4313010199')
    AND T1."Credit" <> 0 AND T1."U_SLD_Remark" = '9999999999' AND "U_SLD_DocTyp" = 'RF'
    AND T0."StornoToTr" IS NULL AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM SBO_ENCONFUND.OJDT WHERE "StornoToTr" IS NOT NULL)
    GROUP BY T1."Project"
) AS MoneyTree ON T0."PrjCode" = MoneyTree."Project"

LEFT JOIN ( 

    SELECT T1."Project", SUM(IFNULL(T1."Credit",0)) AS "Credit"
    FROM SBO_ENCONFUND.OJDT T0 
    INNER JOIN SBO_ENCONFUND.JDT1 T1 ON T0."TransId" = T1."TransId" 
    LEFT JOIN SBO_ENCONFUND.OACT T2 ON T1."Account" = T2."AcctCode"
    WHERE T2."FormatCode" IN ('4203010101' , '1102050106' , '1102050107')
    AND T1."Credit" <> 0 AND T1."U_SLD_Remark" = '4303010101' AND "U_SLD_DocTyp" = 'RF'
    AND T0."StornoToTr" IS NULL AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM SBO_ENCONFUND.OJDT WHERE "StornoToTr" IS NOT NULL)
    GROUP BY T1."Project"
) AS Flowercoin ON T0."PrjCode" = Flowercoin."Project"

LEFT JOIN ( 

    SELECT T1."Project", SUM(IFNULL(T1."Credit",0)) AS "Credit"
    FROM SBO_ENCONFUND.OJDT T0 
    INNER JOIN SBO_ENCONFUND.JDT1 T1 ON T0."TransId" = T1."TransId" 
    LEFT JOIN SBO_ENCONFUND.OACT T2 ON T1."Account" = T2."AcctCode"
    WHERE T2."FormatCode" IN ('4313010103','1102050106' , '1102050107')
    AND T1."Credit" <> 0 AND T1."U_SLD_Remark" = '4313010103' AND "U_SLD_DocTyp" = 'RF'
    AND T0."StornoToTr" IS NULL AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM SBO_ENCONFUND.OJDT WHERE "StornoToTr" IS NOT NULL)
    GROUP BY T1."Project"
) AS Fee ON T0."PrjCode" = Fee."Project"
 
LEFT JOIN ( 

    SELECT T1."Project", SUM(IFNULL(T1."Credit",0)) AS "Credit"
    FROM SBO_ENCONFUND.OJDT T0 
    INNER JOIN SBO_ENCONFUND.JDT1 T1 ON T0."TransId" = T1."TransId" 
    LEFT JOIN SBO_ENCONFUND.OACT T2 ON T1."Account" = T2."AcctCode"
    WHERE T2."FormatCode" IN ('4313010199','1102050106' , '1102050107')
    AND T1."Credit" <> 0 AND T1."U_SLD_Remark" = '4313010199' AND "U_SLD_DocTyp" = 'RF'
    AND T0."StornoToTr" IS NULL AND T0."TransId" NOT IN (SELECT "StornoToTr" FROM SBO_ENCONFUND.OJDT WHERE "StornoToTr" IS NOT NULL)
    GROUP BY T1."Project"
) AS othr ON T0."PrjCode" = othr."Project"

GROUP BY 
    T0."PrjCode" 
    ,T0."U_SLD_ProjectName" 
    ,T0."U_SLD_PlanWork"
    ,T0."U_SLD_GroupWork" 
    ,T0."U_SLD_Period"
    ,T0."U_SLD_REQ" 
    ,T0."U_SLD_REC" 
    ,T0."U_SLD_Vendor" 
    ,T1."START" 
    ,T1."CLOSING" 
    ,T1."DUEDATE" 
    ,Ex."Debit"
	,MoneyTree."Credit" 
    ,Flowercoin."Credit" 
    ,Fee."Credit" 
	,othr."Credit" 
    ,Unitplz."PaidToDate"
    ,T1."U_SLD_Status"
