PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS production_orders;
DROP TABLE IF EXISTS purchase_order_lines;
DROP TABLE IF EXISTS inventory_snapshot;
DROP TABLE IF EXISTS bom;
DROP TABLE IF EXISTS material_master;
DROP TABLE IF EXISTS supplier_master;
DROP TABLE IF EXISTS plant_master;

CREATE TABLE supplier_master (
    Supplier_ID TEXT PRIMARY KEY,
    Supplier_Name TEXT NOT NULL,
    Supplier_Country TEXT,
    Supplier_Category TEXT,
    Payment_Terms_Days INTEGER,
    Risk_Level TEXT CHECK (Risk_Level IN ('Low','Medium','High')),
    Preferred_Status INTEGER CHECK (Preferred_Status IN (0,1)),
    Active_Status INTEGER NOT NULL CHECK (Active_Status IN (0,1)),
    Target_Lead_Time_Days INTEGER CHECK (Target_Lead_Time_Days >= 0),
    Target_On_Time_Rate REAL CHECK (Target_On_Time_Rate BETWEEN 0 AND 1)
);

CREATE TABLE plant_master (
    Plant_ID TEXT PRIMARY KEY,
    Plant_Name TEXT NOT NULL,
    City TEXT,
    Plant_Type TEXT,
    Country TEXT,
    Active_Status INTEGER NOT NULL CHECK (Active_Status IN (0,1))
);

CREATE TABLE material_master (
    Material_ID TEXT PRIMARY KEY,
    Material_Name TEXT NOT NULL,
    Material_Type TEXT NOT NULL,
    Material_Group TEXT,
    Base_Unit TEXT NOT NULL,
    Standard_Cost_EUR REAL CHECK (Standard_Cost_EUR > 0),
    Planned_Lead_Time_Days INTEGER CHECK (Planned_Lead_Time_Days >= 0),
    Safety_Stock_Qty INTEGER CHECK (Safety_Stock_Qty >= 0),
    Reorder_Point_Qty INTEGER CHECK (Reorder_Point_Qty >= 0),
    ABC_Class TEXT CHECK (ABC_Class IN ('A','B','C')),
    XYZ_Class TEXT CHECK (XYZ_Class IN ('X','Y','Z')),
    Criticality TEXT CHECK (Criticality IN ('Critical','Important','Normal')),
    Preferred_Supplier_ID TEXT,
    Active_Status INTEGER NOT NULL CHECK (Active_Status IN (0,1)),
    FOREIGN KEY (Preferred_Supplier_ID) REFERENCES supplier_master(Supplier_ID)
);

CREATE TABLE bom (
    BOM_ID TEXT NOT NULL,
    Finished_Product_ID TEXT NOT NULL,
    BOM_Version TEXT NOT NULL,
    Component_Line INTEGER NOT NULL,
    Component_Material_ID TEXT NOT NULL,
    Quantity_Per_Unit INTEGER NOT NULL CHECK (Quantity_Per_Unit > 0),
    Scrap_Factor_Percent REAL NOT NULL CHECK (Scrap_Factor_Percent >= 0),
    Effective_From TEXT NOT NULL,
    Effective_To TEXT,
    Active_Status INTEGER NOT NULL CHECK (Active_Status IN (0,1)),
    PRIMARY KEY (BOM_ID, BOM_Version, Component_Line),
    FOREIGN KEY (Finished_Product_ID) REFERENCES material_master(Material_ID),
    FOREIGN KEY (Component_Material_ID) REFERENCES material_master(Material_ID)
);

CREATE TABLE inventory_snapshot (
    Snapshot_Date TEXT NOT NULL,
    Material_ID TEXT NOT NULL,
    Plant_ID TEXT NOT NULL,
    Stock_Status TEXT NOT NULL CHECK (
        Stock_Status IN ('Unrestricted','Quality Inspection','Blocked','Reserved','In Transit')
    ),
    Quantity INTEGER NOT NULL CHECK (Quantity >= 0),
    Unit_Cost_EUR REAL NOT NULL CHECK (Unit_Cost_EUR > 0),
    Inventory_Value_EUR REAL NOT NULL CHECK (Inventory_Value_EUR >= 0),
    PRIMARY KEY (Snapshot_Date, Material_ID, Plant_ID, Stock_Status),
    FOREIGN KEY (Material_ID) REFERENCES material_master(Material_ID),
    FOREIGN KEY (Plant_ID) REFERENCES plant_master(Plant_ID)
);

CREATE TABLE purchase_order_lines (
    PO_ID TEXT NOT NULL,
    PO_Line INTEGER NOT NULL,
    Supplier_ID TEXT NOT NULL,
    Material_ID TEXT NOT NULL,
    Plant_ID TEXT NOT NULL,
    PO_Creation_Date TEXT NOT NULL,
    Required_Delivery_Date TEXT NOT NULL,
    Confirmed_Delivery_Date TEXT,
    Actual_Receipt_Date TEXT,
    Ordered_Qty INTEGER NOT NULL CHECK (Ordered_Qty > 0),
    Received_Qty INTEGER NOT NULL CHECK (Received_Qty >= 0),
    Unit_Price_EUR REAL NOT NULL CHECK (Unit_Price_EUR > 0),
    PO_Status TEXT NOT NULL,
    Quality_Accepted_Qty INTEGER NOT NULL CHECK (Quality_Accepted_Qty >= 0),
    Quality_Rejected_Qty INTEGER NOT NULL CHECK (Quality_Rejected_Qty >= 0),
    Actual_Lead_Time_Days INTEGER,
    Delivery_Delay_Days INTEGER,
    On_Time_Flag INTEGER CHECK (On_Time_Flag IN (0,1)),
    Open_Qty INTEGER CHECK (Open_Qty >= 0),
    Quality_Rejection_Rate REAL CHECK (Quality_Rejection_Rate >= 0),
    PRIMARY KEY (PO_ID, PO_Line),
    FOREIGN KEY (Supplier_ID) REFERENCES supplier_master(Supplier_ID),
    FOREIGN KEY (Material_ID) REFERENCES material_master(Material_ID),
    FOREIGN KEY (Plant_ID) REFERENCES plant_master(Plant_ID)
);

CREATE TABLE production_orders (
    Production_Order_ID TEXT PRIMARY KEY,
    Finished_Product_ID TEXT NOT NULL,
    Plant_ID TEXT NOT NULL,
    Order_Creation_Date TEXT NOT NULL,
    Planned_Start_Date TEXT NOT NULL,
    Actual_Start_Date TEXT,
    Planned_End_Date TEXT NOT NULL,
    Actual_End_Date TEXT,
    Planned_Qty INTEGER NOT NULL CHECK (Planned_Qty > 0),
    Actual_Qty INTEGER NOT NULL CHECK (Actual_Qty >= 0),
    Order_Status TEXT NOT NULL,
    Delay_Reason TEXT,
    Material_Shortage_Flag INTEGER NOT NULL CHECK (Material_Shortage_Flag IN (0,1)),
    Production_Priority TEXT,
    Planned_Duration_Days INTEGER CHECK (Planned_Duration_Days >= 0),
    Actual_Duration_Days INTEGER CHECK (Actual_Duration_Days >= 0),
    Completion_Delay_Days INTEGER,
    FOREIGN KEY (Finished_Product_ID) REFERENCES material_master(Material_ID),
    FOREIGN KEY (Plant_ID) REFERENCES plant_master(Plant_ID)
);

CREATE INDEX idx_inventory_material ON inventory_snapshot(Material_ID);
CREATE INDEX idx_inventory_plant ON inventory_snapshot(Plant_ID);
CREATE INDEX idx_po_supplier ON purchase_order_lines(Supplier_ID);
CREATE INDEX idx_po_material ON purchase_order_lines(Material_ID);
CREATE INDEX idx_prod_product ON production_orders(Finished_Product_ID);
CREATE INDEX idx_bom_component ON bom(Component_Material_ID);
