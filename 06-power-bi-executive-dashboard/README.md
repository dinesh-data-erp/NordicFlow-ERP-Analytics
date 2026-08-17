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
