-- ============================================================
-- Report: PDN20002__Good Rec.rpt
Path:   PDN20002__Good Rec.rpt
Extracted: 2026-05-07 18:03:18
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
    HEAD."TransId",
    IFNULL(OT3."BeginStr", '') || CAST(OT1."DocNum" AS NVARCHAR(20)) AS "เลขที่เอกสาร",
    OT1."CardCode" AS "Customer/Vendor Code",
    OT1."CardName" AS "Customer/Vendor Name",
    OT1."DocDate" AS " วันที่เอกสาร ",
    TO_VARCHAR(ADD_YEARS(OT1."DocDate", 543), 'DD.MM.YYYY') AS "DateThai",
    ACCT."FormatCode" AS "รหัสบัญชี",
    ACCT."AcctName" AS "ชื่อบัญชี",
    LINE."Debit",
    LINE."Credit",
    HEAD."Memo" AS "Remark ",
    IFNULL(T2."firstName", '') || ' ' || IFNULL(T2."lastName", '') AS "ชื่อผู้จัดทำ",
    IFNULL(MAX(T14."U_SLD_ConfDocNo") OVER (PARTITION BY HEAD."TransId"), '') AS "เลขที่หนังสือยืนยัน",
    IFNULL(MAX(T13."U_U_SLD_Plan") OVER (PARTITION BY HEAD."TransId"), '') AS "แผนงาน",
    T14."U_SLD_ProjectName" AS "ชื่อโครงการ"
FROM {?Schema@}."OPDN" OT1
-- เชื่อมเอา Series ของ OPDN
LEFT JOIN {?Schema@}."NNM1" OT3 ON OT1."Series" = OT3."Series"
-- เชื่อมไปหา Journal Entry Header ด้วย TransId (เชื่อมได้ตรงตัวและชัวร์ที่สุด)
LEFT JOIN {?Schema@}."OJDT" HEAD ON OT1."TransId" = HEAD."TransId"
-- เชื่อมไปหา Journal Entry Lines
LEFT JOIN {?Schema@}."JDT1" LINE ON HEAD."TransId" = LINE."TransId"
-- เชื่อมไปหาผังบัญชี
LEFT JOIN {?Schema@}."OACT" ACCT ON LINE."Account" = ACCT."AcctCode"
-- เชื่อมไปหาพนักงานผู้จัดทำ
LEFT JOIN {?Schema@}."OUSR" T1 ON HEAD."UserSign" = T1."USERID"
LEFT JOIN {?Schema@}."OHEM" T2 ON T1."USERID" = T2."userId"
-- เชื่อมหา Series ของ OJDT และ Project
LEFT JOIN {?Schema@}."NNM1" T6 ON HEAD."Series" = T6."Series" 
LEFT JOIN {?Schema@}."OPMG" T13 ON HEAD."Project" = T13."FIPROJECT" 
LEFT JOIN {?Schema@}."OPRJ" T14 ON HEAD."Project" = T14."PrjCode"

-- สามารถใส่ WHERE OT1."DocDate" >= '2025-01-01' ตรงนี้ได้ถ้าต้องการกรองข้อมูล


WHERE (LINE."Debit" != 0 OR LINE."Credit" != 0)
AND OT1."DocEntry" = {?DocKey@}
