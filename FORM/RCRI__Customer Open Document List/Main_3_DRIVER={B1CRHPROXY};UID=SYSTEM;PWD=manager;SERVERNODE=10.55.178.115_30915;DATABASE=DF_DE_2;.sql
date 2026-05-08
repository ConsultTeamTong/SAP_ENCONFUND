-- ============================================================
-- Report: RCRI0007__Customer Open Document List.rpt
Path:   RCRI0007__Customer Open Document List.rpt
Extracted: 2026-05-07 18:03:32
-- Source: Main Report
-- Table:  DRIVER={B1CRHPROXY};UID=SYSTEM;PWD=manager;SERVERNODE=10.55.178.115:30915;DATABASE=DF_DE_2;
-- ============================================================

CALL CRSP_OPEN_ITEM_LIST('{?DateType@}', TO_NVARCHAR({?DateValue@}, 'YYYYMMDD'), TO_NVARCHAR({?ReconDateValue@}, 'YYYYMMDD'), '{?CustomerCode@JOINFROM OCRD where "CardType"=    'C'}', '{?IncludeDPMRequest@}')
