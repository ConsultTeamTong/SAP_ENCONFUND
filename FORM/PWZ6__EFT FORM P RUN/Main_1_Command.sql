-- ============================================================
-- Report: PWZ60002__EFT FORM P RUN.rpt
Path:   PWZ60002__EFT FORM P RUN.rpt
Extracted: 2026-05-07 18:03:28
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
     T1."WizardName" AS "Batch Head"
     ,T1."Status"
     ,OV."Canceled"
     ,T1."IdNumber"
     ,T2."InvKey"
     ,OV."DocEntry"
     ,P2."PymDisc"
    ,T3."DocNum" AS "DocNum"
    ,TO_VARCHAR(ADD_YEARS(T1."PmntDate", 543), 'DD.MM.YYYY') AS "วันที่ทำรายการ"
    ,T3."CardCode" AS "Vender Code"
    ,T3."CardName" AS "Vender Name"
    ,T3."NumAtCard" AS "Vender Ref"
    ,TO_VARCHAR(ADD_YEARS(T1."NxtPmntDat", 543), 'DD.MM.YYYY') AS "Effective Date"
    ,(T3."DocTotal" - T3."VatSum") AS "Before TAX"
    ,T3."VatSum" AS "TAX"
    ,(T3."DocTotal" + T3."WTSum") AS "Before WTAX"
    ,IFNULL(T11."WTAmnt",0) AS "W TAX"
    ,IFNULL(T12."WTAmnt",0) AS "WI"
    ,T3."DocTotal" AS "TOTAL"
    ,CONCAT(T7."BeginStr",T3."DocNum") AS "เลขที่เอกสาร(เต็ม)"
    ,CASE WHEN IFNULL(T3."BankCode",'') = ''  THEN CD."BankCode" ELSE T3."BankCode" END AS "ธนาคารลูกค้า"
    ,CASE WHEN IFNULL(T3."BnkAccount",'') = ''  THEN CD."DflAccount" ELSE T3."BnkAccount" END AS "เลขที่บัญชีลูกค้า" 
    ,CASE WHEN IFNULL(T8."AcctName",'') = ''  THEN T9."AcctName" ELSE T8."AcctName" END AS  "ชื่อบัญชีลูกค้า"
    ,IFNULL(T10."firstName", '') || ' ' || IFNULL(T10."lastName", '') AS "ชื่อผู้จัดทำ"
    ,CASE TO_VARCHAR(T1."PmntDate", 'MM')
        WHEN '01' THEN 'มกราคม'
        WHEN '02' THEN 'กุมภาพันธ์'
        WHEN '03' THEN 'มีนาคม'
        WHEN '04' THEN 'เมษายน'
        WHEN '05' THEN 'พฤษภาคม'
        WHEN '06' THEN 'มิถุนายน'
        WHEN '07' THEN 'กรกฎาคม'
        WHEN '08' THEN 'สิงหาคม'
        WHEN '09' THEN 'กันยายน'
        WHEN '10' THEN 'ตุลาคม'
        WHEN '11' THEN 'พฤศจิกายน'
        WHEN '12' THEN 'ธันวาคม'
        ELSE ''
    END AS "เดือน (ภาษาไทย)"    
    ,TO_INTEGER(T_Period."Category") + 543 AS "Year"
    ,IFNULL(NN."BeginStr", '') || TO_VARCHAR(OV."DocNum") AS "เลขที่เอกสาร out going" 
    ,OP."DflAccount" AS "เลขที่บช.หัวเอกสาร"
FROM "{?Schema@}".OPWZ T1
LEFT JOIN "{?Schema@}".PWZ3 T2 ON T1."IdNumber" = T2."IdEntry" 
LEFT JOIN "{?Schema@}".PWZ2 P2 ON T1."IdNumber" = P2."IdEntry" AND P2."Checked" = 'Y' 
LEFT JOIN "{?Schema@}".OPYM OP ON P2."PymDisc" = OP."PayMethCod"
LEFT JOIN "{?Schema@}".OPCH T3 ON T2."InvKey" = T3."DocEntry" 
LEFT JOIN "{?Schema@}".NNM1 T7 ON T3."Series" = T7."Series"
LEFT JOIN "{?Schema@}".OCRB T8 ON T3."BnkAccount" = T8."Account"
LEFT JOIN {?Schema@}."OUSR" U1 ON T1."UserSign" = U1."USERID"
LEFT JOIN {?Schema@}."OHEM" T10 ON U1."USERID" = T10."userId"
LEFT JOIN (SELECT OV.*,V1."DocEntry" AS "InvKey" FROM {?Schema@}.OVPM OV INNER JOIN {?Schema@}.VPM2 V1 ON V1."DocNum" = OV."DocEntry" WHERE OV."Canceled" = 'N') AS OV ON T2."InvKey" = OV."InvKey"
--LEFT JOIN {?Schema@}.VPM2 V1 ON T2."InvKey" = V1."DocEntry"
--LEFT JOIN {?Schema@}.OVPM OV ON V1."DocNum" = OV."DocEntry" --AND OV."Canceled" = 'N'
LEFT JOIN {?Schema@}."NNM1" NN ON OV."Series" = NN."Series"
LEFT JOIN "{?Schema@}".OFPR T_Period ON T1."PmntDate" BETWEEN T_Period."F_RefDate" AND T_Period."T_RefDate"
LEFT JOIN {?Schema@}.OCRD CD ON T3."CardCode" = CD."CardCode"
LEFT JOIN "{?Schema@}".OCRB T9 ON CD."CardCode" = T9."CardCode" AND CD."DflAccount" = T9."Account"
LEFT JOIN "{?Schema@}".PCH5 T11 ON T2."InvKey" = T11."AbsEntry" AND T11."WTCode" <> 'WI05'
LEFT JOIN "{?Schema@}".PCH5 T12 ON T2."InvKey" = T12."AbsEntry" AND T12."WTCode" = 'WI05'
WHERE 1=1
AND T1."Status" IN ('E','D')
--AND (OV."Canceled" = 'N' OR IFNULL(OV."Canceled",'P') = 'P')
AND T1."IdNumber" = {?Dockey@}
AND T1."Canceled" = 'N'
ORDER BY IFNULL(NN."BeginStr", '') || TO_VARCHAR(OV."DocNum")
