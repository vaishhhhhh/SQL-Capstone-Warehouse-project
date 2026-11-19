/*
Stored procedure: bronze.load_bronze (source CSV files -> bronze)
Script purpose:
This procedure loads data into the bronze schema from external CSV files.
It performs the following actions:
- truncates each bronze table before loading
- uses BULK INSERT to load the CSV files into the bronze tables
- prints the load time for each table and for the full batch

Note: the file paths point to a local copy of the datasets folder.
Update them to match where you cloned this repo.

Usage:
    EXEC bronze.load_bronze;
*/
USE Datawarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY

	SET @batch_start_time = GETDATE();

			PRINT '==============================';
			PRINT 'Loading Bronze Layer';
			PRINT '==============================';

			PRINT 'Loading crm Tables';
			PRINT '==============================';

			SET @start_time = GETDATE();
				PRINT 'TRUNCATING TABLE: bronze.crm_cust_info';
				TRUNCATE TABLE bronze.crm_cust_info;

				BULK INSERT bronze.crm_cust_info
				FROM "C:\Users\Vaishnav\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv"
				WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

			SET @end_time = GETDATE();

			PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
			PRINT '==============================';

			SET @start_time = GETDATE();
				PRINT 'TRUNCATING TABLE: bronze.crm_prd_info';
				TRUNCATE TABLE bronze.crm_prd_info;

				BULK INSERT bronze.crm_prd_info
				FROM "C:\Users\Vaishnav\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv"
				WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
			SET @end_time = GETDATE();
			PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
			PRINT '==============================';

			SET @start_time = GETDATE();
				PRINT 'TRUNCATING TABLE: bronze.crm_sales_details';
				TRUNCATE TABLE bronze.crm_sales_details;

				BULK INSERT bronze.crm_sales_details
				FROM "C:\Users\Vaishnav\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv"
				WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

			SET @end_time = GETDATE();
			PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
			PRINT '==============================';

			PRINT 'Loading erp Tables';
			PRINT '==============================';

			SET @start_time = GETDATE();
				PRINT 'TRUNCATING TABLE:  bronze.erp_cust_az12';
				TRUNCATE TABLE bronze.erp_cust_az12;

				BULK INSERT bronze.erp_cust_az12
				FROM "C:\Users\Vaishnav\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv"
				WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
			SET @end_time = GETDATE();
			PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
			PRINT '==============================';

			SET @start_time = GETDATE();
				PRINT 'TRUNCATING TABLE: bronze.erp_loc_a101';
				TRUNCATE TABLE bronze.erp_loc_a101;

				BULK INSERT bronze.erp_loc_a101
				FROM "C:\Users\Vaishnav\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv"
				WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
			SET @end_time = GETDATE();
			PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
			PRINT '==============================';

			SET @start_time = GETDATE();
				PRINT 'TRUNCATING TABLE: bronze.erp_px_cat_gtv2';
				TRUNCATE TABLE bronze.erp_px_cat_gtv2;

				BULK INSERT bronze.erp_px_cat_gtv2
				FROM "C:\Users\Vaishnav\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv"
				WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
			SET @end_time = GETDATE();
			PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
			PRINT '==============================';

		SET @batch_end_time = GETDATE();
		PRINT'Loading Bronze Layer is completed '
		PRINT 'Total Load Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time)AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
			PRINT'========================'
			PRINT'ERROR OCCURRED DURING LOADING BRONZE LAYER'
			PRINT'Error message: ' + ERROR_MESSAGE();
			PRINT'Error number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
			PRINT'Error state: ' + CAST(ERROR_STATE() AS NVARCHAR);
			PRINT'========================'
	END CATCH
END
GO
