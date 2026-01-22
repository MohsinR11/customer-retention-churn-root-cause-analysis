CREATE SCHEMA staging;

-- Create staging_sales table
CREATE TABLE staging.staging_sales AS
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country,
    quantity * unit_price AS net_revenue
FROM raw_sales
WHERE customer_id IS NOT NULL
  AND quantity <> 0;


SELECT COUNT(*) FROM staging.staging_sales;

SELECT *
FROM staging.staging_sales
LIMIT 5;


-- Create staging_support_tickets table
CREATE TABLE staging.staging_support_tickets AS
SELECT
    ticket_id,
    LOWER(customer_email) AS customer_email,
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
FROM raw_support_tickets;

SELECT COUNT(*) FROM staging.staging_support_tickets;

SELECT customer_email, first_response_time, time_to_resolution
FROM staging.staging_support_tickets
LIMIT 5;