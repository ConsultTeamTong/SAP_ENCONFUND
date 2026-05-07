-- ============================================================
-- Report: CLN10001__Calendar (Monthly) - CR (System).rpt
Path:   CLN10001__Calendar (Monthly) - CR (System).rpt
Extracted: 2026-05-07 18:02:51
-- Source: Main Report
-- Table:  DRIVER={B1CRHPROXY};UID=SYSTEM;PWD=manager;SERVERNODE=10.55.178.115:30915;DATABASE=DF_DE_2;
-- ============================================================

CALL CRSP_Calendar_Monthly_GrossActivities({?ActivityTypes}, '{?EmployeeIds}', {?FirstWeekDay}, '{?HolidaysCode}', '{?GotoDate}', '{?RecurringInstances_Month}', {?ShowEmployeeAbsEdu}, {?ShowPersonal}, {?ShowServiceCalls}, '{?UserIds}')
