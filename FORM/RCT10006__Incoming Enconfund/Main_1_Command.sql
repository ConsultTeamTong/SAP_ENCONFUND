-- ============================================================
-- Report: RCT10006__Incoming Enconfund.rpt
Path:   RCT10006__Incoming Enconfund.rpt
Extracted: 2026-05-07 18:03:46
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
    T9."CardName" AS "Custommers / Vender",
        T0."DocDate" AS "DateThai",
     T16."BankName",
    T0."Comments" AS "Remark",
T0."DocType",
    IFNULL(T6."BeginStr", '') || CAST(T0."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร", 
    CASE WHEN T0."TrsfrSum" > 0 THEN T16."BankName" ELSE '' END AS "บัญชี CUS/VENDER",
    CASE WHEN T0."TrsfrSum" > 0 THEN T9."DflBranch" ELSE '' END AS "สาขาบัญชี CUS/VENDER",
    CASE WHEN T0."TrsfrSum" > 0 THEN T9."DflAccount" ELSE '' END AS "เลขบัญชี CUS/VENDER", 
    CASE WHEN T0."TrsfrSum" > 0 THEN T15."AcctName" ELSE '' END AS "ชื่อบัญชี CUS/VENDER",
    
    T0."TrsfrDate" AS "วันที่โอน (เฉพาะโอน)",
    CASE  WHEN     T0."DocType" ='A' THEN ''
    ELSE T0."CardCode" END AS "รหัสCUS/VEN",
 
    CASE 
        WHEN T0."CashSum" > 0 THEN Bank_Cash."BankName"      
        WHEN T0."TrsfrSum" > 0 THEN Bank_Trsfr."BankName"    
        ELSE T19."BankName"                                  
    END AS "ธนาคารเรา",
    
    CASE 
        WHEN T0."CashSum" > 0 THEN DSC_Cash."Branch"
        WHEN T0."TrsfrSum" > 0 THEN DSC_Trsfr."Branch"
        ELSE '' 
    END AS "สาขาเรา",
    
    CASE 
        WHEN T0."CashSum" > 0 THEN DSC_Cash."Account"
        WHEN T0."TrsfrSum" > 0 THEN DSC_Trsfr."Account"
        ELSE '' 
    END AS "เลขที่บัญชีเรา",
    
    CASE  
        WHEN T14."CheckNum" IS NOT NULL THEN 'X'
        ELSE ''
    END AS "ติ๊ก Check",
    
     CASE 
        WHEN T0."DataSource" = 'A' AND T0."Canceled" = 'N'  THEN 'X'
        WHEN T0."TrsfrSum" > 0 AND T0."DataSource" <> 'A'  THEN 'X'
        ELSE ''
    END AS "ติ๊ก ตัดอัตโนมัติ", 
    
    T_CheckBank."BankName" AS "ชื่อธนาคาร (เช็ค)",
    T14."Branch" AS "สาขา ธนาคาร (เช็ค)" ,
    T14."AcctNum" AS "เลขที่บีญชี (เช็ค)",
    T14."CheckNum" AS "เลขที่ (เช็ค)",
    IFNULL(T2."firstName", '') || ' ' || IFNULL(T2."lastName", '') AS "ชื่อผู้จัดทำ",
    T0."DocEntry",
    
    INV_INFO."PROJECT" AS "Project", 
    INV_INFO."NumAtCard_Agg" AS "งวด",
    T_Prj."PrjName" AS "PrjName",

    CASE 
        WHEN T0."DataSource" = 'A' AND T0."Canceled" = 'N' 
        THEN TRIM(SUBSTR_AFTER(SUBSTR_AFTER(T0."JrnlMemo", '-'), '-')) 
        ELSE '' 
    END AS "ที่มาเอกสาร / Wizard Name",
    
    -- 🔽 [จุดที่แก้ไข] รวบเงื่อนไขการดึงชื่อบัญชี (AcctName) ให้จบในฟิลด์เดียว
    CASE 
        WHEN T0."DocType" = 'A' AND OACT2."AcctName" IS NOT NULL THEN OACT2."AcctName" 
        WHEN T0."DocType" <> 'A' AND T0."TrsfrSum" > 0 THEN OACT_Trsfr."AcctName"
        ELSE '' 
    END AS "ชื่อบัญชี / G_L Account",
    DSC_Trsfr."AcctName" AS "ชื่อบัญชีธนาคาร",
    T0."DocType",
    OPRJ."U_SLD_ProjectName",
    T0."DocEntry",
VPM3."CreditCard",
TO_VARCHAR(ADD_YEARS(T0."CreateDate", 543), 'DD.MM.YYYY') AS "วันที่ทำรายการ",
VPM3."CreditSum"
FROM {?Schema@}."ORCT" T0
LEFT JOIN {?Schema@}."OUSR" T1 ON T0."UserSign" = T1."USERID"
LEFT JOIN {?Schema@}."OHEM" T2 ON T1."USERID" = T2."userId"
LEFT JOIN {?Schema@}."NNM1" T6 on T0."Series" = T6."Series"

LEFT JOIN {?Schema@}."RCT2" VPM2 on T0."DocEntry" = VPM2."DocNum"
LEFT JOIN {?Schema@}."RCT3" VPM3 on T0."DocEntry" = VPM3."DocNum"
LEFT JOIN {?Schema@}."OINV" OPCH on VPM2."DocEntry" = OPCH."DocEntry"
LEFT JOIN {?Schema@}."OPRJ" OPRJ on OPCH."Project" = OPRJ."PrjCode"

LEFT JOIN {?Schema@}."RCT1" T14 ON T0."DocEntry" = T14."DocNum"
LEFT JOIN {?Schema@}."OACT" T8 ON T14."CheckAct" = T8."AcctCode" 
LEFT JOIN {?Schema@}."ODSC" T_CheckBank ON T14."BankCode" = T_CheckBank."BankCode"

LEFT JOIN {?Schema@}."OCRD" T9 ON T0."CardCode" = T9."CardCode"
LEFT JOIN {?Schema@}."OCRB" T15 ON T9."CardCode" = T15."CardCode"
    AND T9."BankCode" = T15."BankCode" 
    AND T9."DflAccount" = T15."Account"
LEFT JOIN {?Schema@}."ODSC" T16 ON T15."BankCode" = T16."BankCode"

LEFT JOIN {?Schema@}."OPYM" T18 ON T0."PayMth" = T18."PayMethCod"
LEFT JOIN {?Schema@}."ODSC" T19 ON T18."BnkDflt" = T19."BankCode"

LEFT JOIN {?Schema@}."DSC1" DSC_Cash ON T0."CashAcct" = DSC_Cash."GLAccount"
LEFT JOIN {?Schema@}."ODSC" Bank_Cash ON DSC_Cash."BankCode" = Bank_Cash."BankCode"
LEFT JOIN {?Schema@}."DSC1" DSC_Trsfr ON T0."TrsfrAcct" = DSC_Trsfr."GLAccount"
LEFT JOIN {?Schema@}."ODSC" Bank_Trsfr ON DSC_Trsfr."BankCode" = Bank_Trsfr."BankCode"

-- 🔽 [เพิ่ม JOIN] วิ่งไปเอาชื่อผังบัญชีฝั่งธนาคารเรามาให้ (เผื่อกรณีโอนเงินจ่าย Supplier)
LEFT JOIN {?Schema@}."OACT" OACT_Trsfr ON T0."TrsfrAcct" = OACT_Trsfr."AcctCode"

LEFT JOIN {?Schema@}."RCT4" VPM4 ON T0."DocEntry" = VPM4."DocNum"
LEFT JOIN {?Schema@}."OACT" OACT2 ON VPM4."AcctCode" = OACT2."AcctCode"

LEFT JOIN (
    SELECT 
        T7."DocNum" AS "PayDocKey",
        STRING_AGG(TO_VARCHAR(T_AP."NumAtCard"), ', ') AS "NumAtCard_Agg",
        MAX(PG_SUB."U_U_SLD_Plan") AS "PlanName", 
        '' AS "RefInvoiceJE",
        IFNULL(MAX(PG_SUB."Project"), MAX(T_AP."Project")) AS "PROJECT"    
    FROM {?Schema@}."RCT2" T7
    INNER JOIN {?Schema@}."OINV" T_AP ON T7."DocEntry" = T_AP."DocEntry" AND T7."InvType" = '18' 
    
    LEFT JOIN (
        SELECT DISTINCT 
            T_Line."DocEntry",
            T13."U_U_SLD_Plan",
            T_Line."Project"
        FROM {?Schema@}.OPCH T_Line
        LEFT JOIN {?Schema@}."OPMG" T13 ON T_Line."Project" = T13."NAME"
        LEFT JOIN {?Schema@}."PMG4" PMG4 ON T_Line."DocEntry" = PMG4."DocEntry"
        LEFT JOIN {?Schema@}."PMG1" PMG1 ON PMG4."AbsEntry" = PMG1."AbsEntry" 
    ) PG_SUB ON PG_SUB."DocEntry" = T_AP."DocEntry"
    
    GROUP BY T7."DocNum"
) INV_INFO ON T0."DocEntry" = INV_INFO."PayDocKey"

LEFT JOIN {?Schema@}."OPRJ" T_Prj ON INV_INFO."PROJECT" = T_Prj."PrjCode"

WHERE T0."DocEntry" = {?DocKey@}
