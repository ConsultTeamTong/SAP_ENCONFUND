SELECT
    TO_VARCHAR(ADD_YEARS(ODRF."DocDate", 543), 'DD.MM.YYYY') AS "DateThai",
    IFNULL(T6."BeginStr", '') || CAST(ODRF."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร",
    
    
    CAST(DRF1."U_SLD_DocRef" AS NVARCHAR(2000)) AS "เลขที่อ้างอืง",
    CAST(DRF1."U_SLD_BP_Ref" AS NVARCHAR(2000)) AS "บริษัทผู้ผลิตและนำเข้า",
    TO_VARCHAR(ADD_YEARS(DRF1."U_SLD_DateFrom", 543), 'DD.MM.YYYY') AS "วันทีนำเข้า/ออก",
    TO_VARCHAR(ADD_YEARS(DRF1."U_SLD_DateTo", 543), 'DD.MM.YYYY') AS "วันที่ นำเข้า/ออก",

    -- [กลุ่มเบนซิน]
    SUM(CASE WHEN DRF1."Dscription" = 'เบนซิน' THEN DRF1."Quantity" END) AS "ลิตร เบนซิน",
    MAX(CASE WHEN DRF1."Dscription" = 'เบนซิน' THEN DRF1."Price" END) AS "อัตรา เบนซิน",
    SUM(CASE WHEN DRF1."Dscription" = 'เบนซิน' THEN DRF1."LineTotal" END) AS "SUM เบนซิน",

    -- [กลุ่มแก๊สโซฮอล์]
    SUM(CASE WHEN DRF1."Dscription" = 'แก๊สโซฮอล' THEN DRF1."Quantity" END) AS "ลิตร แก๊สโซฮอล",
    MAX(CASE WHEN DRF1."Dscription" = 'แก๊สโซฮอล' THEN DRF1."Price" END) AS "อัตรา แก๊สโซฮอล",
    SUM(CASE WHEN DRF1."Dscription" = 'แก๊สโซฮอล' THEN DRF1."LineTotal" END) AS "SUM แก๊สโซฮอล",

    -- [กลุ่มดีเซล]
    SUM(CASE WHEN DRF1."Dscription" = 'ดีเซล' THEN DRF1."Quantity" END) AS "ลิตร ดีเซล",
    MAX(CASE WHEN DRF1."Dscription" = 'ดีเซล' THEN DRF1."Price" END) AS "อัตรา ดีเซล",
    SUM(CASE WHEN DRF1."Dscription" = 'ดีเซล' THEN DRF1."LineTotal" END) AS "SUM ดีเซล",

    -- [กลุ่มน้ำมันเตา]
    SUM(CASE WHEN DRF1."Dscription" = 'น้ำมันเตา' THEN DRF1."Quantity" END) AS "ลิตร น้ำมันเตา",
    MAX(CASE WHEN DRF1."Dscription" = 'น้ำมันเตา' THEN DRF1."Price" END) AS "อัตรา น้ำมันเตา",
    SUM(CASE WHEN DRF1."Dscription" = 'น้ำมันเตา' THEN DRF1."LineTotal" END) AS "SUM น้ำมันเตา",

    -- [กลุ่มน้ำมันก๊าด]
    SUM(CASE WHEN DRF1."Dscription" = 'น้ำมันก๊าด' THEN DRF1."Quantity" END) AS "ลิตร น้ำมันก๊าด",
    MAX(CASE WHEN DRF1."Dscription" = 'น้ำมันก๊าด' THEN DRF1."Price" END) AS "อัตรา น้ำมันก๊าด",
    SUM(CASE WHEN DRF1."Dscription" = 'น้ำมันก๊าด' THEN DRF1."LineTotal" END) AS "SUM น้ำมันก๊าด",

    SUM(CASE WHEN DRF1."Dscription" IN ('เบนซิน', 'แก๊สโซฮอล', 'ดีเซล', 'น้ำมันเตา', 'น้ำมันก๊าด') 
             THEN DRF1."LineTotal" END) AS "รวมรายได้น้ำมัน",

    SUM(CASE WHEN DRF1."Dscription" = 'บัญชีรายได้ค่าปรับ' 
             THEN DRF1."LineTotal" END) AS "รายได้ค่าปรับ",

    SUM(CASE WHEN DRF1."Dscription" IN ('เบนซิน', 'แก๊สโซฮอล', 'ดีเซล', 'น้ำมันเตา', 'น้ำมันก๊าด', 'บัญชีรายได้ค่าปรับ') 
             THEN DRF1."LineTotal" END) AS "รวมรายได้สุทธิ"

FROM {?Schema@}."DRF1" DRF1
INNER JOIN {?Schema@}."ODRF" ODRF ON DRF1."DocEntry" = ODRF."DocEntry"
INNER JOIN {?Schema@}."NNM1" T6 ON ODRF."Series" = T6."Series"
WHERE ODRF."DocEntry" = {?DocKey@}
  AND ODRF."ObjType" = '13'  
GROUP BY 
    ODRF."DocDate",
    T6."BeginStr",
    ODRF."DocNum",
    CAST(DRF1."U_SLD_DocRef" AS NVARCHAR(2000)),
    CAST(DRF1."U_SLD_BP_Ref" AS NVARCHAR(2000)),
    DRF1."U_SLD_DateFrom",
    DRF1."U_SLD_DateTo"