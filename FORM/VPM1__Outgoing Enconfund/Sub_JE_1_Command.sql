-- ============================================================
-- Report: VPM10004__Outgoing Enconfund.rpt
Path:   VPM10004__Outgoing Enconfund.rpt
Extracted: 2026-05-07 18:04:05
-- Source: Subreport [JE]
-- Table:  Command
-- ============================================================

SELECT
    HEAD ."TransId",
    ACCT."FormatCode" AS "รหัสบัญชี",
    ACCT."AcctName" AS "ชื่อบัญชี",
    LINE."Debit",
    LINE."Credit",
    PAY_INV."Project",
    PAY_INV."U_SLD_PlanWork",
    COALESCE(PAY_INV."OcrCode3", PAY_ACC."OcrCode3") AS "แผนงาน",
    COALESCE(PAY_INV."OcrCode4", PAY_ACC."OcrCode4") AS "สำนัก",
    RC."ReconNum",
    LINE."Line_ID"
FROM {?Schema@}."OVPM" T0
INNER JOIN {?Schema@}."OJDT" HEAD ON T0."TransId" = HEAD."TransId"
INNER JOIN {?Schema@}."JDT1" LINE ON HEAD."TransId" = LINE."TransId"
LEFT JOIN {?Schema@}."ITR1" RC
    ON HEAD."TransId"   = RC."TransId"
   AND LINE."Line_ID"   = RC."TransRowId"
LEFT JOIN {?Schema@}."OITR" RH
    ON RC."ReconNum"    = RH."ReconNum"
   AND RH."Canceled"    = 'N'
INNER JOIN {?Schema@}."OACT" ACCT ON LINE."Account" = ACCT."AcctCode"
LEFT JOIN (
    SELECT
        v2."DocNum",
        MAX(v2."OcrCode3") AS "OcrCode3",
        MAX(v2."OcrCode4") AS "OcrCode4",
        MAX(ch."Project") AS "Project",
        MAX(pj."U_SLD_PlanWork") AS "U_SLD_PlanWork"
    FROM {?Schema@}."VPM2" v2
    LEFT JOIN {?Schema@}."OPCH" ch ON v2."DocEntry" = ch."DocEntry"
    LEFT JOIN {?Schema@}."OPRJ" pj ON ch."Project" = pj."PrjCode"
    GROUP BY v2."DocNum"
) PAY_INV ON T0."DocEntry" = PAY_INV."DocNum"
LEFT JOIN (
    SELECT
        v4."DocNum",
        MAX(v4."OcrCode3") AS "OcrCode3",
        MAX(v4."OcrCode4") AS "OcrCode4"
    FROM {?Schema@}."VPM4" v4
    GROUP BY v4."DocNum"
) PAY_ACC ON T0."DocEntry" = PAY_ACC."DocNum"
WHERE (LINE."Debit" != 0 OR LINE."Credit" != 0)
  AND T0."DocEntry" = {?DocKey@}
  AND (RC."ReconNum" IS NULL OR RH."ReconNum" IS NOT NULL)
