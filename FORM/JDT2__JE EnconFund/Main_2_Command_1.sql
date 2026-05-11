-- ============================================================
-- Report: JDT20002__JE EnconFund.rpt
Path:   JDT20002__JE EnconFund.rpt
Extracted: 2026-05-07 18:03:11
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

WITH "ChangePoints" AS (
    SELECT 
        C."TransId",
        MAX(CASE WHEN IFNULL(CAST(C."U_SLD_CreateBy" AS NVARCHAR), '')   <> IFNULL(CAST(P."U_SLD_CreateBy" AS NVARCHAR), '')   
                 THEN C."LogInstanc" END) AS "CreateInst",
        MAX(CASE WHEN IFNULL(CAST(C."U_SLD_VerifiedBy" AS NVARCHAR), '') <> IFNULL(CAST(P."U_SLD_VerifiedBy" AS NVARCHAR), '') 
                 THEN C."LogInstanc" END) AS "VerifyInst",
        MAX(CASE WHEN IFNULL(CAST(C."U_SLD_ApprovedBy" AS NVARCHAR), '') <> IFNULL(CAST(P."U_SLD_ApprovedBy" AS NVARCHAR), '') 
                 THEN C."LogInstanc" END) AS "ApproveInst"
    FROM {?Schema@}."AJDT" C
    LEFT JOIN {?Schema@}."AJDT" P 
           ON P."TransId" = C."TransId" 
          AND P."LogInstanc" = C."LogInstanc" - 1
    GROUP BY C."TransId"
)
SELECT
    TC."lastName" || ' ' || TC."firstName" AS "ชื่อผู้จัดทำ",
    TV."lastName" || ' ' || TV."firstName" AS "ชื่อผู้ตรวจ",
    TA."lastName" || ' ' || TA."firstName" AS "ชื่อผู้ยืนยัน",
    HC."descriptio" AS "ตำแหน่งจัดทำ",
    HV."descriptio" AS "ตำแหน่งตรวจ",
    HA."descriptio" AS "ตำแหน่งยืนยัน",
    OBTF."CreateDate" AS "วันที่จัดทำ",
    HEAD."CreateDate" AS "วันที่ตรวจ",
    HEAD."CreateDate" AS "วันที่ยืนยัน"
FROM {?Schema@}."OJDT" HEAD
LEFT JOIN {?Schema@}."OHEM" TC ON CAST(HEAD."U_SLD_CreateBy" AS NVARCHAR)   = TC."lastName" || ' ' || TC."firstName"
LEFT JOIN {?Schema@}."OHEM" TV ON CAST(HEAD."U_SLD_VerifiedBy" AS NVARCHAR) = TV."lastName" || ' ' || TV."firstName"
LEFT JOIN {?Schema@}."OHEM" TA ON CAST(HEAD."U_SLD_ApprovedBy" AS NVARCHAR) = TA."lastName" || ' ' || TA."firstName"
LEFT JOIN {?Schema@}."OHPS" HC ON HC."posID" = TC."position"            
LEFT JOIN {?Schema@}."OHPS" HV ON HV."posID" = TV."position"
LEFT JOIN {?Schema@}."OHPS" HA ON HA."posID" = TA."position"
LEFT JOIN "ChangePoints" CP ON CP."TransId" = HEAD."TransId"
LEFT JOIN {?Schema@}."AJDT" DC 
       ON DC."TransId" = HEAD."TransId" AND DC."LogInstanc" = CP."CreateInst"
LEFT JOIN {?Schema@}."AJDT" DV 
       ON DV."TransId" = HEAD."TransId" AND DV."LogInstanc" = CP."VerifyInst"
LEFT JOIN {?Schema@}."AJDT" DA 
       ON DA."TransId" = HEAD."TransId" AND DA."LogInstanc" = CP."ApproveInst"       
LEFT JOIN {?Schema@}.OBTF ON HEAD."BatchNum" = OBTF."BatchNum"
LEFT JOIN {?Schema@}.OBTD ON OBTF."BatchNum" = OBTD."BatchNum"
  WHERE  HEAD."TransId" = {?DocKey@}