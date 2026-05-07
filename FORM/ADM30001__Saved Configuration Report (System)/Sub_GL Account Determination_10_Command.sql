-- ============================================================
-- Report: ADM30001__Saved Configuration Report (System).rpt
Path:   ADM30001__Saved Configuration Report (System).rpt
Extracted: 2026-05-07 18:02:40
-- Source: Subreport [GL Account Determination]
-- Table:  Command
-- ============================================================

SELECT "VatCharge", "VendorDdct", "CustmrDdct", "DdctPercnt", "DdctExpire", "DfSVatExmp", "DfPVatExmp", "ChCtrAPAct", "ChCtrARAct", 
"SHandleWT", "SDfltWT", "PHandleWT", "PDfltWT", "CrtfcateNO", "ExpireDate", "NINum", "SDfltITWT", "PDfltITWT", "OnHldPert" FROM AADM WHERE "SnapShotId"={?SnapshotID}
