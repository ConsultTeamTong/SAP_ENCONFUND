SELECT 
  AP."DocEntry",
  AP."DocDate" AS "วัน เดือน ปี (เบิก)",
  AP."CardName" AS "หน่วยงาน",
  AP."DocTotal" AS "จำนวนเงิน",
  APL."U_SLD_BP_Ref" AS "บริษัทผู้ผลิต/ผู้นำเข้า" ,
  AP."Comments" AS "เลขที่อ้างอิง AP",
  DocAP."BeginStr" || '' || AP."DocNum" AS "DocAP",
  Outg."DocEntry",
  Outg."DocDate" AS "วัน เดือน ปี (จ่าย)",
  Outg."DocTotal" AS "จำนวนเงินที่จ่าย" ,
  Outg."Comments" AS "เลขที่อ้างอิง OUT",
  DocOutg."BeginStr" || ''|| Outg."DocNum" AS "DocOut",
  CASE WHEN Outg."DocTotal" > 0 THEN '0' ELSE AP."DocTotal" END AS "จำนวนเงินค้างจ่าย",
  CASE WHEN Outg."DocTotal" > 0 THEN 'จ่ายแล้ว' ELSE 'ค้างจ่าย' END AS "สถานะ"
FROM {?Schema@}.OPCH AP
INNER JOIN {?Schema@}.PCH1 APL ON AP."DocEntry" = APL."DocEntry"
LEFT JOIN {?Schema@}.NNM1 DocAP ON AP."Series" = DocAP."Series"
LEFT JOIN {?Schema@}.OVPM Outg ON AP."DocEntry" = Outg."DocEntry"
LEFT JOIN {?Schema@}.VPM2 Outgl ON Outg."DocEntry" = Outgl."DocNum"
LEFT JOIN {?Schema@}.NNM1 DocOutg ON Outg."Series" = DocOutg."Series"
WHERE 1=1
AND AP."CardCode" IN ('VP0038','VP0037')
AND AP."DocDate" >= '{?1SDate@}'
AND AP."DocDate" <= '{?2EDate@}'
