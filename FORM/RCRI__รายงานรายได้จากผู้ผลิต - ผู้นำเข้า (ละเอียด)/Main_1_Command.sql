-- ============================================================
-- Report: RCRI0012__รายงานรายได้จากผู้ผลิต - ผู้นำเข้า (ละเอียด).rpt
Path:   RCRI0012__รายงานรายได้จากผู้ผลิต - ผู้นำเข้า (ละเอียด).rpt
Extracted: 2026-05-07 18:03:34
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT
    IFNULL(CAST(DAYOFMONTH(T10."DocDate") AS NVARCHAR) || ' ' || 
    MAP(MONTH(T10."DocDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
    || ' ' || TO_VARCHAR(ADD_YEARS(T10."DocDate", 543), 'YY'), '') AS "Date IS" ,
    
    CAST(DAYOFMONTH(OINV."DocDate") AS NVARCHAR) || ' ' || 
    MAP(MONTH(OINV."DocDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
    || ' ' || TO_VARCHAR(ADD_YEARS(OINV."DocDate", 543), 'YY') AS "DateThai AR INVOICE" ,
    
    IFNULL(T6."BeginStr", '') || CAST(OINV."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร",
    OINV."CardName" AS "ลูกหนี้",
    CAST(INV1."U_SLD_DocRef" AS NVARCHAR(2000)) AS "เลขที่อ้างอืง",
    CAST(INV1."U_SLD_BP_Ref" AS NVARCHAR(2000)) AS "บริษัทผู้ผลิตและนำเข้า",
    
    IFNULL(CAST(DAYOFMONTH(INV1."U_SLD_DateFrom") AS NVARCHAR)  || ' ' || 
    MAP(MONTH(INV1."U_SLD_DateFrom"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
    || ' ' || TO_VARCHAR(ADD_YEARS(INV1."U_SLD_DateFrom", 543), 'YY')    ||' '|| '-' ||' '||
    CAST(DAYOFMONTH(INV1."U_SLD_DateTo") AS NVARCHAR) || ' ' || 
    MAP(MONTH(INV1."U_SLD_DateTo"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
    || ' ' || TO_VARCHAR(ADD_YEARS(INV1."U_SLD_DateTo", 543), 'YY'), '') AS "วันที่ นำเข้า/ออก",
    
    SUM(CASE WHEN "Dscription" = 'เบนซิน' THEN "Quantity" END) AS "ลิตร เบนซิน",
    MAX(CASE WHEN "Dscription" = 'เบนซิน' THEN "Price" END) AS "อัตรา เบนซิน",
    SUM(CASE WHEN "Dscription" = 'เบนซิน' THEN "LineTotal" END) AS "SUM เบนซิน",
    SUM(CASE WHEN "Dscription" = 'แก๊สโซฮอล' THEN "Quantity" END) AS "ลิตร แก๊สโซฮอล",
    MAX(CASE WHEN "Dscription" = 'แก๊สโซฮอล' THEN "Price" END) AS "อัตรา แก๊สโซฮอล",
    SUM(CASE WHEN "Dscription" = 'แก๊สโซฮอล' THEN "LineTotal" END) AS "SUM แก๊สโซฮอล",
    SUM(CASE WHEN "Dscription" = 'ดีเซล' THEN "Quantity" END) AS "ลิตร ดีเซล",
    MAX(CASE WHEN "Dscription" = 'ดีเซล' THEN "Price" END) AS "อัตรา ดีเซล",
    SUM(CASE WHEN "Dscription" = 'ดีเซล' THEN "LineTotal" END) AS "SUM ดีเซล",
    SUM(CASE WHEN "Dscription" = 'น้ำมันเตา' THEN "Quantity" END) AS "ลิตร น้ำมันเตา",
    MAX(CASE WHEN "Dscription" = 'น้ำมันเตา' THEN "Price" END) AS "อัตรา น้ำมันเตา",
    SUM(CASE WHEN "Dscription" = 'น้ำมันเตา' THEN "LineTotal" END) AS "SUM น้ำมันเตา",
    SUM(CASE WHEN "Dscription" = 'น้ำมันก๊าด' THEN "Quantity" END) AS "ลิตร น้ำมันก๊าด",
    MAX(CASE WHEN "Dscription" = 'น้ำมันก๊าด' THEN "Price" END) AS "อัตรา น้ำมันก๊าด",
    SUM(CASE WHEN "Dscription" = 'น้ำมันก๊าด' THEN "LineTotal" END) AS "SUM น้ำมันก๊าด",
    SUM(CASE WHEN "Dscription" IN ('เบนซิน', 'แก๊สโซฮอล', 'ดีเซล', 'น้ำมันเตา', 'น้ำมันก๊าด') 
             THEN "LineTotal" END) AS "รวมรายได้น้ำมัน",
    SUM(CASE WHEN "Dscription" = 'บัญชีรายได้ค่าปรับ' 
             THEN "LineTotal" END) AS "รายได้ค่าปรับ",
    SUM(CASE WHEN "Dscription" IN ('เบนซิน', 'แก๊สโซฮอล', 'ดีเซล', 'น้ำมันเตา', 'น้ำมันก๊าด', 'บัญชีรายได้ค่าปรับ') 
             THEN "LineTotal" END) AS "รวมรายได้สุทธิ",
    cc."Credit" AS "บัญชีรายได้เงินนำส่งเข้าทุนหมุนเวียน",
    cc2."Credit" AS "บัญชีรายได้ค่าปรับ",
    cc3."Debit" AS "บัญญชีพัก(เงินรับฝากอื่น)"
FROM {?Schema@}."INV1"
INNER JOIN {?Schema@}."OINV" ON INV1."DocEntry" = OINV."DocEntry"
INNER JOIN {?Schema@}."NNM1" T6 ON OINV."Series" = T6."Series"
LEFT JOIN {?Schema@}."RCT2" T7 ON OINV."DocEntry" = T7."DocEntry"
LEFT JOIN {?Schema@}."ORCT" T11 ON T7."DocNum" = T11."DocEntry"
LEFT JOIN {?Schema@}."ITR1" T8 ON T11."TransId" = T8."TransId"
LEFT JOIN {?Schema@}."ITR1" T9 ON T8."ReconNum" = T9."ReconNum" AND T9."LineSeq" = 0
LEFT JOIN {?Schema@}."ORCT" T10 ON T9."TransId" = T10."TransId"  -- แก้จาก INNER เป็น LEFT JOIN แล้ว
LEFT JOIN (SELECT j."Credit" ,j."TransId" FROM {?Schema@}.jdt1 j WHERE j."Account" = '_SYS00000000975') cc ON OINV."TransId" = cc."TransId"
LEFT JOIN (SELECT d."Credit" ,d."TransId" FROM {?Schema@}.jdt1 d WHERE d."Account" = '_SYS00000001000') cc2 ON OINV."TransId" = cc2."TransId"
LEFT JOIN (SELECT t."Debit" ,t."TransId" FROM {?Schema@}.jdt1 t WHERE t."Account" = '_SYS00000001242') cc3 ON OINV."TransId" = cc3."TransId"
WHERE "OINV"."CANCELED" = 'N'
AND OINV."CardName" IN ('กรมสรรพสามิต', 'กรมศุลกากร')
AND OINV."DocDate" BETWEEN {?1SDate} AND {?2EDate}
AND (OINV."CardName" =  '{?Cname@}' OR '{?Cname@}' = '')
GROUP BY 
    T10."DocDate",
    OINV."CardName",
    OINV."DocDate",
    T6."BeginStr",
    OINV."DocNum",
    CAST(INV1."U_SLD_DocRef" AS NVARCHAR(2000)),
    CAST(INV1."U_SLD_BP_Ref" AS NVARCHAR(2000)),
    INV1."U_SLD_DateFrom",
    INV1."U_SLD_DateTo",
    cc."Credit",
    cc2."Credit",
    cc3."Debit"
    

