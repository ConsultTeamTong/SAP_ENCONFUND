-- ============================================================
-- Report: JDT20003__JE ENCONFUND (พลังงานจังหวัด).rpt
Path:   JDT20003__JE ENCONFUND (พลังงานจังหวัด).rpt
Extracted: 2026-05-07 18:03:12
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

WITH "ChangePoints" AS (
    SELECT
        C."TransId",
        MAX(CASE WHEN IFNULL(C."U_SLD_CreateBy",0)   <> IFNULL(P."U_SLD_CreateBy",0)
                 THEN C."LogInstanc" END) AS "CreateInst",
        MAX(CASE WHEN IFNULL(C."U_SLD_VerifiedBy",0) <> IFNULL(P."U_SLD_VerifiedBy",0)
                 THEN C."LogInstanc" END) AS "VerifyInst",
        MAX(CASE WHEN IFNULL(C."U_SLD_ApprovedBy",0) <> IFNULL(P."U_SLD_ApprovedBy",0)
                 THEN C."LogInstanc" END) AS "ApproveInst"
    FROM "{?Schema@}"."AJDT" C
    LEFT JOIN "{?Schema@}"."AJDT" P
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
    -- ✅ Fallback: ถ้าไม่มีใน AJDT แต่ OJDT มีค่า → ใช้ UpdateDate ของ OJDT
    CASE 
        WHEN DC."UpdateDate" IS NOT NULL THEN DC."UpdateDate"
        WHEN HEAD."U_SLD_CreateBy"   IS NOT NULL THEN HEAD."UpdateDate"
        ELSE NULL 
    END AS "วันที่จัดทำ",
    CASE 
        WHEN DV."UpdateDate" IS NOT NULL THEN DV."UpdateDate"
        WHEN HEAD."U_SLD_VerifiedBy" IS NOT NULL THEN HEAD."UpdateDate"
        ELSE NULL 
    END AS "วันที่ตรวจ",
    CASE 
        WHEN DA."UpdateDate" IS NOT NULL THEN DA."UpdateDate"
        WHEN HEAD."U_SLD_ApprovedBy" IS NOT NULL THEN HEAD."UpdateDate"
        ELSE NULL 
    END AS "วันที่ยืนยัน"
FROM "{?Schema@}"."OJDT" HEAD
LEFT JOIN "{?Schema@}"."OHEM" TC ON HEAD."U_SLD_CreateBy"   = TC."empID"
LEFT JOIN "{?Schema@}"."OHEM" TV ON HEAD."U_SLD_VerifiedBy" = TV."empID"
LEFT JOIN "{?Schema@}"."OHEM" TA ON HEAD."U_SLD_ApprovedBy" = TA."empID"
LEFT JOIN "{?Schema@}"."OHPS" HC ON HC."posID" = TC."position"
LEFT JOIN "{?Schema@}"."OHPS" HV ON HV."posID" = TV."position"
LEFT JOIN "{?Schema@}"."OHPS" HA ON HA."posID" = TA."position"
LEFT JOIN "ChangePoints" CP ON CP."TransId" = HEAD."TransId"
LEFT JOIN "{?Schema@}"."AJDT" DC
       ON DC."TransId" = HEAD."TransId" AND DC."LogInstanc" = CP."CreateInst"
LEFT JOIN "{?Schema@}"."AJDT" DV
       ON DV."TransId" = HEAD."TransId" AND DV."LogInstanc" = CP."VerifyInst"
LEFT JOIN "{?Schema@}"."AJDT" DA
       ON DA."TransId" = HEAD."TransId" AND DA."LogInstanc" = CP."ApproveInst"
WHERE HEAD."TransId" = {?DocKey@};
