SELECT 
    CAST(T1."U_SLD_Contract_Number" AS NVARCHAR(250)) AS "เลขที่สัญญา",
    CAST(T1."U_SLD_Project_Name" AS NVARCHAR(250)) AS "รายการ",
    T1."BpName" AS "VENDER",
    T1."StartDate",
    T1."EndDate",
    SUM(T8."Credit") AS "Total_Credit",
    T9."BeginStr" || '' || T6."DocNum" AS "DocOut",
    T6."DocDate" AS "Out 1 Date",
TO_NVARCHAR(TO_INT(OFPR."Category") + 543) AS "Category",
RECON_PAY."BeginStr" || '' || RECON_PAY."DocNum" AS "Recon_DocOut",
    RECON_PAY."DocDate" AS "Recon_Out_Date"

FROM {?Schema@}.OOAT T1
LEFT JOIN {?Schema@}.OFPR ON T1."PIndicator" = OFPR."Code"
-- ลบ LEFT JOIN OAT1 T2 ออก เพื่อป้องกันยอด SUM ของ T8."Credit" เบิ้ลคูณตามจำนวนบรรทัดสินค้าในสัญญา
LEFT JOIN {?Schema@}.PCH1 T3  ON T1."AbsID" = T3."AgrNo" AND T3."LineNum" = '0'
LEFT JOIN {?Schema@}.OPCH T4  ON T3."DocEntry" = T4."DocEntry"
LEFT JOIN {?Schema@}.VPM2 T5  ON T4."DocEntry" = T5."DocEntry" 
LEFT JOIN {?Schema@}.OVPM T6  ON T5."DocNum" = T6."DocEntry" 
LEFT JOIN {?Schema@}.OJDT T7  ON T6."TransId" = T7."TransId" 
LEFT JOIN {?Schema@}.JDT1 T8  ON T7."TransId" = T8."TransId" AND T8."Account" = '_SYS00000000898'
LEFT JOIN {?Schema@}.NNM1 T9  ON T6."Series" = T9."Series"

-- --- ส่วนที่เพิ่มใหม่: Join OVPM (T6) เข้า Recon เพื่อหา AP และ Outgoing ใบที่จ่าย AP นั้น ---
LEFT JOIN (
    SELECT DISTINCT 
        R1."TransId" AS "Source_OVPM_TransId", -- TransId ของ OVPM ตัวตั้งต้น
        OUT_PAY."DocNum",
        OUT_PAY."DocDate",
        OUT_NM."BeginStr"
    FROM {?Schema@}.ITR1 R1
    -- 1. เอา AP ที่อยู่ในเลข Recon เดียวกัน (SrcObjTyp = '18' คือ A/P Invoice)
    INNER JOIN {?Schema@}.ITR1 R2 ON R1."ReconNum" = R2."ReconNum" 
                                         AND R1."TransId" <> R2."TransId" 
                                         AND R2."SrcObjTyp" = '18'
    -- 2. ดึง AP ใบนั้นมา (OPCH)
    INNER JOIN {?Schema@}.OPCH T_AP ON R2."TransId" = T_AP."TransId"
    -- 3. Join ไปที่ Outgoing (VPM2 -> OVPM) ที่ทำการจ่าย AP ใบนั้น
    INNER JOIN {?Schema@}.VPM2 V2 ON T_AP."DocEntry" = V2."DocEntry" AND V2."InvType" = '18'
    INNER JOIN {?Schema@}.OVPM OUT_PAY ON V2."DocNum" = OUT_PAY."DocEntry"
    INNER JOIN {?Schema@}.NNM1 OUT_NM ON OUT_PAY."Series" = OUT_NM."Series"
) RECON_PAY ON T6."TransId" = RECON_PAY."Source_OVPM_TransId"
-- -----------------------------------------------------------------------------------
WHERE (TO_NVARCHAR(TO_INT(OFPR."Category") + 543) ='{?Period@}' OR '{?Period@}' = '')
GROUP BY 
    CAST(T1."U_SLD_Contract_Number" AS NVARCHAR(250)),
    CAST(T1."U_SLD_Project_Name" AS NVARCHAR(250)),
    T1."BpName",
    T1."StartDate",
    T1."EndDate",
    T9."BeginStr",
    T6."DocNum",
    T6."DocDate",
    RECON_PAY."BeginStr",
    RECON_PAY."DocNum",
    RECON_PAY."DocDate",
    OFPR."Category"