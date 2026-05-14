WITH POLineCount AS (
    SELECT "AgrNo", "AgrLnNum", COUNT("LineNum") AS "CountLinePO"
    FROM POR1
    WHERE "AgrNo" IS NOT NULL
    GROUP BY "AgrNo", "AgrLnNum"
),
AgrTotals AS (
    SELECT A."AgrNo", SUM(A."UnitPrice" * P."CountLinePO") AS "CalculatedOpenAmount"
    FROM OAT1 A
    LEFT JOIN POLineCount P ON A."AgrNo" = P."AgrNo" AND A."AgrLineNum" = P."AgrLnNum"
    GROUP BY A."AgrNo"
),
InvoicedLines AS (
    SELECT DISTINCT OOAT."AbsID", OOAT."Number", OOAT."StartDate", OOAT."EndDate", AGT."CalculatedOpenAmount" AS "OpenAmount", OPCH."DocEntry" AS "InvEntry"
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
    CASE WHEN YEAR(INV."EndDate") - CAST('2026' AS INT) <= 5 THEN INV."OpenAmount" - SUM(Pay."PaidAmount") OVER (PARTITION BY INV."AbsID") ELSE 0 END AS "ยอดคงเหลือ 1-5 ปี",
    CASE WHEN YEAR(INV."EndDate") - CAST('2026' AS INT) > 5 THEN INV."OpenAmount" - SUM(Pay."PaidAmount") OVER (PARTITION BY INV."AbsID") ELSE 0 END AS "ยอดคงเหลือ >5 ปี",
    SUM(Pay."PayCount") OVER (PARTITION BY INV."AbsID") AS "จำนวนใบจ่าย"
FROM InvoicedLines INV
LEFT JOIN (
    SELECT 
        V2."DocEntry" AS "InvEntry", 
        SUM(CASE WHEN P."Category" < '2026' THEN V2."SumApplied" ELSE 0 END) AS "OB_Amount",
        SUM(CASE WHEN P."Category" = '2026' THEN V2."SumApplied" ELSE 0 END) AS "Movement_Amount",
        SUM(CASE WHEN P."Category" <= '2026' THEN V2."SumApplied" ELSE 0 END) AS "PaidAmount",
        COUNT(DISTINCT CASE WHEN P."Category" <= '2026' THEN V0."DocEntry" END) AS "PayCount"
    FROM VPM2 V2
    INNER JOIN OVPM V0 ON V2."DocNum" = V0."DocEntry"
    INNER JOIN OFPR P ON V0."DocDate" >= P."F_RefDate" AND V0."DocDate" <= P."T_RefDate"
    WHERE V0."Canceled" = 'N' AND V2."InvType" = 18
    GROUP BY V2."DocEntry"
) Pay ON INV."InvEntry" = Pay."InvEntry";