-- ============================================================
-- Report: CLN20001__Calendar (Weekly) - CR (System).rpt
Path:   CLN20001__Calendar (Weekly) - CR (System).rpt
Extracted: 2026-05-07 18:02:52
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

Call "{?Schema@}".CRSP_Public_CrossDays_Items({?ActivityTypes}, '{?EmployeeIds}', '{?UserIds}', {?FirstWeekDay}, '{?GotoDate}', '{?HolidaysCode}', '{?RecurringInstances_MD}', {?ShowEmployeeAbsEdu}, {?ShowPersonal}, {?ShowServiceCalls})
