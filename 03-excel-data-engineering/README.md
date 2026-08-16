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
