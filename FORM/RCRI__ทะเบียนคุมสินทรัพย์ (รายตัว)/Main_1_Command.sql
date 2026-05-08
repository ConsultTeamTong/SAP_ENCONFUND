-- ============================================================
-- Report: RCRI0037__ทะเบียนคุมสินทรัพย์ (รายตัว).rpt
Path:   RCRI0037__ทะเบียนคุมสินทรัพย์ (รายตัว).rpt
Extracted: 2026-05-07 18:03:44
-- Source: Main Report
-- Table:  Command
-- ============================================================

WITH asset_base AS (
    SELECT
        T0."ItemCode",
        T0."ItemName",
        T0."CapDate",
        T7."DprArea",
        T7."UsefulLife",
        T7."DprStart",
        T7."DprEnd",
        (SELECT COALESCE(SUM(L."LineTotal"), 0)
           FROM {?Schema@}.ACQ1 L
           INNER JOIN {?Schema@}.OACQ H ON H."DocEntry" = L."DocEntry"
          WHERE L."ItemCode"  = T0."ItemCode"
            AND H."CancelOpt" = '1')                              AS "APC"
    FROM {?Schema@}.OITM T0
    INNER JOIN {?Schema@}.ITM7 T7 ON T0."ItemCode" = T7."ItemCode"
    WHERE T0."ItemType" = 'F'
      AND T0."ItemCode" = '{?ItemCode@}'
      AND T7."DprArea"  = 'Posting'
),
yearly_agg AS (
    SELECT
        ab."ItemCode",
        ab."CapDate",
        ab."DprArea",
        ab."APC",
        TO_INT(D."PeriodCat")                                     AS "FiscalYearCE",
        MIN(D."FromDate")                                         AS "Year_StartDate",
        MAX(D."ToDate")                                           AS "Year_EndDate",
        SUM(DAYS_BETWEEN(D."FromDate", D."ToDate") + 1)           AS "TotalDays",
        SUM(D."OrdDprPlan")                                       AS "Planned_Year",
        SUM(D."OrdDprAct")                                        AS "Posted_Year"
    FROM asset_base ab
    INNER JOIN {?Schema@}.ODPV D
            ON D."ItemCode" = ab."ItemCode"
           AND D."DprArea"  = ab."DprArea"
    GROUP BY ab."ItemCode", ab."CapDate", ab."DprArea", ab."APC", D."PeriodCat"
)
SELECT
    "ItemCode",
    "CapDate",
    "DprArea",
    TO_NVARCHAR("FiscalYearCE" + 543)                             AS "FiscalYear",
    "Year_StartDate",
    "Year_EndDate",
    "TotalDays",
    ROUND("APC", 2)                                               AS "APC",
    ROUND("Planned_Year", 2)                                      AS "Planned_Depreciation",
    ROUND("Posted_Year", 2)                                       AS "Posted_Depreciation",
    ROUND(SUM("Planned_Year") OVER (
              PARTITION BY "ItemCode", "DprArea"
              ORDER BY "FiscalYearCE"
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)  AS "Accum_Planned",
    ROUND(SUM("Posted_Year")  OVER (
              PARTITION BY "ItemCode", "DprArea"
              ORDER BY "FiscalYearCE"
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)  AS "Accum_Posted",
    ROUND("APC" - SUM("Planned_Year") OVER (
              PARTITION BY "ItemCode", "DprArea"
              ORDER BY "FiscalYearCE"
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)  AS "NBV_Plan",
    ROUND("APC" - SUM("Posted_Year")  OVER (
              PARTITION BY "ItemCode", "DprArea"
              ORDER BY "FiscalYearCE"
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)  AS "NBV_Posted"
FROM yearly_agg
ORDER BY "FiscalYearCE";
