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

---

## 3. Business Problem

NordicFlow's operational challenge is not simply a lack of data. Relevant information exists across procurement, inventory, production, supplier and BOM processes, but management needs these areas connected to understand the causes and business impact of operational problems.

Five concerns define the initial analytical problem.

### Material Availability

Production-critical materials can fall below safety-stock or reorder-point levels while stock of the same material may exist elsewhere in the network.

This creates a potential mismatch between **where inventory exists** and **where inventory is required**.

### Supplier Reliability

Late supplier deliveries can reduce material availability and increase production schedule risk.

Supplier performance therefore needs to be evaluated not only as a procurement KPI, but also in relation to downstream operational impact.

### Inventory Utilisation

A high inventory balance does not necessarily mean that sufficient usable inventory is available for production.

Inventory status, plant location, planning parameters and material requirements must therefore be considered together.

### Production Reliability

Achieving planned production quantity does not necessarily mean production was completed according to schedule.

Management needs visibility into both **output attainment** and **on-time performance**, together with the reasons behind production delays.

### BOM & Material Dependency

The operational importance of a shortage depends partly on how many products rely on the affected component.

BOM relationships therefore provide an additional risk dimension when prioritising material shortages.

---

## 4. Stakeholder & Decision Requirements

The analytical environment is designed around decisions rather than reports alone.

| Stakeholder | Decision Requirement |
|---|---|
| Executive Management | Identify major cross-functional operational risks and management priorities |
| Procurement | Identify unreliable suppliers and purchasing risks requiring intervention |
| Inventory / Materials | Identify shortages, excess inventory and stock-position risks |
| Production | Understand schedule performance and material-related production disruption |
| Supply Chain | Evaluate cross-plant inventory and internal rebalancing opportunities |
| ERP / Data Management | Maintain reliable master data, business rules and analytical definitions |

This means the solution must connect operational processes instead of analysing each function in isolation.

---

## 5. ERP Process Scope

The Phase I analytical scope covers five connected ERP domains.

### Master Data

Provides the reference structure used by operational transactions.

Core objects include:

- Material Master
- Supplier Master
- Plant Master

### Procurement

Represents purchasing activity and supplier delivery performance.

Relevant information includes:

- purchase order lines
- supplier
- ordered quantity
- expected delivery
- actual delivery
- delivery status
- supplier quality rejection

### Inventory & Material Planning

Represents material availability and planning conditions at plant level.

Relevant information includes:

- available stock
- unrestricted stock
- quality inspection stock
- blocked stock
- safety stock
- reorder point
- material location

### Production

Represents planned and executed manufacturing activity.

Relevant information includes:

- production orders
- planned quantity
- actual quantity
- planned completion
- actual completion
- production delay
- material-shortage status

### Bill of Materials

Connects components to the finished products that depend on them.

This allows material risk to be evaluated according to potential production exposure rather than stock quantity alone.

---

## 6. From ERP Analytics to Decision Support

NordicFlow is designed around a progression from operational data to management action:

**ERP Processes → Governed Data → Analytical Model → Business Insight → Decision → Action**

The objective is therefore not simply to produce reports. The analytical environment should allow management to investigate why a KPI is deteriorating, identify the operational drivers and determine an appropriate response.

### AI-Ready Analytical Foundation

The same principle is increasingly important for AI-assisted analytics.

Natural-language analytical tools and AI-assisted reporting are only useful when the underlying business information is trustworthy and correctly defined.

For this reason, NordicFlow treats the following as prerequisites for future AI-assisted analysis:

- governed and validated ERP data
- clearly defined business entities
- reliable relationships between datasets
- documented KPI definitions
- consistent business rules
- meaningful semantic structure
- traceable analytical results

The Phase I projects establish this foundation.

AI-assisted analysis is treated as an extension of the governed analytical environment rather than a substitute for data modelling, data quality or business-process understanding.
