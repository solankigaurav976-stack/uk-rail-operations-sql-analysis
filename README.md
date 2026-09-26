# UK Rail Operations Performance Analysis with SQL

## From Planned to Delivered: Analysing UK Rail Cancellation Performance

A SQL-based analysis of UK rail cancellation performance using official Office of Rail and Road (ORR) data.

The project investigates operator performance, cancellation causes, reporting-period trends, consistency and data quality using PostgreSQL.

---

## Project Overview

Rail operators plan thousands of train services across the UK every reporting period. When services are cancelled or partially cancelled, it can affect passengers, operations and network performance.

This project uses SQL to investigate:

- How cancellation performance differs between operators
- Which cancellation causes contribute most to the cancellation score
- How cancellation performance changes across reporting periods
- Which operators show greater variation in performance
- Which periods show unusually high cancellation rates
- Whether the underlying dataset passes key data-quality checks

The analysis is designed as a portfolio project demonstrating practical SQL and analytical skills.

---

## Business Questions

The analysis addresses the following questions:

1. How many records and reporting periods are contained in the dataset?
2. How does cancellation performance differ between operators?
3. Which high-volume operators have higher calculated cancellation-score rates?
4. What are the main recorded cancellation causes?
5. How does cancellation performance change between reporting periods?
6. Which operators show greater variability in cancellation rates?
7. How frequently does each operator exceed a 5% cancellation rate?
8. Which operators experience the highest individual reporting-period cancellation rates?
9. Does the dataset contain duplicate or invalid records?
10. How closely does the recorded cancellation score correspond with the underlying cancellation components?

---

## Dataset

**Source:** Office of Rail and Road (ORR)

**Dataset:** Table 3124 – Trains planned and cancellations by operator (periodic)

The dataset contains information including:

- Reporting period
- Operator
- Trains planned
- Part-cancelled trains
- Fully cancelled trains
- Cancellation number / cancellation score
- Infrastructure & network management
- Infrastructure owner external events
- Train operator fault
- Operator external events
- Periodic cancellation percentage
- Moving annual average percentage

### Dataset size

- **2,563 records**
- **96 reporting periods**
- **28 operator/national reporting groups**
- **24 operators with sufficient periodic cancellation data for the consistency analysis**

National aggregate rows such as Great Britain, England and Wales, and Scotland were excluded from operator-level comparisons to avoid mixing aggregate and operator-level results.

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| PostgreSQL | Data storage and SQL analysis |
| pgAdmin 4 | Database management and query development |
| SQL | Cleaning, aggregation and analysis |
| GitHub | Version control and portfolio presentation |
| ORR Open Data | Source dataset |

---

# Data Preparation

The original CSV contained `[z]` values in some percentage fields.

A raw staging table was first created so the source data could be imported without type-conversion errors.

The data was then transformed into the analytical table using:

- `NULLIF()`
- `TRIM()`
- Type casting
- Numeric conversion
- Missing-value handling

The cleaned dataset was stored in the `rail_cancellations` table.

### Data-quality checks

The analysis also checks for:

- Missing values
- Duplicate operator-period records
- Negative operational values
- Cancellation rates above 100%
- Cancellation-score reconciliation
- Operator reporting coverage

---

# SQL Analysis

## 1. Operator Performance

Operator-level cancellation performance was calculated using:

```sql
SUM(cancellation_number)
/
SUM(trains_planned)
* 100
