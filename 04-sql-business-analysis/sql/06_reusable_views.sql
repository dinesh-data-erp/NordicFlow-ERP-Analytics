-- NordicFlow Project 4 — Reusable analytical views

DROP VIEW IF EXISTS v_latest_inventory;
CREATE VIEW v_latest_inventory AS
WITH latest AS (
    SELECT MAX(Snapshot_Date) AS snapshot_date
    FROM inventory_snapshot
)
SELECT i.*
FROM inventory_snapshot i
JOIN latest l ON i.Snapshot_Date = l.snapshot_date;

DROP VIEW IF EXISTS v_supplier_performance;
CREATE VIEW v_supplier_performance AS
SELECT
    p.Supplier_ID,
    s.Supplier_Name,
    COUNT(*) AS po_lines,
    ROUND(100.0 * AVG(CASE WHEN p.On_Time_Flag = 1 THEN 1.0 ELSE 0.0 END),1) AS on_time_delivery_pct,
    ROUND(AVG(p.Delivery_Delay_Days),1) AS avg_delivery_delay_days,
    ROUND(100.0 * SUM(p.Quality_Rejected_Qty) / NULLIF(SUM(p.Received_Qty),0),2) AS rejection_rate_pct
FROM purchase_order_lines p
JOIN supplier_master s ON p.Supplier_ID = s.Supplier_ID
GROUP BY p.Supplier_ID, s.Supplier_Name;
