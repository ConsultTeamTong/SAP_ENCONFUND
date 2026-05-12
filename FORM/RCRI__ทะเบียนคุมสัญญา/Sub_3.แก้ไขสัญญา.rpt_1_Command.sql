-- ============================================================
-- Report: RCRI0022__ทะเบียนคุมสัญญา.rpt
Path:   RCRI0022__ทะเบียนคุมสัญญา.rpt
Extracted: 2026-05-07 18:03:39
-- Source: Subreport [3.แก้ไขสัญญา.rpt]
-- Table:  Command
-- ============================================================

SELECT 
      OOAT."AbsID" AS "DocEntry_Agreement" 
     ,'ครั้งที่ ' || TO_NVARCHAR(T2."U_SLD_The_Time") AS "ครั้งที่"
	 ,'งวดที่ ' || TO_NVARCHAR(T2."U_SLD_Period_No") AS "งวดที่ (สัญญา)" 
	 
	 ,T2."U_SLD_Original_Limit" AS "วงเงินเดิม"
	 ,T2."U_SLD_Edit_Limit" AS "วงเงิน(แก้ไข)"
	 
	 ,TO_VARCHAR(T2."U_SLD_Original_Date", 'D') || ' ' || 
MAP(MONTH(T2."U_SLD_Original_Date"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(T2."U_SLD_Original_Date", 543), 'YY') AS "วันสิ้นสุดสัญญาเดิม" 
	 
 ,TO_VARCHAR(T2."U_SLD_Edit_Date", 'D') || ' ' || 
MAP(MONTH(T2."U_SLD_Edit_Date"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(T2."U_SLD_Edit_Date", 543), 'YY') AS "วันสิ้นสุดสัญญา(แก้ไข)" 

 ,TO_VARCHAR(T2."U_SLD_Date_Letter", 'D') || ' ' || 
MAP(MONTH(T2."U_SLD_Date_Letter"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(T2."U_SLD_Date_Letter", 543), 'YY') AS "วันที่ขยายสัญญา"

 ,TO_VARCHAR(T2."FromDate", 'D') || ' ' || 
MAP(MONTH(T2."FromDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(T2."FromDate", 543), 'YY') AS "วันที่ขยายสัญญา"


FROM {?Schema@}."OAT2" T2
INNER JOIN {?Schema@}.OOAT ON T2."AgrNo" = OOAT."AbsID"
WHERE T2."U_SLD_Type" = '01'
AND OOAT."AbsID"  = '{?Pm-Command.DocEntry_Agreement}'
-- [จุดที่แก้ไข] เปลี่ยนเป็นฟิลด์จัดเรียงบรรทัดของตารางสัญญา
ORDER BY T2."AgrEfctNum"


