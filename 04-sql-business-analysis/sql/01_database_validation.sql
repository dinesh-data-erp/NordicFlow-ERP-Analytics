-- NordicFlow ERP Consultant Portfolio — Project 4
-- 01 Database Validation
-- Run one query at a time in DB Browser for SQLite.

-- Q01 | How many records are loaded in each ERP table?
-- Concepts: COUNT, UNION ALL
-- Decision use: Reconcile the SQL load to the clean Excel release before analysis.
SELECT 'material_master' AS table_name, COUNT(*) AS row_count FROM material_master
UNION ALL SELECT 'supplier_master', COUNT(*) FROM supplier_master
UNION ALL SELECT 'plant_master', COUNT(*) FROM plant_master
UNION ALL SELECT 'bom', COUNT(*) FROM bom
UNION ALL SELECT 'inventory_snapshot', COUNT(*) FROM inventory_snapshot
UNION ALL SELECT 'purchase_order_lines', COUNT(*) FROM purchase_order_lines
UNION ALL SELECT 'production_orders', COUNT(*) FROM production_orders;

-- Q02 | What material categories are managed in the ERP?
-- Concepts: GROUP BY, COUNT
-- Decision use: Understand the manufacturing material structure before transaction analysis.
SELECT Material_Type,
       COUNT(*) AS material_count
FROM material_master
GROUP BY Material_Type
ORDER BY material_count DESC, Material_Type;

-- Q03 | Do logical primary keys contain duplicates?
-- Concepts: CTE, GROUP BY, HAVING, UNION ALL
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
-- Concepts: SUM, CASE, UNION ALL
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
-- Concepts: LEFT JOIN, CASE, UNION ALL
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
