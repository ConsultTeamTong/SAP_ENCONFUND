WITH RawData AS (
SELECT Distinct
    oa."U_SLD_Contract_Number" AS "เลขที่สัญญา/ลงวันที่"
    ,oa."Descript" AS "รายการ"
    ,oa."BpName" AS "ผู้รับจ้าง"
    ,rc."DocTotal" AS "จำนวนเงิน Incom"
    ,CASE 
        WHEN rc."CheckSum" <> 0 THEN 'แคชเชียร์เช็ค ' || sc."BankName" || ' สาขา ' || rc1c."Branch" || ' เลขที่ ' || rc1c."CheckNum" || ' ลว. ' || rc1c."DueDate"
        WHEN rc."CashSum" <> 0 THEN 'เงินสด'
        WHEN rc."TrsfrSum" <> 0 THEN 'เงินโอน'
    END AS "ประเภทเงินหลักประกันสัญญา"
    ,oa."StartDate" 
    ,oa."EndDate"
    ,CASE 
        WHEN MAX(po1."ShipDate") <> MAX(gpo."DocDate") THEN MAX(gpo."DocDate")
        ELSE MAX(po1."ShipDate")
    END AS "วันส่งมอบงาน งวดสุดท้าย"
    ,TRIM(
    CASE 
        WHEN FLOOR(DAYS_BETWEEN(oa."StartDate", oa."EndDate") / 30) > 0 
        THEN FLOOR(DAYS_BETWEEN(oa."StartDate", oa."EndDate") / 30) || ' เดือน ' 
        ELSE '' 
    END
    ||
    CASE 
        WHEN MOD(DAYS_BETWEEN(oa."StartDate", oa."EndDate"), 30) > 0 
        THEN MOD(DAYS_BETWEEN(oa."StartDate", oa."EndDate"), 30) || ' วัน' 
        ELSE '' 
    END
) AS "ระยะเวลาสัญญา"
,'ปี ' || RIGHT(TO_VARCHAR(YEAR(MAX(gpo."DocDate")) + 543), 2) AS "ครบกำหนดการค้ำประกัน"
,nm."BeginStr"||rc."DocNum" AS "เลขที่เอกสารรับหลักประกันสัญญา"
,rc."DocDate" AS "วัน/เดือน/ปี รับหลักประกันสัญญา"
,TO_VARCHAR(rc."U_SLD_Note_Receiving")  AS "หมายเหตุ"
,CASE
	WHEN ac."Segment_0" = '2112010101' OR je."U_SLD_BLANKET" IS NULL THEN 'ระยะสั้น'
    WHEN ac."Segment_0" = '2208010101' OR je."U_SLD_BLANKET" IS NOT NULL THEN 'ระยะสั้น'
	WHEN ac."Segment_0" = '2208010101 ' OR je."U_SLD_BLANKET" IS NULL  THEN 'ระยะยาว'
	WHEN ac."Segment_0" = '2112010101 ' OR je."U_SLD_BLANKET" IS NOT NULL  THEN 'ระยะยาว'
END AS "ระยะสัญญา"
,nmout."BeginStr" || vp."DocNum" AS "เลขที่ Outgoing Payment จ่าย AP"
,TO_VARCHAR(EXTRACT(YEAR FROM fp."Category") + 543 ) AS "ปีพศ"
,fp."Category" AS "Category"
,vp."DocDate" AS "วันที่ Outgoing"
FROM {?Schema@}.OOAT oa
INNER JOIN {?Schema@}.ORCT rc ON oa."U_SLD_Document" = rc."DocEntry" AND rc."DocType" = 'A'
LEFT JOIN {?Schema@}.RCT4 rc4 ON rc."DocEntry" = rc4."DocNum"
LEFT JOIN {?Schema@}.RCT1 rc1c ON rc."DocEntry" = rc1c."DocNum"
LEFT JOIN {?Schema@}.ODSC sc ON rc1c."BankCode" = sc."BankCode"
LEFT JOIN {?Schema@}.POR1 po1 ON oa."AbsID" = po1."AgrNo"
LEFT JOIN {?Schema@}.OPOR po ON po1."DocEntry" = po."DocEntry" 
LEFT JOIN {?Schema@}.PDN1 gpo1 ON gpo1."BaseType" = 22 AND gpo1."BaseEntry" = po1."DocEntry" AND gpo1."BaseLine" = po1."LineNum"
LEFT JOIN {?Schema@}.OPDN gpo ON gpo1."DocEntry" = gpo."DocEntry" 
LEFT JOIN {?Schema@}.NNM1 nm ON rc."Series" = nm."Series"
LEFT JOIN {?Schema@}.OACT ac ON rc4."AcctCode" = ac."AcctCode"
LEFT JOIN {?Schema@}.ITR1 irincom ON rc."TransId" = irincom."TransId" AND irincom."SrcObjTyp" = '24'
LEFT JOIN {?Schema@}.ITR1 irap ON irincom."ReconNum" = irap."ReconNum" AND irap."SrcObjTyp" = '18'
LEFT JOIN {?Schema@}.OPCH ap ON irap."SrcObjAbs" = ap."DocEntry"
LEFT JOIN {?Schema@}.VPM2 vp2 ON ap."DocEntry" = vp2."DocEntry" AND vp2."InvType" = '18'
LEFT JOIN {?Schema@}.OVPM vp ON vp2."DocNum" = vp."DocEntry"
LEFT JOIN {?Schema@}.NNM1 nmout ON vp."Series" = nmout."Series"
LEFT JOIN {?Schema@}.OJDT je ON oa."AbsID" = je."U_SLD_BLANKET" 
LEFT JOIN {?Schema@}.OFPR fp ON oa."PIndicator" = fp."Indicator"
WHERE ac."Segment_0" IN ('2112010101','2208010101' )
GROUP BY 
    oa."U_SLD_Contract_Number" 
    ,oa."Descript"
    ,oa."BpName" 
    ,rc."DocTotal" 
    ,oa."StartDate" 
    ,oa."EndDate"
    ,rc."CheckSum"
    ,rc."CashSum"
    ,rc."TrsfrSum"
    ,sc."BankName"
    ,rc1c."Branch"
    ,rc1c."CheckNum"
    ,rc1c."DueDate"
    ,nm."BeginStr"
    ,rc."DocNum"
    ,TO_VARCHAR(rc."U_SLD_Note_Receiving")
    ,rc."DocDate"
    ,nmout."BeginStr" 
    ,vp."DocNum"
    ,ac."Segment_0"
    ,je."U_SLD_BLANKET" 
    ,fp."Category"
    ,vp."DocDate"
    )
SELECT * FROM RawData
WHERE "ระยะสัญญา" = '{?ContractTerm@}'
AND "ปีพศ" = '{?YStart@}'
ORDER BY "Category"



--SELECT DISTINCT  TO_VARCHAR(EXTRACT(YEAR FROM "Category") + 543 )  FROM ofpr  ORDER BY TO_VARCHAR(EXTRACT(YEAR FROM "Category") + 543 )    



 
 


