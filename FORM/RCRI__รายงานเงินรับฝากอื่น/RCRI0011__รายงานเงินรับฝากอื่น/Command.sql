-- ============================================================
-- Report: RCRI0011__รายงานเงินรับฝากอื่น.rpt
Path:   RCRI0011__รายงานเงินรับฝากอื่น.rpt
Extracted: 2026-05-11 15:52:40
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT
    OACT."FormatCode",
    ORCT."DocTotal",
    RCT4."DocNum",
    CONCAT(IC."BeginStr", ORCT."DocNum") AS "DocNumIC",
    ORCT."TransId",
    RCT4."LineId",
    RCT4."AcctCode",
    
    CAST(DAYOFMONTH(ORCT."DocDate") AS NVARCHAR) || ' ' || 
MAP(MONTH(ORCT."DocDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS(ORCT."DocDate", 543), 'YY') AS "DocDate" ,
    
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY RCT4."DocNum", RCT4."LineId" ORDER BY APinv."LocTotal" DESC) = 1 
        THEN RCT4."SumApplied" 
        ELSE 0 
    END AS "SumApplied",
    CASE 
        WHEN ITR1."ReconNum" IS NOT NULL 
             AND ROW_NUMBER() OVER (PARTITION BY RCT4."DocNum", RCT4."LineId" ORDER BY APinv."LocTotal" DESC) = 1 
        THEN RCT4."SumApplied" 
        ELSE 0 
    END AS "ReconciledSum",
    
      CAST(DAYOFMONTH( APinv."RefDate") AS NVARCHAR) || ' ' || 
MAP(MONTH( APinv."RefDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
|| ' ' || TO_VARCHAR(ADD_YEARS( APinv."RefDate", 543), 'YY') AS "RefDate" ,
    
 
   COALESCE(DSC1."Account",RCT4."U_SLD_BankNo") AS "Account",
    RCT4."U_SLD_BankBranch",
    CASE 
        WHEN ITR1."ReconNum" IS NULL THEN 'Not Reconcile'
        ELSE TO_VARCHAR(ITR1."ReconNum")
    END AS "ReconNum",
    CONCAT(CONCAT(IFNULL(APinv."DocNumIC",''), IFNULL(APinv."DocNumAP",'')), IFNULL(APinv."DocNumJE",'')) AS "DocNumRE",
    APinv."LocTotal"
FROM {?Schema@}.RCT4
INNER JOIN {?Schema@}.ORCT 
    ON ORCT."DocEntry" = RCT4."DocNum" AND ORCT."Canceled" = 'N'
LEFT JOIN {?Schema@}.DSC1  
    ON ORCT."TrsfrAcct" = DSC1."GLAccount"
INNER JOIN {?Schema@}.OACT 
    ON RCT4."AcctCode" = OACT."AcctCode"
LEFT JOIN {?Schema@}.ITR1 
    ON ORCT."DocEntry" = ITR1."SrcObjAbs" 
    AND (ITR1."TransRowId"-1) = RCT4."LineId" 
    AND ORCT."TransId" = ITR1."TransId" 
LEFT JOIN {?Schema@}.OITR 
    ON OITR."ReconNum" = ITR1."ReconNum" 
LEFT JOIN (
    SELECT 
        CONCAT(AP."BeginStr", T0."BaseRef") AS "DocNumAP",
        CONCAT(IC."BeginStr", T0."BaseRef") AS "DocNumIC",
        CONCAT(JE."BeginStr", T0."Number") AS "DocNumJE",
        T0."RefDate",
        T4."ReconSum" AS "LocTotal",
        T4."ReconNum",
        T0."TransType" 
    FROM {?Schema@}.OJDT T0
    INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
    LEFT JOIN {?Schema@}.OACT T2  ON T1."Account" = T2."AcctCode"
    LEFT JOIN {?Schema@}.ORCT T3 ON T0."TransId" = T3."TransId" AND T0."TransType" = '24'
    LEFT JOIN {?Schema@}.NNM1 IC ON T3."Series" = IC."Series" AND T0."TransType" = '24'
    LEFT JOIN {?Schema@}.OPCH T5 ON T1."TransId" = T5."TransId" AND T0."TransType" = '18'
    LEFT JOIN {?Schema@}.NNM1 AP ON T5."Series" = AP."Series" AND T0."TransType" = '18'
    LEFT JOIN {?Schema@}.NNM1 JE ON T0."Series" = JE."Series" AND T0."TransType" = '30'
    LEFT JOIN {?Schema@}.ITR1 T4 ON T0."TransId" = T4."TransId"
    WHERE T2."FormatCode" = '2111020199'
      AND T1."Debit" <> 0
) AS APinv ON ITR1."ReconNum" = APinv."ReconNum" 
LEFT JOIN {?Schema@}.NNM1 IC 
    ON ORCT."Series" = IC."Series" 
WHERE 1=1
  AND (OITR."Canceled" = 'N' OR IFNULL(OITR."Canceled",'0') = '0')
  AND OACT."FormatCode" = '2111020199'
  AND ORCT."DocDate" BETWEEN {?StrDate@} AND {?EndDate@}
