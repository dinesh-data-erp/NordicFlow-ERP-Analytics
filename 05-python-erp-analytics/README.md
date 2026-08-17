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
   ↓
Power BI
```

## 4. Inventory Analysis

The inventory notebook looked at stock availability across NordicFlow locations.

The analysis focused on materials below planning thresholds and cases where stock was not balanced between plants.

Main checks included:

- available stock by material and plant
- safety stock comparison
- reorder-point exposure
- excess stock
- possible stock movement between locations

One important point was that total stock alone was not enough. A material can have enough stock overall but still create a shortage at one plant.

This later became an important part of the inventory and rebalancing views in Power BI.

---

## 5. Supplier Performance Analysis

Supplier performance was analysed using purchase-order delivery data.

The main measure was On-Time Delivery (OTD). I also compared suppliers to see where delays were concentrated.

The analysis showed a clear difference between suppliers. Some performed well, while others created more delivery risk.

For example, supplier OTD ranged from **100% for FastenNordic Oy** to **33.3% for Nordic Motors AB**.

This helped move the analysis from a general supplier KPI to a more useful question:

**Which suppliers need management attention first?**

---

## 6. Production Analysis

The production notebook compared planned and actual production performance.

The analysis included:

- production orders
- planned and actual quantities
- planned and actual completion dates
- production delay
- on-time completion
- material-shortage impact

The data showed that production quantity and production timing should not be treated as the same thing.

A production order may achieve its quantity target but still finish late.

Material shortages were also connected with several delayed orders. This created a link between inventory, procurement and production rather than treating production performance separately.

---

## 7. Executive Analysis

The final notebook brought the operational areas together.

Instead of adding more individual KPIs, I focused on the findings that could support a management decision.

Examples included:

- weak supplier delivery performance
- material shortage exposure
- production schedule risk
- excess inventory at another location
- opportunities for internal stock transfer

The Python stage therefore became a bridge between detailed ERP analysis and the final management dashboard.

The objective was simple: not only show what happened, but give enough context to decide what should be investigated or acted on next.

---

## 8. Cross-Tool Validation

The same ERP business problems were analysed through more than one stage of the project.

SQL was used for structured querying and business-rule analysis. Python was then used for further investigation and visual checking.

The results were later compared with the Power BI semantic model and dashboard.

This was useful because an attractive dashboard is not enough if the underlying numbers cannot be explained or checked.

The workflow became:

**ERP data → Excel data engineering → SQL analysis → Python investigation → Power BI decision support**
