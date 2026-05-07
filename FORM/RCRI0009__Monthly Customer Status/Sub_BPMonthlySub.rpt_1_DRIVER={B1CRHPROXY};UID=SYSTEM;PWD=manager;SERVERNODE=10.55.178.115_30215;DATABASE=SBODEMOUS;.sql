-- ============================================================
-- Report: RCRI0009__Monthly Customer Status.rpt
Path:   RCRI0009__Monthly Customer Status.rpt
Extracted: 2026-05-07 18:03:33
-- Source: Subreport [BPMonthlySub.rpt]
-- Table:  DRIVER={B1CRHPROXY};UID=SYSTEM;PWD=manager;SERVERNODE=10.55.178.115:30215;DATABASE=SBODEMOUS;
-- ============================================================

CALL "{?Schema}".CRSP_BPMONTHLY_WRAPPER({?FromDate}, {?ToDate},'{?DateType}','{?Custs}')
