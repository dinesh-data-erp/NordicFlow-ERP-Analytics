# Project 02 — ERP Data Model & Baseline

## 1. Purpose

Project 01 defined the business questions. The next step was to decide what data was needed and how the different ERP datasets should connect.

For NordicFlow, I built a small ERP analytical model around seven datasets:

- Material Master
- Plant Master
- Supplier Master
- Inventory Snapshot
- Purchase Order Lines
- Production Orders
- Bill of Materials (BOM)

The aim was not to copy a full SAP or IFS database. Real ERP systems contain hundreds or thousands of tables.

Instead, I kept the model focused on the business problems in this simulation: inventory availability, supplier performance, production reliability, material dependency and stock rebalancing.

---

## 2. Data Model

The model combines master data with operational data.

### Master Data

| Table | What it represents |
|---|---|
| Material Master | Materials used or managed by NordicFlow |
| Plant Master | Manufacturing plants and other operating locations |
| Supplier Master | External suppliers and their basic attributes |

### Operational Data

| Table | What it represents |
|---|---|
| Inventory Snapshot | Material stock position at each plant |
| Purchase Order Lines | Individual purchasing transactions |
| Production Orders | Planned and completed production activity |
| BOM | Relationship between finished products and components |

This structure allows the same material or plant to be followed across different business processes.

For example:

**Supplier → Purchase Order → Material → Inventory**

and:

**Material → BOM → Production**

This connection becomes important later. A supplier delay alone tells only part of the story. The real business question is whether that delay contributes to a material shortage or production risk.

---

## 3. Table Grain

Before joining the datasets, I defined what one row means in each table.

| Table | One row represents |
|---|---|
| Material Master | One material |
| Plant Master | One plant or operating location |
| Supplier Master | One supplier |
| Inventory Snapshot | One material at one plant for the available snapshot |
| Purchase Order Lines | One purchase-order line |
| Production Orders | One production order |
| BOM | One finished-product and component relationship |

This was an important modelling step.

For example, Material Master should contain one row per material. But the same material can appear many times in Inventory Snapshot because it can exist at different plants.

The same material can also appear on several purchase orders or in several BOM relationships.

If these different grains are ignored, joins can duplicate records and inflate quantities.

---

## 4. Keys and Relationships

The main identifiers used to connect the datasets are:

- `Material_ID`
- `Plant_ID`
- `Supplier_ID`
- production-order identifier
- purchase-order / line identifier
- finished-product and component identifiers in the BOM

The basic relationship logic is:

```text
Material Master
     │
     ├── Inventory Snapshot
     │
     ├── Purchase Order Lines
     │
     └── BOM / Component relationship

Plant Master
     │
     ├── Inventory Snapshot
     └── Production Orders

Supplier Master
     │
     └── Purchase Order Lines
