-- ============================================================
-- Report: RCRI0028__ทะเบียนคุมลูกหนี้เงินยืม.rpt
Path:   RCRI0028__ทะเบียนคุมลูกหนี้เงินยืม.rpt
Extracted: 2026-05-07 18:03:41
-- Source: Main Report
-- Table:  Command
-- ============================================================

WITH JE1_FOR_AP AS (
    SELECT
         op."DocEntry"  AS "AP_DocEntry"
        ,oj."TransId"   AS "JE1_TransId"
        ,ROW_NUMBER() OVER (
             PARTITION BY op."DocEntry"
             ORDER BY
                 CASE WHEN EXISTS (
                     SELECT 1 FROM {?Schema@}.RCT2 r              -- ✅ schema
                     WHERE r."DocEntry" = oj."TransId" AND r."InvType" = 30
                 ) THEN 0 ELSE 1 END,
                 CASE WHEN EXISTS (
                     SELECT 1 FROM {?Schema@}.ITR1 itr            -- ✅ schema
                     WHERE itr."TransId" = oj."TransId"
                 ) THEN 0 ELSE 1 END,
                 oj."RefDate" DESC,
                 oj."TransId" DESC
         ) AS rn
    FROM {?Schema@}.OPCH op
    INNER JOIN {?Schema@}.PCH1 h1
            ON h1."DocEntry" = op."DocEntry"
    INNER JOIN {?Schema@}.JDT1 j_ap
            ON j_ap."TransId" = op."TransId"
           AND j_ap."Account" = h1."AcctCode"
           AND j_ap."Debit"   > 0
    INNER JOIN {?Schema@}.JDT1 j_je1
            ON j_je1."Account"  = h1."AcctCode"
           AND j_je1."Credit"   = j_ap."Debit"
           AND j_je1."TransId" <> op."TransId"
    INNER JOIN {?Schema@}.OJDT oj
            ON oj."TransId" = j_je1."TransId"
    WHERE op."U_SLD_Greement_Number" IS NOT NULL
      AND op."U_SLD_Greement_Number" <> ''
),
JE2_FOR_AP AS (
    SELECT
         je1."AP_DocEntry"
        ,oj2."TransId"               AS "JE2_TransId"
        ,oj2."RefDate"               AS "JE2_RefDate"
        ,oj2."U_SLD_Voucher_Number"  AS "JE2_Voucher"
        ,oj2."U_SLD_Greement_Number" AS "JE2_GreementNo"
        ,ROW_NUMBER() OVER (
             PARTITION BY je1."AP_DocEntry"
             ORDER BY oj2."RefDate" DESC, oj2."TransId" DESC
         ) AS rn
    FROM JE1_FOR_AP je1                                             -- ✅ CTE — no schema
    INNER JOIN {?Schema@}.ITR1 itr1                                 -- ✅ schema
            ON itr1."TransId" = je1."JE1_TransId"
    INNER JOIN {?Schema@}.ITR1 itr2                                 -- ✅ schema
            ON itr2."ReconNum"  = itr1."ReconNum"
           AND itr2."TransId"  <> je1."JE1_TransId"
    INNER JOIN {?Schema@}.OJDT oj2                                  -- ✅ schema
            ON oj2."TransId" = itr2."TransId"
    WHERE je1.rn = 1
      AND NOT EXISTS (
          SELECT 1 FROM {?Schema@}.ORCT oc                          -- ✅ schema
          WHERE oc."TransId" = oj2."TransId"
      )
      AND NOT EXISTS (
          SELECT 1 FROM {?Schema@}.OVPM ov                          -- ✅ schema
          WHERE ov."TransId" = oj2."TransId"
      )
),
ORCT_RAW AS (
    /* Source 1: via ITR1 ReconNum chain */
    SELECT
         je1."AP_DocEntry"
        ,oc."DocEntry"                                                    AS "ORCT_DocEntry"
        ,oc."DocNum"                                                      AS "ORCT_DocNum"
        ,oc."Series"                                                      AS "ORCT_Series"
        ,nnm."BeginStr"                                                   AS "ORCT_BeginStr"
        ,IFNULL(nnm."BeginStr", '') || CAST(oc."DocNum" AS NVARCHAR(20))  AS "ORCT_FullDocNum"
        ,oc."DocDate"                                                     AS "ORCT_DocDate"
        ,oc."DocTotal"                                                    AS "ORCT_DocTotal"
        ,oc."TransId"                                                     AS "ORCT_TransId"
        ,itr1."ReconNum"                                                  AS "ReconNum"
        ,'RECON'                                                          AS "Source"
        ,1                                                                AS "Priority"
    FROM JE1_FOR_AP je1
    INNER JOIN {?Schema@}.ITR1 itr1
            ON itr1."TransId" = je1."JE1_TransId"
    INNER JOIN {?Schema@}.ITR1 itr_oc
            ON itr_oc."ReconNum"  = itr1."ReconNum"
           AND itr_oc."TransId"  <> je1."JE1_TransId"
    INNER JOIN {?Schema@}.ORCT oc
            ON oc."TransId" = itr_oc."TransId"
    LEFT  JOIN {?Schema@}.NNM1 nnm
            ON nnm."Series" = oc."Series"
    WHERE je1.rn = 1

    UNION ALL

    /* Source 2: via RCT2 direct (Fallback) */
    SELECT
         je1."AP_DocEntry"
        ,oc."DocEntry"                                                    AS "ORCT_DocEntry"
        ,oc."DocNum"                                                      AS "ORCT_DocNum"
        ,oc."Series"                                                      AS "ORCT_Series"
        ,nnm."BeginStr"                                                   AS "ORCT_BeginStr"
        ,IFNULL(nnm."BeginStr", '') || CAST(oc."DocNum" AS NVARCHAR(20))  AS "ORCT_FullDocNum"
        ,oc."DocDate"                                                     AS "ORCT_DocDate"
        ,oc."DocTotal"                                                    AS "ORCT_DocTotal"
        ,oc."TransId"                                                     AS "ORCT_TransId"
        ,CAST(NULL AS INTEGER)                                            AS "ReconNum"
        ,'RCT2'                                                           AS "Source"
        ,2                                                                AS "Priority"
    FROM JE1_FOR_AP je1
    INNER JOIN {?Schema@}.RCT2 t1
            ON t1."DocEntry" = je1."JE1_TransId"
           AND t1."InvType"  = 30
    INNER JOIN {?Schema@}.ORCT oc
            ON oc."DocEntry" = t1."DocNum"
    LEFT  JOIN {?Schema@}.NNM1 nnm
            ON nnm."Series" = oc."Series"
    WHERE je1.rn = 1
),
ORCT_AGG AS (
    SELECT
         "AP_DocEntry"
        ,SUM("ORCT_DocTotal")                                  AS "Total_Amount"
        ,STRING_AGG(CAST("ORCT_FullDocNum" AS NVARCHAR(50)),
                    ', ' ORDER BY "ORCT_DocDate")              AS "All_DocNums"
        ,COUNT(*)                                              AS "Receipt_Count"
    FROM (
        SELECT
             ORCT_RAW.*
            ,ROW_NUMBER() OVER (
                 PARTITION BY "AP_DocEntry", "ORCT_DocEntry"
                 ORDER BY "Priority"
             ) AS dedup_rn
        FROM ORCT_RAW
    ) dedup
    WHERE dedup_rn = 1
    GROUP BY "AP_DocEntry"
)
SELECT
     op."U_SLD_Greement_Number"                                     AS "เลขที่สัญญายืมเงิน/ว.ด.ป.อนุมัติ"
    --,IFNULL(m1."BeginStr", '') || CAST(op."DocNum" AS NVARCHAR(20)) AS "เลขที่หนังสือ/วันที่วางเบิก"
	,op."U_SLD_Document_Number"										AS "เลขที่หนังสือ/วันที่วางเบิก"
    ,op."CardName"                                                  AS "ชื่อ-สกุล ผู้ยืมเงิน"
    ,DAYOFMONTH(op."U_SLD_Start_Date")                              AS "วันที่ปฏิบัติราชการ (เริ่ม)"
    ,op."U_SLD_End_Date"                                            AS "วันที่ปฏิบัติราชการ (สิ้นสุด)"
    ,op."U_SLD_Projects"                                            AS "โครงการ/หลักสูตร/กิจกรรมที่ได้รับอนุมัติให้ดำเนินการ"
    ,op."DocTotal"                                                  AS "จำนวนเงินยืม"
    ,pm."DocDate"                                                   AS "วันที่โอนเงิน(วันที่Outgoing)"
    ,CASE
         WHEN op."U_SLD_Type" = 'ค่าใช้จ่ายเดินทาง'
              THEN ADD_DAYS(op."U_SLD_End_Date", 15)
         ELSE      ADD_DAYS(pm."DocDate", 30)
     END                                                            AS "วันครบกำหนด ส่งใช้เงินยืม (auto 15,30 วัน)"
    ,je2."JE2_RefDate"                                              AS "ว/ด/ป ที่ส่งใช้เงินยืม(JE2)"
    ,ct."Total_Amount"                                              AS "เงินสด (เงินโอน)"
    ,je2."JE2_Voucher"                                              AS "ใบสำคัญเลขที่"
    ,je2."JE2_GreementNo"                                           AS "หมายเหตุ"
    ,ct."All_DocNums"                                               AS "ใบเสร็จเลขที่ / เล่มที่"
    ,ofp."Category" + 543                                           AS "Period"
FROM {?Schema@}.OPCH op
LEFT  JOIN {?Schema@}.NNM1 m1   ON m1."Series"        = op."Series"
INNER JOIN {?Schema@}.OFPR ofp  ON ofp."Indicator"    = op."PIndicator"
INNER JOIN {?Schema@}.OJDT oj   ON oj."TransId"       = op."TransId"
LEFT  JOIN {?Schema@}.VPM2 m2   ON m2."DocEntry"      = op."DocEntry"
                                AND m2."InvType"      = 18
LEFT  JOIN {?Schema@}.OVPM pm   ON pm."DocEntry"      = m2."DocNum"
LEFT  JOIN JE1_FOR_AP je1       ON je1."AP_DocEntry"  = op."DocEntry"     -- ✅ CTE — no schema
                                AND je1.rn            = 1
LEFT  JOIN JE2_FOR_AP je2       ON je2."AP_DocEntry"  = op."DocEntry"     -- ✅ CTE — no schema
                                AND je2.rn            = 1
LEFT  JOIN ORCT_AGG ct          ON ct."AP_DocEntry"   = op."DocEntry"     -- ✅ CTE — no schema
WHERE op."U_SLD_Greement_Number" IS NOT NULL
  AND op."U_SLD_Greement_Number" <> ''
  AND op."DocDate" BETWEEN {?STARTDATE@} AND {?ENDDATE@}
;
