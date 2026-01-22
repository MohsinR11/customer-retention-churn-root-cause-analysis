# Customer Retention & Churn Root Cause Analysis

## Overview
Most churn analyses focus on predicting churn rather than understanding *why* customers disengage.
This project builds an end-to-end analytics workflow to identify **behavioral root causes of churn**, **revenue at risk**, and **cohort-level retention quality**, designed as an internal decision-support system.

This is not a tutorial project or a predictive model.
The focus is on business logic, data quality, and actionable insights.

---

## Business Questions
- What behavioral patterns indicate early churn risk?
- How much revenue is at risk due to churn?
- Which acquisition cohorts produce low-retention customers?
- What business decisions are limited by current data gaps?

---

## Data
- **Transactional sales data** (E-commerce orders)
- **Customer support ticket data**

> Note: Support data could not be reliably linked at the customer level due to missing unified identifiers. This limitation is explicitly documented and reflected in the analysis.

---

## Tools Used
- **SQL (PostgreSQL)** – data modeling, churn logic, cohort analysis
- **Python (Pandas, Matplotlib)** – validation and behavioral analysis
- **Power BI** – executive dashboards and decision storytelling

---

## Key Insights
- ~33% of customers churned, primarily driven by **behavioral disengagement**
- **Recency and order frequency** are the strongest early churn indicators
- Revenue loss is **unevenly distributed across acquisition cohorts**
- Support metrics show limited explanatory power due to low variance and data fragmentation

---

## Dashboard Structure
1. Executive Overview – churn impact and revenue at risk
2. Behavioral Early Warning Signals – recency and frequency patterns
3. Cohort Quality & Revenue Risk – acquisition effectiveness
4. Data Gaps & Strategic Risk – limitations and next steps

---

## Repository Structure
- `sql/` – raw → staging → analytics SQL logic
- `notebooks/` – Python validation and exploratory analysis
- `powerbi/` – Power BI dashboard file
- `data/raw/` – source datasets
- `docs/` – business assumptions and definitions

---

## How to Run
1. Load raw datasets into PostgreSQL
2. Execute SQL scripts in order
3. Run Python notebook for validation
4. Open Power BI dashboard using final analytics table

---

## Notes
- This project prioritizes **explainability and decision support** over prediction
- All assumptions and limitations are explicitly documented

---

## 🙌 Author
This project was designed as a **real-world, business-focused analytics case study** for startup and SME environments, demonstrating practical decision-driven data analysis instead of surface-level dashboards.

---

<p align="center">
  <b>Built by Mohsin  (Data Analyst)</b><br>
  📧 mohsinansari1799@email.com &nbsp;|&nbsp;
  🔗 <a href="https://www.linkedin.com/in/mohsinraza-data/">LinkedIn</a>
</p>
