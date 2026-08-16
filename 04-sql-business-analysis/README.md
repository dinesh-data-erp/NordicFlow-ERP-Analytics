# Project 04 — SQL Business Analysis

## 1. Purpose

Project 03 produced a validated ERP dataset. In this project, I moved that data into SQL and started asking business questions.

The focus was not SQL syntax alone.

I wanted to connect inventory, procurement, suppliers, production and BOM data to find operational problems that would matter to a manager.

The workflow was:

**Clean ERP Data → SQL Database → Validation → Business Analysis → Root-Cause Investigation → Management Findings**

---

## 2. SQL Environment

The seven clean ERP datasets from Project 03 were loaded into the NordicFlow SQL database.

The model covers:

- Material Master
- Supplier Master
- Plant Master
- Inventory Snapshot
- Purchase Order Lines
- Production Orders
- Bill of Materials

Before analysing the data, I checked table structure, row counts, keys and important relationships.

This was an important control. A successful database import does not automatically mean the analytical model is correct.

---

## 3. Business Questions

I organised the SQL work around real operational questions rather than isolated technical exercises.

### Inventory

- What is the latest inventory position?
- Which materials are below safety stock or reorder point?
- Where is usable stock different from total stock?
- Can stock at another plant reduce a shortage?
- Where is excess inventory concentrated?

### Procurement & Suppliers

- What is the supplier on-time delivery performance?
- Which suppliers are creating the longest delays?
- Where are supplier quality problems occurring?
- Which suppliers need management attention?

### Production

- How well are production orders meeting planned dates?
- Which orders are affected by material shortages?
- What are the main production-delay causes?
- Are production problems connected with material or supplier performance?

### Management

The final queries bring these areas together.

The aim is to move from:

**What happened? → Why did it happen? → Where should management act?**

## 4. SQL Analysis Approach

I built the analysis in layers rather than starting directly with KPI queries.

The SQL package contains **40 tested queries**, grouped into:

1. database validation
2. inventory analysis
3. procurement and supplier analysis
4. production analysis
5. executive and cross-functional analysis
6. reusable views

I used joins, CTEs, aggregations, CASE logic, date calculations and business-rule filters.

One important example was inventory.

The dataset contains several inventory snapshots. Summing every historical row would overstate the current stock position. I therefore used the **latest valid snapshot** when calculating current inventory KPIs.

This type of check was important throughout the project. A query can run successfully and still give the wrong business answer.

---

## 5. Selected Findings

The SQL analysis exposed several connected operational issues.

| Finding | SQL Result |
|---|---:|
| Latest inventory value | €199,256.50 |
| Supplier On-Time Delivery | 45.8% |
| Production On-Time Performance | 26.7% |
| Production orders affected by shortages | 9 |

The numbers become more useful when they are viewed together.

### Inventory & Rebalancing

Inventory was not only analysed as total stock value.

I compared stock position with safety stock, reorder points and availability across plants. This exposed cases where one location had a requirement while another location held usable stock.

That created a practical management question:

**Can internal rebalancing reduce unnecessary purchasing or shortage exposure?**

### Supplier Performance

Overall supplier OTD was only **45.8%**.

The supplier queries then went deeper into individual delivery performance, average delays and quality issues instead of stopping at the overall KPI.

This helped separate reliable suppliers from suppliers that may require follow-up.

### Production

Production on-time performance was **26.7%**, while **9 production orders** were affected by material shortages.

I compared planned and actual completion dates and investigated delay reasons and shortage indicators.

This showed why quantity alone is not enough to judge production performance. An order can achieve its quantity target and still be operationally late.

---

## 6. From KPI to Root Cause

The most useful part of the SQL work was connecting the ERP areas.

For example:

**Supplier delay → material availability risk → production shortage → late production order**

Not every late production order can be blamed on a supplier. But SQL made it possible to test these relationships instead of assuming the cause.

The executive queries therefore combined evidence from inventory, procurement, production and BOM data.

The aim was not to produce more KPIs.

It was to identify where management should investigate or act.

## 7. Technical Evidence

The SQL work is kept in separate scripts so each stage can be reviewed independently.

```text
sql/
├── 00_schema.sql
├── 01_database_validation.sql
├── 02_inventory_analysis.sql
├── 03_procurement_analysis.sql
├── 04_production_analysis.sql
├── 05_executive_analysis.sql
├── 06_reusable_views.sql
└── SQL_Query_Library.sql
```

The analysis used SQL techniques such as:

- joins across ERP tables
- CTEs and aggregations
- CASE logic
- date calculations
- latest-snapshot filtering
- validation queries
- reusable views
- cross-functional analysis

Selected query outputs and screenshots are also included as evidence of the results.

---

## 8. What I Learned

This project changed how I look at SQL.

Writing a query that runs is only the first step. I also had to check the data grain, relationships, dates and business definition behind each KPI.

A small mistake in any of these can produce a believable but wrong result.

So my working approach became:

**Business Question → SQL Logic → Validation → Finding → Management Action**

---

## 9. Next Project

### [Project 05 — Python ERP Analytics](../05-python-erp-analytics/)

Project 05 continues the same NordicFlow dataset in Python.

The next step is to use Python for deeper investigation, repeatable analysis and visual exploration before the final Power BI decision-support layer.
