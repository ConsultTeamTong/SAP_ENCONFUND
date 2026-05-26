WITH
  LatestDoc AS (
      SELECT
          H."U_FiscalYear",
          L."U_BudgetCode",
          MAX(H."DocEntry") AS "MaxDocEntry"
      FROM SBO_ENCONFUND_BUDGET."@SLD_BUDGET_HD" H
      INNER JOIN SBO_ENCONFUND_BUDGET."@SLD_BUDGET_LN" L ON L."DocEntry" = H."DocEntry"
      WHERE L."U_selected" = 'Y' AND L."U_BudgetCode" <> ''
      GROUP BY H."U_FiscalYear", L."U_BudgetCode"
  ),

  BaseDoc AS (
      SELECT
          H."U_FiscalYear",
          L."U_BudgetCode",
          (MAX(H."DocEntry")-1) AS "BaseDocEntry"
      FROM SBO_ENCONFUND_BUDGET."@SLD_BUDGET_HD" H
      INNER JOIN SBO_ENCONFUND_BUDGET."@SLD_BUDGET_LN" L ON L."DocEntry" = H."DocEntry"
      WHERE L."U_selected" = 'Y' AND H."U_BudgetStatus" <> 'Transfer Budget'
        AND L."U_BudgetCode" <> ''
      GROUP BY H."U_FiscalYear", L."U_BudgetCode"
  ),

  SummaryData AS (
      SELECT
          "BudgetCode",
          SUM("CommittedStd") AS "CommittedStd",
          SUM("CommittedAdv") AS "CommittedAdv",
          SUM("Actual")       AS "Actual",
          SUM("Remaining")    AS "Remaining"
      FROM SBO_ENCONFUND_BUDGET.SLD_VW_BUDGET_SUMMARY
      GROUP BY "BudgetCode"
  ),

  MonthlySummary AS (
      SELECT
          "BudgetCode",
          SUM("M01") AS "M01", SUM("M02") AS "M02", SUM("M03") AS "M03",
          SUM("M04") AS "M04", SUM("M05") AS "M05", SUM("M06") AS "M06",
          SUM("M07") AS "M07", SUM("M08") AS "M08", SUM("M09") AS "M09",
          SUM("M10") AS "M10", SUM("M11") AS "M11", SUM("M12") AS "M12"
      FROM SBO_ENCONFUND_BUDGET.SLD_VW_BUDGET_SUMMARY_MONTHLY
      GROUP BY "BudgetCode"
  ),

  PBADetail AS (
      SELECT
          "Name"                                          AS "BudgetCode",
          MIN("Code")                                     AS "PBA_Code",
          MAX(CAST("U_SLD_Blanket"    AS NVARCHAR(254)))  AS "PBA_Blanket",
          MAX(CAST("U_SLD_PBA_Remark" AS NVARCHAR(5000))) AS "PBA_Remark"
      FROM SBO_ENCONFUND_BUDGET."@SLD_PBA_BUDGET"
      GROUP BY "Name"
  ),

  PBAOwn AS (
      SELECT "Name" AS "BudgetCode", SUM("U_SLD_PBA_Amount") AS "PBA_Amount"
      FROM SBO_ENCONFUND_BUDGET."@SLD_PBA_BUDGET"
      GROUP BY "Name"
  ),

  LeafCalc AS (
      SELECT
          L."U_BudgetCode"           AS "BudgetCode",
          L."U_BudgetAmt"            AS "BudgetAmt",
          IFNULL(SD."Actual", 0)     AS "Actual",
          IFNULL(PO."PBA_Amount", 0) AS "PBA_Amount"
      FROM LatestDoc LD
      INNER JOIN SBO_ENCONFUND_BUDGET."@SLD_BUDGET_LN" L
              ON L."DocEntry"     = LD."MaxDocEntry"
             AND L."U_BudgetCode" = LD."U_BudgetCode"
      LEFT JOIN SummaryData SD ON SD."BudgetCode" = L."U_BudgetCode"
      LEFT JOIN PBAOwn      PO ON PO."BudgetCode" = L."U_BudgetCode"
  ),

  Tree AS (
      SELECT "U_BudgetCode", "U_FatherCode"
      FROM SBO_ENCONFUND_BUDGET."@SLD_BUDGET_LN"
      WHERE "DocEntry" = (
          SELECT MAX(H."DocEntry")
          FROM SBO_ENCONFUND_BUDGET."@SLD_BUDGET_HD" H
          WHERE H."U_FiscalYear" = '2026'
      )
        AND "U_selected" = 'Y' AND "U_BudgetCode" <> ''
  ),

  FlatTree AS (
      SELECT "U_BudgetCode" AS "LeafCode", "U_BudgetCode" AS "AncestorCode" FROM Tree
      UNION ALL
      SELECT T1."U_BudgetCode", T2."U_BudgetCode" FROM Tree T1 INNER JOIN Tree T2 ON T1."U_FatherCode" = T2."U_BudgetCode"
      UNION ALL
      SELECT T1."U_BudgetCode", T3."U_BudgetCode" FROM Tree T1 INNER JOIN Tree T2 ON T1."U_FatherCode" = T2."U_BudgetCode" INNER JOIN Tree T3 ON T2."U_FatherCode" = T3."U_BudgetCode"
      UNION ALL
      SELECT T1."U_BudgetCode", T4."U_BudgetCode" FROM Tree T1 INNER JOIN Tree T2 ON T1."U_FatherCode" = T2."U_BudgetCode" INNER JOIN Tree T3 ON T2."U_FatherCode" = T3."U_BudgetCode" INNER JOIN Tree T4 ON T3."U_FatherCode" = T4."U_BudgetCode"
      UNION ALL
      SELECT T1."U_BudgetCode", T5."U_BudgetCode" FROM Tree T1 INNER JOIN Tree T2 ON T1."U_FatherCode" = T2."U_BudgetCode" INNER JOIN Tree T3 ON T2."U_FatherCode" = T3."U_BudgetCode" INNER JOIN Tree T4 ON T3."U_FatherCode" = T4."U_BudgetCode" INNER JOIN Tree T5 ON T4."U_FatherCode" = T5."U_BudgetCode"
      UNION ALL
      SELECT T1."U_BudgetCode", T6."U_BudgetCode" FROM Tree T1 INNER JOIN Tree T2 ON T1."U_FatherCode" = T2."U_BudgetCode" INNER JOIN Tree T3 ON T2."U_FatherCode" = T3."U_BudgetCode" INNER JOIN Tree T4 ON T3."U_FatherCode" = T4."U_BudgetCode" INNER JOIN Tree T5 ON T4."U_FatherCode" = T5."U_BudgetCode" INNER JOIN Tree T6 ON T5."U_FatherCode" = T6."U_BudgetCode"
  ),

  RollupSummary AS (
      SELECT
          FT."AncestorCode",
          SUM(S."CommittedStd") AS "CommittedStd",
          SUM(S."CommittedAdv") AS "CommittedAdv",
          SUM(S."Actual")       AS "Actual",
          SUM(S."Remaining")    AS "Remaining"
      FROM FlatTree FT
      INNER JOIN SummaryData S ON S."BudgetCode" = FT."LeafCode"
      GROUP BY FT."AncestorCode"
  ),

  RollupMonthly AS (
      SELECT
          FT."AncestorCode",
          SUM(MS."M01") AS "M01", SUM(MS."M02") AS "M02", SUM(MS."M03") AS "M03",
          SUM(MS."M04") AS "M04", SUM(MS."M05") AS "M05", SUM(MS."M06") AS "M06",
          SUM(MS."M07") AS "M07", SUM(MS."M08") AS "M08", SUM(MS."M09") AS "M09",
          SUM(MS."M10") AS "M10", SUM(MS."M11") AS "M11", SUM(MS."M12") AS "M12"
      FROM FlatTree FT
      INNER JOIN MonthlySummary MS ON MS."BudgetCode" = FT."LeafCode"
      GROUP BY FT."AncestorCode"
  ),

  RollupPBA AS (
      SELECT
          FT."AncestorCode",
          SUM(P."U_SLD_PBA_Amount") AS "PBA_Amount"
      FROM FlatTree FT
      INNER JOIN SBO_ENCONFUND_BUDGET."@SLD_PBA_BUDGET" P ON P."Name" = FT."LeafCode"
      GROUP BY FT."AncestorCode"
  ),

  RollupPBAExpen AS (
      SELECT
          FT."AncestorCode",
          SUM(CASE WHEN LC."PBA_Amount" > 0
                   THEN LC."BudgetAmt" - LC."PBA_Amount"
                   ELSE 0 END) AS "PBA_Expen",
          SUM(CASE WHEN LC."PBA_Amount" > 0
                   THEN LC."Actual"    - LC."PBA_Amount"
                   ELSE 0 END) AS "PBA_Balanc"
      FROM FlatTree FT
      INNER JOIN LeafCalc LC ON LC."BudgetCode" = FT."LeafCode"
      GROUP BY FT."AncestorCode"
  ),

  -- ============== NEW: ยอดใช้ (Used) ที่ระดับ leaf BudgetCode ==============
  -- ยอดใช้ = CommittedAmt + ActualAmt ; ActualAmt = 0 เมื่อแถวนั้นมี RefDocNumber
  -- ใช้ IFNULL กัน RefDocNumber ที่อาจเป็น NULL (ปกติเก็บ '' แต่กันเหนียว)
  UsedDetail AS (
      SELECT
          "BudgetCode",
          SUM("CommittedAmt" + CASE WHEN IFNULL("RefDocNumber", '') <> '' THEN 0 ELSE "ActualAmt" END) AS "UsedAmt"
      FROM SBO_ENCONFUND_BUDGET."SLD_VW_BUDGET_DETAIL"
      WHERE "FiscalYear" = 2026
      GROUP BY "BudgetCode"
  ),

  -- ============== MOCKUP (2026-05-22): Diff = "รับคืนเงิน" ที่ระดับ leaf ==============
  -- ยอดจริงคำนวณไม่ได้: RefDocNumber ใน SLD_VW_BUDGET_DETAIL ว่าง ('') 273/274 แถว
  --   -> join Committed<->Actual ไม่ติด ได้ 0 ทุกแถว
  -- ชั่วคราว: hardcode ยอดรับคืนเงินเดือนมีนา "ที่ระดับ leaf BudgetCode"
  --   RollupDiff ด้านล่างจะ SUM ขึ้น tree ให้เอง (เหมือน RollupUsed / RollupSummary)
  --   -> แถว Title ทุก Level จะได้ยอดรวมของลูกหลานอัตโนมัติ
  -- เมื่อมีแหล่งข้อมูลจริงแล้ว ให้คืน CTE คำนวณ Committed-Actual กลับ
  DiffDetail AS (
      SELECT '212103' AS "BudgetCode", CAST(-6700.00  AS DECIMAL(19,6)) AS "DiffAmt" FROM DUMMY
      UNION ALL
      SELECT '212105' AS "BudgetCode", CAST(-14160.93 AS DECIMAL(19,6)) AS "DiffAmt" FROM DUMMY
      UNION ALL
      SELECT '212302' AS "BudgetCode", CAST(-21703.00 AS DECIMAL(19,6)) AS "DiffAmt" FROM DUMMY
  ),

  -- ============== NEW: roll Used ขึ้น tree เหมือน RollupSummary ==============
  RollupUsed AS (
      SELECT
          FT."AncestorCode",
          SUM(UD."UsedAmt") AS "UsedAmt"
      FROM FlatTree FT
      INNER JOIN UsedDetail UD ON UD."BudgetCode" = FT."LeafCode"
      GROUP BY FT."AncestorCode"
  ),

  -- ============== NEW: roll Diff ขึ้น tree ==============
  RollupDiff AS (
      SELECT
          FT."AncestorCode",
          SUM(DD."DiffAmt") AS "DiffAmt"
      FROM FlatTree FT
      INNER JOIN DiffDetail DD ON DD."BudgetCode" = FT."LeafCode"
      GROUP BY FT."AncestorCode"
  )

SELECT
    H."DocEntry"                                AS "BudgetDocEntry",
    (CAST(H."U_FiscalYear" AS INT) + 543)       AS "FiscalYear",
    L."U_BudgetCode"                            AS "BudgetCode",
    L."U_Name"                                  AS "BudgetName",
    L."U_Type",
    L."U_Level",

    IFNULL(BASE_L."U_BudgetAmt", L."U_BudgetAmt")
            AS "ReceivedBudget",
    (L."U_BudgetAmt" - IFNULL(BASE_L."U_BudgetAmt", L."U_BudgetAmt"))
            AS "TransferAmt",
    L."U_BudgetAmt"
            AS "NewBudget",

    IFNULL(RS."CommittedStd", 0)                AS "CommittedStd",
    IFNULL(RS."CommittedAdv", 0)                AS "CommittedAdv",
    -- เปลี่ยน: เดิม IFNULL(RS."Actual",0) -> ตอนนี้ใช้ "ยอดใช้" (alias คงเป็น "Actual")
    IFNULL(RU."UsedAmt", 0)                     AS "Actual",
    IFNULL(RS."Remaining", 0)                   AS "Remaining",
    -- Diff = "รับคืนเงิน" : ยอด mockup จาก DiffDetail แล้ว roll ขึ้น tree ผ่าน RollupDiff
    IFNULL(RD."DiffAmt", 0)                     AS "Diff",

    IFNULL(RM."M01", 0) AS "M01", IFNULL(RM."M02", 0) AS "M02", IFNULL(RM."M03", 0) AS "M03",
    IFNULL(RM."M04", 0) AS "M04", IFNULL(RM."M05", 0) AS "M05", IFNULL(RM."M06", 0) AS "M06",
    IFNULL(RM."M07", 0) AS "M07", IFNULL(RM."M08", 0) AS "M08", IFNULL(RM."M09", 0) AS "M09",
    IFNULL(RM."M10", 0) AS "M10", IFNULL(RM."M11", 0) AS "M11", IFNULL(RM."M12", 0) AS "M12",

    PBA."PBA_Code"               AS "PBA_Code",
    PBA."PBA_Blanket"            AS "PBA_Blanket",
    PBA."PBA_Remark"             AS "PBA_Remark",
    IFNULL(RP."PBA_Amount", 0)   AS "PBA_Amount",

    IFNULL(RPE."PBA_Expen", 0)   AS "PBA_Expen",
    IFNULL(RPE."PBA_Balanc", 0)  AS "PBA_Balanc"

FROM LatestDoc LD
INNER JOIN SBO_ENCONFUND_BUDGET."@SLD_BUDGET_HD" H
        ON H."DocEntry" = LD."MaxDocEntry"
INNER JOIN SBO_ENCONFUND_BUDGET."@SLD_BUDGET_LN" L
        ON L."DocEntry" = LD."MaxDocEntry"
       AND L."U_BudgetCode" = LD."U_BudgetCode"

LEFT JOIN BaseDoc BD
       ON BD."U_FiscalYear" = LD."U_FiscalYear"
      AND BD."U_BudgetCode" = LD."U_BudgetCode"
LEFT JOIN SBO_ENCONFUND_BUDGET."@SLD_BUDGET_LN" BASE_L
       ON BASE_L."DocEntry"     = BD."BaseDocEntry"
      AND BASE_L."U_BudgetCode" = BD."U_BudgetCode"

LEFT JOIN RollupSummary  RS  ON RS."AncestorCode"  = L."U_BudgetCode"
LEFT JOIN RollupMonthly  RM  ON RM."AncestorCode"  = L."U_BudgetCode"
LEFT JOIN PBADetail      PBA ON PBA."BudgetCode"   = L."U_BudgetCode"
LEFT JOIN RollupPBA      RP  ON RP."AncestorCode"  = L."U_BudgetCode"
LEFT JOIN RollupPBAExpen RPE ON RPE."AncestorCode" = L."U_BudgetCode"
LEFT JOIN RollupUsed     RU  ON RU."AncestorCode"  = L."U_BudgetCode"
LEFT JOIN RollupDiff     RD  ON RD."AncestorCode"  = L."U_BudgetCode"

WHERE L."U_BudgetCode" <> ''
AND H."U_FiscalYear" = '2026'
ORDER BY L."LineId";