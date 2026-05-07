-- ============================================================
-- Report: VPM10004__Outgoing Enconfund.rpt
Path:   VPM10004__Outgoing Enconfund.rpt
Extracted: 2026-05-07 18:04:05
-- Source: Subreport [AP]
-- Table:  Command
-- ============================================================

SELECT DISTINCT
CASE 
    -- กลุ่มลูกหนี้ (A/R)
    WHEN T1."InvType" = '13' THEN 'A/R Invoice'
    WHEN T1."InvType" = '14' THEN 'A/R Credit Memo'
    WHEN T1."InvType" = '165' THEN 'A/R Correction Invoice'
    WHEN T1."InvType" = '203' THEN 'A/R Down Payment'
    -- กลุ่มเจ้าหนี้ (A/P)
    WHEN T1."InvType" = '18' THEN 'A/P Invoice'
    WHEN T1."InvType" = '19' THEN 'A/P Credit Memo'
    WHEN T1."InvType" = '163' THEN 'A/P Correction Invoice'
    WHEN T1."InvType" = '204' THEN 'A/P Down Payment'
    -- กลุ่มการเงิน (Payment & Banking)
    WHEN T1."InvType" = '24' THEN 'Incoming Payment'
    WHEN T1."InvType" = '25' THEN 'Deposit'
    WHEN T1."InvType" = '46' THEN 'Payment Advice' -- หรือ Outgoing Payment
    WHEN T1."InvType" = '57' THEN 'Checks for Payment'
    WHEN T1."InvType" = '76' THEN 'Postdated Deposit'
    -- กลุ่มบัญชีและอื่นๆ (Accounting & Others)
    WHEN T1."InvType" = '30' THEN 'Journal Entry'
    WHEN T1."InvType" = '-2' THEN 'Opening Balance'
    WHEN T1."InvType" = '-3' THEN 'Closing Balance'
    WHEN T1."InvType" = '-1' THEN 'All Transactions'
END AS "ประเภทใบกำกับ",
T2."DocDate",
IFNULL(T4."BeginStr", '') || CAST(T2."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร",
T2."DocDate" AS "DateThai",
T2."DocDate" AS "DateThai",
T2."NumAtCard" AS "เลขที่อ้างอิง",
T1."SumApplied" AS "ยอดจ่ายชำระ"
FROM {?Schema@}.OVPM T0
INNER JOIN {?Schema@}.VPM2 T1 ON T0."DocEntry" = T1."DocNum" 
INNER JOIN {?Schema@}.OPCH T2 ON T1."DocEntry"  = T2."DocEntry" 
INNER JOIN {?Schema@}."NNM1" T3 on T0."Series" = T3."Series"
INNER JOIN {?Schema@}."NNM1" T4 on T2."Series" = T4."Series"
WHERE T0."DocEntry" = {?DocKey@}
ORDER BY T2."DocDate" ASC

--SELECT  * FROM VPM2
--WHERE "DocEntry" = 64


