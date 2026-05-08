-- ============================================================
-- Report: RCRI0033__ทะเบียนคุมจ้างเหมาบริการ.rpt
Path:   RCRI0033__ทะเบียนคุมจ้างเหมาบริการ.rpt
Extracted: 2026-05-07 18:03:43
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
	OOAT."AbsID",
    OOAT."U_SLD_Contract_Number",
    OOAT."BpName",
    CAST(DAYOFMONTH(OAT2."U_SLD_Start_Date") AS NVARCHAR) || ' ' || 
	MAP(MONTH(OAT2."U_SLD_Start_Date"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
	|| ' ' || TO_VARCHAR(ADD_YEARS(OAT2."U_SLD_Start_Date", 543), 'YY') AS "U_SLD_Start_Date",
	CAST(DAYOFMONTH(OAT2."U_SLD_End_Date") AS NVARCHAR) || ' ' || 
	MAP(MONTH(OAT2."U_SLD_End_Date"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.') 
	|| ' ' || TO_VARCHAR(ADD_YEARS(OAT2."U_SLD_End_Date", 543), 'YY') AS "U_SLD_End_Date",
    OAT1."PlanQty",
    OOAT."U_SLD_Contract_Amount",
    OOAT."U_SLD_Receiving_Officer",
    OOAT."U_SLD_Project_Manager",
    LEFT(OFPR."Indicator", 4) AS INDICATOR,
    CASE
    WHEN CURRENT_DATE BETWEEN OAT2."U_SLD_Start_Date" AND OAT2."U_SLD_End_Date" THEN 'บริหารสัญญา'
    WHEN CURRENT_DATE > OAT2."U_SLD_End_Date" THEN 'สิ้นสุดสัญญา'
    WHEN OOAT."Status" = 'C'  THEN 'ยกเลิกสัญญา'
    END AS "Contract_Status",
    IFNULL(Payment_Summary."Txn_Count", 0) AS "Total_Transactions",
    IFNULL(Payment_Summary."Jan_Amt", 0) AS "Jan_Amt",
    IFNULL(Payment_Summary."Jan_Wages", 0) AS "Jan_Wages",

    IFNULL(Payment_Summary."Feb_Amt", 0) AS "Feb_Amt",
    IFNULL(Payment_Summary."Feb_Wages", 0) AS "Feb_Wages",

    IFNULL(Payment_Summary."Mar_Amt", 0) AS "Mar_Amt",
    IFNULL(Payment_Summary."Mar_Wages", 0) AS "Mar_Wages",

    IFNULL(Payment_Summary."Apr_Amt", 0) AS "Apr_Amt",
    IFNULL(Payment_Summary."Apr_Wages", 0) AS "Apr_Wages",

    IFNULL(Payment_Summary."May_Amt", 0) AS "May_Amt",
    IFNULL(Payment_Summary."May_Wages", 0) AS "May_Wages",

    IFNULL(Payment_Summary."Jun_Amt", 0) AS "Jun_Amt",
    IFNULL(Payment_Summary."Jun_Wages", 0) AS "Jun_Wages",

    IFNULL(Payment_Summary."Jul_Amt", 0) AS "Jul_Amt",
    IFNULL(Payment_Summary."Jul_Wages", 0) AS "Jul_Wages",

    IFNULL(Payment_Summary."Aug_Amt", 0) AS "Aug_Amt",
    IFNULL(Payment_Summary."Aug_Wages", 0) AS "Aug_Wages",

    IFNULL(Payment_Summary."Sep_Amt", 0) AS "Sep_Amt",
    IFNULL(Payment_Summary."Sep_Wages", 0) AS "Sep_Wages",

    IFNULL(Payment_Summary."Oct_Amt", 0) AS "Oct_Amt",
    IFNULL(Payment_Summary."Oct_Wages", 0) AS "Oct_Wages",

    IFNULL(Payment_Summary."Nov_Amt", 0) AS "Nov_Amt",
    IFNULL(Payment_Summary."Nov_Wages", 0) AS "Nov_Wages",

    IFNULL(Payment_Summary."Dec_Amt", 0) AS "Dec_Amt",
    IFNULL(Payment_Summary."Dec_Wages", 0) AS "Dec_Wages"

FROM "{?Schema@}"."OOAT" OOAT
INNER JOIN "{?Schema@}"."OAT1" OAT1 ON OOAT."AbsID" = OAT1."AgrNo" 
INNER JOIN "{?Schema@}"."OAT2" OAT2 ON OOAT."AbsID" = OAT2."AgrNo" AND OAT1."AgrLineNum" = OAT2."AgrEfctNum"
INNER JOIN "{?Schema@}".OFPR ON OOAT."StartDate" BETWEEN  OFPR."F_RefDate" AND OFPR."T_RefDate"
INNER JOIN "{?Schema@}"."OCRD" OCRD ON OOAT."BpCode" = OCRD."CardCode" 
LEFT JOIN (
    SELECT 
        PCH1."AgrNo",
        COUNT(DISTINCT OPCH."DocEntry") AS "Txn_Count",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 1 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Jan_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 1 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Jan_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 2 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Feb_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 2 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Feb_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 3 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Mar_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 3 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Mar_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 4 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Apr_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 4 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Apr_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 5 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "May_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 5 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "May_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 6 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Jun_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 6 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Jun_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 7 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Jul_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 7 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Jul_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 8 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Aug_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 8 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Aug_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 9 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Sep_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 9 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Sep_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 10 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Oct_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 10 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Oct_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 11 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Nov_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 11 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Nov_Wages",
        
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 12 THEN PCH1."U_SLD_Compensation" ELSE 0 END) AS "Dec_Amt",
        SUM(CASE WHEN MONTH(OPCH."DocDate") = 12 THEN PCH1."U_SLD_Wages" ELSE 0 END) AS "Dec_Wages"
    FROM "{?Schema@}"."PCH1" PCH1
    INNER JOIN "{?Schema@}"."OPCH" OPCH ON PCH1."DocEntry" = OPCH."DocEntry"
    WHERE OPCH."DocStatus" = 'C' AND OPCH.CANCELED = 'N'
    GROUP BY PCH1."AgrNo"
) AS Payment_Summary ON OOAT."AbsID" = Payment_Summary."AgrNo"
WHERE 1=1
AND LEFT(OFPR."Indicator", 4) = TO_VARCHAR( TO_INT({?Period@}) - 543 )
AND OCRD."QryGroup1" = 'Y'
AND OOAT."Cancelled" = 'N'
ORDER BY 
    OOAT."U_SLD_Contract_Number"
