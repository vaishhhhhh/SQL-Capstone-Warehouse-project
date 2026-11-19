/*
===============================================================================
Change over time analysis
===============================================================================
Purpose:
    Track how sales, customers and quantity change month by month.
    Two versions: separate year and month columns, or one month-start date.
===============================================================================
*/
USE Datawarehouse;
GO

-- Version 1: year and month as separate columns
SELECT
    YEAR(order_date)             AS order_year,
    MONTH(order_date)            AS order_month,
    SUM(sales_amount)            AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity)                AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- Version 2: one column with the first day of each month
SELECT
    DATETRUNC(month, order_date) AS order_month,
    SUM(sales_amount)            AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity)                AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);
