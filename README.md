# SQL Data Warehouse (Capstone Project)

An end-to-end data warehouse built in SQL Server using a medallion architecture (bronze → silver → gold). Raw CRM and ERP CSV files are loaded, cleaned and modeled into a star schema for reporting and analysis in Power BI.

## Architecture

| Layer | What it does | Object type |
|---|---|---|
| **Bronze** | Raw CRM and ERP files loaded as-is with `BULK INSERT` | Tables |
| **Silver** | Cleaned and standardized data: trimmed text, decoded codes, fixed and validated dates, de-duplicated customers, recalculated sales | Tables |
| **Gold** | Business-ready star schema: `dim_customer`, `dim_product`, `fact_sales` | Views |

Each layer is loaded by a stored procedure (`bronze.load_bronze`, `silver.load_silver`) that truncates and reloads its tables, so the pipeline is safe to re-run.

## Data sources

- **CRM** (`datasets/source_crm/`): customers, products, sales details
- **ERP** (`datasets/source_erp/`): customer birthdates and gender, customer locations, product categories

## Repository structure

```
datasets/
  source_crm/        cust_info, prd_info, sales_details
  source_erp/        CUST_AZ12, LOC_A101, PX_CAT_G1V2
scripts/
  database.sql       creates the database and the three schemas
  bronze/            ddl_bronze.sql, proc_load_bronze.sql
  silver/            ddl_silver.sql, proc_load_silver.sql
  gold/              ddl_gold.sql
tests/
  quality_checks_silver.sql
  quality_checks_gold.sql
analytics/           exploratory analysis and reporting views
```

## How to run

1. `scripts/database.sql`: create the `Datawarehouse` database and schemas
2. `scripts/bronze/ddl_bronze.sql`: create the bronze tables
3. `scripts/bronze/proc_load_bronze.sql`: create the load procedure, update the CSV file paths to your local copy, then run `EXEC bronze.load_bronze;`
4. `scripts/silver/ddl_silver.sql`: create the silver tables
5. `scripts/silver/proc_load_silver.sql`: create the load procedure, then run `EXEC silver.load_silver;`
6. `scripts/gold/ddl_gold.sql`: create the gold views
7. `tests/quality_checks_silver.sql` and `tests/quality_checks_gold.sql`: verify the data
8. `analytics/`: run the analysis queries, and create the report views (files 06 and 07)

## Analytics

SQL analysis on the gold layer, in `analytics/`:

| File | Question it answers |
|---|---|
| `01_change_over_time_analysis.sql` | How do sales, customers and quantity change month by month? |
| `02_cumulative_analysis.sql` | What is the running total of sales and the moving average price by year? |
| `03_performance_analysis.sql` | How does each product's yearly sales compare to its own average and to the previous year? |
| `04_part_to_whole_analysis.sql` | Which categories contribute the most to overall sales? |
| `05_data_segmentation.sql` | How many products fall in each cost range, and how many customers are VIP, Regular or New? |
| `06_report_customers.sql` | `gold.report_customers`: customer segments, age groups, recency, average order value and monthly spend |
| `07_report_products.sql` | `gold.report_products`: product segments, recency, average order revenue and monthly revenue |

The two report views are ready to connect to Power BI.

## Data quality checks

- Primary keys: no NULLs or duplicates
- Text fields: no leading or trailing spaces
- Codes standardized (gender, marital status, product line, country)
- Dates: valid ranges and correct order (order ≤ ship ≤ due)
- Sales = quantity × price, with no NULL, zero or negative values
- Gold: every fact row matches a customer and a product dimension

## Tools

SQL Server Express, SQL Server Management Studio, Power BI, Git/GitHub

## License

MIT
