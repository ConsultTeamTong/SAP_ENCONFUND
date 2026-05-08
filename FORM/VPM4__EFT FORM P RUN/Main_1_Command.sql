-- ============================================================
-- Report: VPM40002__EFT FORM P RUN.rpt
Path:   VPM40002__EFT FORM P RUN.rpt
Extracted: 2026-05-07 18:04:06
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
     T1."WizardName" AS "Batch Head"
     ,T1."IdNumber"
    ,T3."DocNum" AS "DocNum"
    ,TO_VARCHAR(ADD_YEARS(T1."PmntDate", 543), 'DD.MM.YYYY') AS "วันที่ทำรายการ"
    
    ,T3."CardCode" AS "Vender Code"
    ,T3."CardName" AS "Vender Name"
    ,T3."NumAtCard" AS "Vender Ref"
    ,TO_VARCHAR(ADD_YEARS(T1."NxtPmntDat", 543), 'DD.MM.YYYY') AS "Effective Date"
    ,(T3."DocTotal" - T3."VatSum") AS "Before TAX"
    ,T3."VatSum" AS "TAX"
    ,(T3."DocTotal" + T3."WTSum") AS "Before WTAX"
    ,T3."WTSum" AS "W TAX"
    ,T3."DocTotal" AS "TOTAL"
    ,CONCAT(T7."BeginStr",T3."DocNum") AS "เลขที่เอกสาร(เต็ม)"
    ,T3."BankCode" AS "ธนาคารลูกค้า"
    ,T3."BnkAccount"  AS "เลขที่บัญชีลูกค้า"
    ,T8."AcctName" AS "ชื่อบัญชีลูกค้า"
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
	,T_Period."Category" + 543 AS "Year"
	,IFNULL(NN."BeginStr", '') || CAST(OV."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร out going" 
    ,OP."DflAccount" AS "เลขที่บช.หัวเอกสาร"
FROM "{?Schema@}".OPWZ T1
LEFT JOIN "{?Schema@}".PWZ3 T2 ON T1."IdNumber" = T2."IdEntry"
LEFT JOIN "{?Schema@}".PWZ2 P2 ON T1."IdNumber" = P2."IdEntry"
LEFT JOIN "{?Schema@}".OPYM OP ON P2."PymDisc" = OP."PayMethCod"
LEFT JOIN "{?Schema@}".OPCH T3 ON T2."DocNum" = T3."DocNum"
LEFT JOIN "{?Schema@}".NNM1 T7 ON T3."Series" = T7."Series"
LEFT JOIN "{?Schema@}".OCRB T8 ON T3."BnkAccount" = T8."Account"
LEFT JOIN {?Schema@}."OUSR" T9 ON T1."UserSign" = T9."USERID"
LEFT JOIN {?Schema@}."OHEM" T10 ON T9."USERID" = T10."userId"
LEFT JOIN {?Schema@}.VPM2 V1 ON T3."DocEntry" = V1."DocEntry"
LEFT JOIN {?Schema@}.OVPM OV ON V1."DocNum" = OV."DocEntry"
LEFT JOIN {?Schema@}."NNM1" NN on OV."Series" = NN."Series"
LEFT JOIN "{?Schema@}".OFPR T_Period 
    ON T1."PmntDate" BETWEEN T_Period."F_RefDate" AND T_Period."T_RefDate"

WHERE 1=1
AND T1."Status" = 'E' --RUN 
AND P2."PymCode" = '{?PymCode@}' --เลือก Payment Method
--AND T1."PmntDate" >= {?DateFrom} AND T1."PmntDate" <= {?DateTo} --ช่วงวันที่
