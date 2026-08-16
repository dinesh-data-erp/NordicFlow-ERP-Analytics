-- NordicFlow ERP Consultant Portfolio — Project 4
-- 05 Executive Analysis
-- Run one query at a time in DB Browser for SQLite.

-- Q34 | Which critical materials combine low usable stock with supplier risk?
-- Concepts: CTE, JOIN, CASE
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
-- Concepts: CTE, self-join
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
-- Concepts: CTE, JOIN, GROUP BY
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
-- Concepts: CTE, JOIN, GROUP BY
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
-- Concepts: CTE, window functions
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
-- Concepts: CTE, scalar subqueries
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
-- Concepts: CTE, UNION ALL, KPI evidence
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
