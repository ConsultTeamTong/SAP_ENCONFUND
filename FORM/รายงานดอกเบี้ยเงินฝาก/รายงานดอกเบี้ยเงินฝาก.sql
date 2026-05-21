WITH Calendar AS (
    -- 1. สร้างปฏิทินรายวัน: คำนวณหาจุดเริ่มต้น 1 ต.ค. ของปีงบประมาณนั้นๆ
    SELECT CAST(GENERATED_PERIOD_START AS DATE) AS "CalDate"
    FROM SERIES_GENERATE_DATE(
        'INTERVAL 1 DAY', 
        CASE 
            WHEN MONTH(CAST({?SelectedDate@} AS DATE)) >= 10 
            THEN TO_DATE(YEAR(CAST({?SelectedDate@} AS DATE)) || '-10-01') -- ถ้าเลือก ต.ค.-ธ.ค. ให้เริ่ม 1 ต.ค. ปีนี้
            ELSE TO_DATE((YEAR(CAST({?SelectedDate@} AS DATE)) - 1) || '-10-01') -- ถ้าเลือก ม.ค.-ก.ย. ให้เริ่ม 1 ต.ค. ปีก่อน
        END,                 
        ADD_MONTHS(TO_DATE(TO_VARCHAR({?SelectedDate@}, 'YYYY-MM') || '-01'), 1)   
    ) 
),
AccountInfo AS (
    -- 2. ดึงข้อมูลธนาคาร
    SELECT DISTINCT
        DSC1."AcctName",
        DSC1."Account" AS "BankAccount",
        ODSC."BankName" || ' ' || DSC1."Branch" AS "BankNameBranch"
    FROM {?Schema@}.OACT T2
    LEFT JOIN {?Schema@}.DSC1 ON T2."AcctCode" = DSC1."GLAccount"
    LEFT JOIN {?Schema@}.ODSC ON DSC1."BankCode" = ODSC."BankCode"
    WHERE T2."FormatCode" = '{?AccCode@}' 
),
DailyBalanceBase AS (
    -- 3. ดึงยอดยกสะสมมาผูกกับปฏิทิน
    SELECT 
        C."CalDate" AS "Date",
        IFNULL((
            SELECT SUM(IFNULL(T1."Debit",0))
            FROM {?Schema@}.OJDT T0
            JOIN {?Schema@}.JDT1 T1 ON T0."TransId" = T1."TransId" 
            JOIN {?Schema@}.OACT T2 ON T1."Account" = T2."AcctCode"
            WHERE T2."FormatCode" = '{?AccCode@}'
              AND T0."RefDate" <= C."CalDate"  
              AND T0."TransId" NOT IN (
                  SELECT T3."StornoToTr" 
                  FROM {?Schema@}.OJDT T3 
                  WHERE T3."StornoToTr" IS NOT NULL
              )
        ), 0) AS "SumDebit"
    FROM Calendar C
),
DailyBalance AS (
    -- 4. คำนวณดอกเบี้ยรายวัน
    SELECT 
        "Date",
        "SumDebit",
        ("SumDebit" * (CAST({?Percen@} AS DECIMAL(10,5)) / 100)) / {?DofYEAR@} AS "DailyInterest"
    FROM DailyBalanceBase
),
CalculatedInterest AS (
    -- 5. คำนวณเงินสะสมรายเดือน และรายปีงบประมาณ
    SELECT 
        "Date",
        "SumDebit",
        "DailyInterest",
        
        -- คอลัมน์ที่ 1: ดอกเบี้ยสะสมรายเดือน (รีเซ็ตยอดกลับเป็น 0 ทุกๆ ต้นเดือน)
        SUM("DailyInterest") OVER(PARTITION BY MONTH("Date") ORDER BY "Date" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "CumInterest_Month",
        
        -- คอลัมน์ที่ 2: ดอกเบี้ยสะสมรายปีงบประมาณ (บวกยาวตั้งแต่วันแรกใน Calendar ซึ่งก็คือ 1 ต.ค.)
        SUM("DailyInterest") OVER(ORDER BY "Date" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "CumInterest_Year"
    FROM DailyBalance
)
-- 6. ประกอบตารางและกรองให้แสดงเฉพาะเดือน-ปี ที่ผู้ใช้เลือก
SELECT 
    CI."Date",
    CASE MONTH(CI."Date")
        WHEN 1 THEN 'มกราคม' WHEN 2 THEN 'กุมภาพันธ์' WHEN 3 THEN 'มีนาคม'
        WHEN 4 THEN 'เมษายน' WHEN 5 THEN 'พฤษภาคม' WHEN 6 THEN 'มิถุนายน'
        WHEN 7 THEN 'กรกฎาคม' WHEN 8 THEN 'สิงหาคม' WHEN 9 THEN 'กันยายน'
        WHEN 10 THEN 'ตุลาคม' WHEN 11 THEN 'พฤศจิกายน' WHEN 12 THEN 'ธันวาคม'
    END || ' ' || CAST((YEAR(CI."Date") + 543) AS VARCHAR) AS "ThaiMonthYear",
    
    AI."BankNameBranch",
    AI."BankAccount",
    AI."AcctName",
    
    CI."SumDebit",
    CI."DailyInterest" AS "ดอก", 
    CI."CumInterest_Month" AS "ดอกสะสม เดือน",     
    CI."CumInterest_Year" AS "ดอกสะสม ปี" 

FROM CalculatedInterest CI
CROSS JOIN AccountInfo AI 
WHERE TO_VARCHAR(CI."Date", 'YYYY-MM') = TO_VARCHAR(CAST({?SelectedDate@} AS DATE), 'YYYY-MM')
ORDER BY CI."Date";