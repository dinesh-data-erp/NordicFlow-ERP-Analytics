# Project 05 — Python ERP Analytics

## 1. Purpose

Project 04 used SQL to answer the main business questions from the NordicFlow ERP data.

This project takes the analysis one step further with Python.

The aim was not to repeat every SQL query. I used Python to explore the results in more detail, compare operational areas and create simple visual analysis before building the final Power BI solution.

The work covers inventory, supplier performance, production and executive-level analysis.

---

## 2. Why Python Was Used

SQL worked well for querying the ERP database and finding specific business results.

Python gave me another way to investigate the same problems.

I used it for:

- loading and checking ERP data
- preparing data for analysis
- comparing inventory positions
- analysing supplier performance
- investigating production performance
- creating charts
- bringing several operational findings together

This also helped me check whether the findings from the SQL stage remained consistent when analysed with another tool.

---

## 3. Analysis Workflow

The Python work was divided into five notebooks.

| Notebook | Main Focus |
|---|---|
| `01_Data_Loading_and_Preparation` | Load the ERP data and prepare it for analysis |
| `02_Inventory_Analytics` | Inventory availability and stock risk |
| `03_Supplier_Performance_Analytics` | Supplier delivery performance |
| `04_Production_Analytics` | Production delays and on-time performance |
| `05_Executive_Analytics` | Bring the main findings together for management |

A small reusable Python script was also created for loading the ERP data.

```text
ERP Data
   ↓
Load & Prepare
   ↓
Inventory / Supplier / Production Analysis
   ↓
Visual Checks
   ↓
Executive Analysis
```
   ↓
Power BI
