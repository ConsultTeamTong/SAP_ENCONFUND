-- ============================================================
-- Report: RCRI0021__ทะเบียนคุมสินทรัพย์ (ตามกลุ่ม).rpt
Path:   RCRI0021__ทะเบียนคุมสินทรัพย์ (ตามกลุ่ม).rpt
Extracted: 2026-05-07 18:03:38
-- Source: Main Report
-- Table:  Command
-- ============================================================

  WITH params AS (                                                     
    SELECT                                                             
      {?1DStart@}                                                      
            AS asof_date,                                              
      CASE WHEN MONTH({?1DStart@}) >= 10                               
           THEN YEAR({?1DStart@}) + 1                                  
           ELSE YEAR({?1DStart@}) END                                  
            AS y0,                                                     
      '{?ItemGroup@}'                                                  
            AS item_group_filter                                       
    FROM DUMMY                                                         
  ),                                                                   
  src AS (                                                             
    SELECT                                                             
      A1."ItemCode",                                                   
      A1."ItemName",                                                   
      A1."AcqDate"
            AS acq_date,
      COALESCE(NULLIF(A6.apc, 0), NULLIF(A5."Total", 0), A1."LastPurPrc", 0)
            AS cost,
      A1."AssetClass"
            AS asset_class_code,
      A1."ItmsGrpCod"
            AS itm_grp_cod,
      A2."ItmsGrpNam"
            AS item_group_name,
      A3."Name"
            AS sld_fix_01_name,
      A4."Name"
            AS sld_y_name,
      A1."U_SLD_Work_Group"
            AS sld_work_group,
      CASE
        WHEN LOCATE(A1."AssetClass", '-') > 0
          THEN TO_INTEGER(SUBSTR(A1."AssetClass",
                                 LOCATE(A1."AssetClass", '-') + 1))
        ELSE 0
      END
            AS life_years
    FROM {?Schema@}."OITM" A1
    LEFT JOIN {?Schema@}."OITB"                A2 ON A1."ItmsGrpCod"
  = A2."ItmsGrpCod"
    LEFT JOIN {?Schema@}."@SLD_FIX_01"         A3 ON A1."U_SLD_FIX_01"
  = A3."Code"
    LEFT JOIN {?Schema@}."@SLD_FIXED_ASSETS_Y" A4 ON A1."U_SLD_Y"
  = A4."Code"
    LEFT JOIN {?Schema@}."ACQ3"                A5 ON A1."ItemCode"
  = A5."ItemCode" AND A5."DprArea" = 'Posting'
    LEFT JOIN (
      SELECT i."ItemCode", MAX(i."APC") AS apc
      FROM {?Schema@}."ITM8" i
      WHERE i."DprArea" = 'Posting'
      GROUP BY i."ItemCode"
    )                                          A6 ON A1."ItemCode"
  = A6."ItemCode"
    WHERE A1."ItemType" = 'F'
  ),
  odpv_agg AS (
    SELECT
      o."ItemCode",
      MAX(CASE WHEN MONTH(o."FromDate") >= 10 THEN YEAR(o."FromDate")+1
   ELSE YEAR(o."FromDate") END) AS max_fy,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0-5 THEN
  o."OrdDprPlan" END) AS dep_y0,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0-4 THEN
  o."OrdDprPlan" END) AS dep_y1,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0-3 THEN
  o."OrdDprPlan" END) AS dep_y2,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0-2 THEN
  o."OrdDprPlan" END) AS dep_y3,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0-1 THEN
  o."OrdDprPlan" END) AS dep_y4,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0+0 THEN
  o."OrdDprPlan" END) AS dep_y5,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0+1 THEN
  o."OrdDprPlan" END) AS dep_y6,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0+2 THEN
  o."OrdDprPlan" END) AS dep_y7,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0+3 THEN
  o."OrdDprPlan" END) AS dep_y8,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) = p.y0+4 THEN
  o."OrdDprPlan" END) AS dep_y9,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0-5 THEN
  o."OrdDprPlan" END) AS cum_y0,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0-4 THEN
  o."OrdDprPlan" END) AS cum_y1,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0-3 THEN
  o."OrdDprPlan" END) AS cum_y2,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0-2 THEN
  o."OrdDprPlan" END) AS cum_y3,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0-1 THEN
  o."OrdDprPlan" END) AS cum_y4,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0+0 THEN
  o."OrdDprPlan" END) AS cum_y5,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0+1 THEN
  o."OrdDprPlan" END) AS cum_y6,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0+2 THEN
  o."OrdDprPlan" END) AS cum_y7,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0+3 THEN
  o."OrdDprPlan" END) AS cum_y8,
      SUM(CASE WHEN (CASE WHEN MONTH(o."FromDate") >= 10 THEN
  YEAR(o."FromDate")+1 ELSE YEAR(o."FromDate") END) <= p.y0+4 THEN
  o."OrdDprPlan" END) AS cum_y9
    FROM {?Schema@}."ODPV" o CROSS JOIN params p
    WHERE o."DprArea" = 'Posting'
    GROUP BY o."ItemCode"
  ),
  calc AS (
    SELECT
      s.*, p.asof_date, p.y0,
      CASE WHEN s.life_years > 0
        THEN DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1
        ELSE 1 END
           AS life_days,
      CASE WHEN s.life_years > 0 THEN 1 ELSE 0 END
           AS depr,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0-6)||'-09-30','YYYY-MM-DD')) + 1)) AS d_prev,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0-5)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y0,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0-4)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y1,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0-3)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y2,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0-2)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y3,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0-1)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y4,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0+0)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y5,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0+1)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y6,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0+2)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y7,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0+3)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y8,
      GREATEST(0, LEAST(
        DAYS_BETWEEN(s.acq_date, ADD_DAYS(ADD_YEARS(s.acq_date,
  s.life_years), -1)) + 1,
        DAYS_BETWEEN(s.acq_date,
  TO_DATE(TO_VARCHAR(p.y0+4)||'-09-30','YYYY-MM-DD')) + 1)) AS d_y9
    FROM src s CROSS JOIN params p
    WHERE ('{?ItemGroup@}' = '' OR s.itm_grp_cod = '{?ItemGroup@}')
  )
  SELECT
    ROW_NUMBER() OVER (ORDER BY c.acq_date ASC NULLS LAST, c."ItemCode")
           AS "ลำดับที่",
    c.acq_date
           AS "วัน/เดือน/ปี",
    c."ItemCode"
           AS "เลขที่/รหัส",
    c."ItemName"
           AS "ชื่อ ชนิด แบบ ขนาดและลักษณะ",
    CASE WHEN c.depr = 0 THEN c.cost END
           AS "ราคา (ต่ำกว่าเกณฑ์)",
    CASE WHEN c.depr = 1 THEN c.cost END
           AS "ราคา (ตามเกณฑ์)",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-5 > IFNULL(o.max_fy,0) THEN (c.d_y0 -
  c.d_prev)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y0,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y0",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-5 > IFNULL(o.max_fy,0) THEN
  c.d_y0*c.cost/c.life_days
           ELSE IFNULL(o.cum_y0,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y0",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-4 > IFNULL(o.max_fy,0) THEN (c.d_y1 -
  c.d_y0)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y1,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y1",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-4 > IFNULL(o.max_fy,0) THEN
  c.d_y1*c.cost/c.life_days
           ELSE IFNULL(o.cum_y1,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y1",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-3 > IFNULL(o.max_fy,0) THEN (c.d_y2 -
  c.d_y1)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y2,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y2",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-3 > IFNULL(o.max_fy,0) THEN
  c.d_y2*c.cost/c.life_days
           ELSE IFNULL(o.cum_y2,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y2",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-2 > IFNULL(o.max_fy,0) THEN (c.d_y3 -
  c.d_y2)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y3,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y3",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-2 > IFNULL(o.max_fy,0) THEN
  c.d_y3*c.cost/c.life_days
           ELSE IFNULL(o.cum_y3,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y3",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-1 > IFNULL(o.max_fy,0) THEN (c.d_y4 -
  c.d_y3)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y4,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y4",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0-1 > IFNULL(o.max_fy,0) THEN
  c.d_y4*c.cost/c.life_days
           ELSE IFNULL(o.cum_y4,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y4",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+0 > IFNULL(o.max_fy,0) THEN (c.d_y5 -
  c.d_y4)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y5,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y5",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+0 > IFNULL(o.max_fy,0) THEN
  c.d_y5*c.cost/c.life_days
           ELSE IFNULL(o.cum_y5,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y5",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+1 > IFNULL(o.max_fy,0) THEN (c.d_y6 -
  c.d_y5)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y6,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y6",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+1 > IFNULL(o.max_fy,0) THEN
  c.d_y6*c.cost/c.life_days
           ELSE IFNULL(o.cum_y6,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y6",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+2 > IFNULL(o.max_fy,0) THEN (c.d_y7 -
  c.d_y6)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y7,0) END
          
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y7",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+2 > IFNULL(o.max_fy,0) THEN
  c.d_y7*c.cost/c.life_days
           ELSE IFNULL(o.cum_y7,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y7",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+3 > IFNULL(o.max_fy,0) THEN (c.d_y8 -
  c.d_y7)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y8,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y8",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+3 > IFNULL(o.max_fy,0) THEN
  c.d_y8*c.cost/c.life_days
           ELSE IFNULL(o.cum_y8,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y8",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+4 > IFNULL(o.max_fy,0) THEN (c.d_y9 -
  c.d_y8)*c.cost/c.life_days
           ELSE IFNULL(o.dep_y9,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อม Y9",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+4 > IFNULL(o.max_fy,0) THEN
  c.d_y9*c.cost/c.life_days
           ELSE IFNULL(o.cum_y9,0) END
    ELSE 0 END,2)
            AS "ค่าเสื่อมสะสม Y9",
    ROUND(CASE WHEN c.depr=1 THEN
      CASE WHEN c.y0+4 > IFNULL(o.max_fy,0) THEN c.cost -
  c.d_y9*c.cost/c.life_days
           ELSE c.cost - IFNULL(o.cum_y9,0) END
    ELSE c.cost END,2)
            AS "มูลค่าบัญชี/ปัจจุบัน Y9",
    c.life_years
            AS "อายุใช้งาน (ปี)",
    c.item_group_name
            AS "กลุ่มสินค้า",
    c.sld_fix_01_name
            AS "ที่มาของเงิน",
    c.sld_y_name
            AS "ปีงบประมาณ",
    c.sld_work_group
            AS "กลุ่มงาน"
  FROM calc c
  LEFT JOIN odpv_agg o ON c."ItemCode" = o."ItemCode"
  ORDER BY c.acq_date ASC NULLS LAST, c."ItemCode";
