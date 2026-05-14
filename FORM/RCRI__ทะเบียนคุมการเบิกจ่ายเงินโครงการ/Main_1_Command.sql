-- ============================================================
-- Report: RCRI0016__ทะเบียนคุมการเบิกจ่ายเงินโครงการ.rpt
Path:   RCRI0016__ทะเบียนคุมการเบิกจ่ายเงินโครงการ.rpt
Extracted: 2026-05-07 18:03:36
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT * FROM (
    SELECT 
        CAST(DAYOFMONTH(OPCH."DocDate") AS NVARCHAR) || ' ' || 
		MAP(MONTH(OPCH."DocDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
		|| ' ' || TO_VARCHAR(ADD_YEARS(OPCH."DocDate", 543), 'YYYY') AS "วัน เดือน ปี (เบิก)"
        , OPCH."DocDate" 
        ,OPCH."Comments" AS "Remark AP"
        , IFNULL(n1."BeginStr", '') || CAST(OPCH."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร AP"
        , OPRJ."U_SLD_Period" AS "ปีงบประมาณ"
        , OPRJ."U_SLD_PlanWork" AS "แผนงาน"
        , OPRJ."U_SLD_GroupWork" AS "กลุ่มงาน"
        , OPRJ."U_SLD_ProjectName" AS "ชื่อโครงการ"
        , OPRJ."U_SLD_ConfDocNo" AS "เลขที่หนังสือยืนยันฯ"
        , OPRJ."U_SLD_Vendor" AS "ผู้ได้รับสนับสนุน"
        , OPRJ."U_SLD_REQ" AS "ผู้เบิกเงินลงทุน"
        , OPRJ."U_SLD_REC" As "ผุ้ได้รับจัดสรร"
        , OPCH."NumAtCard"
        , OPCH."DocTotal" AS "จำนวนเงิน AP"
          ,CAST(DAYOFMONTH(OVPM."DocDate") AS NVARCHAR) || ' ' || 
		MAP(MONTH(OVPM."DocDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
		|| ' ' || TO_VARCHAR(ADD_YEARS(OVPM."DocDate", 543), 'YYYY') AS "วันที่ OUTGO"
        ,IFNULL(n2."BeginStr", '') || CAST(OVPM."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร OUTGO"
        ,OVPM."Comments" AS "Remark Outgoing"
        , IFNULL(OPCH."PaidToDate", 0) AS "จำนวนเงิน PTD"
        , OPCH."DocTotal" - IFNULL(OPCH."PaidToDate", 0) AS "จำนวนเงินค้างจ่าย"
        , CASE 
            WHEN IFNULL(OPCH."PaidToDate", 0) > 0 THEN 'จ่ายแล้ว'
            ELSE 'ค้างจ่าย'
          END AS "สถานะการเบิกจ่าย"
        ,OPRJ."U_SLD_Period"
        ,OPMG."U_U_SLD_Plan"
        ,OPMG."U_U_SLD_WorkGroup"
    FROM {?Schema@}.OPCH
    LEFT JOIN {?Schema@}.NNM1 n1 
        ON OPCH."Series" = n1."Series"  
    INNER JOIN {?Schema@}.OPMG 
        ON OPMG."FIPROJECT" = OPCH."Project"
        AND OPCH."CANCELED" = 'N'    
    INNER JOIN {?Schema@}.OPRJ  
        ON OPMG."FIPROJECT" = OPRJ."PrjCode"   
    LEFT JOIN {?Schema@}.VPM2 
        ON OPCH."DocEntry" = VPM2."DocEntry" 
        AND VPM2."InvType" = '18' 
    LEFT JOIN {?Schema@}.OVPM 
        ON VPM2."DocNum" = OVPM."DocEntry" 
        AND OVPM."Canceled" = 'N' 
    LEFT JOIN {?Schema@}.NNM1 n2 
        ON OVPM."Series" = n2."Series"
left join {?Schema@}.PCH1 n3 On OPCH."DocEntry" = n3."DocEntry"
where n3."Project" IS NOT NULL 
AND n3."Project" != ''
) AS K
WHERE 
K."DocDate" BETWEEN {?DSTART@} AND {?DEND@}
AND (K."สถานะการเบิกจ่าย" = '{?Status@}' OR '{?Status@}' = ' ')
AND (K."U_SLD_Period" = '{?Period@}' OR '{?Period@}' = '')
AND (K."U_U_SLD_Plan" = '{?Plan@}' OR '{?Plan@}' = '')
AND (K."U_U_SLD_WorkGroup" = '{?WorkGroup@}' OR '{?WorkGroup@}' = '')