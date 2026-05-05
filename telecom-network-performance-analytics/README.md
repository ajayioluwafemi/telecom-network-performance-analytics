# Telecom Network Performance & Customer Churn Analytics

> End-to-end analytics project simulating enterprise telecom customer performance monitoring and churn risk identification — the kind of work an Analyst on a Network Business Performance team does week-to-week.

![Status](https://img.shields.io/badge/status-in%20progress-yellow)
![Python](https://img.shields.io/badge/Python-3.11-blue)
![SQL](https://img.shields.io/badge/SQL-SQLite-lightgrey)
![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-yellow)

## Problem statement

Telecom operators lose 15–25% of their customer base every year to churn. For an enterprise customer book worth millions in monthly recurring revenue, even a 1% reduction in churn pays for a full analytics team. This project asks two questions as a Network Business Performance analyst:

1. **Where is revenue at risk this month?** Which customer segments are churning fastest, and what's the dollar value of that churn?
2. **Which customers should we save first?** Given a finite retention budget, which individual customers offer the highest ROI on intervention?

## Dataset

IBM Telco Customer Churn — 7,043 customers, 21 features.
Source: https://www.kaggle.com/datasets/blastchar/telco-customer-churn

Each row is one customer with their demographics, service mix (phone, internet, streaming, security add-ons), contract type, billing method, monthly charges, tenure, and a `Churn` flag.

## Approach

```
Raw CSV  →  Pandas EDA  →  SQLite warehouse  →  SQL analysis  →  Churn model  →  Power BI dashboard  →  Exec summary
```

1. **EDA** — data quality checks, missing values, churn rate by segment
2. **SQL layer** — load to SQLite, write 8–10 analytical queries
3. **Predictive model** — logistic regression baseline + random forest, ROC-AUC, feature importance
4. **Dashboard** — Power BI executive view: KPIs, churn drivers, revenue at risk
5. **Report** — one-page PDF summary written for non-technical stakeholders

## Key findings

> _Filled in after analysis — these are the placeholders to replace:_

- 📉 **Churn rate is X%** overall, rising to **Y%** for month-to-month fibre customers without tech support
- 💰 **$Z monthly recurring revenue** sits in the top-decile churn-risk cohort
- 🎯 Targeting the top **N customers** by predicted churn probability captures **M%** of total churn — a [N/total]% retention list

## Tech stack

| Layer | Tool |
|---|---|
| Data wrangling | Python 3.11, pandas, numpy |
| Storage | SQLite (portable; can swap for Azure SQL) |
| Modelling | scikit-learn (logistic regression, random forest) |
| Visualisation | matplotlib, seaborn, Power BI Desktop |
| Reporting | Jupyter, Power BI, PDF export |

## Repository structure

```
telecom-network-performance-analytics/
├── data/
│   ├── raw/                  # original Kaggle CSV (gitignored)
│   └── processed/            # cleaned dataset, SQLite DB
├── notebooks/
│   ├── 01_eda.ipynb          # exploratory data analysis
│   ├── 02_sql_analysis.ipynb # runs the SQL queries against SQLite
│   └── 03_churn_model.ipynb  # ML pipeline
├── sql/
│   └── churn_analysis.sql    # 8–10 analytical queries
├── src/
│   └── load_to_sqlite.py     # one-shot script: CSV → SQLite
├── dashboard/
│   └── Telecom_Performance.pbix  # Power BI report
├── reports/
│   └── executive_summary.pdf
├── images/                   # dashboard screenshots for this README
├── docs/
│   └── methodology.md
├── requirements.txt
├── .gitignore
└── README.md
```

## How to reproduce

```bash
# 1. Clone
git clone https://github.com/<your-username>/telecom-network-performance-analytics.git
cd telecom-network-performance-analytics

# 2. Set up environment
python -m venv .venv
.venv\Scripts\activate              # Windows
pip install -r requirements.txt

# 3. Download the dataset
# Manually from https://www.kaggle.com/datasets/blastchar/telco-customer-churn
# Place WA_Fn-UseC_-Telco-Customer-Churn.csv into data/raw/

# 4. Build the SQLite warehouse
python src/load_to_sqlite.py

# 5. Open notebooks in order
jupyter notebook
# Run 01_eda.ipynb → 02_sql_analysis.ipynb → 03_churn_model.ipynb

# 6. Open dashboard/Telecom_Performance.pbix in Power BI Desktop
```

## Author

**Ajayi, Oluwafemi Oladayo** 
femidayo5@gmail.com

---
