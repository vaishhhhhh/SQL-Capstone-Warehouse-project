/* Creat Database and schemas
==================
Script purpose:
THis script created a new databse named datawarehouse, additionally,
the script up three schemas within the database : 'bronze', 'silve', 'gold'.
*/

-- Createing datawarehouse database
Use master;
GO
CREATE DATABASE Datawarehouse;

USE DataWarehouse;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA GOLD;
GO
