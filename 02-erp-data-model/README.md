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
| Inventory Snapshot | One material + plant + stock status + snapshot date |
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


## 6. Actual Keys Used in the Model

The seven tables use a mix of single-field and composite business keys.

| Table | Key used |
|---|---|
| Material Master | `Material_ID` |
| Supplier Master | `Supplier_ID` |
| Plant Master | `Plant_ID` |
| BOM | `BOM_ID + BOM_Version + Component_Line` |
| Inventory Snapshot | `Snapshot_Date + Material_ID + Plant_ID + Stock_Status` |
| Purchase Order Lines | `PO_ID + PO_Line` |
| Production Orders | `Production_Order_ID` |

The master-data keys are simple because each master record should be unique.

The operational tables are different. A purchase order can have several lines, and inventory can contain the same material at different plants, dates and stock statuses. Composite keys are therefore needed.

---

## 7. Foreign Keys

The main foreign keys connect transactions and operational records back to trusted master data.

| Child table | Foreign key | Parent table |
|---|---|---|
| Purchase Order Lines | `Supplier_ID` | Supplier Master |
| Purchase Order Lines | `Material_ID` | Material Master |
| Purchase Order Lines | `Plant_ID` | Plant Master |
| Inventory Snapshot | `Material_ID` | Material Master |
| Inventory Snapshot | `Plant_ID` | Plant Master |
| Production Orders | `Finished_Product_ID` | Material Master |
| Production Orders | `Plant_ID` | Plant Master |
| BOM | `Finished_Product_ID` | Material Master |
| BOM | `Component_Material_ID` | Material Master |

This makes the master tables the reference layer for the operational data.

A purchase-order line, for example, should not contain a supplier, material or plant that does not exist in the related master table.

---

## 8. Relationship Design

The baseline relationship model uses mainly one-to-many relationships.

| Parent | Child | Cardinality | Business meaning |
|---|---|---|---|
| Supplier Master | Purchase Order Lines | 1:M | One supplier can appear on many PO lines |
| Material Master | Purchase Order Lines | 1:M | One material can appear on many PO lines |
| Plant Master | Purchase Order Lines | 1:M | One plant can receive many PO lines |
| Material Master | Inventory Snapshot | 1:M | One material can have many stock records |
| Plant Master | Inventory Snapshot | 1:M | One plant can hold many stock records |
| Material Master | Production Orders | 1:M | One finished product can have many production orders |
| Plant Master | Production Orders | 1:M | One plant can execute many production orders |
| Material Master | BOM | 1:M | One finished product can have many BOM component lines |
| Material Master | BOM | 1:M | One component can be used in many BOMs |

The relationship direction is mainly from the master record to the repeated operational records.

Simple idea:

**Master table (1) → Transaction / Snapshot table (many)**

This later helped when the same structure was implemented in SQL and Power BI.

---

## 9. One Important BOM Modelling Issue

The BOM was the most interesting part of the relationship design.

`Material_Master` is used in two different roles:

- finished product
- component material

The BOM therefore contains both:

`Finished_Product_ID`

and:

`Component_Material_ID`

Both fields refer back to Material Master.

This creates a modelling issue because one Material table is being asked to play two roles.

In SQL, this can be handled by joining Material Master twice with different aliases.

In Power BI, the same relationship needs more care. Two active relationships from the same material dimension to the BOM can create ambiguity.

This was an important lesson from the project:

> A relationship can be logically correct but still create problems in the analytical model if the same dimension is used for different business roles.

The final Power BI model therefore did not simply activate every possible BOM relationship.

---

## 10. Relationship Risks

I also documented what could go wrong if the relationships or keys were incorrect.

Some examples:

- Duplicate suppliers can inflate supplier and purchasing KPIs.
- Missing material references can remove cost or classification information from PO analysis.
- Wrong plant relationships can hide where stock is actually located.
- Duplicate inventory keys can double-count inventory quantities and value.
- Broken BOM references can understate component requirements.
- Incorrect production-product relationships can make product-level production analysis unreliable.

This was useful later because data-quality testing was not treated only as checking blank cells. It was also about whether records could be connected correctly across the ERP model.

---

## 11. Key Validation

Before using the model for analysis, I defined checks for the most important key and relationship rules.

Examples:

- Material IDs must be unique.
- Supplier IDs must be unique.
- Plant IDs must be unique.
- `BOM_ID + BOM_Version + Component_Line` must be unique.
- `Snapshot_Date + Material_ID + Plant_ID + Stock_Status` must be unique.
- `PO_ID + PO_Line` must be unique.
- Production Order ID must be unique.
- BOM finished products and components must exist in Material Master.
- Inventory materials and plants must exist in their master tables.
- PO suppliers, materials and plants must exist in the related master tables.

The aim was simple: no orphan records and no duplicate business keys before analytical work starts.

---

## 12. End-to-End Validation Example

The model was also tested with business scenarios, not only technical key checks.

One example was a motor shortage in Tampere:

**Production demand → BOM component → Tampere stock position → Vaasa excess stock**

The model needed to show both sides of the problem:

- local shortage at the production plant
- available stock somewhere else in the network

Another scenario connected an incorrect planned lead time with late purchase-order receipts and production risk.

These tests helped confirm that the model could trace a business issue across master data, transactions and inventory rather than only report isolated table values.
