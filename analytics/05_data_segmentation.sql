/*
===============================================================================
Data segmentation
===============================================================================
Purpose:
    1. Group products into cost ranges and count products in each range.
    2. Group customers by spending behaviour:
       - VIP:     at least 12 months of history and spending more than 5,000
       - Regular: at least 12 months of history and spending 5,000 or less
       - New:     less than 12 months of history
       and count customers in each segment.
===============================================================================
*/
USE Datawarehouse;
GO

-- 1. Products by cost range
WITH product_segment AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE WHEN cost < 100  THEN 'Below 100'
             WHEN cost < 500  THEN '100-499'
             WHEN cost < 1000 THEN '500-999'
             ELSE '1000 and above'
        END AS cost_range
    FROM gold.dim_product
)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;

-- 2. Customers by spending segment
WITH customer_spending AS (
    SELECT
        f.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date)   AS first_order,
        MAX(f.order_date)   AS last_order,
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.fact_sales f
    GROUP BY f.customer_key
)
SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT
        customer_key,
        CASE WHEN lifespan >= 12 AND total_spending > 5000  THEN 'VIP'
             WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
             ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) t
GROUP BY customer_segment
ORDER BY total_customers DESC;
