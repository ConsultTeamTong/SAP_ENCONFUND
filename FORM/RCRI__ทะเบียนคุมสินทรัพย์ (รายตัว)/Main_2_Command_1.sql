-- ============================================================
-- Report: RCRI0037__ทะเบียนคุมสินทรัพย์ (รายตัว).rpt
Path:   RCRI0037__ทะเบียนคุมสินทรัพย์ (รายตัว).rpt
Extracted: 2026-05-07 18:03:44
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT 
    T0."CapDate", 
        COALESCE(
        T0."U_SLD_Contract_Number", 
        (
            SELECT MAX(OOAT."U_SLD_Contract_Number") 
            FROM {?Schema@}.OAT1 
            INNER JOIN {?Schema@}.OOAT ON OAT1."AgrNo" = OOAT."AbsID" 
            WHERE OAT1."ItemCode" = T0."ItemCode" 
            AND T0."ItemCode" = '{?ItemCode@}'
        ),'-') AS "Contact No." ,
    T0."ItemName",
    1,
    T7."UsefulLife",
    T7."VisOrder",
      CASE
        WHEN T7."UsefulLife" > 0
        THEN CAST((100.0 / (T7."UsefulLife" / 12.0)) AS DECIMAL(10,2))
        ELSE 0
    END  AS "อัตราค่าเสื่อม (%)",
    GK."Name" ,
    T0."ItemCode",
    T0."ItemName" ,
    T1."LineTotal" ,
    T1."Quantity" ,
    T0."U_SLD_Work_Group" ,
    T0."U_SLD_Partner_Name" ,
    T0."U_SLD_Partner_Address" ,
    T0."U_SLD_Type" ,
    T0."U_SLD_Get" 
FROM {?Schema@}.OITM T0
INNER JOIN {?Schema@}.ACQ1 T1 ON T1."ItemCode" = T0."ItemCode"
INNER JOIN {?Schema@}.OACQ T2 ON T2."DocEntry"  = T1."DocEntry"
                                  AND T2."DocStatus" = 'P'
LEFT JOIN {?Schema@}.ITM7 T7 ON T0."ItemCode" = T7."ItemCode" AND T7."DprArea" = 'Posting'
INNER JOIN {?Schema@}."@SLD_GROUP_KRUPHAN" GK ON T0."U_SLD_Groupkruphan" = GK."Code"
WHERE T0."ItemType" = 'F'
  AND T0."ItemCode" = '{?ItemCode@}'
