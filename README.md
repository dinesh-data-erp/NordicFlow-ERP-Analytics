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
