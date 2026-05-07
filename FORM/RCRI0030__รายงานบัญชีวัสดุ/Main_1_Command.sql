-- ============================================================
-- Report: RCRI0030__รายงานบัญชีวัสดุ.rpt
Path:   RCRI0030__รายงานบัญชีวัสดุ.rpt
Extracted: 2026-05-07 18:03:42
-- Source: Main Report
-- Table:  Command
-- ============================================================

WITH TransData AS (
    -- ยุบรวม Layer ของ IVL1 ให้เหลือบรรทัดเดียวต่อ 1 เอกสาร
    SELECT 
        T0."TransSeq",
        T0."ItemCode",
        T0."CreateDate", -- System Date
        T0."DocDate",    -- Posting Date
        T0."LocCode" AS "WhsCode",
        T0."TransType",
        T0."CreatedBy" AS "DocEntry",
        T0."BASE_REF",
        SUM(IFNULL(T1."LayerInQty", 0) - IFNULL(T1."LayerOutQ", 0)) AS "Quantity",
        SUM(T1."TransValue") AS "TransValue"
    FROM {?Schema@}.OIVL T0
    INNER JOIN {?Schema@}.IVL1 T1 ON T0."TransSeq" = T1."TransSeq"
    GROUP BY 
        T0."TransSeq", T0."ItemCode", T0."CreateDate", T0."DocDate", T0."LocCode", T0."TransType", T0."CreatedBy", T0."BASE_REF"
)
SELECT 
    D."ItemCode" AS "รหัสสินค้า",
    I."ItemName" AS "Name",
    T7."ItmsGrpNam" AS "ITEM GROUP",
    T8."InvntryUom" AS "UoM",
    D."CreateDate" AS "System Date",
    D."DocDate" AS "Posting Date",
    D."TransType",
    
    -- แปลงรหัส TransType ให้เป็นชื่อประเภทเอกสาร
    CASE D."TransType"
        WHEN 13 THEN 'AR Invoice'
        WHEN 14 THEN 'AR Credit Memo'
        WHEN 15 THEN 'Delivery'
        WHEN 16 THEN 'Sales Return'
        WHEN 18 THEN 'AP Invoice'
        WHEN 19 THEN 'AP Credit Memo'
        WHEN 20 THEN 'Goods Receipt PO'
        WHEN 21 THEN 'Goods Return'
        WHEN 162 THEN 'Inventory Revaluation' 
        WHEN 58 THEN 'Inventory Revaluation'
        WHEN 59 THEN 'Goods Receipt'
        WHEN 60 THEN 'Goods Issue'
        WHEN 67 THEN 'Inventory Transfer'
        WHEN 69 THEN 'Landed Costs'
        ELSE 'Other'
    END AS "Doc. Type",
    
    -- จัดรูปแบบ Document Number
    IFNULL(T6."BeginStr", '') || CAST(IFNULL(T5."DocNum", D."BASE_REF") AS VARCHAR(20)) AS "เลขที่เอกสาร",
    
    -- เพิ่ม CardName จาก T5
    T5."CardName" AS "หน่วยงาน/ผู้ขาย",
    
    T9."WhsName" AS "ที่เก็บ",
    D."Quantity",
    
    -- 🟢 ไฮไลท์การแก้ไข: คำนวณ Cost Baht แบบอัจฉริยะ 
    CASE 
        -- ถ้าเป็น Revaluation (ปรับมูลค่าแต่ Qty เป็น 0) ให้เอา (ยอดเงินสะสม / ยอดจำนวนสะสม) จะได้ต้นทุนใหม่พอดีเป๊ะ!
        WHEN D."TransType" IN (162, 58) THEN 
            IFNULL(ABS(
                SUM(D."TransValue") OVER (PARTITION BY D."ItemCode" ORDER BY D."TransSeq") / 
                NULLIF(SUM(D."Quantity") OVER (PARTITION BY D."ItemCode" ORDER BY D."TransSeq"), 0)
            ), 0)
        -- ถ้าเป็นเอกสารปกติที่มีจำนวนเคลื่อนไหว
        WHEN D."Quantity" <> 0 THEN ABS(D."TransValue" / D."Quantity") 
        ELSE 0 
    END AS "Cost Baht",
    
    D."TransValue" AS "Trans. Value",
    
    -- คำนวณยอดสะสม (Cumulative Qty & Value)
    SUM(D."Quantity") OVER (PARTITION BY D."ItemCode" ORDER BY D."TransSeq") AS "Cumulative Qty",
    SUM(D."TransValue") OVER (PARTITION BY D."ItemCode" ORDER BY D."TransSeq") AS "Cumulative Value"
    
FROM TransData D
INNER JOIN {?Schema@}.OITM I ON D."ItemCode" = I."ItemCode"

-- ดึงหัวเอกสารต่างๆ (T5) มารวมกัน พร้อมดึง CardCode และ CardName
LEFT JOIN (
    SELECT 20 AS "ObjType", "DocEntry", "Series", "DocNum", "CardCode", "CardName" FROM {?Schema@}.OPDN UNION ALL
    SELECT 18 AS "ObjType", "DocEntry", "Series", "DocNum", "CardCode", "CardName" FROM {?Schema@}.OPCH UNION ALL
    SELECT 15 AS "ObjType", "DocEntry", "Series", "DocNum", "CardCode", "CardName" FROM {?Schema@}.ODLN UNION ALL
    SELECT 13 AS "ObjType", "DocEntry", "Series", "DocNum", "CardCode", "CardName" FROM {?Schema@}.OINV UNION ALL
    SELECT 162 AS "ObjType", "DocEntry", "Series", "DocNum", NULL AS "CardCode", NULL AS "CardName" FROM {?Schema@}.OMRV UNION ALL 
    SELECT 58 AS "ObjType", "DocEntry", "Series", "DocNum", NULL AS "CardCode", NULL AS "CardName" FROM {?Schema@}.OMRV UNION ALL 
    SELECT 59 AS "ObjType", "DocEntry", "Series", "DocNum", NULL AS "CardCode", NULL AS "CardName" FROM {?Schema@}.OIGN UNION ALL 
    SELECT 60 AS "ObjType", "DocEntry", "Series", "DocNum", NULL AS "CardCode", NULL AS "CardName" FROM {?Schema@}.OIGE UNION ALL 
    SELECT 67 AS "ObjType", "DocEntry", "Series", "DocNum", "CardCode", "CardName" FROM {?Schema@}.OWTR UNION ALL
    SELECT 21 AS "ObjType", "DocEntry", "Series", "DocNum", "CardCode", "CardName" FROM {?Schema@}.ORPD UNION ALL
    SELECT 14 AS "ObjType", "DocEntry", "Series", "DocNum", "CardCode", "CardName" FROM {?Schema@}.ORIN UNION ALL
    SELECT 16 AS "ObjType", "DocEntry", "Series", "DocNum", "CardCode", "CardName" FROM {?Schema@}.ORDN UNION ALL
    SELECT 69 AS "ObjType", "DocEntry", "Series", "DocNum", NULL AS "CardCode", NULL AS "CardName" FROM {?Schema@}.OIPF 
) T5 ON D."TransType" = T5."ObjType" AND D."DocEntry" = T5."DocEntry"

-- เชื่อมตารางอื่นๆ
LEFT JOIN {?Schema@}.NNM1 T6 ON T5."Series" = T6."Series" AND T5."ObjType" = T6."ObjectCode"
LEFT JOIN {?Schema@}.OITB T7 ON I."ItmsGrpCod" = T7."ItmsGrpCod" 
LEFT JOIN {?Schema@}.OITM T8 ON I."ItemCode" = T8."ItemCode"
LEFT JOIN {?Schema@}.OWHS T9 ON D."WhsCode" = T9."WhsCode"

-- กรองเฉพาะรายการที่มีการเคลื่อนไหวของจำนวน หรือ มูลค่า
WHERE (D."Quantity" <> 0 OR D."TransValue" <> 0)
AND D."DocDate" >= {?StartDate} 
AND D."DocDate" <= {?EndDate}

ORDER BY D."ItemCode", D."TransSeq";
