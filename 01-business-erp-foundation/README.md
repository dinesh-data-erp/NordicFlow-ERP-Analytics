# Project 01 — Business & ERP Foundation

## NordicFlow ERP Analytics

**Phase:** Business Discovery & Requirements Definition  
**Environment:** Simulated manufacturing ERP environment  
**Next Stage:** Project 02 — ERP Data Model & Baseline

---

## 1. Project Purpose

NordicFlow is a fictional manufacturing company created to simulate a realistic ERP and data analytics consulting engagement.

The project begins with a business problem rather than a dashboard or analytical tool.

NordicFlow management needs better visibility into the relationship between:

- inventory availability
- purchasing and supplier performance
- production execution
- material planning
- BOM dependencies
- inter-plant inventory
- operational risk

The objective of this first project is therefore to translate operational concerns into structured ERP information requirements and analytical questions.

The technical implementation begins only after these requirements are defined.

---

## 2. Business Scenario

NordicFlow operates a simulated manufacturing network consisting of:

- Tampere Manufacturing Plant
- Vaasa Manufacturing Plant
- Vantaa Distribution Centre

The organisation purchases materials from external suppliers, maintains inventory across locations and uses materials and components to support manufacturing operations.

Its ERP environment must therefore connect several business processes:

```text
Supplier
   ↓
Procurement
   ↓
Material Receipt
   ↓
Inventory
   ↓
BOM / Material Requirement
   ↓
Production
   ↓
Finished Product
