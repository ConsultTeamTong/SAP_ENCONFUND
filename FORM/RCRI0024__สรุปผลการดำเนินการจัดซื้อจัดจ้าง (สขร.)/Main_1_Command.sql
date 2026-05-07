-- ============================================================
-- Report: RCRI0024__สรุปผลการดำเนินการจัดซื้อจัดจ้าง (สขร.).rpt
Path:   RCRI0024__สรุปผลการดำเนินการจัดซื้อจัดจ้าง (สขร.).rpt
Extracted: 2026-05-07 18:03:40
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT A1."U_SLD_Contract_Amount" ,
A1."U_SLD_Procurement_Method" ,
A1."Number",
A1."Remarks"  ,
A1."Descript" ,
A1."U_SLD_Contract_Number",
A1."SignDate" ,
A1."U_SLD_Average_Price" ,
A1."U_SLD_Offered_Price" ,
A2."CardName"

FROM {?Schema@}.OOAT A1
Inner join {?Schema@}.OCRD A2 on A1."BpCode" = A2."CardCode"

WHERE 1=1
AND (A1."SignDate" >= {?StartSignDate@} AND A1."SignDate" <= {?EndSignDate@})

