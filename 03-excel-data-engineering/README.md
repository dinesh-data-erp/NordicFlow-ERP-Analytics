# Project 03 — Excel Data Engineering & Data Quality

## 1. What I Did

Project 02 gave me a trusted ERP baseline. For Project 03, I wanted to test something closer to a real data-quality situation.

So I kept the original baseline unchanged and created a separate working copy with controlled data problems.

The idea was simple:

**Trusted Baseline → Raw Data Problems → Profiling → Governance → Cleaning → Revalidation → Clean ERP Dataset**

I worked across the same seven NordicFlow datasets:

- Material Master
- Supplier Master
- Plant Master
- BOM
- Inventory Snapshot
- Purchase Order Lines
- Production Orders

The goal was not only to make the spreadsheet look clean. I wanted every important change to be traceable and the final dataset to be safe for SQL, Python and Power BI.

---

## 2. Why I Kept Three Separate Workbooks

I used three controlled files.

| Workbook | Purpose |
|---|---|
| `01_NordicFlow_Project2_Baseline.xlsx` | Trusted reference. Kept unchanged. |
| `02_NordicFlow_Project3_Raw_and_Governance.xlsx` | Raw working copy with controlled data-quality issues and governance records |
| `03_NordicFlow_Project3_Clean_ERP_Dataset.xlsx` | Corrected and revalidated output for later analytics |

I did not clean the original baseline directly.

This gave me a clear audit path. If something changed, I could compare the raw record, the cleaning decision and the final result.

It also separated two different things:

**Raw evidence** — what was wrong.

**Trusted output** — what later analysis was allowed to use.

---

## 3. Data Quality Method

I followed this sequence:

1. Preserve the trusted baseline.
2. Create a separate raw working copy.
3. Profile the seven ERP datasets.
4. Detect and register data-quality issues.
5. Classify the issue and business impact.
6. Decide the remediation method and source of truth.
7. Apply the correction in a separate clean dataset.
8. Re-run the validation rules.
9. Reconcile row counts and technical checks.
10. Release the clean dataset for analysis.

The checks covered more than missing values.

I looked at areas such as:

- completeness
- uniqueness
- validity
- conformity
- consistency
- referential integrity
- business-rule conflicts

This mattered because an ERP record can look complete but still be wrong.

For example, a material ID may exist but point to the wrong business object. A date may be filled in but occur in an impossible sequence. A BOM quantity may be present but still be invalid.

---

## 4. Project Result

The controlled exercise identified **42 data-quality issues** across the ERP datasets.

| Result | Value |
|---|---:|
| ERP tables cleaned | 7 |
| Issues identified | 42 |
| Clean-state changes implemented | 42 |
| Normally validated / approved | 37 |
| Simulated business approvals pending | 5 |
| Remaining technical issues | 0 |
| Final clean records | 374 |

The five pending items are important.

In a real ERP project, some corrections cannot be decided by a data analyst alone. They need a business data owner.

For this simulation, the expected final values were applied so the later analytics could continue, but those five decisions are still marked as **simulated approvals** in the governance record.

That distinction keeps the technical result separate from business ownership.

## 5. What Kind of Problems Were Found

The 42 issues were spread across master data, BOM, inventory, purchasing and production.

They were not all the same type.

Some examples:

- missing or incomplete values
- duplicate business keys
- invalid classifications
- broken references between tables
- impossible or inconsistent dates
- invalid quantities
- supplier and planning fields outside the expected rule
- BOM records that could create wrong material requirements
- production records where delay reasons and shortage flags did not agree

The point was not only to count errors.

I also looked at what each error could do to the business.

For example, a duplicate supplier can distort supplier KPIs. A broken material reference can remove records from later joins. An invalid BOM quantity can affect material requirement calculations.

---

## 6. Rule Catalogue

Before cleaning the data, I documented the rules used to judge whether a record was acceptable.

The final rule catalogue contained **39 reusable data-quality and business rules**.

Examples include:

| Area | Rule example | Risk if wrong |
|---|---|---|
| Material Master | Material ID must be unique and nonblank | Duplicate or untraceable materials |
| Supplier Master | Supplier ID must be unique | Supplier KPIs may be double-counted |
| Supplier Master | Target OTD must stay between 0% and 100% | Invalid performance comparison |
| BOM | Component must exist in Material Master | BOM explosion may fail |
| BOM | Quantity per unit must be greater than zero | Material demand can be understated |
| Inventory | Snapshot key must be unique | Inventory can be double-counted |
| Inventory | Quantity cannot be negative in this model | False stock position |
| Purchase Orders | Supplier, material and plant references must be valid | Untraceable purchasing records |
| Production | End date cannot be before start date | Invalid delay calculation |
| Production | Delayed order should have a meaningful delay reason | Weak root-cause analysis |

Each rule had an owner, severity and expected control or correction method.

That made the cleaning work easier to explain later. It was not just "fix the cell." There was a reason behind the change.

---

## 7. Issue Log and Cleaning Decisions

Every identified issue was registered before the clean dataset was updated.

The issue log recorded details such as:

- affected table
- affected field
- issue type
- severity
- business impact
- related validation rule
- expected action

Then I used a cleaning decision matrix to decide how the issue should be handled.

Typical actions included:

- correct
- standardise
- enrich
- merge
- escalate
- retain with governance note

This part was important because not every bad-looking value should be changed automatically.

Sometimes the correct value can be proved from another trusted field or master table.

Other times the technical problem is clear, but the final business value needs an owner to decide.

That is where the five simulated approvals came from.

---

## 8. Examples of Remediation

A few examples show the difference between technical cleaning and business judgement.

### Broken Material Reference

If a material ID did not match the controlled Material Master, the reference had to be corrected before the record could safely join with other ERP data.

This is a technical integrity issue.

### Invalid BOM Quantity

A BOM quantity of zero or below is not useful for normal material-requirement analysis.

The rule requires the quantity per unit to be greater than zero.

### Planning Parameter Problem

One simulated material had a planned lead time that did not agree with the much longer delivery behaviour seen in the purchase-order data.

This is different from a simple typing error.

The data can show that the parameter is unrealistic, but changing the planning value would normally require business ownership.

### Production Delay Coding

A delayed production order needs a meaningful reason.

If the material-shortage flag and the delay reason contradict each other, the root-cause analysis becomes unreliable.

So both fields were checked together.

---

## 9. Before and After

The clean workbook was not accepted just because all 42 expected changes had been entered.

I re-ran the quality checks.

The final clean dataset contained:

- 20 Material Master records
- 8 Supplier Master records
- 3 Plant Master records
- 33 BOM lines
- 271 Inventory Snapshot records
- 24 Purchase Order Lines
- 15 Production Orders

**Total: 374 records**

After revalidation:

- completeness issues: 0
- uniqueness issues: 0
- validity issues: 0
- conformity issues: 0
- consistency issues: 0
- referential-integrity issues: 0
- technical issues: 0

Five items remained open only as governance approvals.

Technically clean. Governance status still visible.\

## 10. Release Readiness

The clean dataset was released only after a final control check.

Key results:

- 7 ERP tables present
- 374 records reconciled
- duplicate-key issues: 0
- orphan references: 0
- date and quantity rule failures: 0
- technical formula errors: 0
- 42 cleaning actions traceable
- 5 simulated business approvals still disclosed

The clean workbook was then accepted as the trusted source for later analysis.

---

## 11. Main Learning

The biggest lesson from this project was simple:

**Clean-looking data is not always reliable data.**

A record can be complete but still have the wrong relationship, wrong planning parameter, wrong status or conflicting business meaning.

For ERP analysis, data quality has to include both technical checks and business logic.

---

## 12. Files in This Project

The Project 03 folder will contain:

- baseline workbook
- raw/governance workbook
- clean ERP dataset
- selected screenshots showing profiling, cleaning and release evidence

The raw workbook is evidence of the quality problems.

The clean workbook is the source used for the next analytical stages.

---

## 13. Next Project

### [Project 04 — SQL Business Analysis](../04-sql-business-analysis/)

Project 04 takes the validated clean dataset and moves from data quality into business analysis using SQL.

The focus changes from:

**Is the data reliable?**

to:

**What does the data tell us about inventory, suppliers and production?**
