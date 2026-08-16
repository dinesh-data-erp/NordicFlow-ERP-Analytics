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

Its ERP environment must therefore connect several interdependent business processes:

**Supplier → Procurement → Material Receipt → Inventory → Production → Finished Product**

Material planning and BOM relationships operate across this flow by connecting component requirements, inventory availability and production demand.


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

## 7. Core Business Questions

The business and stakeholder requirements are translated into a structured set of analytical questions. These questions define what the later data-engineering, SQL, Python and Power BI stages must be capable of answering.

### Inventory & Material Availability

1. What is the latest inventory position and value across NordicFlow locations?
2. How much inventory is unrestricted and available for operational use?
3. Which material-plant positions are below safety stock?
4. Which material-plant positions are below reorder point?
5. Where is excess inventory concentrated?
6. Can available stock at one location support a shortage or requirement at another location?

### Procurement & Supplier Performance

7. What is the overall supplier On-Time Delivery (OTD) performance?
8. Which suppliers have the greatest delivery delays?
9. Which suppliers create the highest combination of delivery and operational risk?
10. Where are supplier-related quality rejections occurring?
11. Which suppliers should receive management attention first?

### Production Performance

12. What percentage of production orders are completed on time?
13. Is planned production quantity being achieved?
14. Which production orders are affected by material shortages?
15. What are the main causes of production delay?
16. Which plants or production priorities show the greatest schedule risk?

### BOM & Material Dependency

17. Which components support the greatest number of finished products?
18. Which critical components are below planning thresholds?
19. Which material shortages could affect multiple finished products?
20. Where does material dependency increase operational risk?

### Inventory Rebalancing

21. Which materials have shortage exposure at one plant while usable stock exists at another?
22. What internal transfer opportunities can be identified?
23. How much inventory could potentially be rebalanced before additional procurement is considered?

### Executive Decision Support

24. What are the most significant cross-functional operational risks?
25. Which issues require immediate management attention?
26. What evidence explains the underlying causes of those risks?
27. What operational actions could reduce shortage, supplier and production exposure?

These questions establish the analytical requirements. They do not assume the answers in advance; the evidence is developed progressively through Projects 03–06.

---

## 8. Information Requirements

Answering the business questions requires connected master, transactional and planning data rather than isolated departmental reports.

| Dataset | Business Purpose | Example Information Required |
|---|---|---|
| Material Master | Define materials and planning characteristics | Material ID, material name, material type, ABC class, criticality |
| Plant Master | Define organisational and location structure | Plant ID, plant name, plant type/location |
| Supplier Master | Define supplier characteristics | Supplier ID, supplier name, category, risk level, preferred status |
| Inventory Snapshot | Measure material availability by location | Material, plant, stock quantities, safety stock, reorder point, inventory value |
| Purchase Order Lines | Analyse procurement execution and supplier performance | Supplier, material, ordered quantity, expected delivery, actual delivery, receipt and rejection information |
| Production Orders | Analyse manufacturing execution | Plant, production order, planned/actual quantity, planned/actual completion, priority, shortage indicator |
| Bill of Materials | Connect components with dependent products | Finished product, component/material relationship |

These datasets must support analysis across ERP processes rather than only within individual tables.

For example:

**Supplier → Purchase Order → Material → Inventory → Production Requirement**

and:

**Component → BOM → Finished Product**

The analytical environment therefore depends on consistent identifiers, reliable master data and clearly defined relationships between operational datasets.

---

## 9. Analytical Grain

Before building calculations or joining ERP datasets, the grain of each dataset must be explicitly defined.

**Grain** describes what one row represents.

| Dataset | Analytical Grain |
|---|---|
| Material Master | One row per material |
| Supplier Master | One row per supplier |
| Plant Master | One row per plant/location |
| Inventory Snapshot | One row per material × plant × inventory snapshot |
| Purchase Order Lines | One row per purchase-order line |
| Production Orders | One row per production order |
| Bill of Materials | One row per finished-product × component relationship |

Defining grain is important because different ERP datasets represent different levels of business activity.

For example, a material may:

- exist at multiple plants,
- appear on multiple purchase-order lines,
- support multiple production orders,
- and be used by multiple finished products through the BOM.

Joining these datasets without respecting their grain can duplicate records, inflate quantities and produce misleading KPIs.

The NordicFlow analytical design therefore follows three principles:

1. **Preserve the natural grain of each source dataset.**
2. **Use master-data keys to establish controlled relationships between business objects.**
3. **Aggregate measures only at a level supported by the underlying transactional grain.**

These requirements provide the bridge from business discovery into the ERP analytical data model developed in Project 02.

## 10. Business Rules & KPI Logic

The analytical requirements must be translated into explicit business rules before technical calculations are implemented.

This prevents KPI definitions from changing between Excel, SQL, Python and Power BI.

### Supplier On-Time Delivery

A purchase-order line is considered on time when the actual receipt date meets the required delivery date.

Conceptually:

**On Time = Actual Receipt Date ≤ Required Delivery Date**

Supplier OTD is then calculated from the proportion of purchase-order lines meeting this rule.

### Production On-Time Performance

A production order is considered on time when actual completion does not exceed the planned completion date.

Conceptually:

**On Time = Actual End Date ≤ Planned End Date**

### Production Attainment

Production attainment compares actual production quantity with planned production quantity.

Conceptually:

**Production Attainment = Actual Quantity / Planned Quantity**

This must be analysed separately from schedule performance because a production order can achieve the planned quantity and still finish late.

### Safety-Stock Exposure

A material-plant position is considered below safety stock when:

**Available Stock < Safety Stock**

### Reorder-Point Exposure

A material-plant position is considered below reorder point when:

**Available Stock < Reorder Point**

### Internal Rebalancing

A transfer opportunity can exist when the same material has:

- shortage exposure at one location, and
- usable surplus stock at another location.

The recommended transfer quantity must respect both the destination requirement and the amount that can be transferred without creating a new shortage at the source.

### BOM Dependency

Material risk should consider not only stock quantity but also the number and criticality of finished products that depend on the component.

These business definitions are implemented and validated progressively in later project stages.

---

## 11. Scope Boundaries

Project 01 defines the Phase I analytical scope.

### Included

- ERP master data
- supplier management
- procurement
- inventory availability
- material planning parameters
- production execution
- BOM relationships
- inter-plant inventory analysis
- cross-functional operational risk
- management KPI requirements
- analytical validation requirements

### Outside Phase I

The following are intentionally excluded from the completed Phase I implementation:

- live SAP, IFS or other ERP-system integration
- automated production ERP transactions
- financial accounting and controlling processes
- sales-order and customer-service processes
- warehouse-management execution
- automated MRP runs
- predictive machine-learning models
- production deployment
- autonomous AI decision-making

These boundaries keep the simulation focused on ERP operational analytics and decision support.

---

## 12. Decision-Support & AI-Readiness Principle

NordicFlow is designed as a decision-support environment rather than a collection of disconnected reports.

The target analytical progression is:

**Business Problem → ERP Process → Governed Data → Analytical Model → KPI → Insight → Decision → Action**

A further design principle is that future AI-assisted analytics should operate on the same governed foundation.

AI-assisted analysis can potentially support tasks such as:

- natural-language exploration of business metrics
- assisted analytical investigation
- explanation of KPI changes
- generation or refinement of analytical calculations
- management-question exploration
- guided decision support

However, these capabilities depend on reliable underlying information.

For this reason, NordicFlow treats the following as prerequisites for AI-assisted analysis:

- validated ERP data
- explicit business definitions
- controlled relationships
- documented KPI logic
- reliable semantic modelling
- traceable calculations
- human review of business conclusions

The Phase I projects establish these prerequisites.

AI-assisted functionality is therefore positioned as a future analytical layer built on top of trusted ERP data and semantic models, not as a replacement for data quality, ERP knowledge or analytical judgement.

---

## 13. Project 01 Deliverable

Project 01 produces the business and requirements foundation for the complete NordicFlow ERP Analytics portfolio.

The key deliverables are:

- business scenario definition
- ERP process scope
- stakeholder decision requirements
- core business questions
- information requirements
- analytical grain definitions
- business rules
- KPI logic
- project scope boundaries
- decision-support architecture
- AI-readiness principles

The output of Project 01 can be summarised as:

**Business Problem → Requirements → Information Needs → Business Rules → Analytical Scope**

No analytical result is claimed at this stage.

The purpose is to define what must be modelled, validated and analysed before technical implementation begins.

---

## 14. Handover to Project 02

The requirements defined in Project 01 are converted into an ERP analytical data structure in:

### [Project 02 — ERP Data Model & Baseline](../02-erp-data-model/)

Project 02 defines:

- ERP entities
- table grain
- primary keys
- foreign keys
- relationships
- cardinality
- baseline data
- business-rule controls
- validation structure

This creates the controlled data foundation required by Projects 03–06.

---

## Simulation Notice

**NordicFlow Manufacturing Oy is fictional.**

The company, datasets and business scenarios were created for an ERP and data analytics portfolio simulation.

The project does not represent a live client ERP implementation or production environment.

The business-analysis methodology, data modelling, validation, analytical implementation and management recommendations are presented as portfolio evidence of an end-to-end ERP and data analytics workflow.
