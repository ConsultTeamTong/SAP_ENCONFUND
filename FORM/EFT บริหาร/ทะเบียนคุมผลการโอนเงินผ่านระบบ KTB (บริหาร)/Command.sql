-- ============================================================
-- Report: ทะเบียนคุมผลการโอนเงินผ่านระบบ KTB (บริหาร).rpt
Path:   FORM\EFT บริหาร\ทะเบียนคุมผลการโอนเงินผ่านระบบ KTB (บริหาร).rpt
Extracted: 2026-07-01 09:28:05
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
    -- 1. ข้อมูลส่วนหัว Wizard และสถานะ
    T1."WizardName" AS "Batch Head",
    T1."Status",
    T11."Canceled" AS "Canceled",
    T1."IdNumber",
    T2."InvKey",
    T11."DocEntry" AS "DocEntry",
    P2."PymDisc",

    -- 2. เลขที่เอกสาร AP Invoice
    T3."DocNum" AS "DocNum",
    CAST(IFNULL(T7."BeginStr", '') || TO_VARCHAR(T3."DocNum") AS NVARCHAR(50)) AS "เลขที่เอกสาร(เต็ม)",
    
    -- 3. วันที่และเดือน (ภาษาไทย + พ.ศ.)
    T1."PmntDate" AS "วันที่ทำรายการ",
    CASE TO_VARCHAR(T1."PmntDate", 'MM')
        WHEN '01' THEN 'มกราคม' WHEN '02' THEN 'กุมภาพันธ์' WHEN '03' THEN 'มีนาคม'
        WHEN '04' THEN 'เมษายน' WHEN '05' THEN 'พฤษภาคม' WHEN '06' THEN 'มิถุนายน'
        WHEN '07' THEN 'กรกฎาคม' WHEN '08' THEN 'สิงหาคม' WHEN '09' THEN 'กันยายน'
        WHEN '10' THEN 'ตุลาคม' WHEN '11' THEN 'พฤศจิกายน' WHEN '12' THEN 'ธันวาคม'
        ELSE ''
    END AS "เดือน (ภาษาไทย)",
    TO_INTEGER(T_Period."Category") + 543 AS "Year",
    IFNULL(T1."NxtPmntDat", T1."PmntDate") AS "Effective Date",

    -- 4. ข้อมูลคู่ค้า (Vendor)
    T3."CardCode" AS "Vender Code",
    T3."CardName" AS "Vender Name",
    T3."NumAtCard" AS "Vender Ref",
    CAST(T3."U_SLD_Document_Number" AS NVARCHAR(100)) AS "U_SLD_Document_Number",
    CAST(T3."U_SLD_Remark" AS NVARCHAR(254)) AS "U_SLD_Remark",

    -- 5. ข้อมูลจำนวนเงิน
    (T3."DocTotal" - T3."VatSum") AS "Before TAX",
    T3."VatSum" AS "TAX",
    (T3."DocTotal" + T3."WTSum") AS "Before WTAX",
    IFNULL((SELECT SUM(W1."WTAmnt") FROM {?Schema@}.PCH5 W1 WHERE W1."AbsEntry" = T3."DocEntry" AND W1."WTCode" <> 'WI05'), 0) AS "W TAX",
    IFNULL((SELECT SUM(W2."WTAmnt") FROM {?Schema@}.PCH5 W2 WHERE W2."AbsEntry" = T3."DocEntry" AND W2."WTCode" = 'WI05'), 0) AS "WI",
    T3."DocTotal" AS "TOTAL",

    -- 6. ข้อมูลธนาคาร (ฝั่งลูกค้า/Vendor)
    COALESCE(NULLIF(T3."BankCode", ''), CD."BankCode") AS "ธนาคารลูกค้า",
    COALESCE(NULLIF(T3."BnkAccount", ''), CD."DflAccount") AS "เลขที่บัญชีลูกค้า", 
    CAST(COALESCE(NULLIF(T8."AcctName", ''), T9."AcctName") AS NVARCHAR(254)) AS "ชื่อบัญชีลูกค้า",
	T9."SwiftNum",
	T9."Branch",
	(T_Period."Category"+543) AS "Category",
    -- 7. ธนาคารฝั่งเรา (ธนาคารที่เอาเงินออก)
    OP."DflAccount" AS "เลขที่บช.หัวเอกสาร",

    -- 8. ข้อมูล Outgoing Payment และผู้จัดทำ
    T11."เลขที่เอกสาร out going",
    IFNULL(T10."lastName", '') || ' ' || IFNULL(T10."firstName", '') AS "ชื่อผู้จัดทำ"

FROM {?Schema@}.OPWZ T1
INNER JOIN {?Schema@}.PWZ3 T2 ON T1."IdNumber" = T2."IdEntry" 
INNER JOIN {?Schema@}.OPCH T3 ON T2."InvKey" = T3."DocEntry"
LEFT JOIN {?Schema@}.PWZ2 P2 ON T1."IdNumber" = P2."IdEntry" AND P2."Checked" = 'Y' 
LEFT JOIN {?Schema@}.OPYM OP ON P2."PymDisc" = OP."PayMethCod"
LEFT JOIN {?Schema@}.NNM1 T7 ON T3."Series" = T7."Series"
LEFT JOIN {?Schema@}.OCRD CD ON T3."CardCode" = CD."CardCode"
LEFT JOIN {?Schema@}.OCRB T8 ON T3."BnkAccount" = T8."Account" AND T3."CardCode" = T8."CardCode"
LEFT JOIN {?Schema@}.OCRB T9 ON CD."CardCode" = T9."CardCode" AND CD."DflAccount" = T9."Account"
LEFT JOIN {?Schema@}.OUSR U1 ON T1."UserSign" = U1."USERID"
LEFT JOIN {?Schema@}.OHEM T10 ON U1."USERID" = T10."userId"
LEFT JOIN {?Schema@}.OFPR T_Period ON T1."PmntDate" BETWEEN T_Period."F_RefDate" AND T_Period."T_RefDate"
-- Join ข้อมูลการจ่ายเงิน (Outgoing Payment)
LEFT JOIN (
    SELECT 
        V1."DocEntry" AS "InvKey", 
        OV."DocEntry",
        OV."Canceled",
        OV."Series",
        IFNULL(NN."BeginStr", '') || TO_VARCHAR(OV."DocNum") AS "เลขที่เอกสาร out going"
    FROM {?Schema@}.OVPM OV
    INNER JOIN {?Schema@}.VPM2 V1 ON V1."DocNum" = OV."DocEntry"
    LEFT JOIN {?Schema@}.NNM1 NN ON OV."Series" = NN."Series"
    WHERE OV."Canceled" = 'N' AND V1."InvType" = 18
) T11 ON T3."DocEntry" = T11."InvKey"

WHERE T1."IdNumber" = {?Dockey@}
  AND T1."Status" IN ('E','D')
  AND T1."Canceled" = 'N'

ORDER BY T11."เลขที่เอกสาร out going" ASC, T3."DocNum" ASC;
