-- ============================================================
-- Report: ทะเบียนคุมจ้างเหมาบริการผู้เชี่ยวชาญ.rpt
Path:   ทะเบียนคุมจ้างเหมาบริการผู้เชี่ยวชาญ.rpt
Extracted: 2026-05-08 14:34:48
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
    OOAT."U_SLD_Contract_Number",
    OOAT."BpName",
    TO_VARCHAR(OOAT."SignDate", 'D') || ' ' || 
    MAP(MONTH(OOAT."SignDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
    || ' ' || TO_VARCHAR(ADD_YEARS(OOAT."SignDate", 543), 'YY') AS "SignDate",
    OOAT."Descript",
    OOAT."U_SLD_Contract_Amount",
    OOAT."U_SLD_Warranty_Term",
    OOAT."StartDate",
    OOAT."EndDate",
    LEFT(OFPR_MAIN."Indicator", 4) AS "INDICATOR",
    OOAT."U_SLD_Contract_Amount" - IFNULL(Payment_Summary."OB_Wages", 0) AS "Opening_Balance",
    IFNULL(Payment_Summary."Jan_Wages", 0) AS "Jan_Wages",
    Payment_Summary."Jan_Ref",
    Payment_Summary."Jan_Out",
    IFNULL(Payment_Summary."Feb_Wages", 0) AS "Feb_Wages",
    Payment_Summary."Feb_Ref",
    Payment_Summary."Feb_Out",
    IFNULL(Payment_Summary."Mar_Wages", 0) AS "Mar_Wages",
    Payment_Summary."Mar_Ref",
    Payment_Summary."Mar_Out",
    IFNULL(Payment_Summary."Apr_Wages", 0) AS "Apr_Wages",
    Payment_Summary."Apr_Ref",
    Payment_Summary."Apr_Out",
    IFNULL(Payment_Summary."May_Wages", 0) AS "May_Wages",
    Payment_Summary."May_Ref",
    Payment_Summary."May_Out",
    IFNULL(Payment_Summary."Jun_Wages", 0) AS "Jun_Wages",
    Payment_Summary."Jun_Ref",
    Payment_Summary."Jun_Out",
    IFNULL(Payment_Summary."Jul_Wages", 0) AS "Jul_Wages",
    Payment_Summary."Jul_Ref",
    Payment_Summary."Jul_Out",
    IFNULL(Payment_Summary."Aug_Wages", 0) AS "Aug_Wages",
    Payment_Summary."Aug_Ref",
    Payment_Summary."Aug_Out",
    IFNULL(Payment_Summary."Sep_Wages", 0) AS "Sep_Wages",
    Payment_Summary."Sep_Ref",
    Payment_Summary."Sep_Out",
    IFNULL(Payment_Summary."Oct_Wages", 0) AS "Oct_Wages",
    Payment_Summary."Oct_Ref",
    Payment_Summary."Oct_Out",
    IFNULL(Payment_Summary."Nov_Wages", 0) AS "Nov_Wages",
    Payment_Summary."Nov_Ref",
    Payment_Summary."Nov_Out",
    IFNULL(Payment_Summary."Dec_Wages", 0) AS "Dec_Wages",
    Payment_Summary."Dec_Ref",
    Payment_Summary."Dec_Out"
FROM "{?Schema@}"."OOAT" OOAT
INNER JOIN "{?Schema@}"."OFPR" OFPR_MAIN
    ON (OOAT."StartDate" BETWEEN OFPR_MAIN."F_RefDate" AND OFPR_MAIN."T_RefDate") 
    OR (OOAT."EndDate" BETWEEN OFPR_MAIN."F_RefDate" AND OFPR_MAIN."T_RefDate")
INNER JOIN "{?Schema@}"."OCRD" OCRD ON OOAT."BpCode" = OCRD."CardCode" 
LEFT JOIN (
    SELECT 
        PCH1."AgrNo",
        SUM(CASE 
            WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) < TO_VARCHAR(TO_INT({?Period@}) - 543) 
            THEN PCH1."U_SLD_Wages" 
            ELSE 0 
        END) AS "OB_Wages",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 1 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Jan_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 1 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Jan_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 1 THEN OutEntry."DocDate" ELSE NULL END) AS "Jan_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 2 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Feb_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 2 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Feb_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 2 THEN OutEntry."DocDate" ELSE NULL END) AS "Feb_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 3 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Mar_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 3 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Mar_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 3 THEN OutEntry."DocDate" ELSE NULL END) AS "Mar_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 4 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Apr_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 4 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Apr_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 4 THEN OutEntry."DocDate" ELSE NULL END) AS "Apr_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 5 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "May_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 5 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "May_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 5 THEN OutEntry."DocDate" ELSE NULL END) AS "May_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 6 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Jun_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 6 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Jun_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 6 THEN OutEntry."DocDate" ELSE NULL END) AS "Jun_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 7 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Jul_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 7 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Jul_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 7 THEN OutEntry."DocDate" ELSE NULL END) AS "Jul_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 8 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Aug_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 8 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Aug_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 8 THEN OutEntry."DocDate" ELSE NULL END) AS "Aug_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 9 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Sep_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 9 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Sep_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 9 THEN OutEntry."DocDate" ELSE NULL END) AS "Sep_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 10 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Oct_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 10 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Oct_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 10 THEN OutEntry."DocDate" ELSE NULL END) AS "Oct_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 11 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Nov_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 11 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Nov_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 11 THEN OutEntry."DocDate" ELSE NULL END) AS "Nov_Out",

        SUM(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 12 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Dec_Wages",
        STRING_AGG(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 12 THEN PDN1."FreeTxt" ELSE NULL END, ', ') AS "Dec_Ref",
        MAX(CASE WHEN LEFT(IFNULL(OFPR_SUB."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543) AND MONTH(OPCH."DocDate") = 12 THEN OutEntry."DocDate" ELSE NULL END) AS "Dec_Out"

    FROM "{?Schema@}"."PCH1" PCH1
    INNER JOIN "{?Schema@}"."OPCH" OPCH ON PCH1."DocEntry" = OPCH."DocEntry"
    INNER JOIN (
        SELECT 
            VPM2."DocEntry",
            OVPM."DocNum",
            OVPM."DocDate"
        FROM "{?Schema@}"."OVPM" OVPM
        INNER JOIN "{?Schema@}"."VPM2" VPM2 ON OVPM."DocEntry" = VPM2."DocNum"
    ) AS OutEntry ON OPCH."DocEntry" = OutEntry."DocEntry"
    LEFT JOIN "{?Schema@}"."PDN1" PDN1 
        ON PCH1."BaseEntry" = PDN1."DocEntry" 
        AND PCH1."BaseLine" = PDN1."LineNum"
    INNER JOIN "{?Schema@}"."OFPR" OFPR_SUB 
        ON OPCH."DocDate" BETWEEN OFPR_SUB."F_RefDate" AND OFPR_SUB."T_RefDate"
    WHERE 1=1
      AND OPCH."DocStatus" = 'C' 
      AND OPCH."CANCELED" = 'N'
      AND LEFT(IFNULL(OFPR_SUB."Code", ''), 4) <= TO_VARCHAR(TO_INT({?Period@}) - 543)    
    GROUP BY 
        PCH1."AgrNo"
) AS Payment_Summary ON OOAT."AbsID" = Payment_Summary."AgrNo"
WHERE 1=1
    AND LEFT(IFNULL(OFPR_MAIN."Code", ''), 4) = TO_VARCHAR(TO_INT({?Period@}) - 543)
    AND OCRD."QryGroup3" = 'Y'
ORDER BY OOAT."U_SLD_Contract_Number";
