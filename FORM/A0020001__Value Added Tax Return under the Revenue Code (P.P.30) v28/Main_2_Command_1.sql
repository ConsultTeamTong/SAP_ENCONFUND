-- ============================================================
-- Report: A0020001__Value Added Tax Return under the Revenue Code (P.P.30) v28.rpt
Path:   A0020001__Value Added Tax Return under the Revenue Code (P.P.30) v28.rpt
Extracted: 2026-05-07 18:02:33
-- Source: Main Report
-- Table:  Command_1
-- ============================================================


WITH QS (
    "U_SubmitDate",
    "Years",
    "MonthDate",
    "Mount",
    "row",
    "TotalB",
    "TaxAmount"
) AS (
SELECT DISTINCT "U_SubmitDate",
TO_NVARCHAR(TO_INT(LEFT("U_SubmitDate", 4)) + 543) AS "Year",
        CASE
            WHEN RIGHT("U_SubmitDate", 2) = '01' THEN N'มกราคม'
            WHEN RIGHT("U_SubmitDate", 2) = '02' THEN N'กุมภาพันธ์'
            WHEN RIGHT("U_SubmitDate", 2) = '53' THEN N'มีนาคม'
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
        RIGHT("U_SubmitDate", 2) AS "Mount",
        row_NUMBER() OVER(
            ORDER BY "U_SubmitDate"
        ) AS "row",
        SUM("U_Total") - SUM("U_TaxAmount") AS "Total",
        SUM("U_TaxAmount") AS "TaxAmount"
    FROM "{?Schema@}"."@SLDT_TS_TST"
        INNER JOIN "{?Schema@}"."@SLDT_SET_VAT" ON  "{?Schema@}"."@SLDT_SET_VAT"."Code" =  "{?Schema@}"."@SLDT_TS_TST"."U_TaxCode"
    WHERE  "{?Schema@}"."@SLDT_SET_VAT"."U_SLD_TYPE" <> 'U'
        AND "{?Schema@}"."@SLDT_TS_TST"."U_SubmitDate" = '{?DocKey@}'
    GROUP BY "U_SubmitDate","U_Type","U_SLD_TYPE"
)

SELECT * FROM(
SELECT "QS"."U_SubmitDate"  ,
"QS"."Years",
"QS"."MonthDate",
"QS"."Mount",
"QS"."row",
"QS"."TotalB",
"QS"."TaxAmount" ,
"TotalB" AS "Total B",
"TaxAmount" AS "TaxAmount Buy",
    IFNULL(
        (
            SELECT "TotalB"
            FROM "QS"
            WHERE "row" = 2
        ),
        0
    ) AS "Total D",
    IFNULL(
        (
            SELECT "TotalB"
            FROM "QS"
            WHERE "row" = 3
        ),
        0
    ) AS "Total E",
    IFNULL(
        (
            SELECT "TotalB"
            FROM "QS"
            WHERE "row" = 4
        ),
        0
    ) AS "Total N",
    IFNULL(
        (
            SELECT "TaxAmount"
            FROM "QS"
            WHERE "row" = 2
        ),
        0
    ) AS "TaxAmount Sale",
    IFNULL(
        (
            SELECT "TaxAmount"
            FROM "QS"
            WHERE "row" = 2
        ) - "TaxAmount",
        0
    ) AS "Total TaxAmount"

FROM "QS"
) AS "MAX1"
WHERE "MAX1"."row" = '1'
