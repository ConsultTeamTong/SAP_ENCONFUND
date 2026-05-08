-- ============================================================
-- Report: PCH20002__AP Invoice Enconfund.rpt
Path:   PCH20002__AP Invoice Enconfund.rpt
Extracted: 2026-05-07 18:03:17
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
    T0."CardCode" AS "Vender",
    T0."CardName" AS "Vender Name",
    T0."DocDate" AS "DateThai",
    T0."CreateDate" AS "วันที่ทำรายการ",
    IFNULL(T7."BeginStr", '') || CAST(HEAD."Number" AS NVARCHAR(20)) AS "เลขที่เอกสาร JE",
    T0."U_SLD_RefDocNo" AS "เลขที่เอกสารอ้างอิง",
    T0."U_SLD_RefDoc" AS "เอกสารอ้างอิง",
    ACCT."FormatCode" AS "รหัสบัญชี",
    ACCT."AcctName" AS "ชื่อบัญชี",
    LINE."Debit",
    LINE."Credit",
    T0."Comments" AS "Remark INV",
    IFNULL(T6."BeginStr", '') ||  CAST(T0."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร",
    CASE 
        WHEN T0."ObjType" = '18' THEN 'A/P INVOICE'
    END AS "ประเภทเอกสาร", 
    T2."lastName" || ' ' || T2."firstName" AS "ชื่อผู้จัดทำ",
    p1."descriptio" AS "ตำแหน่งผู้จัดทำ",   
    T0."Project" AS "ชื่อโครงการ",
    T0."NumAtCard" AS "งวด",
    T0."DocEntry",
    T13."U_SLD_ProjectName" AS "PrjName",
    T_Bridge."OcrCode3" AS "แผนงาน",
    T_Bridge."OcrCode4" AS "สำนัก",
    APPR."ชื่อผู้ตรวจ",
    APPR."ตำแหน่งผู้ตรวจ",
    APPR."เวลาผู้ตรวจ",
    APPR."ชื่อผู้อนุมัติ",
    APPR."ตำแหน่งผู้อนุมัติ",
    APPR."เวลาผู้อนุมัติ",
    RC."ReconNum" 
FROM {?Schema@}."OPCH" T0
INNER JOIN {?Schema@}."OJDT" HEAD ON T0."TransId" = HEAD."TransId"
INNER JOIN {?Schema@}."JDT1" LINE ON HEAD."TransId" = LINE."TransId"
LEFT JOIN "{?Schema@}"."ITR1" RC ON HEAD."TransId" = RC."TransId" AND LINE."Line_ID" = RC."TransRowId" 
LEFT JOIN {?Schema@}."OACT" ACCT ON LINE."Account" = ACCT."AcctCode"
LEFT JOIN {?Schema@}."OHEM" T2 ON T0."OwnerCode" = T2."empID"
LEFT JOIN {?Schema@}."OHPS" p1   ON T2."position" = p1."posID"
INNER JOIN {?Schema@}."NNM1" T6 ON T0."Series" = T6."Series"
LEFT JOIN {?Schema@}."NNM1" T7 ON HEAD."Series" = T7."Series"
LEFT JOIN {?Schema@}."INV12" T12 ON T0."DocEntry" = T12."DocEntry"
LEFT JOIN {?Schema@}."OPRJ" T13 ON T0."Project" = T13."PrjCode"
LEFT JOIN (
    SELECT 
        T_Line."DocEntry",
        MAX(T_Line."Project") AS "Project",
        MAX(PMG1."UniqueID") AS "UniqueID",
        MAX(T13."U_U_SLD_Plan") AS "U_U_SLD_Plan",
        MAX(PCH1."OcrCode3") AS "OcrCode3",
        MAX(PCH1."OcrCode4") AS "OcrCode4"
    FROM {?Schema@}."OPCH" T_Line
    LEFT JOIN {?Schema@}."PCH1" PCH1 ON T_Line."DocEntry" = PCH1."DocEntry"
    LEFT JOIN {?Schema@}."OPMG" T13 ON T_Line."Project" = T13."NAME"
    LEFT JOIN {?Schema@}."PMG4" PMG4 ON T_Line."DocEntry" = PMG4."DocEntry"
    LEFT JOIN {?Schema@}."PMG1" PMG1 ON PMG4."AbsEntry" = PMG1."AbsEntry" 
          AND PMG4."StageID" = PMG1."LineID"
    GROUP BY T_Line."DocEntry"
) T_Bridge ON T0."DocEntry" = T_Bridge."DocEntry"
LEFT JOIN (
    SELECT 
        o."DocEntry", 
        o."ObjType",
        MAX(CASE WHEN w."SortId" = '1' AND w."Status" = 'Y' THEN oh."lastName" || ' ' || oh."firstName" END) AS "ชื่อผู้ตรวจ",
        MAX(CASE WHEN w."SortId" = '1' AND w."Status" = 'Y' THEN ps."name" END) AS "ตำแหน่งผู้ตรวจ",
        MAX(CASE WHEN w."SortId" = '1' AND w."Status" = 'Y' THEN w."CreateDate" END) AS "เวลาผู้ตรวจ",
        MAX(CASE WHEN w."SortId" = '2' AND w."Status" = 'Y' THEN oh."lastName" || ' ' || oh."firstName" END) AS "ชื่อผู้อนุมัติ",
        MAX(CASE WHEN w."SortId" = '2' AND w."Status" = 'Y' THEN ps."name" END) AS "ตำแหน่งผู้อนุมัติ",
        MAX(CASE WHEN w."SortId" = '2' AND w."Status" = 'Y' THEN w."CreateDate" END) AS "เวลาผู้อนุมัติ"
    FROM {?Schema@}."OWDD" o 
    INNER JOIN {?Schema@}."WDD1" w ON o."WddCode" = w."WddCode"
    LEFT JOIN {?Schema@}."OUSR" o2 ON w."UserID" = o2."USERID"
    LEFT JOIN {?Schema@}."OHEM" oh ON o2."USERID" = oh."userId"
    LEFT JOIN {?Schema@}."OHPS" ps ON oh."position" = ps."posID"
    GROUP BY o."DocEntry", o."ObjType"
) APPR ON T0."DocEntry" = APPR."DocEntry" AND T0."ObjType" = APPR."ObjType"
WHERE (LINE."Debit" != 0 OR LINE."Credit" != 0)
AND T0."DocEntry" = {?DocKey@}
