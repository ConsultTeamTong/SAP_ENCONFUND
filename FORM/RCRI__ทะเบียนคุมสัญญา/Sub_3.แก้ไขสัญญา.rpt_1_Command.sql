SELECT 
	CASE 
		WHEN T2."U_SLD_Type" = '01' THEN 'แก้ไขสัญญา'
	ELSE 'หนังสือค้ำประกัน' END AS "Type"
    ,OOAT."AbsID" AS "DocEntry_Agreement" 
     ,'ครั้งที่ ' || TO_NVARCHAR(T2."U_SLD_The_Time") AS "ครั้งที่"
	 ,'งวดที่ ' || TO_NVARCHAR(T2."U_SLD_Period_No") AS "งวดที่ (สัญญา)" 
	 ,CASE 
	 	WHEN T2."U_SLD_Type" = '02' THEN T2."U_SLD_Amount" 
	ELSE T2."U_SLD_Original_Limit" END AS "วงเงินเดิม" 
	 ,CASE 
	 	WHEN T2."U_SLD_Type" = '02' THEN T2."U_SLD_Amount_Edit" 
	ELSE T2."U_SLD_Edit_Limit" END AS "วงเงิน(แก้ไข)"	 

	 ,T2."U_SLD_Original_Date" AS "วันสิ้นสุดสัญญาเดิม" 
	 
 	,T2."U_SLD_Edit_Date" AS "วันสิ้นสุดสัญญา(แก้ไข)" 

 	,T2."U_SLD_Date_Letter" AS "วันที่แก้ไขสัญญา"

FROM {?Schema@}."OAT2" T2
INNER JOIN {?Schema@}.OOAT ON T2."AgrNo" = OOAT."AbsID"
AND OOAT."AbsID"  = '{?Pm-Command.DocEntry_Agreement}'
-- [จุดที่แก้ไข] เปลี่ยนเป็นฟิลด์จัดเรียงบรรทัดของตารางสัญญา
ORDER BY T2."AgrEfctNum"


