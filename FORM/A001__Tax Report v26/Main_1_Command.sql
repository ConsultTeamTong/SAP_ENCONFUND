-- ============================================================
-- Report: A0010001__Tax Report v26.rpt
Path:   A0010001__Tax Report v26.rpt
Extracted: 2026-05-07 18:02:33
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
TO_NVARCHAR(LEFT("U_SubmitDate",4)) AS "YearDate",
    CASE
        WHEN RIGHT("U_SubmitDate", 2) = '01' THEN N'มกราคม'
        WHEN RIGHT("U_SubmitDate", 2) = '02' THEN N'กุมภาพันธ์'
        WHEN RIGHT("U_SubmitDate", 2) = '03' THEN N'มีนาคม'
        WHEN RIGHT("U_SubmitDate", 2) = '04' THEN N'เมษายน'
        WHEN RIGHT("U_SubmitDate", 2) = '05' THEN N'พฤษภาคม'
        WHEN RIGHT("U_SubmitDate", 2) = '06' THEN N'มิถุนายน'
        WHEN RIGHT("U_SubmitDate", 2) = '07' THEN N'กรกฎาคม'
        WHEN RIGHT("U_SubmitDate", 2) = '08' THEN N'สิงหาคม'
        WHEN RIGHT("U_SubmitDate", 2) = '09' THEN N'กันยายน'
        WHEN RIGHT("U_SubmitDate", 2) = '10' THEN N'ตุลาคม'
        WHEN RIGHT("U_SubmitDate", 2) = '11' THEN N'พฤศจิกายน'
        WHEN RIGHT("U_SubmitDate", 2) = '12' THEN N'ธันวาคม'
    END AS "MonthDate",    
    CONCAT
    (
            CONCAT(RIGHT("U_Date", 2), '/') , CONCAT(LEFT(RIGHT("U_Date", 4),2),CONCAT( '/',LEFT("U_Date", 4)))
    )  AS "U_Date",        
    "{?Schema@}"."@SLDT_RT_TST"."Name" AS "DocKey",
    *
FROM "{?Schema@}"."@SLDT_RT_TST"
LEFT JOIN "{?Schema@}"."@SLDT_SET_BRANCH" ON "{?Schema@}"."@SLDT_SET_BRANCH"."Code" = "{?Schema@}"."@SLDT_RT_TST"."U_Branch"
WHERE 
"{?Schema@}"."@SLDT_RT_TST"."U_TaxType" IN ({?DocKey@}) AND "U_SubmitDate" IS NOT NULL AND
CONCAT("{?Schema@}"."@SLDT_RT_TST"."U_DocNum","{?Schema@}"."@SLDT_RT_TST"."U_TaxId") IN ({?DocKey@})

