-- ============================================================
-- Report: RCT10006__Incoming Enconfund.rpt
Path:   RCT10006__Incoming Enconfund.rpt
Extracted: 2026-05-07 18:03:46
-- Source: Subreport [JE]
-- Table:  Command
-- ============================================================

SELECT DISTINCT
    ACCT."FormatCode" AS "รหัสบัญชี",
    ACCT."AcctName" AS "ชื่อบัญชี",
    LINE."Debit",
    LINE."Credit",
    T2."Project",
    OPRJ."U_SLD_PlanWork",
    COALESCE(T1."OcrCode3", T3."OcrCode3") AS "แผนงาน",
    COALESCE(T1."OcrCode4", T3."OcrCode4") AS "สำนัก",
        RC."ReconNum",
    LINE."Line_ID"
FROM {?Schema@}."ORCT" T0
INNER JOIN {?Schema@}."OJDT" HEAD ON T0."TransId" = HEAD."TransId"
INNER JOIN {?Schema@}."JDT1" LINE ON HEAD."TransId" = LINE."TransId"
INNER JOIN {?Schema@}."OACT" ACCT ON LINE."Account" = ACCT."AcctCode"
LEFT JOIN {?Schema@}."ITR1" RC
    ON HEAD."TransId"   = RC."TransId"
   AND LINE."Line_ID"   = RC."TransRowId"
LEFT JOIN {?Schema@}."OITR" RH
    ON RC."ReconNum"    = RH."ReconNum"
   AND RH."Canceled"    = 'N'
LEFT JOIN {?Schema@}.RCT2 T1 ON T0."DocEntry" = T1."DocNum" 
LEFT JOIN {?Schema@}.RCT4 T3 ON T0."DocEntry" = T3."DocNum" 
LEFT JOIN {?Schema@}.OINV T2 ON T1."DocEntry" = T2."DocEntry" 
LEFT JOIN {?Schema@}.OPRJ ON T2."Project" = OPRJ."PrjCode" 
WHERE (LINE."Debit" != 0 OR LINE."Credit" != 0)
AND T0."DocEntry" = {?DocKey@}
AND (RC."ReconNum" IS NULL OR RH."ReconNum" IS NOT NULL)
