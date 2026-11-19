/*
Quality checks: bronze and silver layers.
Run after EXEC silver.load_silver. Most checks expect no rows back.
*/
USE Datawarehouse;
GO

-- ============================================================
-- crm_cust_info
-- ============================================================
-- ===== BRONZE =====
-- check for NULLs or duplicates in primary key (expectation: no result)
SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- check for duplicates: keep the latest record per customer
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1;

-- check for unwanted spaces (expectation: no result)
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- data standardization and consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

-- ===== SILVER =====
-- check for NULLs or duplicates in primary key (expectation: no result)
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- check for unwanted spaces (expectation: no result)
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- data standardization and consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- ============================================================
-- crm_prd_info
-- ============================================================
-- check for NULLs or duplicates in primary key (expectation: no result)
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- check for unwanted spaces (expectation: no result)
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- check for negative or NULL costs
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- data standardization and consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

-- invalid date orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ============================================================
-- crm_sales_details
-- ============================================================
-- check for invalid dates in bronze
SELECT NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 20260101
   OR sls_order_dt < 19000101;

-- check for invalid date order in silver (expectation: no result)
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- check data consistency: sales = quantity * price; values must not be NULL or zero
SELECT DISTINCT
    sls_sales    AS old_sls_sales,
    sls_quantity,
    sls_price    AS old_sls_price,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
         THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
    END AS sls_sales,
    CASE WHEN sls_price IS NULL OR sls_price <= 0
         THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ============================================================
-- erp_cust_az12
-- ============================================================
-- identify out-of-range dates
SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- data standardization and consistency
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

-- review the silver result
SELECT * FROM silver.erp_cust_az12;

-- ============================================================
-- erp_loc_a101
-- ============================================================
-- data standardization and consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;

-- preview the country transformation
SELECT DISTINCT
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
         WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
         WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
         ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;

-- review the silver result
SELECT * FROM silver.erp_loc_a101;

-- ============================================================
-- erp_px_cat_gtv2
-- ============================================================
-- check for unwanted spaces (expectation: no result)
SELECT *
FROM bronze.erp_px_cat_gtv2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- data standardization and consistency
SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_gtv2;

-- review the silver result
SELECT * FROM silver.erp_px_cat_gtv2;

-- ============================================================
-- column audit (compare with scripts/silver/ddl_silver.sql)
-- ============================================================
SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
