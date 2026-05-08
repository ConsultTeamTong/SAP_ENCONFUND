-- ============================================================
-- Report: PCH10002__APInvoice Enconfund.rpt
Path:   PCH10002__APInvoice Enconfund.rpt
Extracted: 2026-05-07 18:03:16
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
    T0."CardCode" AS "Vender",
    T0."CardName" AS "Vender Name",
 	TO_VARCHAR(ADD_YEARS(T0."DocDate", 543), 'DD.MM.YYYY') AS "DateThai",
    IFNULL(T7."BeginStr", '') || CAST(HEAD."Number" AS NVARCHAR(20)) AS "เลขที่เอกสาร JE",
T0."U_SLD_RefDocNo" AS "เอกสารอ้างอิง",
T0."U_SLD_RefDoc" AS "เลขที่เอกสารอ้างอิง",
    ACCT."FormatCode" AS "รหัสบัญชี",
    ACCT."AcctName" AS "ชื่อบัญชี",
    LINE."Debit",
    LINE."Credit",
    T0."Comments" AS "Remark INV",
    IFNULL(T6."BeginStr", '') ||  CAST(T0."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร",
    CASE 
        WHEN T0."ObjType" = '18' THEN 'A/P INVOICE'
    END AS "เอกสารนอ้างอิง",
    IFNULL(T2."firstName", '') || ' ' || IFNULL(T2."lastName", '') AS "ชื่อผู้จัดทำ",
    
    --T_Bridge."U_U_SLD_Plan" AS "แผนงาน",
    T0."Project" AS "ชื่อโครงการ",
    T0."NumAtCard" AS "งวด",
    T0."DocEntry",
	T13."U_SLD_ProjectName" AS "PrjName",
	T_Bridge."OcrCode3" as "แผนงาน",
	T_Bridge."OcrCode4" as "สำนัก"
	
FROM "{?Schema@}"."OPCH" T0
INNER JOIN "{?Schema@}"."OJDT" HEAD ON T0."TransId" = HEAD."TransId"
INNER JOIN "{?Schema@}"."JDT1" LINE ON HEAD."TransId" = LINE."TransId"
LEFT JOIN "{?Schema@}"."OACT" ACCT ON LINE."Account" = ACCT."AcctCode"
LEFT JOIN "{?Schema@}"."OUSR" T1 ON T0."UserSign" = T1."USERID"
LEFT JOIN "{?Schema@}"."OHEM" T2 ON T1."USERID" = T2."userId"
INNER JOIN "{?Schema@}"."NNM1" T6 ON T0."Series" = T6."Series"
LEFT JOIN "{?Schema@}"."NNM1" T7 ON HEAD."Series" = T7."Series"
LEFT JOIN "{?Schema@}"."INV12" T12 ON T0."DocEntry" = T12."DocEntry"
LEFT JOIN "{?Schema@}"."OPRJ" T13 ON T0."Project" = T13."PrjCode"
LEFT JOIN (
    SELECT 
        T_Line."DocEntry",
        T_Line."Project",
        PMG1."UniqueID",
        T13."U_U_SLD_Plan",
       PCH1."OcrCode3",
       PCH1."OcrCode4"
        
        
    FROM "{?Schema@}"."OPCH" T_Line
    LEFT JOIN "{?Schema@}"."PCH1" PCH1 ON T_Line."DocEntry" = PCH1."DocEntry"
    LEFT JOIN "{?Schema@}"."OPMG" T13 ON T_Line."Project" = T13."NAME"
    LEFT JOIN "{?Schema@}"."PMG4" PMG4 ON T_Line."DocEntry" = PMG4."DocEntry"
    LEFT JOIN "{?Schema@}"."PMG1" PMG1 ON PMG4."AbsEntry" = PMG1."AbsEntry" 
          AND PMG4."StageID" = PMG1."LineID"
) T_Bridge ON T0."DocEntry" = T_Bridge."DocEntry"

WHERE (LINE."Debit" != 0 OR LINE."Credit" != 0)
AND T0."DocEntry" = {?DocKey@}


