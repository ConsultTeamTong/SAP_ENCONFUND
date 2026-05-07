-- ============================================================
-- Report: RCRI0026__ทะเบียนคุมหลักประกันสัญญา.rpt
Path:   RCRI0026__ทะเบียนคุมหลักประกันสัญญา.rpt
Extracted: 2026-05-07 18:03:40
-- Source: Main Report
-- Table:  Command
-- ============================================================



SELECT 
 rc."DocTotal" AS "ยอดรวมเอกสาร"
 ,TO_VARCHAR(rc."DocDate", 'D') || ' ' || 
MAP(MONTH(rc."DocDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(rc."DocDate", 543), 'YY') AS "วันที่รับหลักประกัน" 
 ,t4."Descrip" AS "รายการ"
 ,ofp."Category" + 543 AS "Period"
 ,IFNULL(T6."BeginStr", '') || CAST(rc."DocNum" AS NVARCHAR(20)) AS "เล่มที่/เลขที่ใบเสร็จรับเงิน/ใบรับหลักประกันสัญญา" 
 ,CASE 
		WHEN rc."CheckSum" > 0 THEN 'เช็ค'
		WHEN rc."TrsfrSum" > 0 THEN 'เงินโอน'
		WHEN rc."CashSum" > 0 THEN 'เงินสด'
  END AS "ประเภทหลักประกันสัญญา"
,CASE 
       WHEN TO_VARCHAR({?STARTDATE@}, 'MM') IN ('10', '11', '12') 
       THEN CAST(ofp."Category" AS INT) + 542 
       ELSE CAST(ofp."Category" AS INT) + 543  
   END AS "ปีของวันที่"
 ,rc."U_SLD_Note_Receiving" AS "หมายเหตุ"
 ,oo."U_SLD_Contract_Number" AS "เลขที่สัญญา"
 ,oo."BpName" AS "ผู้ขาย/ผู้รับจ้าง"
 
      ,CAST(DAYOFMONTH(oo."StartDate") AS NVARCHAR) || ' ' || 
MAP(MONTH(oo."StartDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(oo."StartDate", 543), 'YY')  

|| '-' || 

 CAST(DAYOFMONTH(oo."EndDate") AS NVARCHAR) || ' ' || 
MAP(MONTH(oo."EndDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(oo."EndDate", 543), 'YY')  AS "เริ่มต้น - สิ้นสุดสัญญา"
   

     ,CAST(DAYOFMONTH(oo."U_SLD_Warranty") AS NVARCHAR) || ' ' || 
MAP(MONTH(oo."U_SLD_Warranty"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(oo."U_SLD_Warranty", 543), 'YY') AS "เริ่มต้น - ครบกำหนดการค้ำประกัน" 



FROM {?Schema@}.ORCT rc
LEFT JOIN {?Schema@}."RCT4" t4 ON rc."DocEntry" = t4."DocNum"
INNER JOIN {?Schema@}."OFPR" ofp ON rc."FinncPriod" = ofp."AbsEntry"
LEFT JOIN {?Schema@}."NNM1" T6 ON rc."Series" = T6."Series"
INNER JOIN {?Schema@}."OOAT" oo ON rc."DocEntry" = oo."U_SLD_Document"
WHERE rc."DocType" = 'A'
AND rc."DocDate" BETWEEN {?STARTDATE@} AND {?ENDDATE@}
 AND (oo."U_SLD_Document" IS NOT NULL OR oo."U_SLD_Document" = '')
