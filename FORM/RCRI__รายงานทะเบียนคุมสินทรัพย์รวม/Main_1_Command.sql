-- ============================================================
-- Report: RCRI0019__รายงานทะเบียนคุมสินทรัพย์รวม.rpt
Path:   RCRI0019__รายงานทะเบียนคุมสินทรัพย์รวม.rpt
Extracted: 2026-05-07 18:03:37
-- Source: Main Report
-- Table:  Command
-- ============================================================

  SELECT
      A1."ItmsGrpCod",
      A2."ItmsGrpNam" AS "ประเภทครุภัณฑ์",
      A1."ItemCode" AS "เลขที่หรือรหัส",
      A1."CapDate" AS "วัน/เดือน/ปี",
      A1."U_SLD_Get" AS "วิธีการได้มา",
      A1."U_SLD_Work_Group" AS "dept",
      A5."Location" AS "สถานที่ตั้ง",
      A1."LastPurPrc" AS "ราคาต่อหน่วย(บาท)",
      A1."U_SLD_Status",
      A1."ItemName" AS "ยี่ห้อ ชนิด แบบ ขนาดและลักษณะ",
      CASE
          WHEN A1."U_SLD_Vendor" IS NOT NULL AND A1."U_SLD_Vendor" <> '' THEN 'จ้างเหมา'
          WHEN A3."firstName" IS NOT NULL AND A3."firstName" <> '' THEN 'พนักงาน'
          ELSE ''
      END AS "ประเภทผู้ดำเนินการ",
      CASE
          WHEN A1."U_SLD_Vendor" IS NOT NULL AND A1."U_SLD_Vendor" <> '' THEN A1."U_SLD_Vendor"
          ELSE IFNULL(A3."firstName", '') || ' ' || IFNULL(A3."lastName", '')
      END AS "ชื่อผู้ดำเนินการ",
      OFPR."Category"
  FROM {?Schema@}."OITM" A1
  LEFT JOIN {?Schema@}."OITB" A2
      ON A1."ItmsGrpCod" = A2."ItmsGrpCod"
  LEFT JOIN {?Schema@}."OHEM" A3
      ON A1."Employee" = A3."empID"
  LEFT JOIN {?Schema@}."OUDP" A4
      ON A3."dept" = A4."Code"
  LEFT JOIN {?Schema@}."OLCT" A5
      ON A1."Location" = A5."Code"
  LEFT JOIN {?Schema@}."@SLD_LIST_KRUPHAN" A7
      ON A1."U_SLD_Listkruphan" = A7."Code"
  INNER JOIN {?Schema@}.OFPR ON A1."CapDate" BETWEEN OFPR."F_RefDate" AND OFPR."T_RefDate" AND  OFPR."Category" BETWEEN ({?dateFrom@}-543) AND ({?dateTo@}-543)
  WHERE A1."ItemType" = 'F'
