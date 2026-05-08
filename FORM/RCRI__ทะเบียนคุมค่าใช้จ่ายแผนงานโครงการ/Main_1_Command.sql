-- ============================================================
-- Report: RCRI0014__ทะเบียนคุมค่าใช้จ่ายแผนงานโครงการ.rpt
Path:   RCRI0014__ทะเบียนคุมค่าใช้จ่ายแผนงานโครงการ.rpt
Extracted: 2026-05-07 18:03:35
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
    T0."PrjCode",
    T0."U_SLD_ProjectName",
    T0."U_SLD_PlanWork",
    T0."U_SLD_GroupWork",
    T0."U_SLD_Period",
    T0."U_SLD_REQ",
    T0."U_SLD_REC",
    T0."U_SLD_Vendor",

    CAST(DAYOFMONTH(T1."START") AS NVARCHAR)  || ' ' || 
    MAP(MONTH(T1."START"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
    || ' ' || TO_VARCHAR(ADD_YEARS(T1."START", 543), 'YY') AS "START" ,

    CAST(DAYOFMONTH(T1."CLOSING") AS NVARCHAR)  || ' ' || 
    MAP(MONTH(T1."CLOSING"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
    || ' ' || TO_VARCHAR(ADD_YEARS(T1."CLOSING", 543), 'YY') AS "CLOSING" ,

    CAST(DAYOFMONTH(T1."DUEDATE") AS NVARCHAR)  || ' ' || 
    MAP(MONTH(T1."DUEDATE"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
    || ' ' || TO_VARCHAR(ADD_YEARS(T1."DUEDATE" , 543), 'YY') AS "DUEDATE" ,

    T1."U_SLD_Status",

    SUM(EX."Debit") AS "TotalDebit"

FROM {?Schema@}.OPRJ T0
INNER JOIN {?Schema@}.OPMG T1 
    ON T0."PrjCode" = T1."FIPROJECT"
LEFT JOIN (
    SELECT  
        T1."Project",
        SUM(IFNULL(T1."Debit",0)) AS "Debit"
    FROM {?Schema@}.OJDT T0 
    INNER JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId"
    LEFT JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
    LEFT JOIN {?Schema@}.OFPR T3 ON T1."FinncPriod" = T3."AbsEntry"
    WHERE T2."FormatCode" IN ('5107010101','5107010103','5107010105','5107010106','5107020104','5107020105','5107020199')
        AND T0."RefDate" <= {?StartDate@}
        AND T1."Debit" <> 0
        AND T0."TransId" NOT IN (
            SELECT "StornoToTr" FROM {?Schema@}.OJDT WHERE "StornoToTr" IS NOT NULL
        )
    GROUP BY T1."Project"
)  AS EX ON T0."PrjCode" = EX."Project"

WHERE 
    (T0."U_SLD_Period" = '{?Period@}' OR '{?Period@}' = '')
    AND (T0."U_SLD_PlanWork" = '{?Plan@}' OR '{?Plan@}' = '')
    AND (T0."U_SLD_GroupWork" = '{?WorkGroup@}' OR '{?WorkGroup@}' = '')

GROUP BY 
    T0."PrjCode",
    T0."U_SLD_ProjectName",
    T0."U_SLD_PlanWork",
    T0."U_SLD_GroupWork",
    T0."U_SLD_Period",
    T0."U_SLD_REQ",
    T0."U_SLD_REC",
    T0."U_SLD_Vendor",
    T1."START",
    T1."CLOSING",
    T1."DUEDATE",
    T1."U_SLD_Status"
