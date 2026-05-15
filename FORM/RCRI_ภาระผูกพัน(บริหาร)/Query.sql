WITH POLines AS (
    SELECT A."AgrNo", A."UnitPrice", P."ShipDate"
    FROM OAT1 A
    INNER JOIN POR1 P ON A."AgrNo" = P."AgrNo" AND A."AgrLineNum" = P."AgrLnNum"
),
AgrTotals AS (
    SELECT "AgrNo", SUM("UnitPrice") AS "CalculatedOpenAmount", SUM(CASE WHEN YEAR("ShipDate") - CAST('2021' AS INT) <= 5 THEN "UnitPrice" ELSE 0 END) AS "Amt_1_5", SUM(CASE WHEN YEAR("ShipDate") - CAST('2021' AS INT) > 5 THEN "UnitPrice" ELSE 0 END) AS "Amt_Over_5"
    FROM POLines
    GROUP BY "AgrNo"
),
InvoicedLines AS (
    SELECT DISTINCT OOAT."AbsID", OOAT."Number", OOAT."StartDate", OOAT."EndDate", AGT."CalculatedOpenAmount" AS "OpenAmount", AGT."Amt_1_5", AGT."Amt_Over_5", OPCH."DocEntry" AS "InvEntry"
    FROM OOAT
    INNER JOIN AgrTotals AGT ON OOAT."AbsID" = AGT."AgrNo"
    INNER JOIN PDN1 ON OOAT."AbsID" = PDN1."AgrNo"
    INNER JOIN PCH1 ON PDN1."DocEntry" = PCH1."BaseEntry" AND PDN1."LineNum" = PCH1."BaseLine" AND PCH1."BaseType" = 20
    INNER JOIN OPCH ON PCH1."DocEntry" = OPCH."DocEntry"
)
SELECT DISTINCT
    INV."AbsID",
    INV."Number",
    INV."StartDate",
    INV."EndDate",
    INV."OpenAmount" AS "Open Amount",
    SUM(Pay."OB_Amount") OVER (PARTITION BY INV."AbsID") AS "ยอดยกมา (OB)",
    SUM(Pay."Movement_Amount") OVER (PARTITION BY INV."AbsID") AS "จ่ายปีนี้ (Movement)",
    SUM(Pay."PaidAmount") OVER (PARTITION BY INV."AbsID") AS "จ่ายจริงสะสมรวม",
    INV."OpenAmount" - SUM(Pay."PaidAmount") OVER (PARTITION BY INV."AbsID") AS "คงเหลือ",
    CASE WHEN INV."Amt_1_5" - SUM(Pay."PaidAmount") OVER (PARTITION BY INV."AbsID") < 0 THEN 0 ELSE INV."Amt_1_5" - SUM(Pay."PaidAmount") OVER (PARTITION BY INV."AbsID") END AS "ยอดคงเหลือ 1-5 ปี",
    CASE WHEN INV."Amt_1_5" - SUM(Pay."PaidAmount") OVER (PARTITION BY INV."AbsID") < 0 THEN INV."Amt_Over_5" + (INV."Amt_1_5" - SUM(Pay."PaidAmount") OVER (PARTITION BY INV."AbsID")) ELSE INV."Amt_Over_5" END AS "ยอดคงเหลือ >5 ปี",
    SUM(Pay."PayCount") OVER (PARTITION BY INV."AbsID") AS "จำนวนใบจ่าย"
FROM InvoicedLines INV
LEFT JOIN (
    SELECT V2."DocEntry" AS "InvEntry", SUM(CASE WHEN P."Category" < '2021' THEN V2."SumApplied" ELSE 0 END) AS "OB_Amount", 
    SUM(CASE WHEN P."Category" = '2021' THEN V2."SumApplied" ELSE 0 END) AS "Movement_Amount", 
    SUM(CASE WHEN P."Category" <= '2021' THEN V2."SumApplied" ELSE 0 END) AS "PaidAmount", 
    COUNT(DISTINCT CASE WHEN P."Category" <= '2021' THEN V0."DocEntry" END) AS "PayCount"
    FROM VPM2 V2 
    INNER JOIN OVPM V0 ON V2."DocNum" = V0."DocEntry"
    INNER JOIN OFPR P ON V0."DocDate" >= P."F_RefDate" AND V0."DocDate" <= P."T_RefDate"
    WHERE V0."Canceled" = 'N' AND V2."InvType" = 18
    GROUP BY V2."DocEntry"
) Pay ON INV."InvEntry" = Pay."InvEntry";