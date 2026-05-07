-- ============================================================
-- Report: ADM30001__Saved Configuration Report (System).rpt
Path:   ADM30001__Saved Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:40
-- Source: Subreport [GL Account Determination]
-- Table:  DRIVER={B1CRHPROXY};UID=SYSTEM;PWD=manager;SERVERNODE=skbtsh001.btsl.sap.corp:30915;DATABASE=VK_1303_US;
-- ============================================================

SELECT * 
FROM (SELECT 10000 AS "LineNum", 'Credit Card Deposit Fee' AS "AcctDesc", "ComissAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ComissAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 10001 AS "LineNum", 'Credit Card Deposit Fee' AS "AcctDesc", "ComissAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ComissAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 10002 AS "LineNum", 'Rounding Account' AS "AcctDesc", "LinkAct_24" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_24" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "RoundMthd" 
        FROM OADM 
        WHERE "RoundMthd" = 'Y') 
    UNION 
    SELECT 10003 AS "LineNum", 'Automatic Reconciliation Diff.' AS "AcctDesc", "LinkAct_27" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_27" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 10004 AS "LineNum", 'Period-End Closing Account' AS "AcctDesc", "LinkAct_28" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_28" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 10005 AS "LineNum", 'G/L Revaluation Offset Account' AS "AcctDesc", "GlRvOffAct" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "GlRvOffAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblInfla" 
        FROM CINF 
        WHERE "EnblInfla" = 'Y') 
    UNION 
    SELECT 10006 AS "LineNum", 'REPOMO Revaluation Account' AS "AcctDesc", "RepomoAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "RepomoAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblInfla" 
        FROM CINF 
        WHERE "EnblInfla" = 'Y' AND "EnbRepomo" = 'Y') 
    UNION 
    SELECT 10007 AS "LineNum", 'Ex. Rate Diff. in All Curr. BP' AS "AcctDesc", "DfltRateDi" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "DfltRateDi" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblRealRD" 
        FROM CINF 
        WHERE "EnblRealRD" <> 'Y') 
    UNION 
    SELECT 10008 AS "LineNum", 'Realized Exchange Diff. Gain' AS "AcctDesc", "GLGainXdif" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "GLGainXdif" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblRealRD" 
        FROM CINF 
        WHERE "EnblRealRD" = 'Y') 
    UNION 
    SELECT 10009 AS "LineNum", 'Realized Exchange Diff. Loss' AS "AcctDesc", "GLLossXdif" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "GLLossXdif" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblRealRD" 
        FROM CINF 
        WHERE "EnblRealRD" = 'Y') 
    UNION 
    SELECT 10010 AS "LineNum", 'Opening Balance Account' AS "AcctDesc", "LinkAct_18" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_18" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 10011 AS "LineNum", 'Bank Charges Account' AS "AcctDesc", "BnkChgAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "BnkChgAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" <> 'IL') 
    UNION 
    SELECT 10012 AS "LineNum", 'Incoming CENVAT Clearing Acct' AS "AcctDesc", "ICClrAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ICClrAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'IN') 
    UNION 
    SELECT 10013 AS "LineNum", 'Outgoing CENVAT Clearing Acct' AS "AcctDesc", "OCClrAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "OCClrAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'IN') 
    UNION 
    SELECT 10014 AS "LineNum", 'PLA' AS "AcctDesc", "PlaAct" AS "AcctCode", "PeriodCat", AACP."SnapShotId", 
        "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "PlaAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'IN') 
    UNION 
    SELECT 10015 AS "LineNum", 'Ex Rate on Def Tax Account' AS "AcctDesc", "ExrateOnDt" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 1 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ExrateOnDt" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblDfrTax" 
        FROM CINF 
        WHERE "EnblDfrTax" = 'Y')) AS T1 
WHERE T1."PeriodCat" = '{?OACPCategory}' AND T1."SnapShotId" = {?SnapshotID} 
UNION 
SELECT * 
FROM (SELECT 20000 AS "LineNum", 'Domestic Accounts Receivable' AS "AcctDesc", "LinkAct_1" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_1" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20016 AS "LineNum", 'Domestic Accounts Receivable' AS "AcctDesc", "LinkAct_1" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_1" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20017 AS "LineNum", 'Foreign Accounts Receivable' AS "AcctDesc", "LinkAct_9" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_9" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20018 AS "LineNum", 'EU Accounts Receivable' AS "AcctDesc", "EURecvAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "EURecvAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'DE') 
    UNION 
    SELECT 20019 AS "LineNum", 'Checks Received' AS "AcctDesc", "LinkAct_2" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_2" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20020 AS "LineNum", 'Cash on Hand' AS "AcctDesc", "LinkAct_3" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_3" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20021 AS "LineNum", 'Bill of Exchange Presentation' AS "AcctDesc", "CBoEPresnt" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "CBoEPresnt" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnableBOE" 
        FROM CINF 
        WHERE "EnableBOE" = 'Y') AND (EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'IT') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'PT') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'BR')) 
    UNION 
    SELECT 20022 AS "LineNum", 'Bill of Exchange Discounted' AS "AcctDesc", "CBoEDiscnt" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "CBoEDiscnt" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnableBOE" 
        FROM CINF 
        WHERE "EnableBOE" = 'Y') AND (EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'PT') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'FR') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'BE') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CN') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'JP') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'KR') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'BR')) 
    UNION 
    SELECT 20023 AS "LineNum", 'Bill of Exchange on Collection' AS "AcctDesc", "CBoEOnClct" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "CBoEOnClct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnableBOE" 
        FROM CINF 
        WHERE "EnableBOE" = 'Y') AND (EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'FR') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'BE') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CN') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'JP') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'KR')) 
    UNION 
    SELECT 20024 AS "LineNum", 'Unpaid Bill of Exchange' AS "AcctDesc", "CUnpaidBoE" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "CUnpaidBoE" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnableBOE" 
        FROM CINF 
        WHERE "EnableBOE" = 'Y') AND (EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'FR') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'BE') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CN') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'JP') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'KR')) 
    UNION 
    SELECT 20025 AS "LineNum", 'Overpayment A/R Account' AS "AcctDesc", "OverpayAR" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "OverpayAR" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20026 AS "LineNum", 'Underpayment A/R Account' AS "AcctDesc", "UndrpayAR" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "UndrpayAR" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20027 AS "LineNum", 'Payment Advances' AS "AcctDesc", "DpmSalAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "DpmSalAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblDownP" 
        FROM CINF 
        WHERE "EnblDownP" = 'Y') AND (NOT EXISTS (SELECT "EnblDownP" 
        FROM CINF 
        WHERE "EnblDownP" = 'Y') OR (NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CN') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'JP') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'KR')) OR NOT EXISTS (SELECT "NewDPRCus" 
        FROM OADM 
        WHERE "NewDPRCus" = 'Y')) 
    UNION 
    SELECT 20028 AS "LineNum", 'Realized Exchange Diff. Gain' AS "AcctDesc", "LinkAct_26" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_26" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblRealRD" 
        FROM CINF 
        WHERE "EnblRealRD" = 'Y') 
    UNION 
    SELECT 20029 AS "LineNum", 'Realized Exchange Diff. Loss' AS "AcctDesc", "LinkAct_23" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_23" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblRealRD" 
        FROM CINF 
        WHERE "EnblRealRD" = 'Y') 
    UNION 
    SELECT 20030 AS "LineNum", 'Cash Discount' AS "AcctDesc", "LinkAct_22" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_22" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20031 AS "LineNum", 'Revenue Account' AS "AcctDesc", "DfltIncom" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "DfltIncom" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20032 AS "LineNum", 'Tax Exempt Revenue Account' AS "AcctDesc", "ExmptIncom" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ExmptIncom" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE NOT EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" = 'L') AND NOT EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" = 'C') 
    UNION 
    SELECT 20033 AS "LineNum", 'Revenue Account - Foreign' AS "AcctDesc", "ForgnIncm" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ForgnIncm" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblFrnAct" 
        FROM CINF 
        WHERE "EnblFrnAct" = 'Y') 
    UNION 
    SELECT 20034 AS "LineNum", 'Revenue Account - EU' AS "AcctDesc", "ECIncome" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ECIncome" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblECAct" 
        FROM CINF 
        WHERE "EnblECAct" = 'Y') 
    UNION 
    SELECT 20035 AS "LineNum", 'Sales Credit Account' AS "AcctDesc", "ARCMAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ARCMAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 20036 AS "LineNum", 'Tax Exempt Credit Account' AS "AcctDesc", "ARCMExpAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ARCMExpAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE NOT EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" = 'L') AND NOT EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" = 'C') 
    UNION 
    SELECT 20037 AS "LineNum", 'Sales Credit Account - Foreign' AS "AcctDesc", "ARCMFrnAct" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ARCMFrnAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblFrnAct" 
        FROM CINF 
        WHERE "EnblFrnAct" = 'Y') 
    UNION 
    SELECT 20038 AS "LineNum", 'Sales Credit Account - EU' AS "AcctDesc", "ARCMEUAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ARCMEUAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblECAct" 
        FROM CINF 
        WHERE "EnblECAct" = 'Y') 
    UNION 
    SELECT 20039 AS "LineNum", 'Other Receivable' AS "AcctDesc", "LinkAct_29" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_29" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "Version" 
        FROM CINF 
        WHERE "Version" < 880000) AND (EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CN') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'JP') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'KR')) 
    UNION 
    SELECT 20040 AS "LineNum", 'Down Payment Interim Account' AS "AcctDesc", "SalDpmInt" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 2 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "SalDpmInt" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblDownP" 
        FROM CINF 
        WHERE "EnblDownP" = 'Y') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CZ') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'SK') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'HU') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'PL') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'RU') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CN') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'KR') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'JP') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'US') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CA')) AS T2 
WHERE T2."PeriodCat" = '{?OACPCategory}' AND T2."SnapShotId" = {?SnapshotID} 
UNION 
SELECT * 
FROM (SELECT 30000 AS "LineNum", 'Customer''s Deduction at Source' AS "AcctDesc", "LinkAct_6" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 3 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "SalDpmInt" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 30041 AS "LineNum", 'Customer''s Deduction at Source' AS "AcctDesc", "LinkAct_6" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 3 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_6" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "CustmrDdct" 
        FROM OADM 
        WHERE "CustmrDdct" = 'Y') 
    UNION 
    SELECT 30042 AS "LineNum", 'Down Payment Tax Offset Acct' AS "AcctDesc", "SaleVatOff" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 3 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "SaleVatOff" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblDownP" 
        FROM CINF 
        WHERE "EnblDownP" = 'Y') AND (NOT EXISTS (SELECT "EnblDownP" 
        FROM CINF 
        WHERE "EnblDownP" = 'Y') OR (NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'US') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CA') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'BR'))) AND (NOT EXISTS (SELECT "EnblDownP" 
        FROM CINF 
        WHERE "EnblDownP" = 'Y') OR (NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CN') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'JP') AND NOT EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'KR'))) 
    UNION 
    SELECT 30043 AS "LineNum", 'Sales Tax Account' AS "AcctDesc", "LinkAct_5" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 3 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_5" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE NOT EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" = 'L') AND NOT EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" = 'C')) AS T3 
WHERE T3."PeriodCat" = '{?OACPCategory}' AND T3."SnapShotId" = {?SnapshotID} 
UNION 
SELECT * 
FROM (SELECT 40000 AS "LineNum", 'Domestic Accounts Payable' AS "AcctDesc", "LinkAct_10" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_10" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 40016 AS "LineNum", 'Domestic Accounts Payable' AS "AcctDesc", "LinkAct_10" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_10" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 40017 AS "LineNum", 'Foreign Accounts Payable' AS "AcctDesc", "LinkAct_11" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_11" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 40018 AS "LineNum", 'EU Accounts Payable' AS "AcctDesc", "EUPayAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "EUPayAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'DE') 
    UNION 
    SELECT 40019 AS "LineNum", 'Tax Definition' AS "AcctDesc", "LinkAct_14" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_14" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" <> 'L' AND "EnblVatGrp" <> 'C') 
    UNION 
    SELECT 40020 AS "LineNum", 'Equipment and Assets' AS "AcctDesc", "LinkAct_15" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_15" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" <> 'L' AND "EnblVatGrp" <> 'C') 
    UNION 
    SELECT 40021 AS "LineNum", 'Tax Payable' AS "AcctDesc", "LinkAct_13" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_13" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" <> 'L' AND "EnblVatGrp" <> 'C') AND NOT EXISTS (SELECT "VatCharge", "EnblSlfPCH" 
        FROM OADM, 
            CINF 
        WHERE "EnblSlfPCH" = 'Y' AND ("VatCharge" = 'Y' OR "LawsSet" = 'PL')) 
    UNION 
    SELECT 40022 AS "LineNum", 'Realized Exchange Diff. Gain' AS "AcctDesc", "LinkAct_25" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_25" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblRealRD" 
        FROM CINF 
        WHERE "EnblRealRD" = 'Y') 
    UNION 
    SELECT 40023 AS "LineNum", 'Realized Exchange Diff. Loss' AS "AcctDesc", "LinkAct_21" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_21" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblRealRD" 
        FROM CINF 
        WHERE "EnblRealRD" = 'Y') 
    UNION 
    SELECT 40024 AS "LineNum", 'Bank Transfer' AS "AcctDesc", "LinkAct_12" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_12" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 40025 AS "LineNum", 'Cash Discount' AS "AcctDesc", "LinkAct_19" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_19" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblCshDsc" 
        FROM CINF 
        WHERE "EnblCshDsc" <> 'N') 
    UNION 
    SELECT 40026 AS "LineNum", 'Cash Discount Clearing' AS "AcctDesc", "LinkAct_20" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_20" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblCshDsc" 
        FROM CINF 
        WHERE "EnblCshDsc" = 'Y') 
    UNION 
    SELECT 40027 AS "LineNum", 'Expense Account' AS "AcctDesc", "DfltExpn" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "DfltExpn" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 40028 AS "LineNum", 'Expense Account - Foreign' AS "AcctDesc", "ForgnExpn" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ForgnExpn" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblFrnAct" 
        FROM CINF 
        WHERE "EnblFrnAct" = 'Y') 
    UNION 
    SELECT 40029 AS "LineNum", 'Expense Account - EU' AS "AcctDesc", "ECExepnses" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ECExepnses" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblECAct" 
        FROM CINF 
        WHERE "EnblECAct" = 'Y') 
    UNION 
    SELECT 40030 AS "LineNum", 'Purchase Credit Account' AS "AcctDesc", "APCMAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "APCMAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 40031 AS "LineNum", 'Purchase Credit Acct - Foreign' AS "AcctDesc", "APCMFrnAct" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "APCMFrnAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblFrnAct" 
        FROM CINF 
        WHERE "EnblFrnAct" = 'Y') 
    UNION 
    SELECT 40032 AS "LineNum", 'Purchase Credit Account - EU' AS "AcctDesc", "APCMEUAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "APCMEUAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblECAct" 
        FROM CINF 
        WHERE "EnblECAct" = 'Y') 
    UNION 
    SELECT 40033 AS "LineNum", 'Overpayment A/P Account' AS "AcctDesc", "OverpayAP" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "OverpayAP" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 40034 AS "LineNum", 'Underpayment A/P Account' AS "AcctDesc", "UndrpayAP" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "UndrpayAP" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 40035 AS "LineNum", 'Payment Advances' AS "AcctDesc", "DpmPurAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "DpmPurAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblDownP" 
        FROM CINF 
        WHERE "EnblDownP" = 'Y') AND NOT EXISTS (SELECT "NewDPRCus" 
        FROM OADM, 
            CINF 
        WHERE "NewDPRCus" = 'Y' AND "EnblDownP" = 'Y' AND ("LawsSet" = 'KR' OR "LawsSet" = 'JP' OR "LawsSet" = 'CN')) 
    UNION 
    SELECT 40036 AS "LineNum", 'Expense and Inventory Account' AS "AcctDesc", "ExpVarAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ExpVarAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 40037 AS "LineNum", 'Amount Differences' AS "AcctDesc", "AmountDiff" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "AmountDiff" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'RU') 
    UNION 
    SELECT 40038 AS "LineNum", 'Other Payable' AS "AcctDesc", "LinkAct_30" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_30" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "Version" 
        FROM CINF 
        WHERE "Version" < 880000) AND (EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'CN') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'JP') OR EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'KR')) 
    UNION 
    SELECT 40039 AS "LineNum", 'Down Payment Interim Account' AS "AcctDesc", "PurDpmInt" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 4 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "PurDpmInt" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblDownP" 
        FROM CINF 
        WHERE "EnblDownP" = 'Y' AND "LawsSet" <> 'CZ' AND "LawsSet" <> 'SK' AND "LawsSet" <> 'HU' AND
             "LawsSet" <> 'PL' AND "LawsSet" <> 'RU' AND "LawsSet" <> 'CN' AND "LawsSet" <> 'KR' AND
             "LawsSet" <> 'JP' AND "LawsSet" <> 'US' AND "LawsSet" <> 'CA')) AS T4 
WHERE T4."PeriodCat" = '{?OACPCategory}' AND T4."SnapShotId" = {?SnapshotID} 
UNION 
SELECT * 
FROM (SELECT 50000 AS "LineNum", 'Withholding Tax' AS "AcctDesc", "LinkAct_16" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 5 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_16" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 50040 AS "LineNum", 'Withholding Tax' AS "AcctDesc", "LinkAct_16" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 5 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_16" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "VendorDdct" 
        FROM OADM 
        WHERE "VendorDdct" = 'Y') 
    UNION 
    SELECT 50041 AS "LineNum", 'Purchase Tax' AS "AcctDesc", "LinkAct_8" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 5 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "LinkAct_8" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblVatGrp" 
        FROM CINF 
        WHERE "EnblVatGrp" <> 'L' AND "EnblVatGrp" <> 'C') AND NOT EXISTS (SELECT "VatCharge" 
        FROM OADM, 
            CINF 
        WHERE ("VatCharge" = 'Y' OR "LawsSet" = 'PL') AND "EnblSlfPCH" = 'Y') 
    UNION 
    SELECT 50042 AS "LineNum", 'Down Payment Tax Offset Acct' AS "AcctDesc", "PurcVatOff" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 5 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "PurcVatOff" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblDownP" 
        FROM CINF 
        WHERE "EnblDownP" = 'Y' AND "LawsSet" <> 'RU' AND "LawsSet" <> 'US' AND "LawsSet" <> 'CA' AND
             "LawsSet" <> 'BR' AND "LawsSet" <> 'CN' AND "LawsSet" <> 'JP' AND "LawsSet" <> 'KR') 
    UNION 
    SELECT 50043 AS "LineNum", 'Capital Goods On Hold Account' AS "AcctDesc", "OnHoldAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 5 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "OnHoldAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'IN') 
    UNION 
    SELECT 50044 AS "LineNum", 'Self Invoice Revenue Account' AS "AcctDesc", "SlfInvIncm" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 5 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "SlfInvIncm" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "VatCharge" 
        FROM OADM, 
            CINF 
        WHERE ("VatCharge" = 'Y' OR "LawsSet" = 'PL') AND "EnblSlfPCH" = 'Y') 
    UNION 
    SELECT 50045 AS "LineNum", 'Self Invoice Expense Account' AS "AcctDesc", "SlfInvExpn" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 5 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "SlfInvExpn" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "VatCharge" 
        FROM OADM, 
            CINF 
        WHERE ("VatCharge" = 'Y' OR "LawsSet" = 'PL') AND "EnblSlfPCH" = 'Y')) AS T5 
WHERE T5."PeriodCat" = '{?OACPCategory}' AND T5."SnapShotId" = {?SnapshotID} 
UNION 
SELECT * 
FROM (SELECT 60000 AS "LineNum", 'Inventory Account' AS "AcctDesc", "StockAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "StockAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    UNION 
    SELECT 60049 AS "LineNum", 'Inventory Account' AS "AcctDesc", "StockAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "StockAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60050 AS "LineNum", 'Cost of Goods Sold Account' AS "AcctDesc", "COGM_Act" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "COGM_Act" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60051 AS "LineNum", 'Allocation Account' AS "AcctDesc", "AlocCstAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "AlocCstAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60052 AS "LineNum", 'Variance Account' AS "AcctDesc", "VariancAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "VariancAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60053 AS "LineNum", 'Price Difference Account' AS "AcctDesc", "PricDifAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "PricDifAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y' 
        UNION 
        SELECT "UsePaSys" 
        FROM OADM 
        WHERE "UsePaSys" <> 'Y' 
        UNION 
        SELECT "IsOldPA" 
        FROM CINF 
        WHERE "IsOldPA" <> 'Y') 
    UNION 
    SELECT 60054 AS "LineNum", 'Negative Inventory Adj. Acct' AS "AcctDesc", "NegStckAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "NegStckAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60055 AS "LineNum", 'Inventory Offset - Decr. Acct' AS "AcctDesc", "DfltLoss" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "DfltLoss" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60056 AS "LineNum", 'Inventory Offset - Incr. Acct' AS "AcctDesc", "DfltProfit" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "DfltProfit" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60057 AS "LineNum", 'Sales Returns Account' AS "AcctDesc", "RturnngAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "RturnngAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60062 AS "LineNum", 'Purchase Account' AS "AcctDesc", "PurchseAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "PurchseAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "UsePaSys" 
        FROM OADM 
        WHERE "UsePaSys" = 'Y') 
    UNION 
    SELECT 60063 AS "LineNum", 'Purchase Return Account' AS "AcctDesc", "PaReturnAc" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "PaReturnAc" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "UsePaSys" 
        FROM OADM 
        WHERE "UsePaSys" = 'Y') 
    UNION 
    SELECT 60064 AS "LineNum", 'Purchase Offset Account' AS "AcctDesc", "PaOffsetAc" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "PaOffsetAc" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "UsePaSys" 
        FROM OADM 
        WHERE "UsePaSys" = 'Y') 
    UNION 
    SELECT 60065 AS "LineNum", 'Exchange Rate Differences Account' AS "AcctDesc", "ExDiffAct" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ExDiffAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60066 AS "LineNum", 'Goods Clearing Account' AS "AcctDesc", "BalanceAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "BalanceAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y' 
        UNION 
        SELECT "UsePaSys" 
        FROM OADM 
        WHERE "UsePaSys" <> 'Y') 
    UNION 
    SELECT 60067 AS "LineNum", 'G/L Decrease Account' AS "AcctDesc", "DecresGlAc" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "DecresGlAc" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60068 AS "LineNum", 'G/L Increase Account' AS "AcctDesc", "IncresGlAc" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "IncresGlAc" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60069 AS "LineNum", 'WIP Inventory Account' AS "AcctDesc", "WipAcct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "WipAcct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60070 AS "LineNum", 'WIP Inventory Variance Account' AS "AcctDesc", "WipVarAcct" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "WipVarAcct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60071 AS "LineNum", 'Inventory Revaluation Account' AS "AcctDesc", "StockRvAct" AS "AcctCode", 
        "PeriodCat", AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "StockRvAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblInfla" 
        FROM CINF 
        WHERE "EnblInfla" = 'Y') 
    UNION 
    SELECT 60072 AS "LineNum", 'Inventory Reval. Offset Acct' AS "AcctDesc", "StkRvOfAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "StkRvOfAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblInfla" 
        FROM CINF 
        WHERE "EnblInfla" = 'Y') 
    UNION 
    SELECT 60073 AS "LineNum", 'COGS Revaluation Offset Acct' AS "AcctDesc", "CostRevAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "CostRevAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblInfla" 
        FROM CINF 
        WHERE "EnblInfla" = 'Y' OR "LawsSet" = 'MX' OR "LawsSet" = 'CR' OR "LawsSet" = 'GT') 
    UNION 
    SELECT 60074 AS "LineNum", 'COGS Revaluation Offset Acct' AS "AcctDesc", "CostOffAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "CostOffAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblInfla" 
        FROM CINF 
        WHERE "EnblInfla" = 'Y' OR "LawsSet" = 'MX' OR "LawsSet" = 'CR' OR "LawsSet" = 'GT') 
    UNION 
    SELECT 60075 AS "LineNum", 'Expense Clearing Account' AS "AcctDesc", "ExpClrAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ExpClrAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM 
        WHERE "ContInvnt" = 'Y') 
    UNION 
    SELECT 60076 AS "LineNum", 'Expense Offset Account' AS "AcctDesc", "ExpOfstAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ExpOfstAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "UsePaSys" 
        FROM OADM, 
            CINF 
        WHERE "UsePaSys" = 'Y' AND "IsOldPA" = 'Y') 
    UNION 
    SELECT 60077 AS "LineNum", 'Stock In Transit Account' AS "AcctDesc", "StkInTnAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "StkInTnAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "ContInvnt" 
        FROM OADM, 
            CINF 
        WHERE "ContInvnt" = 'Y' AND ("LawsSet" <> 'SG' OR "LawsSet" <> 'IN')) 
    UNION 
    SELECT 60078 AS "LineNum", 'Shipped Goods Account' AS "AcctDesc", "ShpdGdsAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "ShpdGdsAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblRuDIP" 
        FROM CINF 
        WHERE "EnblRuDIP" = 'Y') 
    UNION 
    SELECT 60079 AS "LineNum", 'VAT in Revenue Account' AS "AcctDesc", "VatRevAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "VatRevAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "EnblRuDIP" 
        FROM CINF 
        WHERE "EnblRuDIP" = 'Y') 
    UNION 
    SELECT 60087 AS "LineNum", 'Purchase Balance Account' AS "AcctDesc", "PurBalAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "PurBalAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "UsePaSys" 
        FROM OADM 
        WHERE "UsePaSys" = 'Y') 
    UNION 
    SELECT 60088 AS "LineNum", 'Incoming CENVAT Account (WH)' AS "AcctDesc", "WhICenAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "WhICenAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'IN') 
    UNION 
    SELECT 60089 AS "LineNum", 'Outgoing CENVAT Account (WH)' AS "AcctDesc", "WhOCenAct" AS "AcctCode", "PeriodCat", 
        AACP."SnapShotId", "FormatCode", "AcctName", 6 AS "Type" 
    FROM AACP 
        LEFT OUTER JOIN AACT ON "WhOCenAct" = "AcctCode" AND AACP."SnapShotId" = AACT."SnapShotId" 
    WHERE EXISTS (SELECT "LawsSet" 
        FROM CINF 
        WHERE "LawsSet" = 'IN')) AS T6 
WHERE T6."PeriodCat" = '{?OACPCategory}' AND T6."SnapShotId" = {?SnapshotID}
