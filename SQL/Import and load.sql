-- Sales Table
CREATE TABLE raw_sales (
    invoice_no TEXT,
    stock_code TEXT,
    description TEXT,
    quantity INTEGER,
    invoice_date TIMESTAMP,
    unit_price NUMERIC,
    customer_id INTEGER,
    country TEXT
);

-- Support tickets table
DROP TABLE raw_support_tickets;

CREATE TABLE raw_support_tickets (
    ticket_id INTEGER,
    customer_name TEXT,
    customer_email TEXT,
    customer_age INTEGER,
    customer_gender TEXT,
    product_purchased TEXT,
    date_of_purchase TIMESTAMP,
    ticket_type TEXT,
    ticket_subject TEXT,
    ticket_description TEXT,
    ticket_status TEXT,
    resolution TEXT,
    ticket_priority TEXT,
    ticket_channel TEXT,
    first_response_time TIMESTAMP,
    time_to_resolution TIMESTAMP,
    customer_satisfaction_rating INTEGER
);

COPY raw_support_tickets (
    ticket_id,
    customer_name,
    customer_email,
    customer_age,
    customer_gender,
    product_purchased,
    date_of_purchase,
    ticket_type,
    ticket_subject,
    ticket_description,
    ticket_status,
    resolution,
    ticket_priority,
    ticket_channel,
    first_response_time,
    time_to_resolution,
    customer_satisfaction_rating
)
FROM 'D:/Projects/End-to-end projects/Customer Retention Churn/Data/Raw/customer_support_tickets.csv'
WITH (
    FORMAT csv,
	HEADER true,
    DELIMITER ',',
    QUOTE '"',
    ESCAPE '"',
    ENCODING 'UTF8'
);


SELECT COUNT(*) FROM raw_sales;

SELECT *
FROM raw_sales
LIMIT 5;


SELECT COUNT(*) FROM raw_support_tickets;

SELECT
    ticket_id,
    customer_email,
    first_response_time,
    time_to_resolution,
    customer_satisfaction_rating
FROM raw_support_tickets
LIMIT 5;


DROP TABLE IF EXISTS analytics.final_churn_powerbi;

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE analytics.final_churn_powerbi AS
SELECT
    c.customer_id,

    -- Churn label
    c.is_churned,

    -- Sales value
    c.total_orders,
    c.total_revenue,

    -- Behavioral signals
    b.customer_lifetime_days,
    b.orders_per_day,
    b.avg_order_value,
    b.days_since_last_purchase,

    -- Time anchors (for cohorts & slicing)
    c.first_purchase_date,
    c.last_purchase_date,
    DATE_TRUNC('month', c.first_purchase_date) AS cohort_month,

    -- Flags (future-proof)
    CASE 
        WHEN c.is_churned = 1 THEN 1 ELSE 0 
    END AS churn_flag

FROM staging.customer_churn_status c
JOIN staging.customer_behavior_metrics b
  ON c.customer_id = b.customer_id;