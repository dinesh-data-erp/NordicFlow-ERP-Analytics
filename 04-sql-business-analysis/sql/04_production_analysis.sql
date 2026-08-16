-- NordicFlow ERP Consultant Portfolio — Project 4
-- 04 Production Analysis
-- Run one query at a time in DB Browser for SQLite.

-- Q25 | What percentage of production orders finish on time?
-- Concepts: AVG, CASE
-- Decision use: Establish the overall production schedule-reliability baseline.
SELECT COUNT(*) AS production_orders,
       SUM(CASE WHEN Completion_Delay_Days <= 0 THEN 1 ELSE 0 END) AS on_time_orders,
       SUM(CASE WHEN Completion_Delay_Days > 0 THEN 1 ELSE 0 END) AS delayed_orders,
       ROUND(100.0 * AVG(CASE WHEN Completion_Delay_Days <= 0 THEN 1.0 ELSE 0.0 END),1) AS on_time_completion_pct
FROM production_orders;

-- Q26 | What are the main production delay reasons?
-- Concepts: COUNT, AVG, GROUP BY
-- Decision use: Focus improvement work on the most frequent and severe root causes.
SELECT COALESCE(NULLIF(TRIM(Delay_Reason),''),'No Delay / Not Recorded') AS delay_reason,
       COUNT(*) AS order_count,
       ROUND(AVG(Completion_Delay_Days),1) AS avg_completion_delay_days
FROM production_orders
GROUP BY COALESCE(NULLIF(TRIM(Delay_Reason),''),'No Delay / Not Recorded')
ORDER BY order_count DESC, avg_completion_delay_days DESC;

-- Q27 | How much worse are orders affected by material shortages?
-- Concepts: CASE, GROUP BY, AVG
-- Decision use: Quantify the operational impact of material availability problems.
SELECT CASE
           WHEN UPPER(CAST(Material_Shortage_Flag AS TEXT)) IN ('TRUE','1') THEN 'Material Shortage'
           ELSE 'No Material Shortage'
       END AS shortage_status,
       COUNT(*) AS orders,
       ROUND(AVG(Completion_Delay_Days),1) AS avg_completion_delay_days,
       ROUND(AVG(Actual_Duration_Days - Planned_Duration_Days),1) AS avg_duration_variance_days
FROM production_orders
GROUP BY shortage_status
ORDER BY avg_completion_delay_days DESC;

-- Q28 | Which finished products experience the most production delay?
-- Concepts: JOIN, GROUP BY, AVG, MAX
-- Decision use: Identify product families requiring deeper planning or component analysis.
SELECT pr.Finished_Product_ID,
       m.Material_Name AS finished_product_name,
       COUNT(*) AS production_orders,
       ROUND(AVG(pr.Completion_Delay_Days),1) AS avg_completion_delay_days,
       MAX(pr.Completion_Delay_Days) AS max_completion_delay_days
FROM production_orders pr
LEFT JOIN material_master m ON pr.Finished_Product_ID = m.Material_ID
GROUP BY pr.Finished_Product_ID, m.Material_Name
ORDER BY avg_completion_delay_days DESC, max_completion_delay_days DESC;

-- Q29 | How closely does actual output match planned production quantity?
-- Concepts: SUM, CASE, arithmetic
-- Decision use: Measure whether schedule delays are also translating into output shortfalls.
SELECT SUM(Planned_Qty) AS planned_qty,
       SUM(Actual_Qty) AS actual_qty,
       ROUND(100.0 * SUM(Actual_Qty) / NULLIF(SUM(Planned_Qty),0),1) AS production_attainment_pct,
       SUM(Actual_Qty - Planned_Qty) AS total_quantity_variance
FROM production_orders;

-- Q30 | Do urgent and high-priority orders suffer more delay?
-- Concepts: GROUP BY, AVG, CASE
-- Decision use: Check whether prioritisation is genuinely protecting the most important orders.
SELECT Production_Priority,
       COUNT(*) AS orders,
       ROUND(AVG(Completion_Delay_Days),1) AS avg_completion_delay_days,
       SUM(CASE WHEN Completion_Delay_Days > 0 THEN 1 ELSE 0 END) AS delayed_orders
FROM production_orders
GROUP BY Production_Priority
ORDER BY CASE Production_Priority
             WHEN 'Urgent' THEN 1
             WHEN 'High' THEN 2
             WHEN 'Normal' THEN 3
             ELSE 4
         END;

-- Q31 | How does production performance compare by plant?
-- Concepts: JOIN, GROUP BY, AVG
-- Decision use: Distinguish system-wide problems from plant-specific performance issues.
SELECT pr.Plant_ID,
       pl.Plant_Name,
       COUNT(*) AS orders,
       ROUND(AVG(pr.Completion_Delay_Days),1) AS avg_completion_delay_days,
       ROUND(100.0 * AVG(CASE WHEN pr.Completion_Delay_Days <= 0 THEN 1.0 ELSE 0.0 END),1) AS on_time_completion_pct,
       ROUND(100.0 * SUM(pr.Actual_Qty) / NULLIF(SUM(pr.Planned_Qty),0),1) AS attainment_pct
FROM production_orders pr
LEFT JOIN plant_master pl ON pr.Plant_ID = pl.Plant_ID
GROUP BY pr.Plant_ID, pl.Plant_Name
ORDER BY on_time_completion_pct ASC;

-- Q32 | Which production orders have the largest duration variance?
-- Concepts: JOIN, arithmetic, ORDER BY
-- Decision use: Create an exception list for production root-cause review.
SELECT pr.Production_Order_ID,
       pr.Finished_Product_ID,
       m.Material_Name,
       pr.Plant_ID,
       pr.Planned_Duration_Days,
       pr.Actual_Duration_Days,
       pr.Actual_Duration_Days - pr.Planned_Duration_Days AS duration_variance_days,
       pr.Delay_Reason
FROM production_orders pr
LEFT JOIN material_master m ON pr.Finished_Product_ID = m.Material_ID
ORDER BY duration_variance_days DESC, pr.Production_Order_ID;

-- Q33 | Which BOM components are most exposed to material-shortage production orders?
-- Concepts: JOIN, GROUP BY, COUNT
-- Decision use: Prioritise components that can disrupt multiple shortage-affected production orders.
SELECT b.Component_Material_ID,
       cm.Material_Name AS component_name,
       cm.Criticality,
       COUNT(DISTINCT pr.Production_Order_ID) AS shortage_orders_using_component,
       COUNT(DISTINCT b.Finished_Product_ID) AS affected_finished_products
FROM production_orders pr
JOIN bom b ON pr.Finished_Product_ID = b.Finished_Product_ID
LEFT JOIN material_master cm ON b.Component_Material_ID = cm.Material_ID
WHERE UPPER(CAST(pr.Material_Shortage_Flag AS TEXT)) IN ('TRUE','1')
  AND UPPER(CAST(b.Active_Status AS TEXT)) IN ('TRUE','1')
GROUP BY b.Component_Material_ID, cm.Material_Name, cm.Criticality
ORDER BY shortage_orders_using_component DESC,
         CASE cm.Criticality WHEN 'Critical' THEN 1 WHEN 'Important' THEN 2 ELSE 3 END;
