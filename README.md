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
```

## How to run

1. `scripts/database.sql`: create the `Datawarehouse` database and schemas
2. `scripts/bronze/ddl_bronze.sql`: create the bronze tables
3. `scripts/bronze/proc_load_bronze.sql`: create the load procedure, update the CSV file paths to your local copy, then run `EXEC bronze.load_bronze;`
4. `scripts/silver/ddl_silver.sql`: create the silver tables
5. `scripts/silver/proc_load_silver.sql`: create the load procedure, then run `EXEC silver.load_silver;`
6. `scripts/gold/ddl_gold.sql`: create the gold views
7. `tests/quality_checks_silver.sql` and `tests/quality_checks_gold.sql`: verify the data

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
