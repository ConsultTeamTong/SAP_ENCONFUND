WITH Raw_JE AS (
   
    SELECT 
        T0."DocEntry",
        1 AS "SortOrder",
        T0."CardCode" AS "FormatCode",  
        T0."CardName" AS "AcctName",    
        T0."DocTotal" AS "Debit",
        0 AS "Credit",
        T0."Project"
    FROM {?Schema@}."ODRF" T0
    WHERE T0."ObjType" = '13'
    
    UNION ALL
    

    SELECT 
        T1."DocEntry",
        2 AS "SortOrder",
        A1."FormatCode" AS "FormatCode", 
        A1."AcctName" AS "AcctName",
        0 AS "Debit",
        T1."LineTotal" AS "Credit",
        T1."Project"
    FROM {?Schema@}."DRF1" T1
    LEFT JOIN {?Schema@}."OACT" A1 ON T1."AcctCode" = A1."AcctCode"
    WHERE T1."LineTotal" != 0
    
    UNION ALL
    
    SELECT 
        T1."DocEntry",
        3 AS "SortOrder",
        A2."FormatCode" AS "FormatCode", 
        A2."AcctName" AS "AcctName",
        0 AS "Debit",
        T1."VatSum" AS "Credit",
        T1."Project"
    FROM {?Schema@}."DRF1" T1
    LEFT JOIN {?Schema@}."OVTG" V1 ON T1."VatGroup" = V1."Code"
    LEFT JOIN {?Schema@}."OACT" A2 ON V1."Account" = A2."AcctCode"
    WHERE T1."VatSum" > 0
),

Simulated_JE AS (
    SELECT 
        "DocEntry",
        MIN("SortOrder") AS "SortOrder",
        "FormatCode",
        MAX("AcctName") AS "AcctName",
        SUM("Debit") AS "Debit",   
        SUM("Credit") AS "Credit",  
        "Project"
    FROM Raw_JE
    WHERE "FormatCode" IS NOT NULL
    
    GROUP BY "DocEntry", "FormatCode", "Project"
)

SELECT 
    T0."CardCode" AS "Customer Code", 
    T0."CardName" AS "Customer Name", 
    T0."DocEntry",
    T0."CANCELED" AS "สถานะยกเลิก",
    T0."U_SLD_RefDocNo" AS "เลขที่เอกสารอ้างอิง",
    T0."U_SLD_RefDoc" AS "เอกสารอ้างอิง",
    T0."DocDate" AS "วันที่เอกสาร",
    T0."CreateDate" AS "วันที่ทำรายการ",
    JE."FormatCode" AS "รหัสบัญชี",
    JE."AcctName" AS "ชื่อบัญชี",
    JE."Debit" AS "Debit",
    JE."Credit" AS "Credit",
    
    T0."Comments" AS "Remark INV",
    T14."OcrCode3" AS "แผนงาน",
    T14."OcrCode4" AS "สำนัก",
    IFNULL(T6."BeginStr", '') || CAST(T0."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร",
    
    IFNULL(JE."Project", '') AS "ชื่อโครงการ",
    IFNULL(T13."U_U_SLD_Plan", '') AS "แผนงาน_โครงการ",
    
    ps1."descriptio" AS "ตำแหน่งผู้จัดทำ",
    
    CASE 
        WHEN CAST(T2."userId" AS NVARCHAR(50)) IS NULL OR CAST(T2."userId" AS NVARCHAR(50)) = '' 
            THEN  '(                           )'                                         
        ELSE 
            '(' || IFNULL(T2."lastName", '') || ' ' || IFNULL(T2."firstName", '') || ')'  
    END  AS "ชื่อผู้จัดทำ",
    
    CASE 
        WHEN CAST(w1."UserID" AS NVARCHAR(50)) IS NULL OR CAST(w1."UserID" AS NVARCHAR(50)) = '' 
            THEN  '(                           )'                                         
        ELSE 
            '(' || IFNULL(h1."lastName", '') || ' ' || IFNULL(h1."firstName", '') || ')'  
    END  AS "ชื่อผู้ตรวจ",
    p1."descriptio" AS "ตำแหน่งผู้ตรวจ",
    w1."UpdateDate" As "วันที่ผุ้ตรวจ",
    
    CASE 
        WHEN CAST(w2."UserID" AS NVARCHAR(50)) IS NULL OR CAST(w2."UserID" AS NVARCHAR(50)) = '' 
            THEN  '(                           )'                                         
        ELSE 
            '(' || IFNULL(h2."lastName", '') || ' ' || IFNULL(h2."firstName", '') || ')'  
    END  AS "ชื่อผู้อนุมัติ",
    p2."descriptio" AS "ตำแหน่งผู้อนุมัติ",
    w2."UpdateDate" As "วันที่ผุ้อนุมัติ",
    
    NULL AS "ReconNum"

FROM {?Schema@}."ODRF" T0

INNER JOIN Simulated_JE JE ON T0."DocEntry" = JE."DocEntry"

LEFT JOIN {?Schema@}."OHEM" T2   ON T0."OwnerCode" = T2."empID"
LEFT JOIN {?Schema@}."OHPS" ps1  ON T2."position" = ps1."posID"

LEFT JOIN (
    SELECT "DocEntry", MAX("OcrCode3") AS "OcrCode3", MAX("OcrCode4") AS "OcrCode4"
    FROM {?Schema@}."DRF1"
    GROUP BY "DocEntry"
) T14 ON T0."DocEntry" = T14."DocEntry"

LEFT JOIN {?Schema@}."NNM1" T6   ON T0."Series" = T6."Series"
LEFT JOIN {?Schema@}."OPMG" T13  ON JE."Project" = T13."FIPROJECT"

LEFT JOIN {?Schema@}."OWDD" o    ON T0."DocEntry" = o."DocEntry" AND T0."ObjType" = o."ObjType"
LEFT JOIN {?Schema@}."WDD1" w1   ON o."WddCode" = w1."WddCode" AND w1."SortId" = '1' AND w1."Status" = 'Y'
LEFT JOIN {?Schema@}."OUSR" u1   ON w1."UserID" = u1."USERID"
LEFT JOIN {?Schema@}."OHEM" h1   ON u1."USERID" = h1."userId"
LEFT JOIN {?Schema@}."OHPS" p1   ON h1."position" = p1."posID"
LEFT JOIN {?Schema@}."WDD1" w2   ON o."WddCode" = w2."WddCode" AND w2."SortId" = '2' AND w2."Status" = 'Y'
LEFT JOIN {?Schema@}."OUSR" u2   ON w2."UserID" = u2."USERID"
LEFT JOIN {?Schema@}."OHEM" h2   ON u2."USERID" = h2."userId"
LEFT JOIN {?Schema@}."OHPS" p2   ON h2."position" = p2."posID"

WHERE T0."DocEntry" = {?DocKey@}
AND T0."ObjType" = '13'

ORDER BY T0."DocEntry", JE."SortOrder"