# Methodology

## Data source and licence

IBM Telco Customer Churn dataset, hosted on Kaggle by user `blastchar`. The data is a sample IBM provides as part of their Cognos Analytics tutorials and is freely redistributable for educational use. Source: https://www.kaggle.com/datasets/blastchar/telco-customer-churn

## Cleaning steps

1. `TotalCharges` arrives as a string with blank values for customers whose `tenure = 0`. Coerced to numeric and filled missing with 0.
2. Column names converted from PascalCase to snake_case for SQL friendliness.
3. Added a binary `churn_flag` column (0/1) for modelling.

No rows were dropped.

## Modelling decisions

- **Stratified 80/20 split** on `churn_flag`. The dataset is imbalanced (~26% churners) so stratification matters.
- **Class weighting** — random forest uses `class_weight='balanced'` so the minority class is weighted up. Logistic regression baseline does not, to keep the comparison clean.
- **Scaling** — only the logistic regression sees scaled features. Trees are scale-invariant.
- **Metric** — primary metric is ROC-AUC because the business decision is "whom do we call first", which is a ranking problem, not a hard classification one.

## Known limitations

- The dataset is a snapshot, not a time series. Real churn modelling uses panel data (monthly snapshots) and survival analysis. This project simulates a cross-sectional approach.
- No customer interaction history (call logs, support tickets). In a real telecom, those features dominate.
- The "top 500 call list" in notebook 03 is built by scoring the full dataset including the training rows. In production you'd score only customers the model has not seen during training, or refit on all data and then deploy. The notebook flags this honestly.
