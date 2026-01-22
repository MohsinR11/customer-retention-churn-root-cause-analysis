-- Create customer_sales_summary table
CREATE TABLE staging.customer_sales_summary AS
SELECT
    customer_id,
    MIN(invoice_date) AS first_purchase_date,
    MAX(invoice_date) AS last_purchase_date,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(net_revenue) AS total_revenue
FROM staging.staging_sales
GROUP BY customer_id;

SELECT COUNT(*) FROM staging.customer_sales_summary;

SELECT *
FROM staging.customer_sales_summary
LIMIT 5;


-- Create customer_churn_status table
CREATE TABLE staging.customer_churn_status AS
SELECT
    customer_id,
    first_purchase_date,
    last_purchase_date,
    total_orders,
    total_revenue,
    CASE
        WHEN last_purchase_date <
             (SELECT MAX(invoice_date) FROM staging.staging_sales) - INTERVAL '90 days'
        THEN 1
        ELSE 0
    END AS is_churned
FROM staging.customer_sales_summary;

SELECT is_churned, COUNT(*) 
FROM staging.customer_churn_status
GROUP BY is_churned;

SELECT *
FROM staging.customer_churn_status
LIMIT 5;


-- Create customer cohort table
CREATE TABLE staging.customer_cohorts AS
SELECT
    customer_id,
    DATE_TRUNC('month', first_purchase_date) AS cohort_month
FROM staging.customer_sales_summary;

SELECT cohort_month, COUNT(*) 
FROM staging.customer_cohorts
GROUP BY cohort_month
ORDER BY cohort_month;


-- Join cohorts with churn status
CREATE TABLE staging.cohort_churn_analysis AS
SELECT
    c.customer_id,
    c.cohort_month,
    s.is_churned,
    s.total_orders,
    s.total_revenue
FROM staging.customer_cohorts c
JOIN staging.customer_churn_status s
  ON c.customer_id = s.customer_id;

SELECT *
FROM staging.cohort_churn_analysis
LIMIT 5;


-- Cohort-level churn rate (Which acquisition cohorts are low quality?)
SELECT
    cohort_month,
    COUNT(*) AS total_customers,
    SUM(is_churned) AS churned_customers,
    ROUND(
        SUM(is_churned)::numeric / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM staging.cohort_churn_analysis
GROUP BY cohort_month
ORDER BY cohort_month;


-- Revenue-weighted churn (Are we losing valuable customers or cheap ones?)
SELECT
    cohort_month,
    ROUND(
        SUM(
            CASE WHEN is_churned = 1 THEN total_revenue ELSE 0 END
        ), 2
    ) AS churned_revenue,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(
        SUM(
            CASE WHEN is_churned = 1 THEN total_revenue ELSE 0 END
        ) / NULLIF(SUM(total_revenue), 0) * 100,
        2
    ) AS revenue_churn_pct
FROM staging.cohort_churn_analysis
GROUP BY cohort_month
ORDER BY cohort_month;


-- Create behavioral metrics table
CREATE TABLE staging.customer_behavior_metrics AS
SELECT
    s.customer_id,

    -- Customer lifetime in days
    DATE_PART(
        'day',
        s.last_purchase_date - s.first_purchase_date
    ) AS customer_lifetime_days,

    -- Order frequency (orders per day)
    CASE
        WHEN DATE_PART('day', s.last_purchase_date - s.first_purchase_date) = 0
        THEN s.total_orders
        ELSE ROUND(
            s.total_orders::numeric /
            NULLIF(
                DATE_PART(
                    'day',
                    s.last_purchase_date - s.first_purchase_date
                )::numeric,
                0
            ),
            4
        )
    END AS orders_per_day,

    -- Average order value
    ROUND(
        s.total_revenue / NULLIF(s.total_orders, 0),
        2
    ) AS avg_order_value,

    -- Days since last purchase
    DATE_PART(
        'day',
        (SELECT MAX(invoice_date) FROM staging.staging_sales)
        - s.last_purchase_date
    ) AS days_since_last_purchase

FROM staging.customer_sales_summary s;

SELECT *
FROM staging.customer_behavior_metrics
LIMIT 5;


-- Join behavior metrics with churn status
CREATE TABLE staging.behavior_churn_analysis AS
SELECT
    b.customer_id,
    c.is_churned,

    b.customer_lifetime_days,
    b.orders_per_day,
    b.avg_order_value,
    b.days_since_last_purchase,

    c.total_orders,
    c.total_revenue

FROM staging.customer_behavior_metrics b
JOIN staging.customer_churn_status c
  ON b.customer_id = c.customer_id;

SELECT COUNT(*) FROM staging.behavior_churn_analysis;

SELECT *
FROM staging.behavior_churn_analysis
LIMIT 5;


-- Compare churned vs active customers
SELECT
    is_churned,

    ROUND(AVG(customer_lifetime_days)::numeric, 2) AS avg_lifetime_days,
    ROUND(AVG(orders_per_day)::numeric, 4) AS avg_orders_per_day,
    ROUND(AVG(avg_order_value)::numeric, 2) AS avg_aov,
    ROUND(AVG(days_since_last_purchase)::numeric, 2) AS avg_days_since_last_purchase,

    COUNT(*) AS customer_count
FROM staging.behavior_churn_analysis
GROUP BY is_churned;


-- Create support experience metrics table
DROP TABLE IF EXISTS staging.customer_support_metrics;

CREATE TABLE staging.customer_support_metrics AS
SELECT
    customer_email,

    1 AS had_support_ticket,

    ticket_priority,

    -- Resolution time in hours (absolute, cleaned)
    CASE
        WHEN first_response_time IS NOT NULL
         AND time_to_resolution IS NOT NULL
        THEN ROUND(
            ABS(
                EXTRACT(
                    EPOCH FROM (time_to_resolution - first_response_time)
                ) / 3600
            ),
            2
        )
        ELSE NULL
    END AS resolution_time_hours,

    CASE
        WHEN customer_satisfaction_rating IS NOT NULL
             AND customer_satisfaction_rating <= 2
        THEN 1
        ELSE 0
    END AS low_satisfaction_flag

FROM staging.staging_support_tickets;


-- Merge Support Experience with Churn & Behavior (Merge Support Experience with Churn & Behavior)
CREATE TABLE staging.final_churn_analysis AS
SELECT
    c.customer_id,
    c.is_churned,

    -- Behavioral metrics
    b.customer_lifetime_days,
    b.orders_per_day,
    b.avg_order_value,
    b.days_since_last_purchase,

    -- Support metrics
    COALESCE(s.had_support_ticket, 0) AS had_support_ticket,
    s.ticket_priority,
    s.resolution_time_hours,
    COALESCE(s.low_satisfaction_flag, 0) AS low_satisfaction_flag

FROM staging.behavior_churn_analysis c
JOIN staging.customer_behavior_metrics b
  ON c.customer_id = b.customer_id

LEFT JOIN staging.customer_support_metrics s
  ON LOWER(s.customer_email) LIKE '%' || c.customer_id::text || '%';

SELECT COUNT(*) FROM staging.final_churn_analysis;

SELECT
    is_churned,
    had_support_ticket,
    COUNT(*) AS customers
FROM staging.final_churn_analysis
GROUP BY is_churned, had_support_ticket
ORDER BY is_churned, had_support_ticket;


-- Quantify Support Impact on Churn (Are customers with bad support experience meaningfully more likely to churn?)
SELECT
    ROUND(
        SUM(is_churned)::numeric / COUNT(*) * 100,
        2
    ) AS overall_churn_rate_pct
FROM staging.final_churn_analysis;


-- Churn rate by support interaction (Compare customers with vs without support tickets)
SELECT
    had_support_ticket,
    COUNT(*) AS customers,
    SUM(is_churned) AS churned_customers,
    ROUND(
        SUM(is_churned)::numeric / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM staging.final_churn_analysis
GROUP BY had_support_ticket
ORDER BY had_support_ticket;


-- Impact of poor support quality
SELECT
    low_satisfaction_flag,
    COUNT(*) AS customers,
    SUM(is_churned) AS churned_customers,
    ROUND(
        SUM(is_churned)::numeric / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM staging.final_churn_analysis
WHERE had_support_ticket = 1
GROUP BY low_satisfaction_flag
ORDER BY low_satisfaction_flag;

SELECT
    had_support_ticket,
    COUNT(*) AS customers
FROM staging.final_churn_analysis
GROUP BY had_support_ticket;

SELECT
    COUNT(*) AS support_customers
FROM staging.customer_support_metrics;


-- Compare behavior distributions
SELECT
    CASE
        WHEN resolution_time_hours <= 24 THEN '0–24 hours'
        WHEN resolution_time_hours <= 72 THEN '24–72 hours'
        ELSE '72+ hours'
    END AS resolution_bucket,

    COUNT(*) AS customers,
    ROUND(AVG(resolution_time_hours)::numeric, 2) AS avg_resolution_time

FROM staging.customer_support_metrics
WHERE resolution_time_hours IS NOT NULL
GROUP BY resolution_bucket
ORDER BY resolution_bucket;