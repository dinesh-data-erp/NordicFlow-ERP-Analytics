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
