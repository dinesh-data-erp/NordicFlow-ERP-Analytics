# Project 06 — Power BI Executive Dashboard

## 1. Purpose

Project 06 is the reporting and decision-support stage of the NordicFlow ERP analytics project.

Projects 03–05 prepared, queried and investigated the ERP data. Here I brought those findings into one Power BI solution.

The goal was not only to build charts. I wanted management to move from a high-level problem to the supporting operational detail and then to a possible action.

**ERP data → validated analysis → business insight → management decision**

---

## 2. Dashboard Scope

The Power BI solution connects several operational areas in one report.

| Area | Main Question |
|---|---|
| Executive Overview | Where are the main operational risks? |
| Inventory | Where are shortages, excess stock and working-capital risks? |
| Rebalancing | Can available stock at one plant support another plant? |
| Suppliers | Which suppliers are creating delivery or quality risk? |
| Production | Where are production delays and material shortages affecting performance? |
| BOM Risk | Which component shortages can affect finished products? |
| Risk Analysis | Which risks should receive more attention? |
| Management Actions | What actions are supported by the analysis? |

This cross-functional view was important. A production delay may start with a supplier problem or material shortage, while another location may already hold usable stock.

---

## 3. Report Design

The report was designed in layers.

### Overview

The executive page gives a quick view of inventory, supplier delivery, production performance, shortages and operational risk.

### Investigation

The functional pages allow the user to investigate inventory, suppliers, production and BOM dependencies in more detail.

### Detail

Drill-through pages provide additional material and production-order information when deeper investigation is needed.

Report-page tooltips are used selectively where they add useful context without forcing the user to leave the current page.

### Action

The final part of the report brings the main risks together and connects them with management actions.

This creates a simple navigation path:

**Overview → Investigate → Detail → Action**

---

## 4. Management Questions

The report was built to answer practical questions rather than only display KPIs.

Examples include:

- How much inventory is currently available and usable?
- Which materials are below safety stock or reorder point?
- Is excess inventory available at another plant?
- Which suppliers have weak delivery performance?
- Are material shortages affecting production orders?
- Which components create wider BOM dependency risk?
- Which operational issues should management investigate first?
- What action could reduce the identified risk?

The dashboard therefore acts as the final decision-support layer of the Phase I NordicFlow analytics workflow.

## 5. Key Findings

The dashboard brought several operational issues together.

### Supplier Performance

Overall Supplier On-Time Delivery was **45.8%**.

Performance was not equal across suppliers. Some suppliers delivered reliably, while others showed much weaker results. This gives procurement a clearer starting point for supplier follow-up instead of looking only at total purchase activity.

### Production Reliability

Production On-Time Performance was **26.67%**.

There were **9 shortage-affected production orders**. This showed that material availability was one factor behind weak production schedule performance, although not every delay was caused by a shortage.

This distinction was important. Production delay and material shortage should not automatically be treated as the same problem.

### Inventory Risk

The latest inventory value was approximately **$199.26K**, with around **$143.47K in unrestricted inventory**.

The analysis also identified stock positions below safety stock and reorder point.

At the same time, excess inventory existed elsewhere in the network. So the problem was not simply "buy more stock".

### Internal Rebalancing

The rebalancing analysis identified **6 internal transfer opportunities** with **123 units recommended for transfer**.

C-class excess inventory was **590 units**.

This created an alternative management action:

**Check internal stock availability before creating additional procurement demand.**

### Quality

Approximately **$8.02K** of inventory was in quality inspection stock, while the overall supplier rejection rate was **1.48%**.

This helped separate physical inventory from stock that was immediately usable.

---

## 6. From Insight to Action

The final report does not stop at KPI monitoring.

The findings point to several practical actions:

- investigate suppliers with weak delivery performance
- prioritise materials below planning thresholds
- review shortage-affected production orders
- use BOM dependency when judging material criticality
- evaluate internal stock transfers before additional purchasing
- separate supplier, inventory and production causes before deciding corrective action

The aim is not to let the dashboard make the decision automatically.

It gives management a connected view of the evidence so the next action can be better informed.

---

## 7. Investigation Features

The report includes several features for moving from summary information into operational detail.

### Drill-through

Material and production drill-through pages allow a selected item to be investigated without putting all detail on the main dashboard.

### Report-Page Tooltips

Supplier and material tooltips provide additional context when the visual has a reliable filter context.

Tooltips were used selectively rather than on every visual.

### Filtering

Plant, material and other relevant slicers allow the report to be viewed from different operational perspectives.

### Navigation

A consistent side navigation connects the main analytical pages.

Reset-filter controls were also added so users can return pages to their intended starting state.

---

## 8. Management Decision Layer

The final stage connects analytical findings with management priorities.

The logic is:

**Signal → Investigation → Business Context → Possible Action**

For example:

**Low material availability**  
→ check plant-level stock  
→ check stock at another location  
→ review production dependency  
→ consider internal transfer before new procurement

Or:

**Low supplier OTD**  
→ identify the supplier  
→ review delay performance and risk  
→ check related material exposure  
→ prioritise supplier improvement action

This was an important part of the project for me. A KPI becomes more useful when I can connect it to the business process behind it and the decision that may follow.

## 9. Power BI Skills Used

This project gave me a chance to bring the earlier ERP analysis into one working Power BI solution.

The main areas I worked with were:

- data modelling and table relationships
- DAX measures and calculated business KPIs
- filter context
- slicers and cross-filtering
- conditional formatting
- drill-through pages
- report-page tooltips
- bookmarks and reset-filter controls
- page navigation
- management-focused dashboard design

I also learned that adding more features does not always improve a report.

For example, some tooltip behaviour depended strongly on the filter context of the source visual. Where it did not behave reliably, I kept the interaction simple instead of forcing the feature.

---

## 10. Validation and QA

Before closing the Power BI stage, I checked the report page by page.

The final review covered:

- KPI values against the underlying analysis
- slicer behaviour
- visual interactions
- drill-through behaviour
- report-page tooltips
- navigation and back buttons
- reset-filter bookmarks
- table and chart consistency
- labels, titles and number formatting

Some visuals were adjusted during this stage when the first design could give a confusing result.

The final QA was completed before preparing the project for GitHub.

---

## 11. What I Learned

The biggest lesson from Project 06 was that building a dashboard is only one part of Power BI work.

The harder part was deciding what the user should see first, what detail should stay behind the main page and how one business problem connects with another.

Inventory, procurement and production looked like separate topics at the beginning. After working through the data, the links became much clearer.

A supplier delay can affect material availability. A material shortage can affect production. But excess stock at another plant may change the action completely.

That business connection became more important to me than adding another chart.

---

## 12. Limitations and Next Development

NordicFlow is a simulated environment using static data. It is not connected to a live ERP system.

The current solution also does not include automated refresh pipelines, forecasting or production deployment.

A useful next stage would be to explore AI-assisted analysis on top of a trusted semantic model. The important point would still be the same: AI should work from clear business definitions and reliable data.

A possible future flow is:

**ERP Data → Data Quality → SQL / Python → Semantic Model → Power BI → AI-Assisted Analysis → Decision / Action**

This is planned as a future extension rather than a feature of the current dashboard.

---

## 13. End-to-End Project Result

Project 06 completes the first major phase of NordicFlow.

The work developed through a connected sequence:

1. Business and ERP requirements
2. ERP data model and baseline
3. Excel data engineering and quality work
4. SQL business analysis
5. Python ERP analytics
6. Power BI decision support

Each stage uses the work from the previous stage rather than acting as a separate portfolio exercise.

For me, this is the main value of NordicFlow. It shows the full path from an ERP business problem and raw operational data to analysis, management insight and possible action.

Projects 07–12 remain future development areas and are described separately in the project roadmap.

---

## Simulation Notice

NordicFlow Manufacturing Oy is a fictional organisation created for portfolio and learning purposes.

The data, business cases and management situations are simulated. The project demonstrates my approach to ERP, data analysis and decision-support work. It does not represent a real NordicFlow client implementation.
