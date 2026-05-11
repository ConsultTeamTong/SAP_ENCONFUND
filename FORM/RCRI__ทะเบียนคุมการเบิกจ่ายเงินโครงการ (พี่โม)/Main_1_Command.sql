SELECT * FROM (
    SELECT DISTINCT
        OPMG."AbsEntry",
        OPRJ."U_SLD_Period" AS "ปีงบประมาณ",
        OPMG."U_U_SLD_Plan" AS "แผนงาน",
        OPMG."U_U_SLD_WorkGroup" AS "กลุ่มงาน",
        OPRJ."U_SLD_ProjectName" AS "ชื่อโครงการ",
        OPMG."NAME" AS "หนังสือเลขที่",
        OPMG."CARDNAME" AS "ผู้ได้รับการสนับสนุน",
        'งวดที่' || ' ' || PMG1."StageID" AS "งวดเบิกจ่ายตามหนังสือยืนยัน",
        PMG1."EXPCOSTS" AS "จำนวนเงินตามหนังสือยืนยัน",

        CASE WHEN PMG1."CLOSE" IS NOT NULL THEN
            CAST(DAYOFMONTH(PMG1."CLOSE") AS NVARCHAR) || ' ' ||
            MAP(MONTH(PMG1."CLOSE"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
            || ' ' || TO_VARCHAR(ADD_YEARS(PMG1."CLOSE", 543), 'YY')
        END AS "วันที่เบิกจ่ายตามหนังสือยืนยันกำหนดส่ง",

        PMG2."U_U_SLD_InstAmt" AS "วงเงินตามสัญญาจ้าง",
        IFNULL(OPCH."PaidToDate",0) AS "เบิกจ่ายจริง",

        CASE WHEN OPCH."DocDate" IS NOT NULL THEN
            CAST(DAYOFMONTH(OPCH."DocDate") AS NVARCHAR) || ' ' ||
            MAP(MONTH(OPCH."DocDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
            || ' ' || TO_VARCHAR(ADD_YEARS(OPCH."DocDate", 543), 'YY')
        END AS "วันที่จ่ายจริง",

        Concat(NNM1."SeriesName", OPCH."DocNum") AS "DocNum",
                Concat(NNM2."SeriesName", OVPM."DocNum") AS "เอกสารจ่าย",

        
        CASE
            WHEN PMG1."StageID" IS NULL THEN 0
            WHEN IFNULL(PMG2."U_U_SLD_InstAmt",0) <= 0 AND IFNULL(OPCH."PaidToDate",0) > 0 THEN (IFNULL(PMG1."EXPCOSTS",0) - OPCH."PaidToDate")
            WHEN IFNULL(PMG2."U_U_SLD_InstAmt",0) > 0 AND IFNULL(OPCH."PaidToDate",0) <= 0 THEN (IFNULL(PMG1."EXPCOSTS",0) - IFNULL(PMG2."U_U_SLD_InstAmt",0))
            WHEN IFNULL(PMG2."U_U_SLD_InstAmt",0) > 0 AND IFNULL(OPCH."PaidToDate",0) > 0 THEN (IFNULL(PMG1."EXPCOSTS",0) - OPCH."PaidToDate")
            WHEN IFNULL(PMG2."U_U_SLD_InstAmt",0) > IFNULL(PMG1."EXPCOSTS",0) THEN 0
            ELSE 0
        END AS "ไม่ขอเบิกจ่าย",

        CASE WHEN OPMG."CLOSING" IS NOT NULL THEN
            CAST(DAYOFMONTH(OPMG."CLOSING") AS NVARCHAR) || ' ' ||
            MAP(MONTH(OPMG."CLOSING"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
            || ' ' || TO_VARCHAR(ADD_YEARS(OPMG."CLOSING", 543), 'YY')
        END AS "วันสิ้นสุดโครงการ",

        CASE WHEN OPMG."U_U_SLD_ExtEndDate" IS NOT NULL THEN
            CAST(DAYOFMONTH(OPMG."U_U_SLD_ExtEndDate") AS NVARCHAR) || ' ' ||
            MAP(MONTH(OPMG."U_U_SLD_ExtEndDate"), 1,'ม.ค.', 2,'ก.พ.', 3,'มี.ค.', 4,'เม.ย.', 5,'พ.ค.', 6,'มิ.ย.', 7,'ก.ค.', 8,'ส.ค.', 9,'ก.ย.', 10,'ต.ค.', 11,'พ.ย.', 12,'ธ.ค.')
            || ' ' || TO_VARCHAR(ADD_YEARS(OPMG."U_U_SLD_ExtEndDate", 543), 'YY')
        END AS "ขยายระยะเวลา",

        CASE
            WHEN PMG1."StageID" IS NULL THEN 0
            WHEN IFNULL(OPCH."PaidToDate",0) <= 0 AND IFNULL(PMG2."U_U_SLD_InstAmt",0) <= 0 THEN IFNULL(PMG1."EXPCOSTS",0)
            WHEN IFNULL(OPCH."PaidToDate",0) <= 0 AND IFNULL(PMG2."U_U_SLD_InstAmt",0) > 0 THEN IFNULL(PMG2."U_U_SLD_InstAmt",0)
            WHEN IFNULL(OPCH."PaidToDate",0) > 0 THEN 0
            ELSE IFNULL(PMG1."EXPCOSTS",0)
        END AS "คงเหลือเบิกจ่าย",

        CASE
            WHEN PMG1."StageID" IS NULL THEN 'ยังไม่ตั้งงวด'
            WHEN OPCH."PaidToDate" > 0 THEN 'เบิกจ่ายแล้ว'
            ELSE 'ยังไม่เบิก'
        END AS "สถานะการเบิกจ่าย",

        CASE
            WHEN COUNT(PMG1."StageID") OVER (PARTITION BY OPMG."AbsEntry") = 0
                THEN 'ยังไม่ตั้งงวด'
            WHEN SUM(CASE WHEN IFNULL(OPCH."PaidToDate", 0) > 0 THEN 1 ELSE 0 END) OVER (PARTITION BY OPMG."AbsEntry")
                 = COUNT(PMG1."StageID") OVER (PARTITION BY OPMG."AbsEntry")
                THEN 'เบิกครบ'
            WHEN SUM(CASE WHEN IFNULL(OPCH."PaidToDate", 0) > 0 THEN 1 ELSE 0 END) OVER (PARTITION BY OPMG."AbsEntry") > 0
                THEN 'ดำเนินงาน'
            ELSE 'ยังไม่เบิก'
        END AS "สถานะโครงการ(ภาพรวม)",

        OPMG."START",
        PMG1."StageID"

    FROM {?Schema@}.OPMG
    LEFT JOIN {?Schema@}.OPRJ ON OPMG."FIPROJECT" = OPRJ."PrjCode"
    LEFT JOIN {?Schema@}.PMG1 ON OPMG."AbsEntry" = PMG1."AbsEntry"
    LEFT JOIN {?Schema@}.PMG4 ON PMG1."AbsEntry" = PMG4."AbsEntry"
        AND PMG4."TYP" = 18
        AND PMG4."StageID" = PMG1."LineID"
    LEFT JOIN {?Schema@}.OPCH ON PMG4."DocEntry" = OPCH."DocEntry"
        AND OPCH."CANCELED" = 'N'
    LEFT JOIN {?Schema@}.PMG2 ON PMG1."AbsEntry" = PMG2."AbsEntry" 
        AND PMG1."StageID" = PMG2."PRIORITY"
    LEFT JOIN {?Schema@}.NNM1 ON OPCH."Series" = NNM1."Series"
    LEFT JOIN {?Schema@}.VPM2 
    ON OPCH."DocEntry" = VPM2."DocEntry" 
    AND VPM2."InvType" = 18               
LEFT JOIN {?Schema@}.OVPM 
    ON VPM2."DocNum" = OVPM."DocEntry"    
LEFT JOIN {?Schema@}.NNM1 NNM2 
    ON OVPM."Series" = NNM2."Series"        
) AS "DEV"
WHERE 1=1
AND (DEV."ปีงบประมาณ" = '{?Period@}' OR '{?Period@}' = ' ')
AND (DEV."สถานะโครงการ(ภาพรวม)" = '{?Status@}' OR '{?Status@}' = ' ')
AND (DEV."หนังสือเลขที่" = '{?BookCon@}' OR '{?BookCon@}' = ' ')
AND DEV."START" BETWEEN {?1DStart@} AND {?2DEnd@} 
ORDER BY DEV."AbsEntry", DEV."StageID";
-----------------------กรณีขึ้นทุกงวด