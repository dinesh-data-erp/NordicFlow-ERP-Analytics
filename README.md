# NordicFlow ERP Analytics

## End-to-End ERP, Data Engineering & Business Analytics Simulation

NordicFlow is a fictional manufacturing ERP environment developed as an end-to-end portfolio case study covering business requirements, ERP data modelling, data quality management, SQL analysis, Python analytics and Power BI management decision support.

The project was designed around a realistic operational problem:

> How can a manufacturing company experience material shortages and production delays even while significant inventory exists elsewhere in the organisation?

Rather than treating Excel, SQL, Python and Power BI as separate exercises, NordicFlow follows one connected analytical lifecycle from business problem definition through data governance, analysis and management action.

---

## Business Challenge

NordicFlow operates a simulated manufacturing and distribution network involving purchasing, inventory management, production planning, supplier management, Bills of Materials and inter-plant material movement.

The scenario contains several interconnected operational risks:

- material shortages at production plants despite inventory elsewhere in the network
- weak supplier delivery reliability
- inventory held in restricted or non-usable stock statuses
- excess inventory in lower-priority materials
- production orders completed late despite strong overall quantity attainment
- BOM dependencies that increase production exposure to selected components
- inconsistent planning and master-data parameters

The objective is not simply to build dashboards.

The project demonstrates how ERP data can be structured, governed, analysed and converted into management decisions.

---

## Consulting Objective

The NordicFlow project aims to demonstrate an ERP/data consulting workflow capable of:

1. understanding the business problem and ERP process context
2. defining ERP information requirements
3. designing a relational ERP data model
4. establishing data-quality and business rules
5. profiling and remediating unreliable ERP data
6. validating an analysis-ready dataset
7. building a relational analytical database
8. investigating business problems using SQL
9. automating repeatable analytics with Python
10. developing a Power BI semantic and reporting layer
11. validating KPIs across analytical tools
12. translating analytical findings into management recommendations

---

## End-to-End Project Architecture

```text
Business Problem
      ↓
ERP Process & Information Requirements
      ↓
ERP Data Model & Business Rules
      ↓
Data Quality Profiling & Governance
      ↓
Data Cleaning & Validation
      ↓
SQL Business Analysis
      ↓
Python Analytics & Automation
      ↓
Power BI Semantic Model
      ↓
Cross-Functional Business Insights
      ↓
Management Decisions & Actions
```

## Phase I — Completed ERP Analytics Workflow

The first phase of NordicFlow is complete. It covers Projects 01–06 and follows one business case through the full analytical process.

| Project | Focus | Main Outcome |
|---|---|---|
| [01 — Business & ERP Foundation](01-business-erp-foundation/) | Business and ERP requirements | Defined the business problem, processes, stakeholders and decision needs |
| [02 — ERP Data Model & Baseline](02-erp-data-model/) | ERP data architecture | Defined entities, keys, relationships, grain and business rules |
| [03 — Excel Data Engineering](03-excel-data-engineering/) | Data quality and preparation | Profiled, cleaned and validated the ERP dataset |
| [04 — SQL Business Analysis](04-sql-business-analysis/) | Business investigation | Analysed inventory, suppliers, production and cross-plant risks |
| [05 — Python ERP Analytics](05-python-erp-analytics/) | Analytics and automation | Built repeatable KPI, risk and management-level analytical outputs |
| [06 — Power BI Executive Dashboard](06-power-bi-executive-dashboard/) | Decision support | Connected the analysis into an interactive management reporting solution |

These projects are not separate tool demonstrations. Each stage uses the previous stage and moves the same ERP case forward.

The completed Phase I can be summarised as:

**Business Problem → ERP Data → Data Quality → SQL → Python → Semantic Model → Power BI → Management Decision / Action**

---

## Selected Business Findings

The analysis showed that NordicFlow's main operational issues were connected rather than isolated.

| Finding | Result | Why It Matters |
|---|---:|---|
| Supplier On-Time Delivery | **45.8%** | Supplier reliability needs attention |
| Production On-Time Performance | **26.67%** | Production quantity alone does not show schedule performance |
| Shortage-Affected Production Orders | **9** | Material availability is contributing to production risk |
| Latest Inventory Value | **$199.26K** | Significant inventory exists across the network |
| Unrestricted Inventory Value | **$143.47K** | Not all inventory is immediately usable |
| C-Class Excess Inventory | **590 units** | Excess stock exists while shortages occur elsewhere |
| Internal Transfer Opportunities | **6** | Some shortages may be supported from another plant |
| Recommended Transfer Quantity | **123 units** | Internal rebalancing can be considered before new purchasing |

One finding became especially useful during the project.

A shortage does not always mean **buy more material**.

When inventory was viewed across plants, some excess stock could potentially support shortages at another location. This moved the analysis from simply reporting stock levels toward a management question:

> **Can existing inventory be used better before creating additional procurement demand?**

---

## Power BI Decision Support

The final Power BI report brings inventory, procurement, supplier, production and BOM information into one connected management view.

### Executive Overview

The overview gives management the main operational signals first, with access to deeper investigation when needed.

![NordicFlow Executive Overview](06-power-bi-executive-dashboard/screenshots/01-executive-overview.png)

### Inventory Rebalancing

The rebalancing page looks for situations where excess stock at one plant may support demand at another.

![NordicFlow Inventory Rebalancing](06-power-bi-executive-dashboard/screenshots/03-rebalancing.png)

### Production Performance

Production analysis connects schedule performance with material shortages and other delay information.

![NordicFlow Production Analysis](06-power-bi-executive-dashboard/screenshots/05-production.png)

### Management Actions

The final layer brings the main analytical signals closer to possible management action.

![NordicFlow Management Actions](06-power-bi-executive-dashboard/screenshots/08-management-actions.png)

The full Power BI case includes inventory, suppliers, BOM risk, risk analysis, drill-through pages, report-page tooltips, filtering, navigation and reset controls.

[Explore the complete Power BI project](06-power-bi-executive-dashboard/)

---
