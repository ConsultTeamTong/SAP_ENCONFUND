-- ============================================================
-- Report: RLR20002__Pick List Including Batch_SN - CR (System).rpt
Path:   RLR20002__Pick List Including Batch_SN - CR (System).rpt
Extracted: 2026-05-07 18:03:51
-- Source: Main Report
-- Table:  Command
-- ============================================================

select "OITL"."ApplyType" , "OITL"."ApplyEntry", "OITL"."ApplyLine", "OITL"."ManagedBy", "ITL1"."ItemCode", "ITL1"."SysNumber" , sum("ITL1"."ReleaseQty")  as "ReleasQtySum", sum("ITL1"."PickedQty")  as "PickedQtySum"   from "ITL1" join "OITL"  on "OITL"."LogEntry" ="ITL1"."LogEntry" 
where "OITL"."ApplyType"=156 and "OITL"."ApplyEntry"={?DocKey@}
 group by "OITL"."ApplyType" , "OITL"."ApplyEntry" , "OITL"."ApplyLine", "OITL"."ManagedBy", "ITL1"."ItemCode", "ITL1"."SysNumber" order by "OITL"."ApplyLine"  
