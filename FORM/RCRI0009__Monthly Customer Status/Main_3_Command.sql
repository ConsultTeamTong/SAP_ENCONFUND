-- ============================================================
-- Report: RCRI0009__Monthly Customer Status.rpt
Path:   RCRI0009__Monthly Customer Status.rpt
Extracted: 2026-05-07 18:03:33
-- Source: Main Report
-- Table:  Command
-- ============================================================

CALL "{?Schema@}".CRSP_BPRANGE('{?Custs@JOINFROM OCRD where "CardType"= 'C'}')
