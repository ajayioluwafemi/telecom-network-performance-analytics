-- =======================================================================
-- churn_analysis.sql
-- Analytical queries for the Telecom Customer Churn dataset.
-- Run against data/processed/telecom.db (SQLite).
--
-- Each query answers a specific business question. Comment block above
-- each query explains the question, the answer pattern, and what the
-- analyst would do with the result.
-- =======================================================================


-- -----------------------------------------------------------------------
-- Q1. What is the overall churn rate?
-- One-line headline KPI for any executive dashboard.
-- -----------------------------------------------------------------------
SELECT
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct,
    COUNT(*)                                     AS total_customers,
    SUM(churn_flag)                              AS churned_customers
FROM customers;


-- -----------------------------------------------------------------------
-- Q2. Churn rate by contract type.
-- Hypothesis: month-to-month customers churn far more than 1- or 2-year
-- contract holders. If true, retention spend should focus on converting
-- M2M to longer contracts.
-- -----------------------------------------------------------------------
SELECT
    contract,
    COUNT(*)                                     AS customers,
    SUM(churn_flag)                              AS churned,
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY contract
ORDER BY churn_rate_pct DESC;


-- -----------------------------------------------------------------------
-- Q3. Churn rate by internet service type.
-- Fibre optic customers are often the most lucrative AND the most likely
-- to churn (high expectations, competitive market). Quantify it.
-- -----------------------------------------------------------------------
SELECT
    internet_service,
    COUNT(*)                                     AS customers,
    SUM(churn_flag)                              AS churned,
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2)               AS avg_arpu
FROM customers
GROUP BY internet_service
ORDER BY churn_rate_pct DESC;


-- -----------------------------------------------------------------------
-- Q4. Tenure cohort analysis.
-- New customers (0–12 months) churn at very different rates than
-- long-tenured ones. Bucket and report.
-- -----------------------------------------------------------------------
SELECT
    CASE
        WHEN tenure <= 12  THEN '0-12 months'
        WHEN tenure <= 24  THEN '13-24 months'
        WHEN tenure <= 48  THEN '25-48 months'
        ELSE '49+ months'
    END                                          AS tenure_bucket,
    COUNT(*)                                     AS customers,
    SUM(churn_flag)                              AS churned,
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY tenure_bucket
ORDER BY
    CASE tenure_bucket
        WHEN '0-12 months'  THEN 1
        WHEN '13-24 months' THEN 2
        WHEN '25-48 months' THEN 3
        ELSE 4
    END;


-- -----------------------------------------------------------------------
-- Q5. Revenue at risk by segment.
-- Multiplies churned customers by their MRR to put a £/$ figure on
-- monthly recurring revenue lost to churn, broken down by contract.
-- -----------------------------------------------------------------------
SELECT
    contract,
    SUM(churn_flag)                                            AS churned_customers,
    ROUND(SUM(CASE WHEN churn_flag = 1 THEN monthly_charges ELSE 0 END), 2)
                                                               AS monthly_revenue_lost,
    ROUND(SUM(CASE WHEN churn_flag = 1 THEN monthly_charges ELSE 0 END) * 12, 2)
                                                               AS annualised_revenue_lost
FROM customers
GROUP BY contract
ORDER BY monthly_revenue_lost DESC;


-- -----------------------------------------------------------------------
-- Q6. Tech support as a churn lever.
-- Customers without tech support are hypothesised to churn more.
-- If the effect is large, this becomes a clear retention play:
-- bundle tech support with at-risk fibre customers.
-- -----------------------------------------------------------------------
SELECT
    tech_support,
    internet_service,
    COUNT(*)                                     AS customers,
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
WHERE internet_service != 'No'
GROUP BY tech_support, internet_service
ORDER BY internet_service, churn_rate_pct DESC;


-- -----------------------------------------------------------------------
-- Q7. Payment method effect.
-- Electronic check users sometimes show higher churn — possibly a proxy
-- for less "sticky" customers without auto-pay set up.
-- -----------------------------------------------------------------------
SELECT
    payment_method,
    COUNT(*)                                     AS customers,
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2)               AS avg_arpu
FROM customers
GROUP BY payment_method
ORDER BY churn_rate_pct DESC;


-- -----------------------------------------------------------------------
-- Q8. The "danger zone" cohort.
-- Combines the worst features into one query: month-to-month + fibre
-- + no tech support + electronic check. This is the cohort the
-- retention team should call first.
-- -----------------------------------------------------------------------
SELECT
    COUNT(*)                                     AS danger_zone_customers,
    SUM(churn_flag)                              AS churned,
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct,
    ROUND(SUM(monthly_charges), 2)               AS total_mrr_at_risk
FROM customers
WHERE contract         = 'Month-to-month'
  AND internet_service = 'Fiber optic'
  AND tech_support     = 'No'
  AND payment_method   = 'Electronic check';


-- -----------------------------------------------------------------------
-- Q9. Top 20 highest-MRR customers flagged as churned.
-- The "save list" — these are the individual high-value losses.
-- -----------------------------------------------------------------------
SELECT
    customer_id,
    contract,
    internet_service,
    tenure,
    ROUND(monthly_charges, 2) AS mrr,
    ROUND(total_charges, 2)   AS lifetime_value
FROM customers
WHERE churn_flag = 1
ORDER BY monthly_charges DESC
LIMIT 20;


-- -----------------------------------------------------------------------
-- Q10. Tenure x contract heatmap data.
-- Two-dimensional cut for the Power BI matrix visual.
-- -----------------------------------------------------------------------
SELECT
    contract,
    CASE
        WHEN tenure <= 12  THEN '0-12 months'
        WHEN tenure <= 24  THEN '13-24 months'
        WHEN tenure <= 48  THEN '25-48 months'
        ELSE '49+ months'
    END                                          AS tenure_bucket,
    COUNT(*)                                     AS customers,
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY contract, tenure_bucket
ORDER BY contract, tenure_bucket;
