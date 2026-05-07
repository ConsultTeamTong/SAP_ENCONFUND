-- ============================================================
-- Report: RCRI0022__ทะเบียนคุมสัญญา.rpt
Path:   RCRI0022__ทะเบียนคุมสัญญา.rpt
Extracted: 2026-05-07 18:03:39
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
    /* --- ตัวเชื่อม --- */
     T0."AbsID" AS "DocEntry_Agreement"  /* <<< ตัวแปรหลักสำหรับโยงไป Subreport */

    /* --- ข้อมูลส่วนหัวสัญญา --- */
    ,T0."Descript" AS "รายการ"
    ,T0."BpName" AS "ชื่อคู่สัญญา"
    ,T0."U_SLD_Approve_Budget" AS "งบประมาณที่ได้รับอนุมัติ"
    ,T0."U_SLD_Contract_Amount" AS "วงเงินตามสัญญา"
    ,T0."U_SLD_Contract_Number" AS "สัญญาจ้างเลขที่"
    ,T0."U_SLD_Contract_ID" AS "เลขที่คุมสัญญา"
    ,T0."U_SLD_Project_Number" AS "เลขที่โครงการ"
    ,T0."U_SLD_Order_Number" AS "เลขคำสั่ง"
    ,T0."U_SLD_Procurement_Method" AS "วิธีการจัดหา"
    ,T0."U_SLD_Project_Manager" AS "ผู้รับผิดชอบโครงการ"
    ,TO_VARCHAR(T0."U_SLD_Order_Date", 'D') || ' ' || 
MAP(MONTH(T0."U_SLD_Order_Date"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(T0."U_SLD_Order_Date", 543), 'YY') AS "วันที่คำสั่ง"


    ,CASE
        WHEN T0."EndDate" < CURRENT_DATE THEN 'สิ้นสุดสัญญา' 
        ELSE 'บริหารสัญญา' 
     END AS "สถานะสัญญา"

    /* --- ข้อมูลวันที่ (แปลง พ.ศ. แล้ว) --- */
     ,TO_VARCHAR(T0."StartDate", 'D') || ' ' || 
MAP(MONTH(T0."StartDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(T0."StartDate", 543), 'YY') AS "วันที่เริ่มต้นสัญญา"

,TO_VARCHAR(T0."EndDate", 'D') || ' ' || 
MAP(MONTH(T0."EndDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(T0."EndDate", 543), 'YY') AS "วันที่สิ้นสุดสัญญา"

    ,LTRIM(
            CASE
                WHEN FLOOR(DAYS_BETWEEN(T0."StartDate", T0."EndDate") / 30) = 0 THEN ''
                ELSE TO_VARCHAR(FLOOR(DAYS_BETWEEN(T0."StartDate", T0."EndDate") / 30)) || ' เดือน'
            END
            ||
            CASE
                WHEN MOD(DAYS_BETWEEN(T0."StartDate", T0."EndDate"), 30) = 0 THEN ''
                ELSE ' ' || TO_VARCHAR(MOD(DAYS_BETWEEN(T0."StartDate", T0."EndDate"), 30)) || ' วัน'
            END
        ) AS "ระยะเวลา (เดือน วัน)"
       -- ,T1."PlanQty" AS "จำนวนงวด"
        , TO_VARCHAR(a."PeriodCat" + 543) AS "ปีงบประมาณ"
        ,T0."U_SLD_Receiving_Officer"
		,INC.*
		,PO.*
FROM {?Schema@}."OOAT" T0
INNER JOIN {?Schema@}.OFPR o ON T0."PIndicator" = o."Indicator"
INNER JOIN {?Schema@}.OACP a ON o."Category" = a."PeriodCat"
LEFT JOIN (SELECT DISTINCT
		     T0."AbsID" AS "DocEntry_Agreement" /* <<< รับค่าจาก Main Report */
		    
		    /* --- 1. ฝั่งรับหลักประกัน (Incoming Payment: ORCT) --- */
		     ,TO_VARCHAR(T1."TrsfrDate", 'D') || ' ' || 
		MAP(MONTH(T1."TrsfrDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
		|| ' ' || TO_VARCHAR(ADD_YEARS(T1."TrsfrDate", 543), 'YY') AS "วันที่ (สด/โอน)"
		
		 
		    ,CASE 
		        WHEN (IFNULL(T1."CashSum", 0) + IFNULL(T1."TrsfrSum", 0) > 0) 
		        THEN IFNULL(T6."BeginStr", '') || CAST(T1."DocNum" AS NVARCHAR(20))
		    END AS "ใบเสร็จ (โอน/สด)"
		    ,CASE 
		        WHEN T1."CashSum" = 0 THEN T1."TrsfrSum"
		        WHEN T1."TrsfrSum" = 0 THEN T1."CashSum"			
		        ELSE T1."CashSum" + T1."TrsfrSum" 
		    END AS "จำนวนเงิน สด/โอน"
		    ,CASE 
		        WHEN T1."CheckSum" > 0 
		        THEN IFNULL(T6."BeginStr", '') || CAST(T1."DocNum" AS NVARCHAR(20))
		    END AS "ใบเสร็จ (เช็ค)"    
		    ,T1."CheckSum" AS "จำนวนเงินเช็ค"
		    
		     , TO_VARCHAR(T4."DueDate", 'D') || ' ' || 
		MAP(MONTH(T4."DueDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
		|| ' ' || TO_VARCHAR(ADD_YEARS(T4."DueDate", 543), 'YY') AS "วันที่(เช็ค)"
		    
		    ,CASE 
		        WHEN T5."U_SLD_Type" = '02' THEN T5."U_SLD_Amount"
		    END AS "จำนวนเงิน (ค้ำประกัน)"
		    ,CASE 
		        WHEN T5."U_SLD_Type" = '02' THEN 
		        TO_VARCHAR(T5."U_SLD_End_Date", 'D') || ' ' || 
		MAP(MONTH(T5."U_SLD_End_Date"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
		|| ' ' || TO_VARCHAR(ADD_YEARS(T5."U_SLD_End_Date", 543), 'YY') 
		    END AS "วันที่สิ้นสุด (ค้ำประกัน)"
		
		    /* --- จุดที่แก้ไข: เช็คค่าทีละฟิลด์, ย้ายสูตรมาหลัง THEN, และตั้งชื่อ Alias เป็นข้อความ --- */
		    ,CASE 
		        WHEN (IFNULL(T1."CashSum", 0) + IFNULL(T1."TrsfrSum", 0) > 0) 
		             OR (T4."DueDate" IS NOT NULL) 
		             OR (T1."CheckSum" IS NOT NULL) 
		        THEN TO_VARCHAR(T0."EndDate", 'D') || ' ' || 
		MAP(MONTH(T0."EndDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
		|| ' ' || TO_VARCHAR(ADD_YEARS(T0."EndDate", 543), 'YY') 
		    END AS "วันที่สิ้นสุด (แปลงปี 543)"
		  ,CASE 
		        WHEN (IFNULL(T1."CashSum", 0) + IFNULL(T1."TrsfrSum", 0) > 0) 
		             OR (T4."DueDate" IS NOT NULL) 
		             OR (T1."CheckSum" IS NOT NULL) 
		        THEN T0."U_SLD_Percentage"
		    END AS "ร้อยละ"
		    /* --- จุดที่แก้ไข: ใช้ T0."U_SLD_Percentage" แทน Alias --- */
			,CASE 
		        WHEN (IFNULL(T1."CashSum", 0) + IFNULL(T1."TrsfrSum", 0) > 0) 
		             OR (T4."DueDate" IS NOT NULL) 
		             OR (T1."CheckSum" IS NOT NULL) 
		        THEN T0."U_SLD_Contract_Amount" * T0."U_SLD_Percentage" / 100
		    END AS "จำนวนเงิน (ประกันผลงาน)"
		FROM {?Schema@}."OOAT" T0
		LEFT JOIN {?Schema@}."OAT1" T3 ON T0."AbsID" = T3."AgrNo"
		LEFT JOIN {?Schema@}."OAT2" T5 ON T0."AbsID" = T5."AgrNo"
		LEFT JOIN {?Schema@}."ORCT" T1 ON T0."U_SLD_Document" = T1."DocEntry"
		LEFT JOIN {?Schema@}."NNM1" T6 ON T1."Series" = T6."Series" 
		LEFT JOIN {?Schema@}."RCT1" T4 ON T4."DocNum" = T1."DocNum"
		LEFT JOIN {?Schema@}."OPCH" T2 ON T0."AbsID" = T2."AgrNo"
		WHERE T0."AbsID" IS NOT NULL
		--AND T0."AbsID" = '{?Pm-Command.DocEntry_Agreement}' --OR '{?AbsID@}' = '')
		) AS INC ON T0."AbsID" = INC."DocEntry_Agreement" 
LEFT JOIN (SELECT 	POR1."AgrNo",
					POR1."DocEntry",
					IFNULL(POR1."FreeTxt",'งวดที่ 1') AS "งวด_PO",
					CAST(SUBSTRING_REGEXPR('[0-9]+' IN IFNULL(POR1."FreeTxt", '1')) AS INT) AS "Int_Number",
					POR1."ShipDate" ,
					SUM(POR1."LineTotal") AS "SumPO",
					GRPO."DocDate" AS "วันที่_GRPO",
					OVPM."DocDate" AS "วันที่_Outgoing"
			FROM {?Schema@}.OPOR
			INNER JOIN {?Schema@}.POR1 ON OPOR."DocEntry" = POR1."DocEntry"
			LEFT JOIN {?Schema@}.OOAT ON POR1."AgrNo" = OOAT."AbsID"
			--------------------------------------------------------------------------------------------------
			LEFT JOIN ( SELECT 
						         L."BaseEntry"
						        ,L."BaseLine"
						        ,MAX(L."DocEntry") AS "GRPO_DocEntry"
						        ,MAX(L."LineNum")  AS "GRPO_LineNum"
						        ,STRING_AGG(CAST(H."DocNum" AS NVARCHAR(20)), ', ') AS "DocNum"
						        ,MAX(H."DocDate")  AS "DocDate"
						    FROM "{?Schema@}"."PDN1" L
						    INNER JOIN "{?Schema@}"."OPDN" H ON L."DocEntry" = H."DocEntry"
						    WHERE L."BaseType" = 22
						    AND H."CANCELED" <> 'Y'
						    GROUP BY L."BaseEntry", L."BaseLine"
						) GRPO ON POR1."DocEntry" = GRPO."BaseEntry" AND POR1."LineNum" = GRPO."BaseLine"
			------------------------------------------------------------------------------------------------------------------
			LEFT JOIN "{?Schema@}"."PCH1" ON 
			    (PCH1."BaseType" = 20 AND PCH1."BaseEntry" = GRPO."GRPO_DocEntry" AND PCH1."BaseLine" = GRPO."GRPO_LineNum") 
			    OR (PCH1."BaseType" = 22 AND PCH1."BaseEntry" = POR1."DocEntry" AND PCH1."BaseLine" = POR1."LineNum")
			LEFT JOIN "{?Schema@}"."OPCH"  ON PCH1."DocEntry" = OPCH."DocEntry"			
			------------------------------------------------------------------------------------------------------------------
			LEFT JOIN "{?Schema@}"."VPM2"  ON VPM2."InvType" = 18 AND VPM2."DocEntry" = OPCH."DocEntry"
			LEFT JOIN "{?Schema@}"."OVPM"  ON VPM2."DocNum" = OVPM."DocEntry"
			---------------------------------------------------------------------------------------------------------------------
			WHERE OPOR."CANCELED" = 'N'
			AND POR1."AgrNo" IS NOT NULL
			AND IFNULL(OPCH."CANCELED",'N') <> 'Y'
			GROUP BY POR1."AgrNo",
					POR1."DocEntry",
					IFNULL(POR1."FreeTxt",'งวดที่ 1'),
					CAST(SUBSTRING_REGEXPR('[0-9]+' IN IFNULL(POR1."FreeTxt", '1')) AS INT),
					POR1."ShipDate" ,
					GRPO."DocDate",
					OVPM."DocDate"
			ORDER BY POR1."AgrNo",CAST(SUBSTRING_REGEXPR('[0-9]+' IN IFNULL(POR1."FreeTxt", '1')) AS INT)
		) AS PO ON T0."AbsID" = PO."AgrNo"
--INNER JOIN {?Schema@}."OAT1" T1 ON T1."AgrNo" = T0."AbsID"
WHERE T0."BpName" IS NOT NULL 
AND T0."BpName" <> ''
AND T0."Status" <> 'C'
 --AND (T0."AbsID" = '{?AbsID@}' OR '{?AbsID@}' = '')



