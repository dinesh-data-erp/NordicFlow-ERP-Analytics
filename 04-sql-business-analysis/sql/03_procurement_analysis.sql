-- NordicFlow ERP Consultant Portfolio — Project 4
-- 03 Procurement Analysis
-- Run one query at a time in DB Browser for SQLite.

-- Q16 | How many purchase lines and how much received spend are associated with each supplier?
-- Concepts: JOIN, COUNT, SUM, GROUP BY
-- Decision use: Understand supplier dependency and financial exposure.
SELECT p.Supplier_ID,
       s.Supplier_Name,
       COUNT(*) AS po_lines,
       ROUND(SUM(p.Received_Qty * CAST(REPLACE(REPLACE(REPLACE(CAST(p.Unit_Price_EUR AS TEXT),'€',''),' ',''),',','') AS REAL)), 2) AS received_spend_eur
FROM purchase_order_lines p
LEFT JOIN supplier_master s ON p.Supplier_ID = s.Supplier_ID
GROUP BY p.Supplier_ID, s.Supplier_Name
ORDER BY received_spend_eur DESC;

-- Q17 | What is supplier on-time delivery performance?
-- Concepts: JOIN, AVG, CASE, GROUP BY
-- Decision use: Identify suppliers whose delivery performance is below the expected service level.
SELECT p.Supplier_ID,
       s.Supplier_Name,
       COUNT(*) AS received_lines,
       ROUND(100.0 * AVG(
           CASE
               WHEN UPPER(CAST(p.On_Time_Flag AS TEXT)) IN ('TRUE','1') THEN 1.0
               ELSE 0.0
           END
       ), 1) AS on_time_delivery_pct,
       ROUND(100.0 * s.Target_On_Time_Rate, 1) AS target_on_time_pct
FROM purchase_order_lines p
LEFT JOIN supplier_master s ON p.Supplier_ID = s.Supplier_ID
GROUP BY p.Supplier_ID, s.Supplier_Name, s.Target_On_Time_Rate
ORDER BY on_time_delivery_pct ASC;

-- Q18 | What is the average actual lead time by supplier?
-- Concepts: JOIN, AVG, GROUP BY
-- Decision use: Separate master-data assumptions from actual supplier performance.
SELECT p.Supplier_ID,
       s.Supplier_Name,
       s.Target_Lead_Time_Days,
       ROUND(AVG(p.Actual_Lead_Time_Days), 1) AS avg_actual_lead_time_days,
       ROUND(AVG(p.Actual_Lead_Time_Days) - s.Target_Lead_Time_Days, 1) AS variance_to_target_days
FROM purchase_order_lines p
LEFT JOIN supplier_master s ON p.Supplier_ID = s.Supplier_ID
WHERE p.Actual_Lead_Time_Days IS NOT NULL
GROUP BY p.Supplier_ID, s.Supplier_Name, s.Target_Lead_Time_Days
ORDER BY variance_to_target_days DESC;

-- Q19 | Which suppliers have the highest average delivery delay?
-- Concepts: JOIN, AVG, GROUP BY
-- Decision use: Prioritise supplier improvement discussions by delay severity.
SELECT p.Supplier_ID,
       s.Supplier_Name,
       COUNT(*) AS po_lines,
       ROUND(AVG(p.Delivery_Delay_Days), 1) AS avg_delivery_delay_days,
       MAX(p.Delivery_Delay_Days) AS max_delivery_delay_days
FROM purchase_order_lines p
LEFT JOIN supplier_master s ON p.Supplier_ID = s.Supplier_ID
GROUP BY p.Supplier_ID, s.Supplier_Name
ORDER BY avg_delivery_delay_days DESC;

-- Q20 | Which purchase order lines were delivered late?
-- Concepts: JOIN, WHERE, ORDER BY
-- Decision use: Create an exception list for procurement follow-up.
SELECT p.PO_ID,
       p.PO_Line,
       p.Supplier_ID,
       s.Supplier_Name,
       p.Material_ID,
       p.Plant_ID,
       p.Required_Delivery_Date,
       p.Actual_Receipt_Date,
       p.Delivery_Delay_Days
FROM purchase_order_lines p
LEFT JOIN supplier_master s ON p.Supplier_ID = s.Supplier_ID
WHERE p.Delivery_Delay_Days > 0
ORDER BY p.Delivery_Delay_Days DESC, p.PO_ID;

-- Q21 | Which suppliers and materials generate quality rejections?
-- Concepts: JOIN, SUM, GROUP BY, HAVING
-- Decision use: Link supplier quality problems to inventory availability risk.
SELECT p.Supplier_ID,
       s.Supplier_Name,
       p.Material_ID,
       m.Material_Name,
       SUM(p.Received_Qty) AS received_qty,
       SUM(p.Quality_Rejected_Qty) AS rejected_qty,
       ROUND(100.0 * SUM(p.Quality_Rejected_Qty) / NULLIF(SUM(p.Received_Qty),0), 2) AS rejection_rate_pct
FROM purchase_order_lines p
LEFT JOIN supplier_master s ON p.Supplier_ID = s.Supplier_ID
LEFT JOIN material_master m ON p.Material_ID = m.Material_ID
GROUP BY p.Supplier_ID, s.Supplier_Name, p.Material_ID, m.Material_Name
HAVING SUM(p.Quality_Rejected_Qty) > 0
ORDER BY rejection_rate_pct DESC, rejected_qty DESC;

-- Q22 | Which suppliers should management review first based on delivery, quality and risk?
-- Concepts: CTE, CASE, JOIN, GROUP BY
-- Decision use: Combine multiple supplier-risk signals rather than relying on one KPI.
WITH supplier_perf AS (
    SELECT p.Supplier_ID,
           COUNT(*) AS po_lines,
           AVG(p.Delivery_Delay_Days) AS avg_delay,
           100.0 * SUM(p.Quality_Rejected_Qty) / NULLIF(SUM(p.Received_Qty),0) AS rejection_pct,
           100.0 * AVG(CASE WHEN UPPER(CAST(p.On_Time_Flag AS TEXT)) IN ('TRUE','1') THEN 1.0 ELSE 0.0 END) AS otd_pct
    FROM purchase_order_lines p
    GROUP BY p.Supplier_ID
)
SELECT sp.Supplier_ID,
       s.Supplier_Name,
       s.Risk_Level,
       ROUND(sp.otd_pct,1) AS otd_pct,
       ROUND(sp.avg_delay,1) AS avg_delay_days,
       ROUND(COALESCE(sp.rejection_pct,0),2) AS rejection_pct,
       CASE
           WHEN s.Risk_Level = 'High'
                OR sp.otd_pct < 90
                OR COALESCE(sp.rejection_pct,0) > 5 THEN 'High Review Priority'
           WHEN s.Risk_Level = 'Medium'
                OR sp.otd_pct < 95 THEN 'Medium Review Priority'
           ELSE 'Monitor'
       END AS review_priority
FROM supplier_perf sp
JOIN supplier_master s ON sp.Supplier_ID = s.Supplier_ID
ORDER BY CASE review_priority
             WHEN 'High Review Priority' THEN 1
             WHEN 'Medium Review Priority' THEN 2
             ELSE 3
         END,
         sp.otd_pct ASC;

-- Q23 | What is purchase spend by supplier and material?
-- Concepts: JOIN, SUM, GROUP BY
-- Decision use: Identify high-spend supplier-material combinations for sourcing attention.
SELECT p.Supplier_ID,
       s.Supplier_Name,
       p.Material_ID,
       m.Material_Name,
       ROUND(SUM(p.Received_Qty * CAST(REPLACE(REPLACE(REPLACE(CAST(p.Unit_Price_EUR AS TEXT),'€',''),' ',''),',','') AS REAL)), 2) AS received_spend_eur
FROM purchase_order_lines p
LEFT JOIN supplier_master s ON p.Supplier_ID = s.Supplier_ID
LEFT JOIN material_master m ON p.Material_ID = m.Material_ID
GROUP BY p.Supplier_ID, s.Supplier_Name, p.Material_ID, m.Material_Name
ORDER BY received_spend_eur DESC;

-- Q24 | Which materials have actual purchase lead times materially above the planned material lead time?
-- Concepts: JOIN, AVG, GROUP BY, HAVING
-- Decision use: Update planning parameters where repeated actual lead time exceeds master-data assumptions.
SELECT p.Material_ID,
       m.Material_Name,
       m.Planned_Lead_Time_Days,
       ROUND(AVG(p.Actual_Lead_Time_Days),1) AS avg_actual_lead_time_days,
       ROUND(AVG(p.Actual_Lead_Time_Days) - m.Planned_Lead_Time_Days,1) AS planning_gap_days
FROM purchase_order_lines p
JOIN material_master m ON p.Material_ID = m.Material_ID
WHERE p.Actual_Lead_Time_Days IS NOT NULL
GROUP BY p.Material_ID, m.Material_Name, m.Planned_Lead_Time_Days
HAVING AVG(p.Actual_Lead_Time_Days) > m.Planned_Lead_Time_Days
ORDER BY planning_gap_days DESC;
