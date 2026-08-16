-- NordicFlow ERP Consultant Portfolio — Project 4
-- 02 Inventory Analysis
-- Run one query at a time in DB Browser for SQLite.

-- Q06 | What is the latest inventory snapshot date?
-- Concepts: MAX
-- Decision use: Use one reporting date to avoid double-counting inventory across monthly snapshots.
SELECT MAX(Snapshot_Date) AS latest_snapshot_date
FROM inventory_snapshot;

-- Q07 | What is the latest inventory value by plant?
-- Concepts: CTE, JOIN, SUM, GROUP BY
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
-- Concepts: CTE, SUM, GROUP BY
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
-- Concepts: CTE, JOIN, SUM, GROUP BY
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
-- Concepts: CTE, JOIN, SUM, CASE, HAVING
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
-- Concepts: CTE, JOIN, SUM, WHERE
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
-- Concepts: CTE, self-join, CASE, SUM
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
-- Concepts: CTE, JOIN, SUM, GROUP BY
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
-- Concepts: CTE, JOIN, SUM, ORDER BY, LIMIT
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
-- Concepts: CTE, JOIN, SUM, WHERE
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
