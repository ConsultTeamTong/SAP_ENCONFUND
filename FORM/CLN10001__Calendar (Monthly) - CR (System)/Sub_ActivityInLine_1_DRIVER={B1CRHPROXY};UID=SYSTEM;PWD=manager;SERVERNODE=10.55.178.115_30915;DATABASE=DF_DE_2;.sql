-- ============================================================
-- Report: CLN10001__Calendar (Monthly) - CR (System).rpt
Path:   CLN10001__Calendar (Monthly) - CR (System).rpt
Extracted: 2026-05-07 18:02:51
-- Source: Subreport [ActivityInLine]
-- Table:  DRIVER={B1CRHPROXY};UID=SYSTEM;PWD=manager;SERVERNODE=10.55.178.115:30915;DATABASE=DF_DE_2;
-- ============================================================

CALL CRSP_Calendar_Monthly_ActivityInLine({?Activity1},{?Activity2},{?Activity3},{?Activity4},{?Activity5},{?Activity6},{?Activity7},
{?EmployeeAbsEdu1}, {?EmployeeAbsEdu2}, {?EmployeeAbsEdu3},{?EmployeeAbsEdu4}, {?EmployeeAbsEdu5},{?EmployeeAbsEdu6},{?EmployeeAbsEdu7},
 '{?EmployeeIDList}', 1,{?FirstWeekDay},'{?GotoDate}','{?HldCode}',{?ServiceCall1},{?ServiceCall2},{?ServiceCall3},{?ServiceCall4},{?ServiceCall5},{?ServiceCall6},{?ServiceCall7},'{?ServiceCallInstance1}','{?ServiceCallInstance2}','{?ServiceCallInstance3}','{?ServiceCallInstance4}','{?ServiceCallInstance5}','{?ServiceCallInstance6}','{?ServiceCallInstance7}',{?ShowEmployeeAbsEdu},{?ShowServiceCalls},'{?UserIds}')
