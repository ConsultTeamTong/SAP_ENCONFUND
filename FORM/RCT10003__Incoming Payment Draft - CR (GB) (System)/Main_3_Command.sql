-- ============================================================
-- Report: RCT10003__Incoming Payment Draft - CR (GB) (System).rpt
Path:   RCT10003__Incoming Payment Draft - CR (GB) (System).rpt
Extracted: 2026-05-07 18:03:45
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT                                                                                                                                               
		"PDF2"."DocNum" "PDF2_DocNum",                                                                                                                   
		"PDF2"."InvType" "PDF2_InvType", "PDF2"."DocEntry" "PDF2_DocEntry", "PDF2"."SumApplied" "PDF2_SumApplied", "PDF2"."AppliedSys" "PDF2_AppliedSys",
		"PDF2"."AppliedFC" "PDF2_AppliedFC", "PDF2"."InstId" "PDF2_InstId",                                                                              
		"OJDT"."DueDate" "OJDT_DueDate", "OJDT"."Number" "OJDT_Number", "OJDT"."TransId" "OJDT_TransId",                                                 
		"JDT1"."FCCurrency" "JDT1_FCCurrency",                                                                                                           
		"OINV"."DocDate" "OINV_DocDate", "OINV"."NumAtCard" "OINV_NumAtCard", "OINV"."DocCur" "OINV_DocCur", "OINV"."DocNum" "OINV_DocNum",              
		"OINV"."DocEntry" "OINV_DocEntry", "OINV"."Installmnt" "OINV_Installmnt",                                                                        
		"ORIN"."DocDate" "ORIN_DocDate", "ORIN"."NumAtCard" "ORIN_NumAtCard", "ORIN"."DocCur" "ORIN_DocCur", "ORIN"."DocNum" "ORIN_DocNum",              
		"ORIN"."DocEntry" "ORIN_DocEntry", "ORIN"."Installmnt" "ORIN_Installmnt",                                                                        
		"OPCH"."DocDate" "OPCH_DocDate", "OPCH"."NumAtCard" "OPCH_NumAtCard", "OPCH"."DocCur" "OPCH_DocCur", "OPCH"."DocNum" "OPCH_DocNum",              
		"OPCH"."DocEntry" "OPCH_DocEntry", "OPCH"."Installmnt" "OPCH_Installmnt",                                                                        
		"ORPC"."DocDate" "ORPC_DocDate", "ORPC"."NumAtCard" "ORPC_NumAtCard", "ORPC"."DocCur" "ORPC_DocCur", "ORPC"."DocNum" "ORPC_DocNum",              
		"ORPC"."DocEntry" "ORPC_DocEntry", "ORPC"."Installmnt" "ORPC_Installmnt",                                                                        
		"ODPO"."DocDate" "ODPO_DocDate", "ODPO"."NumAtCard" "ODPO_NumAtCard", "ODPO"."DocCur" "ODPO_DocCur", "ODPO"."DocNum" "ODPO_DocNum",              
		"ODPO"."DocEntry" "ODPO_DocEntry",  "ODPO"."Installmnt" "ODPO_Installmnt",                                                                       
		"ODPI"."DocDate" "ODPI_DocDate", "ODPI"."NumAtCard" "ODPI_NumAtCard", "ODPI"."DocCur" "ODPI_DocCur", "ODPI"."DocNum" "ODPI_DocNum",              
		"ODPI"."DocEntry" "ODPI_DocEntry", "ODPI"."Installmnt" "ODPI_Installmnt",                                                                        
		"ODPS"."DeposCurr" "ODPS_DeposCurr", "ODPS"."TransAbs" "ODPS_TransAbs", "ODPS"."DeposId" "ODPS_DeposId"                                          
 FROM "PDF2" "PDF2" 
		LEFT OUTER JOIN "OJDT" "OJDT" ON "PDF2"."DocTransId"="OJDT"."TransId"                                                                            
		LEFT OUTER JOIN "JDT1" "JDT1" ON ("PDF2"."DocLine"="JDT1"."Line_ID") AND ("PDF2"."DocTransId"="JDT1"."TransId")                                  
		LEFT OUTER JOIN "OINV" "OINV" ON "PDF2"."DocEntry"="OINV"."DocEntry"                                                                             
		LEFT OUTER JOIN "ORIN" "ORIN" ON "PDF2"."DocTransId"="ORIN"."TransId"                                                                            
		LEFT OUTER JOIN "OPCH" "OPCH" ON "PDF2"."DocTransId"="OPCH"."TransId"                                                                            
		LEFT OUTER JOIN "ORPC" "ORPC" ON "PDF2"."DocTransId"="ORPC"."TransId"                                                                            
		LEFT OUTER JOIN "ODPO" "ODPO" ON "PDF2"."DocTransId"="ODPO"."TransId"                                                                            
		LEFT OUTER JOIN "ODPI" "ODPI" ON "PDF2"."DocEntry"="ODPI"."DocEntry"                                                                             
		LEFT OUTER JOIN "ODPS" "ODPS" ON "PDF2"."DocTransId"="ODPS"."TransAbs"                                                                           
WHERE "PDF2"."DocNum" = {?DocKey@}                                                                                                                       
