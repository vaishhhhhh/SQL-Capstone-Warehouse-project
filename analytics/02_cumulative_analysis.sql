/*
===============================================================================
Cumulative analysis
===============================================================================
Purpose:
    Running total of sales and running average of price, by year,
    to show how the business grows over time.
===============================================================================
*/
USE Datawarehouse;
GO

SELECT
    order_year,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_year) AS running_total_sales,
    AVG(avg_price)   OVER (ORDER BY order_year) AS moving_avg_price
FROM (
    SELECT
        DATETRUNC(year, order_date) AS order_year,
        SUM(sales_amount)           AS total_sales,
        AVG(price)                  AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t
ORDER BY order_year;
