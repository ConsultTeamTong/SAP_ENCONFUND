-- ============================================================
-- Report: RCT10006__Incoming Enconfund.rpt
Path:   RCT10006__Incoming Enconfund.rpt
Extracted: 2026-05-07 18:03:46
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

WITH "ChangePoints" AS (
    SELECT
        C."DocEntry",
        MAX(CASE WHEN IFNULL(C."U_SLD_CreateBy",'') <> IFNULL(P."U_SLD_CreateBy",'')
                 THEN C."LogInstanc" END) AS "CreateInst",
        MAX(CASE WHEN IFNULL(C."U_SLD_REV",'')      <> IFNULL(P."U_SLD_REV",'')
                 THEN C."LogInstanc" END) AS "VerifyInst",
        MAX(CASE WHEN IFNULL(C."U_SLD_APP",'')      <> IFNULL(P."U_SLD_APP",'')
                 THEN C."LogInstanc" END) AS "ApproveInst"
    FROM "{?Schema@}"."ARCT" C
    LEFT JOIN "{?Schema@}"."ARCT" P
           ON P."DocEntry"   = C."DocEntry"
          AND P."LogInstanc" = C."LogInstanc" - 1
    GROUP BY C."DocEntry"
)
SELECT
    HEAD."DocEntry",
    HEAD."DocNum",
    HEAD."U_SLD_CreateBy" AS "ชื่อผู้จัดทำ",
    HEAD."U_SLD_REV"      AS "ชื่อผู้ตรวจ",
    HEAD."U_SLD_APP"      AS "ชื่อผู้ยืนยัน",
    HC."descriptio" AS "ตำแหน่งจัดทำ",
    HV."descriptio" AS "ตำแหน่งตรวจ",
    HA."descriptio" AS "ตำแหน่งยืนยัน",
    DC."UpdateDate" AS "วันที่จัดทำ",
    DV."UpdateDate" AS "วันที่ตรวจ",
    DA."UpdateDate" AS "วันที่ยืนยัน"
FROM "{?Schema@}"."ORCT" HEAD
LEFT JOIN "{?Schema@}"."OHEM" TC 
       ON HEAD."U_SLD_CreateBy" = IFNULL(TC."lastName",'') || ' ' || IFNULL(TC."firstName",'')
LEFT JOIN "{?Schema@}"."OHEM" TV 
       ON HEAD."U_SLD_REV"      = IFNULL(TV."lastName",'') || ' ' || IFNULL(TV."firstName",'')
LEFT JOIN "{?Schema@}"."OHEM" TA 
       ON HEAD."U_SLD_APP"      = IFNULL(TA."lastName",'') || ' ' || IFNULL(TA."firstName",'')
LEFT JOIN "{?Schema@}"."OHPS" HC ON HC."posID" = TC."position"
LEFT JOIN "{?Schema@}"."OHPS" HV ON HV."posID" = TV."position"
LEFT JOIN "{?Schema@}"."OHPS" HA ON HA."posID" = TA."position"
LEFT JOIN "ChangePoints" CP ON CP."DocEntry" = HEAD."DocEntry"
LEFT JOIN "{?Schema@}"."ARCT" DC
       ON DC."DocEntry"   = HEAD."DocEntry"
      AND DC."LogInstanc" = CP."CreateInst"
LEFT JOIN "{?Schema@}"."ARCT" DV
       ON DV."DocEntry"   = HEAD."DocEntry"
      AND DV."LogInstanc" = CP."VerifyInst"
LEFT JOIN "{?Schema@}"."ARCT" DA
       ON DA."DocEntry"   = HEAD."DocEntry"
      AND DA."LogInstanc" = CP."ApproveInst"
WHERE HEAD."DocEntry" = {?DocKey@}
