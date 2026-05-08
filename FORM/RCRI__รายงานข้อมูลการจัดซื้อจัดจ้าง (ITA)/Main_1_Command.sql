-- ============================================================
-- Report: RCRI0023__รายงานข้อมูลการจัดซื้อจัดจ้าง (ITA).rpt
Path:   RCRI0023__รายงานข้อมูลการจัดซื้อจัดจ้าง (ITA).rpt
Extracted: 2026-05-07 18:03:39
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT TOP 100
p."Descript" AS "ชื่อรายการของงานที่ซื้อหรือจ้าง"
,p."U_SLD_Approve_Budget" AS "วงเงินงบประมาณที่ได้รับจัดสรร (บาท)"
,p."U_SLD_Budget_Source" AS "แหล่งที่มาของงบประมาณ "
,CASE
     WHEN p."EndDate" < CURRENT_DATE THEN 'สิ้นสุดระยะสัญญา' 
     ELSE 'อยู่ระหว่างระยะสัญญา' 
 END AS "สถานะการจัดซื้อจัดจ้าง "
,p."U_SLD_Procurement_Method" AS "วิธีการจัดซื้อจัดจ้าง"
,p."U_SLD_Average_Price" AS "ราคากลาง (บาท)"
,p."U_SLD_Contract_Amount" AS "ราคาที่ตกลงซื้อหรือจ้าง (บาท)"
,p."BpName" AS "รายชื่อผู้ประกอบการที่ได้รับการคัดเลือก"
,p."U_SLD_Project_Number" AS "เลขที่โครงการ"
,TO_VARCHAR(a."PeriodCat" + 543) AS "ปีงบประมาณ"
FROM {?Schema@}.OOAT p
LEFT JOIN {?Schema@}.OFPR o ON p."PIndicator" = o."Indicator"
LEFT JOIN {?Schema@}.OACP a ON o."Category" = a."PeriodCat"
WHERE 1 = 1
AND (TO_VARCHAR(a."PeriodCat" + 543) = '{?Year@}' OR '{?Year@}' = ' ') 
AND p."Cancelled" <> 'Y'
ORDER BY 
    CASE 
        WHEN p."U_SLD_Budget_Source" = 'งบลงทุน' THEN 1 
        WHEN p."U_SLD_Budget_Source" = 'งบดำเนินงาน' THEN 2 
        ELSE 3 
    END ASC,
        p."U_SLD_Budget_Source" ASC,
        p."U_SLD_Approve_Budget" DESC, 
        p."U_SLD_Project_Number" ASC
        
        
