-- ============================================================================
-- NordicFlow ERP Consultant Portfolio
-- Project 4 — SQL Business Analysis
-- Complete SQL Query Library
-- Database: SQLite
-- Source: Project 3 trusted clean ERP dataset
-- Portfolio note: NordicFlow and all data are fictional/simulated.
-- ============================================================================

-- IMPORTANT:
-- Run one query at a time in DB Browser for SQLite.
-- Inventory queries intentionally use the latest snapshot date to avoid
-- double-counting monthly inventory snapshots.
-- Currency expressions are written defensively so they also work when CSV
-- imports store euro-formatted values as TEXT.


-- ============================================================================
-- SECTION A — DATABASE VALIDATION
-- ============================================================================

-- Q01 | How many records are loaded in each ERP table?
-- SQL concepts: COUNT, UNION ALL
-- Decision use: Reconcile the SQL load to the clean Excel release before analysis.
SELECT 'material_master' AS table_name, COUNT(*) AS row_count FROM material_master
UNION ALL SELECT 'supplier_master', COUNT(*) FROM supplier_master
UNION ALL SELECT 'plant_master', COUNT(*) FROM plant_master
UNION ALL SELECT 'bom', COUNT(*) FROM bom
UNION ALL SELECT 'inventory_snapshot', COUNT(*) FROM inventory_snapshot
UNION ALL SELECT 'purchase_order_lines', COUNT(*) FROM purchase_order_lines
UNION ALL SELECT 'production_orders', COUNT(*) FROM production_orders;

-- Q02 | What material categories are managed in the ERP?
-- SQL concepts: GROUP BY, COUNT
-- Decision use: Understand the manufacturing material structure before transaction analysis.
SELECT Material_Type,
       COUNT(*) AS material_count
FROM material_master
GROUP BY Material_Type
ORDER BY material_count DESC, Material_Type;

-- Q03 | Do logical primary keys contain duplicates?
-- SQL concepts: CTE, GROUP BY, HAVING, UNION ALL
-- Decision use: A clean release should return no rows; duplicates would distort joins and KPIs.
WITH duplicate_checks AS (
    SELECT 'material_master' AS table_name, Material_ID AS key_value, COUNT(*) AS duplicate_count
    FROM material_master
    GROUP BY Material_ID
    HAVING COUNT(*) > 1

    UNION ALL
    SELECT 'supplier_master', Supplier_ID, COUNT(*)
    FROM supplier_master
    GROUP BY Supplier_ID
    HAVING COUNT(*) > 1

    UNION ALL
    SELECT 'plant_master', Plant_ID, COUNT(*)
    FROM plant_master
    GROUP BY Plant_ID
    HAVING COUNT(*) > 1

    UNION ALL
    SELECT 'bom', BOM_ID || '|' || BOM_Version || '|' || Component_Line, COUNT(*)
    FROM bom
    GROUP BY BOM_ID, BOM_Version, Component_Line
    HAVING COUNT(*) > 1

    UNION ALL
    SELECT 'inventory_snapshot',
           Snapshot_Date || '|' || Material_ID || '|' || Plant_ID || '|' || Stock_Status,
           COUNT(*)
    FROM inventory_snapshot
    GROUP BY Snapshot_Date, Material_ID, Plant_ID, Stock_Status
    HAVING COUNT(*) > 1

    UNION ALL
    SELECT 'purchase_order_lines', PO_ID || '|' || PO_Line, COUNT(*)
    FROM purchase_order_lines
    GROUP BY PO_ID, PO_Line
    HAVING COUNT(*) > 1

    UNION ALL
    SELECT 'production_orders', Production_Order_ID, COUNT(*)
    FROM production_orders
    GROUP BY Production_Order_ID
    HAVING COUNT(*) > 1
)
SELECT *
FROM duplicate_checks
ORDER BY table_name, key_value;

-- Q04 | Are mandatory business keys missing?
-- SQL concepts: SUM, CASE, UNION ALL
-- Decision use: Confirm that key records can be uniquely identified and traced.
SELECT 'material_master' AS table_name,
       SUM(CASE WHEN Material_ID IS NULL OR TRIM(Material_ID) = '' THEN 1 ELSE 0 END) AS missing_key_count
FROM material_master
UNION ALL
SELECT 'supplier_master',
       SUM(CASE WHEN Supplier_ID IS NULL OR TRIM(Supplier_ID) = '' THEN 1 ELSE 0 END)
FROM supplier_master
UNION ALL
SELECT 'plant_master',
       SUM(CASE WHEN Plant_ID IS NULL OR TRIM(Plant_ID) = '' THEN 1 ELSE 0 END)
FROM plant_master
UNION ALL
SELECT 'bom',
       SUM(CASE WHEN BOM_ID IS NULL OR TRIM(BOM_ID) = ''
                 OR Component_Line IS NULL THEN 1 ELSE 0 END)
FROM bom
UNION ALL
SELECT 'inventory_snapshot',
       SUM(CASE WHEN Snapshot_Date IS NULL OR Material_ID IS NULL
                 OR Plant_ID IS NULL OR Stock_Status IS NULL THEN 1 ELSE 0 END)
FROM inventory_snapshot
UNION ALL
SELECT 'purchase_order_lines',
       SUM(CASE WHEN PO_ID IS NULL OR PO_Line IS NULL THEN 1 ELSE 0 END)
FROM purchase_order_lines
UNION ALL
SELECT 'production_orders',
       SUM(CASE WHEN Production_Order_ID IS NULL OR TRIM(Production_Order_ID) = '' THEN 1 ELSE 0 END)
FROM production_orders;

-- Q05 | Are there orphan references after cleaning?
-- SQL concepts: LEFT JOIN, CASE, UNION ALL
-- Decision use: Zero orphan counts confirm referential integrity for analytical joins.
SELECT 'inventory_material' AS relationship, COUNT(*) AS orphan_count
FROM inventory_snapshot i
LEFT JOIN material_master m ON i.Material_ID = m.Material_ID
WHERE m.Material_ID IS NULL

UNION ALL
SELECT 'inventory_plant', COUNT(*)
FROM inventory_snapshot i
LEFT JOIN plant_master pl ON i.Plant_ID = pl.Plant_ID
WHERE pl.Plant_ID IS NULL

UNION ALL
SELECT 'po_material', COUNT(*)
FROM purchase_order_lines p
LEFT JOIN material_master m ON p.Material_ID = m.Material_ID
WHERE m.Material_ID IS NULL

UNION ALL
SELECT 'po_supplier', COUNT(*)
FROM purchase_order_lines p
LEFT JOIN supplier_master s ON p.Supplier_ID = s.Supplier_ID
WHERE s.Supplier_ID IS NULL

UNION ALL
SELECT 'po_plant', COUNT(*)
FROM purchase_order_lines p
LEFT JOIN plant_master pl ON p.Plant_ID = pl.Plant_ID
WHERE pl.Plant_ID IS NULL

UNION ALL
SELECT 'bom_component', COUNT(*)
FROM bom b
LEFT JOIN material_master m ON b.Component_Material_ID = m.Material_ID
WHERE m.Material_ID IS NULL

UNION ALL
SELECT 'production_product', COUNT(*)
FROM production_orders pr
LEFT JOIN material_master m ON pr.Finished_Product_ID = m.Material_ID
WHERE m.Material_ID IS NULL;


-- ============================================================================
-- SECTION B — INVENTORY ANALYTICS
-- ============================================================================

-- Q06 | What is the latest inventory snapshot date?
-- SQL concepts: MAX
-- Decision use: Use one reporting date to avoid double-counting inventory across monthly snapshots.
SELECT MAX(Snapshot_Date) AS latest_snapshot_date
FROM inventory_snapshot;

-- Q07 | What is the latest inventory value by plant?
-- SQL concepts: CTE, JOIN, SUM, GROUP BY
-- Decision use: Identify where working capital is concentrated.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
)
SELECT i.Plant_ID,
       pl.Plant_Name,
       ROUND(SUM(CAST(REPLACE(REPLACE(REPLACE(CAST(i.Inventory_Value_EUR AS TEXT),'€',''),' ',''),',','') AS REAL)), 2) AS inventory_value_eur
FROM inventory_snapshot i
JOIN latest l ON i.Snapshot_Date = l.snapshot_date
LEFT JOIN plant_master pl ON i.Plant_ID = pl.Plant_ID
GROUP BY i.Plant_ID, pl.Plant_Name
ORDER BY inventory_value_eur DESC;

-- Q08 | How is latest inventory distributed by stock status?
-- SQL concepts: CTE, SUM, GROUP BY
-- Decision use: Separate physically present inventory from immediately usable stock.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
)
SELECT i.Stock_Status,
       SUM(i.Quantity) AS quantity,
       ROUND(SUM(CAST(REPLACE(REPLACE(REPLACE(CAST(i.Inventory_Value_EUR AS TEXT),'€',''),' ',''),',','') AS REAL)), 2) AS inventory_value_eur
FROM inventory_snapshot i
JOIN latest l ON i.Snapshot_Date = l.snapshot_date
GROUP BY i.Stock_Status
ORDER BY inventory_value_eur DESC;

-- Q09 | How much inventory value sits in each ABC class?
-- SQL concepts: CTE, JOIN, SUM, GROUP BY
-- Decision use: Check whether working capital is aligned with material importance.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
)
SELECT m.ABC_Class,
       ROUND(SUM(CAST(REPLACE(REPLACE(REPLACE(CAST(i.Inventory_Value_EUR AS TEXT),'€',''),' ',''),',','') AS REAL)), 2) AS inventory_value_eur,
       SUM(i.Quantity) AS quantity
FROM inventory_snapshot i
JOIN latest l ON i.Snapshot_Date = l.snapshot_date
JOIN material_master m ON i.Material_ID = m.Material_ID
GROUP BY m.ABC_Class
ORDER BY inventory_value_eur DESC;

-- Q10 | Which materials have unrestricted stock below safety stock?
-- SQL concepts: CTE, JOIN, SUM, CASE, HAVING
-- Decision use: Prioritise materials that threaten production continuity.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
),
unrestricted AS (
    SELECT i.Material_ID,
           i.Plant_ID,
           SUM(CASE WHEN i.Stock_Status = 'Unrestricted' THEN i.Quantity ELSE 0 END) AS unrestricted_qty
    FROM inventory_snapshot i
    JOIN latest l ON i.Snapshot_Date = l.snapshot_date
    GROUP BY i.Material_ID, i.Plant_ID
)
SELECT u.Plant_ID,
       u.Material_ID,
       m.Material_Name,
       m.Criticality,
       u.unrestricted_qty,
       m.Safety_Stock_Qty,
       ROUND(m.Safety_Stock_Qty - u.unrestricted_qty, 2) AS safety_stock_gap
FROM unrestricted u
JOIN material_master m ON u.Material_ID = m.Material_ID
WHERE u.unrestricted_qty < m.Safety_Stock_Qty
ORDER BY CASE m.Criticality WHEN 'Critical' THEN 1 WHEN 'Important' THEN 2 ELSE 3 END,
         safety_stock_gap DESC;

-- Q11 | Which materials are below reorder point at the latest snapshot?
-- SQL concepts: CTE, JOIN, SUM, WHERE
-- Decision use: Identify replenishment exposure before a stockout occurs.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
),
unrestricted AS (
    SELECT i.Material_ID,
           i.Plant_ID,
           SUM(CASE WHEN i.Stock_Status = 'Unrestricted' THEN i.Quantity ELSE 0 END) AS unrestricted_qty
    FROM inventory_snapshot i
    JOIN latest l ON i.Snapshot_Date = l.snapshot_date
    GROUP BY i.Material_ID, i.Plant_ID
)
SELECT u.Plant_ID,
       u.Material_ID,
       m.Material_Name,
       m.ABC_Class,
       u.unrestricted_qty,
       m.Reorder_Point_Qty,
       ROUND(m.Reorder_Point_Qty - u.unrestricted_qty, 2) AS reorder_gap
FROM unrestricted u
JOIN material_master m ON u.Material_ID = m.Material_ID
WHERE u.unrestricted_qty < m.Reorder_Point_Qty
ORDER BY reorder_gap DESC;

-- Q12 | Which materials have usable shortage in one plant while unrestricted stock exists in another plant?
-- SQL concepts: CTE, self-join, CASE, SUM
-- Decision use: Identify stock-transfer opportunities before placing new purchase orders.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
),
unrestricted AS (
    SELECT i.Material_ID,
           i.Plant_ID,
           SUM(CASE WHEN i.Stock_Status = 'Unrestricted' THEN i.Quantity ELSE 0 END) AS unrestricted_qty
    FROM inventory_snapshot i
    JOIN latest l ON i.Snapshot_Date = l.snapshot_date
    GROUP BY i.Material_ID, i.Plant_ID
),
shortages AS (
    SELECT u.Material_ID,
           u.Plant_ID AS shortage_plant,
           u.unrestricted_qty,
           m.Safety_Stock_Qty
    FROM unrestricted u
    JOIN material_master m ON u.Material_ID = m.Material_ID
    WHERE u.unrestricted_qty < m.Safety_Stock_Qty
)
SELECT s.Material_ID,
       m.Material_Name,
       s.shortage_plant,
       s.unrestricted_qty AS shortage_plant_qty,
       s.Safety_Stock_Qty,
       o.Plant_ID AS other_plant,
       o.unrestricted_qty AS other_plant_qty
FROM shortages s
JOIN unrestricted o
  ON s.Material_ID = o.Material_ID
 AND s.shortage_plant <> o.Plant_ID
 AND o.unrestricted_qty > 0
JOIN material_master m ON s.Material_ID = m.Material_ID
ORDER BY s.Material_ID, o.unrestricted_qty DESC;

-- Q13 | Which materials have the most stock tied up in quality inspection?
-- SQL concepts: CTE, JOIN, SUM, GROUP BY
-- Decision use: Focus quality and supplier actions on stock that is physically present but unavailable.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
)
SELECT i.Material_ID,
       m.Material_Name,
       i.Plant_ID,
       SUM(i.Quantity) AS quality_qty,
       ROUND(SUM(CAST(REPLACE(REPLACE(REPLACE(CAST(i.Inventory_Value_EUR AS TEXT),'€',''),' ',''),',','') AS REAL)), 2) AS quality_value_eur
FROM inventory_snapshot i
JOIN latest l ON i.Snapshot_Date = l.snapshot_date
JOIN material_master m ON i.Material_ID = m.Material_ID
WHERE i.Stock_Status = 'Quality Inspection'
GROUP BY i.Material_ID, m.Material_Name, i.Plant_ID
ORDER BY quality_value_eur DESC;

-- Q14 | What are the top materials by latest inventory value?
-- SQL concepts: CTE, JOIN, SUM, ORDER BY, LIMIT
-- Decision use: Target working-capital reviews at the materials with the largest financial exposure.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
)
SELECT i.Material_ID,
       m.Material_Name,
       m.ABC_Class,
       m.Criticality,
       ROUND(SUM(CAST(REPLACE(REPLACE(REPLACE(CAST(i.Inventory_Value_EUR AS TEXT),'€',''),' ',''),',','') AS REAL)), 2) AS inventory_value_eur
FROM inventory_snapshot i
JOIN latest l ON i.Snapshot_Date = l.snapshot_date
JOIN material_master m ON i.Material_ID = m.Material_ID
GROUP BY i.Material_ID, m.Material_Name, m.ABC_Class, m.Criticality
ORDER BY inventory_value_eur DESC
LIMIT 10;

-- Q15 | Which C-class materials appear overstocked relative to reorder point?
-- SQL concepts: CTE, JOIN, SUM, WHERE
-- Decision use: Reduce low-priority excess stock and redirect working capital toward critical materials.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
),
unrestricted AS (
    SELECT i.Material_ID,
           i.Plant_ID,
           SUM(CASE WHEN i.Stock_Status = 'Unrestricted' THEN i.Quantity ELSE 0 END) AS unrestricted_qty,
           SUM(CASE WHEN i.Stock_Status = 'Unrestricted' THEN CAST(REPLACE(REPLACE(REPLACE(CAST(i.Inventory_Value_EUR AS TEXT),'€',''),' ',''),',','') AS REAL) ELSE 0 END) AS unrestricted_value
    FROM inventory_snapshot i
    JOIN latest l ON i.Snapshot_Date = l.snapshot_date
    GROUP BY i.Material_ID, i.Plant_ID
)
SELECT u.Material_ID,
       m.Material_Name,
       u.Plant_ID,
       u.unrestricted_qty,
       m.Reorder_Point_Qty,
       ROUND(u.unrestricted_qty - m.Reorder_Point_Qty, 2) AS excess_qty,
       ROUND(u.unrestricted_value, 2) AS unrestricted_value_eur
FROM unrestricted u
JOIN material_master m ON u.Material_ID = m.Material_ID
WHERE m.ABC_Class = 'C'
  AND u.unrestricted_qty > m.Reorder_Point_Qty
ORDER BY unrestricted_value_eur DESC;


-- ============================================================================
-- SECTION C — PROCUREMENT ANALYTICS
-- ============================================================================

-- Q16 | How many purchase lines and how much received spend are associated with each supplier?
-- SQL concepts: JOIN, COUNT, SUM, GROUP BY
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
-- SQL concepts: JOIN, AVG, CASE, GROUP BY
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
-- SQL concepts: JOIN, AVG, GROUP BY
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
-- SQL concepts: JOIN, AVG, GROUP BY
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
-- SQL concepts: JOIN, WHERE, ORDER BY
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
-- SQL concepts: JOIN, SUM, GROUP BY, HAVING
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
-- SQL concepts: CTE, CASE, JOIN, GROUP BY
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
-- SQL concepts: JOIN, SUM, GROUP BY
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
-- SQL concepts: JOIN, AVG, GROUP BY, HAVING
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


-- ============================================================================
-- SECTION D — PRODUCTION ANALYTICS
-- ============================================================================

-- Q25 | What percentage of production orders finish on time?
-- SQL concepts: AVG, CASE
-- Decision use: Establish the overall production schedule-reliability baseline.
SELECT COUNT(*) AS production_orders,
       SUM(CASE WHEN Completion_Delay_Days <= 0 THEN 1 ELSE 0 END) AS on_time_orders,
       SUM(CASE WHEN Completion_Delay_Days > 0 THEN 1 ELSE 0 END) AS delayed_orders,
       ROUND(100.0 * AVG(CASE WHEN Completion_Delay_Days <= 0 THEN 1.0 ELSE 0.0 END),1) AS on_time_completion_pct
FROM production_orders;

-- Q26 | What are the main production delay reasons?
-- SQL concepts: COUNT, AVG, GROUP BY
-- Decision use: Focus improvement work on the most frequent and severe root causes.
SELECT COALESCE(NULLIF(TRIM(Delay_Reason),''),'No Delay / Not Recorded') AS delay_reason,
       COUNT(*) AS order_count,
       ROUND(AVG(Completion_Delay_Days),1) AS avg_completion_delay_days
FROM production_orders
GROUP BY COALESCE(NULLIF(TRIM(Delay_Reason),''),'No Delay / Not Recorded')
ORDER BY order_count DESC, avg_completion_delay_days DESC;

-- Q27 | How much worse are orders affected by material shortages?
-- SQL concepts: CASE, GROUP BY, AVG
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
-- SQL concepts: JOIN, GROUP BY, AVG, MAX
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
-- SQL concepts: SUM, CASE, arithmetic
-- Decision use: Measure whether schedule delays are also translating into output shortfalls.
SELECT SUM(Planned_Qty) AS planned_qty,
       SUM(Actual_Qty) AS actual_qty,
       ROUND(100.0 * SUM(Actual_Qty) / NULLIF(SUM(Planned_Qty),0),1) AS production_attainment_pct,
       SUM(Actual_Qty - Planned_Qty) AS total_quantity_variance
FROM production_orders;

-- Q30 | Do urgent and high-priority orders suffer more delay?
-- SQL concepts: GROUP BY, AVG, CASE
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
-- SQL concepts: JOIN, GROUP BY, AVG
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
-- SQL concepts: JOIN, arithmetic, ORDER BY
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
-- SQL concepts: JOIN, GROUP BY, COUNT
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


-- ============================================================================
-- SECTION E — EXECUTIVE & CROSS-FUNCTIONAL ANALYTICS
-- ============================================================================

-- Q34 | Which critical materials combine low usable stock with supplier risk?
-- SQL concepts: CTE, JOIN, CASE
-- Decision use: Create a management watchlist combining inventory and supplier exposure.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
),
stock AS (
    SELECT i.Material_ID,
           i.Plant_ID,
           SUM(CASE WHEN i.Stock_Status = 'Unrestricted' THEN i.Quantity ELSE 0 END) AS unrestricted_qty
    FROM inventory_snapshot i
    JOIN latest l ON i.Snapshot_Date = l.snapshot_date
    GROUP BY i.Material_ID, i.Plant_ID
)
SELECT st.Material_ID,
       m.Material_Name,
       st.Plant_ID,
       m.Criticality,
       m.ABC_Class,
       st.unrestricted_qty,
       m.Safety_Stock_Qty,
       s.Supplier_ID,
       s.Supplier_Name,
       s.Risk_Level,
       CASE
           WHEN st.unrestricted_qty < m.Safety_Stock_Qty AND s.Risk_Level IN ('High','Medium') THEN 'High'
           WHEN st.unrestricted_qty < m.Reorder_Point_Qty OR s.Risk_Level = 'High' THEN 'Medium'
           ELSE 'Low'
       END AS supply_risk
FROM stock st
JOIN material_master m ON st.Material_ID = m.Material_ID
LEFT JOIN supplier_master s ON m.Preferred_Supplier_ID = s.Supplier_ID
WHERE m.Criticality = 'Critical'
ORDER BY CASE supply_risk WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END,
         st.unrestricted_qty ASC;

-- Q35 | What interplant transfer opportunities could reduce shortages without new purchasing?
-- SQL concepts: CTE, self-join
-- Decision use: Use internal stock balancing before increasing external purchases.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
),
stock AS (
    SELECT i.Material_ID,
           i.Plant_ID,
           SUM(CASE WHEN i.Stock_Status = 'Unrestricted' THEN i.Quantity ELSE 0 END) AS unrestricted_qty
    FROM inventory_snapshot i
    JOIN latest l ON i.Snapshot_Date = l.snapshot_date
    GROUP BY i.Material_ID, i.Plant_ID
)
SELECT a.Material_ID,
       m.Material_Name,
       a.Plant_ID AS shortage_plant,
       a.unrestricted_qty AS shortage_plant_qty,
       m.Safety_Stock_Qty,
       b.Plant_ID AS source_plant,
       b.unrestricted_qty AS source_plant_qty,
       ROUND(MIN(
           m.Safety_Stock_Qty - a.unrestricted_qty,
           MAX(b.unrestricted_qty - m.Safety_Stock_Qty, 0)
       ), 2) AS indicative_transfer_qty
FROM stock a
JOIN stock b
  ON a.Material_ID = b.Material_ID
 AND a.Plant_ID <> b.Plant_ID
JOIN material_master m ON a.Material_ID = m.Material_ID
WHERE a.unrestricted_qty < m.Safety_Stock_Qty
  AND b.unrestricted_qty > m.Safety_Stock_Qty
ORDER BY indicative_transfer_qty DESC;

-- Q36 | How much latest inventory value is tied up by ABC class and stock status?
-- SQL concepts: CTE, JOIN, GROUP BY
-- Decision use: Expose working capital tied up in low-priority or restricted inventory.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
)
SELECT m.ABC_Class,
       i.Stock_Status,
       ROUND(SUM(CAST(REPLACE(REPLACE(REPLACE(CAST(i.Inventory_Value_EUR AS TEXT),'€',''),' ',''),',','') AS REAL)),2) AS inventory_value_eur
FROM inventory_snapshot i
JOIN latest l ON i.Snapshot_Date = l.snapshot_date
JOIN material_master m ON i.Material_ID = m.Material_ID
GROUP BY m.ABC_Class, i.Stock_Status
ORDER BY m.ABC_Class, inventory_value_eur DESC;

-- Q37 | Which purchased components combine production dependency with weak supplier performance?
-- SQL concepts: CTE, JOIN, GROUP BY
-- Decision use: Target dual-sourcing or supplier-development efforts at high-dependency components.
WITH component_dependency AS (
    SELECT Component_Material_ID AS Material_ID,
           COUNT(DISTINCT Finished_Product_ID) AS finished_products_using_component
    FROM bom
    WHERE UPPER(CAST(Active_Status AS TEXT)) IN ('TRUE','1')
    GROUP BY Component_Material_ID
),
supplier_perf AS (
    SELECT Material_ID,
           Supplier_ID,
           ROUND(AVG(Delivery_Delay_Days),1) AS avg_delay_days,
           ROUND(100.0 * AVG(CASE WHEN UPPER(CAST(On_Time_Flag AS TEXT)) IN ('TRUE','1') THEN 1.0 ELSE 0.0 END),1) AS otd_pct
    FROM purchase_order_lines
    GROUP BY Material_ID, Supplier_ID
)
SELECT cd.Material_ID,
       m.Material_Name,
       m.Criticality,
       cd.finished_products_using_component,
       sp.Supplier_ID,
       s.Supplier_Name,
       s.Risk_Level,
       sp.otd_pct,
       sp.avg_delay_days
FROM component_dependency cd
JOIN material_master m ON cd.Material_ID = m.Material_ID
LEFT JOIN supplier_perf sp ON cd.Material_ID = sp.Material_ID
LEFT JOIN supplier_master s ON sp.Supplier_ID = s.Supplier_ID
WHERE sp.Supplier_ID IS NOT NULL
ORDER BY cd.finished_products_using_component DESC,
         CASE m.Criticality WHEN 'Critical' THEN 1 WHEN 'Important' THEN 2 ELSE 3 END,
         sp.otd_pct ASC;

-- Q38 | Which materials make up the Pareto concentration of latest inventory value?
-- SQL concepts: CTE, window functions
-- Decision use: Focus working-capital management on the small set of materials driving most inventory value.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
),
material_value AS (
    SELECT i.Material_ID,
           m.Material_Name,
           SUM(CAST(REPLACE(REPLACE(REPLACE(CAST(i.Inventory_Value_EUR AS TEXT),'€',''),' ',''),',','') AS REAL)) AS inventory_value_eur
    FROM inventory_snapshot i
    JOIN latest l ON i.Snapshot_Date = l.snapshot_date
    JOIN material_master m ON i.Material_ID = m.Material_ID
    GROUP BY i.Material_ID, m.Material_Name
),
ranked AS (
    SELECT Material_ID,
           Material_Name,
           inventory_value_eur,
           SUM(inventory_value_eur) OVER (
               ORDER BY inventory_value_eur DESC
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS cumulative_value,
           SUM(inventory_value_eur) OVER () AS total_value
    FROM material_value
)
SELECT Material_ID,
       Material_Name,
       ROUND(inventory_value_eur,2) AS inventory_value_eur,
       ROUND(100.0 * cumulative_value / NULLIF(total_value,0),1) AS cumulative_value_pct,
       CASE
           WHEN 100.0 * cumulative_value / NULLIF(total_value,0) <= 80 THEN 'Top ~80% Value'
           ELSE 'Remaining Value'
       END AS pareto_segment
FROM ranked
ORDER BY inventory_value_eur DESC;

-- Q39 | What are the core executive KPIs across inventory, procurement and production?
-- SQL concepts: CTE, scalar subqueries
-- Decision use: Provide a one-row management summary for later Power BI KPI cards.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
)
SELECT
    (SELECT COUNT(*) FROM material_master) AS materials,
    (SELECT COUNT(*) FROM supplier_master) AS suppliers,
    ROUND((
        SELECT SUM(CAST(REPLACE(REPLACE(REPLACE(CAST(i.Inventory_Value_EUR AS TEXT),'€',''),' ',''),',','') AS REAL))
        FROM inventory_snapshot i
        JOIN latest l ON i.Snapshot_Date = l.snapshot_date
    ),2) AS latest_inventory_value_eur,
    ROUND((
        SELECT 100.0 * AVG(
            CASE WHEN UPPER(CAST(On_Time_Flag AS TEXT)) IN ('TRUE','1') THEN 1.0 ELSE 0.0 END
        )
        FROM purchase_order_lines
    ),1) AS supplier_otd_pct,
    ROUND((
        SELECT AVG(Delivery_Delay_Days)
        FROM purchase_order_lines
    ),1) AS avg_po_delay_days,
    ROUND((
        SELECT 100.0 * AVG(
            CASE WHEN Completion_Delay_Days <= 0 THEN 1.0 ELSE 0.0 END
        )
        FROM production_orders
    ),1) AS production_on_time_pct,
    (SELECT SUM(
        CASE WHEN UPPER(CAST(Material_Shortage_Flag AS TEXT)) IN ('TRUE','1') THEN 1 ELSE 0 END
     ) FROM production_orders) AS shortage_affected_orders;

-- Q40 | What evidence supports the main root-cause categories behind shortages and delays?
-- SQL concepts: CTE, UNION ALL, KPI evidence
-- Decision use: Summarise the evidence chain for the final consultant narrative instead of blaming one cause.
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
),
latest_stock AS (
    SELECT i.Material_ID,
           i.Plant_ID,
           SUM(CASE WHEN i.Stock_Status = 'Unrestricted' THEN i.Quantity ELSE 0 END) AS unrestricted_qty,
           SUM(CASE WHEN i.Stock_Status = 'Quality Inspection' THEN i.Quantity ELSE 0 END) AS quality_qty
    FROM inventory_snapshot i
    JOIN latest l ON i.Snapshot_Date = l.snapshot_date
    GROUP BY i.Material_ID, i.Plant_ID
)
SELECT 'Material availability' AS root_cause_category,
       COUNT(*) AS evidence_count,
       'Plant-material positions below safety stock' AS evidence
FROM latest_stock st
JOIN material_master m ON st.Material_ID = m.Material_ID
WHERE st.unrestricted_qty < m.Safety_Stock_Qty

UNION ALL
SELECT 'Quality restriction',
       COUNT(*),
       'Plant-material positions with quality-inspection stock'
FROM latest_stock
WHERE quality_qty > 0

UNION ALL
SELECT 'Supplier / purchasing delay',
       COUNT(*),
       'Purchase order lines delivered after required date'
FROM purchase_order_lines
WHERE Delivery_Delay_Days > 0

UNION ALL
SELECT 'Planning master data',
       COUNT(*),
       'Materials where average actual PO lead time exceeds planned lead time'
FROM (
    SELECT p.Material_ID
    FROM purchase_order_lines p
    JOIN material_master m ON p.Material_ID = m.Material_ID
    GROUP BY p.Material_ID, m.Planned_Lead_Time_Days
    HAVING AVG(p.Actual_Lead_Time_Days) > m.Planned_Lead_Time_Days
) x

UNION ALL
SELECT 'Production material shortage',
       SUM(CASE WHEN UPPER(CAST(Material_Shortage_Flag AS TEXT)) IN ('TRUE','1') THEN 1 ELSE 0 END),
       'Production orders flagged for material shortage'
FROM production_orders;
