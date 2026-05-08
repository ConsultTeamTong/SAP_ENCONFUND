-- ============================================================
-- Report: JDT20003__JE ENCONFUND (พลังงานจังหวัด).rpt
Path:   JDT20003__JE ENCONFUND (พลังงานจังหวัด).rpt
Extracted: 2026-05-07 18:03:12
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT 
    HEAD."TransId",
    RC."ReconNum",
    COALESCE(
    IFNULL(AP3."BeginStr", '') || CAST(AP1."DocNum" AS NVARCHAR(20)),
    IFNULL(AR3."BeginStr", '') ||  CAST(AR1."DocNum" AS NVARCHAR(20)),
    IFNULL(NC3."BeginStr", '') ||  CAST(NC1."DocNum" AS NVARCHAR(20)),
    IFNULL(OT3."BeginStr", '') || CAST(OT1."DocNum" AS NVARCHAR(20)),
    IFNULL(NC3."BeginStr", '') ||  CAST(NC1."DocNum" AS NVARCHAR(20))
    ) AS "เลขที่เอกสาร",
      COALESCE(AP2."CardCode",AR2."CardCode",NC2."CardCode",OTC."CardCode") AS "Customer/Vendor Code",
     COALESCE(AP2."CardName",AR2."CardName",NC2."CardName",OTC."CardName",T14."U_SLD_Vendor") AS "Customer/Vendor Name",
      HEAD."RefDate" AS " วันที่เอกสาร ",
TO_VARCHAR(ADD_YEARS( HEAD."CreateDate", 543), 'DD.MM.YYYY') AS "วันที่ทำรายการ",
TO_VARCHAR(ADD_YEARS( HEAD."RefDate", 543), 'DD.MM.YYYY') AS "DateThai",
    IFNULL(T6."BeginStr", '') ||  CAST(HEAD."Number" AS NVARCHAR(20)) AS "เลขที่เอกสาร JE",
    ACCT."FormatCode" AS "รหัสบัญชี",
    ACCT."AcctName" AS "ชื่อบัญชี",
    LINE."Debit",
    LINE."Credit",
    HEAD."Memo" AS "Remark ",
  HEAD."U_SLD_RefDoc" as "เอกสารอ้างอิง",
    HEAD."U_SLD_RefDocNo" as "เลขที่เอกสารอ้างอิง",
    LINE."OcrCode3" as "แผนงาน",
   LINE."OcrCode4" as "สำนัก",
    IFNULL(MAX(T14."U_SLD_ConfDocNo") OVER (PARTITION BY HEAD."TransId"), '') AS "เลขที่หนังสือยืนยัน",
    IFNULL(MAX(T13."U_U_SLD_Plan") OVER (PARTITION BY HEAD."TransId"), '') AS "แผนงาน",
    T14."U_SLD_ProjectName" AS "ชื่อโครงการ"
    ,LINE."OcrCode2"    
FROM "{?Schema@}"."OJDT" HEAD
INNER JOIN "{?Schema@}"."JDT1" LINE ON HEAD."TransId" = LINE."TransId"
LEFT JOIN "{?Schema@}"."ITR1" RC 
       ON HEAD."TransId"  = RC."TransId" 
      AND LINE."Line_ID"  = RC."TransRowId"
LEFT JOIN "{?Schema@}"."OITR" RH
       ON RC."ReconNum"   = RH."ReconNum"
      AND RH."Canceled"   = 'N'
LEFT JOIN "{?Schema@}"."OACT" ACCT ON LINE."Account" = ACCT."AcctCode"
INNER JOIN "{?Schema@}"."NNM1" T6 ON HEAD."Series" = T6."Series" 
LEFT JOIN "{?Schema@}"."OPMG" T13 ON HEAD."Project" = T13."FIPROJECT" 
LEFT JOIN "{?Schema@}"."OPRJ" T14 ON HEAD."Project" = T14."PrjCode"
LEFT JOIN  "{?Schema@}".OPCH AP1 ON HEAD."BaseRef" = AP1."DocNum" AND HEAD."TransType" = 18
LEFT JOIN  "{?Schema@}".OCRD AP2 ON AP1."CardCode" = AP2."CardCode"
LEFT JOIN  "{?Schema@}".NNM1 AP3 ON AP1."Series" = AP3."Series"
LEFT JOIN  "{?Schema@}".OINV AR1 ON HEAD."BaseRef" = AR1."DocNum" AND HEAD."TransType" = 13
LEFT JOIN  "{?Schema@}".OCRD AR2 ON AR1."CardCode" = AR2."CardCode"
LEFT JOIN  "{?Schema@}".NNM1 AR3 ON AR1."Series" = AR3."Series"
LEFT JOIN  "{?Schema@}".ORCT NC1 ON HEAD."BaseRef" = NC1."DocNum" AND HEAD."TransType" = 24
LEFT JOIN  "{?Schema@}".OCRD NC2 ON NC1."CardCode" = NC2."CardCode"
LEFT JOIN  "{?Schema@}".NNM1 NC3 ON NC1."Series" = NC3."Series"
LEFT JOIN  "{?Schema@}".OVPM OT1 ON HEAD."BaseRef" = OT1."DocNum" AND HEAD."TransType" = 46
LEFT JOIN  "{?Schema@}".OVPM OTC ON OT1."CardCode" = OTC."CardCode"
LEFT JOIN  "{?Schema@}".NNM1 OT3 ON OT1."Series" = OT3."Series"
WHERE (LINE."Debit" != 0 OR LINE."Credit" != 0)
  AND HEAD."TransId" = {?DocKey@}
  AND (RC."ReconNum" IS NULL OR RH."ReconNum" IS NOT NULL)
