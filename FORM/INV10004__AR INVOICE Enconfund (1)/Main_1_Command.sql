-- ============================================================
-- Report: INV10004__AR INVOICE Enconfund (1).rpt
Path:   INV10004__AR INVOICE Enconfund (1).rpt
Extracted: 2026-05-07 18:03:04
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
    T0."CardCode" AS "Customer Code", 
    T0."CardName" AS "Customer Name", 
    T0."DocEntry",
    T0."CANCELED" AS "สถานะยกเลิก",
    T0."U_SLD_RefDocNo" AS "เลขที่เอกสารอ้างอิง",
    T0."U_SLD_RefDoc" AS "เอกสารอ้างอิง",
    T0."DocDate" AS "วันที่เอกสาร",
    T0."CreateDate" AS "วันที่ทำรายการ",
    ACCT."FormatCode" AS "รหัสบัญชี",
    ACCT."AcctName" AS "ชื่อบัญชี",
    IFNULL(LINE."Debit", 0) AS "Debit",
    IFNULL(LINE."Credit", 0) AS "Credit",
    T0."Comments" AS "Remark INV",
    T14."OcrCode3" AS "แผนงาน",
    T14."OcrCode4" AS "สำนัก"
   ,
    IFNULL(T6."BeginStr", '') || CAST(T0."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร",
    IFNULL(MAX(LINE."Project") OVER (PARTITION BY T0."DocEntry"), '') AS "ชื่อโครงการ",
    IFNULL(MAX(T13."U_U_SLD_Plan") OVER (PARTITION BY T0."DocEntry"), '') AS "แผนงาน",
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
    w1."CreateDate" As "วันที่ผุ้ตรวจ",
   CASE 
    WHEN CAST(w2."UserID" AS NVARCHAR(50)) IS NULL OR CAST(w2."UserID" AS NVARCHAR(50)) = '' 
        THEN  '(                           )'                                         
    ELSE 
        '(' || IFNULL(h2."lastName", '') || ' ' || IFNULL(h2."firstName", '') || ')'  
END  AS "ชื่อผู้อนุมัติ",
    p2."descriptio" AS "ตำแหน่งผู้อนุมัติ",
	w2."CreateDate" As "วันที่ผุ้อนุมัติ",
	RC."ReconNum"
FROM {?Schema@}."OINV" T0
LEFT JOIN {?Schema@}."OJDT" HEAD 
       ON T0."TransId" = HEAD."TransId" 
      AND T0."TransId" IS NOT NULL   -- ป้องกัน join กับ TransId ที่เป็น NULL
LEFT JOIN {?Schema@}."JDT1" LINE 
       ON HEAD."TransId" = LINE."TransId" 
      AND (IFNULL(LINE."Debit", 0) != 0 OR IFNULL(LINE."Credit", 0) != 0)
LEFT JOIN {?Schema@}."ITR1" RC ON HEAD."TransId" = RC."TransId" AND LINE."Line_ID" = RC."TransRowId" 
LEFT JOIN {?Schema@}."OACT" ACCT ON LINE."Account" = ACCT."AcctCode"
LEFT JOIN {?Schema@}."OHEM" T2   ON T0."OwnerCode" = T2."empID"
LEFT JOIN {?Schema@}."OHPS" ps1  ON T2."position" = ps1."posID"
LEFT JOIN (
    SELECT "DocEntry", MAX("OcrCode3") AS "OcrCode3", MAX("OcrCode4") AS "OcrCode4"
    FROM {?Schema@}."INV1"
    GROUP BY "DocEntry"
) T14 ON T0."DocEntry" = T14."DocEntry"
LEFT JOIN {?Schema@}."NNM1" T6   ON T0."Series" = T6."Series"
LEFT JOIN {?Schema@}."OPMG" T13  ON LINE."Project" = T13."FIPROJECT"
LEFT JOIN {?Schema@}."OWDD" o    ON T0."DocEntry" = o."DocEntry" 
                                AND T0."ObjType" = o."ObjType"
LEFT JOIN {?Schema@}."WDD1" w1   ON o."WddCode" = w1."WddCode" 
                                AND w1."SortId" = '1' 
                                AND w1."Status" = 'Y'
LEFT JOIN {?Schema@}."OUSR" u1   ON w1."UserID" = u1."USERID"
LEFT JOIN {?Schema@}."OHEM" h1   ON u1."USERID" = h1."userId"
LEFT JOIN {?Schema@}."OHPS" p1   ON h1."position" = p1."posID"
LEFT JOIN {?Schema@}."WDD1" w2   ON o."WddCode" = w2."WddCode" 
                                AND w2."SortId" = '2' 
                                AND w2."Status" = 'Y'
LEFT JOIN {?Schema@}."OUSR" u2   ON w2."UserID" = u2."USERID"
LEFT JOIN {?Schema@}."OHEM" h2   ON u2."USERID" = h2."userId"
LEFT JOIN {?Schema@}."OHPS" p2   ON h2."position" = p2."posID"
WHERE T0."DocEntry" = {?DocKey@}
