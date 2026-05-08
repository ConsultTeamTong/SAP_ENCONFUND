-- ============================================================
-- Report: A0050001__Withholding Tax certificate (53) v28.rpt
Path:   A0050001__Withholding Tax certificate (53) v28.rpt
Extracted: 2026-05-07 18:02:34
-- Source: Main Report
-- Table:  Command
-- ============================================================


SELECT STRING_AGG("Ref"."TxNo",', ') AS "StrAggRef"
FROM(
SELECT 
CASE WHEN VPM2."InvType" = '30' THEN CAST(OJDT."TransId" AS NVARCHAR)
				WHEN VPM2."InvType" = '18' THEN OPCH."NumAtCard"
				WHEN VPM2."InvType" = '19' THEN ORPC."NumAtCard"
				WHEN VPM2."InvType" = '204' THEN ODPO."NumAtCard"
		End AS "TxNo"
		,OVPM."TransId"
FROM {?Schema@}.OVPM
LEFT JOIN {?Schema@}.VPM2 ON OVPM."DocEntry" = VPM2."DocNum"
LEFT JOIN {?Schema@}.OPCH ON VPM2."DocEntry" = OPCH."DocEntry"
LEFT JOIN {?Schema@}.ORPC ON VPM2."DocEntry" = ORPC."DocEntry"
LEFT JOIN {?Schema@}.ODPO ON VPM2."DocEntry" = ODPO."DocEntry"
LEFT JOIN {?Schema@}.OJDT ON VPM2."DocEntry" = OJDT."TransId"
UNION ALL
SELECT JDT1."U_SLD_TAXNo" AS "TxNo",JDT1."TransId"
FROM {?Schema@}.JDT1
WHERE JDT1."ShortName" = 
		(SELECT "AcctCode" 
			FROM {?Schema@}.OACT 
			WHERE "FormatCode" = 
			(SELECT "Name" 
				FROM {?Schema@}."@SLDT_SET_ACCWH" 
				WHERE "U_SLD_TypeWH" = '53'))
) "Ref"
WHERE "Ref"."TransId" IN ({?DocKey@})
