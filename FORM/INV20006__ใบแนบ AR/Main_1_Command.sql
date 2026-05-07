-- ============================================================
-- Report: INV20006__ใบแนบ AR.rpt
Path:   INV20006__ใบแนบ AR.rpt
Extracted: 2026-05-07 18:03:07
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT
    TO_VARCHAR(ADD_YEARS(OINV."DocDate", 543), 'DD.MM.YYYY') AS "DateThai",
    IFNULL(T6."BeginStr", '') || CAST(OINV."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร",
    
    -- [เอา MAX ออก เพื่อให้แยกบรรทัดตามข้อมูลจริง]
    CAST(INV1."U_SLD_DocRef" AS NVARCHAR(2000)) AS "เลขที่อ้างอืง",
    CAST(INV1."U_SLD_BP_Ref" AS NVARCHAR(2000)) AS "บริษัทผู้ผลิตและนำเข้า",
    TO_VARCHAR(ADD_YEARS(INV1."U_SLD_DateFrom", 543), 'DD.MM.YYYY') AS "วันทีนำเข้า/ออก",
    TO_VARCHAR(ADD_YEARS(INV1."U_SLD_DateTo", 543), 'DD.MM.YYYY') AS "วันที่ นำเข้า/ออก",

    -- [กลุ่มเบนซิน]
    SUM(CASE WHEN "Dscription" = 'เบนซิน' THEN "Quantity" END) AS "ลิตร เบนซิน",
    MAX(CASE WHEN "Dscription" = 'เบนซิน' THEN "Price" END) AS "อัตรา เบนซิน",
    SUM(CASE WHEN "Dscription" = 'เบนซิน' THEN "LineTotal" END) AS "SUM เบนซิน",

    -- [กลุ่มแก๊สโซฮอล์]
    SUM(CASE WHEN "Dscription" = 'แก๊สโซฮอล' THEN "Quantity" END) AS "ลิตร แก๊สโซฮอล",
    MAX(CASE WHEN "Dscription" = 'แก๊สโซฮอล' THEN "Price" END) AS "อัตรา แก๊สโซฮอล",
    SUM(CASE WHEN "Dscription" = 'แก๊สโซฮอล' THEN "LineTotal" END) AS "SUM แก๊สโซฮอล",

    -- [กลุ่มดีเซล]
    SUM(CASE WHEN "Dscription" = 'ดีเซล' THEN "Quantity" END) AS "ลิตร ดีเซล",
    MAX(CASE WHEN "Dscription" = 'ดีเซล' THEN "Price" END) AS "อัตรา ดีเซล",
    SUM(CASE WHEN "Dscription" = 'ดีเซล' THEN "LineTotal" END) AS "SUM ดีเซล",

    -- [กลุ่มน้ำมันเตา]
    SUM(CASE WHEN "Dscription" = 'น้ำมันเตา' THEN "Quantity" END) AS "ลิตร น้ำมันเตา",
    MAX(CASE WHEN "Dscription" = 'น้ำมันเตา' THEN "Price" END) AS "อัตรา น้ำมันเตา",
    SUM(CASE WHEN "Dscription" = 'น้ำมันเตา' THEN "LineTotal" END) AS "SUM น้ำมันเตา",

    -- [กลุ่มน้ำมันก๊าด]
    SUM(CASE WHEN "Dscription" = 'น้ำมันก๊าด' THEN "Quantity" END) AS "ลิตร น้ำมันก๊าด",
    MAX(CASE WHEN "Dscription" = 'น้ำมันก๊าด' THEN "Price" END) AS "อัตรา น้ำมันก๊าด",
    SUM(CASE WHEN "Dscription" = 'น้ำมันก๊าด' THEN "LineTotal" END) AS "SUM น้ำมันก๊าด",


    
    SUM(CASE WHEN "Dscription" IN ('เบนซิน', 'แก๊สโซฮอล', 'ดีเซล', 'น้ำมันเตา', 'น้ำมันก๊าด') 
             THEN "LineTotal" END) AS "รวมรายได้น้ำมัน",

    SUM(CASE WHEN "Dscription" = 'บัญชีรายได้ค่าปรับ' 
             THEN "LineTotal" END) AS "รายได้ค่าปรับ",

    SUM(CASE WHEN "Dscription" IN ('เบนซิน', 'แก๊สโซฮอล', 'ดีเซล', 'น้ำมันเตา', 'น้ำมันก๊าด', 'บัญชีรายได้ค่าปรับ') 
             THEN "LineTotal" END) AS "รวมรายได้สุทธิ"

FROM {?Schema@}."INV1"
INNER JOIN {?Schema@}."OINV" ON INV1."DocEntry" = OINV."DocEntry"
INNER JOIN {?Schema@}."NNM1" T6 ON OINV."Series" = T6."Series"
WHERE OINV."DocEntry" = {?DocKey@}
GROUP BY 
    OINV."DocDate",
    T6."BeginStr",
    OINV."DocNum",
    CAST(INV1."U_SLD_DocRef" AS NVARCHAR(2000)),
    CAST(INV1."U_SLD_BP_Ref" AS NVARCHAR(2000)),
    INV1."U_SLD_DateFrom",
    INV1."U_SLD_DateTo"
