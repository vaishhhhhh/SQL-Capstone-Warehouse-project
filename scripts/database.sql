/*
Create database and schemas
=============================
Script purpose:
This script creates a new database named Datawarehouse and sets up three schemas
within it: 'bronze', 'silver' and 'gold'.
*/

USE master;
GO

CREATE DATABASE Datawarehouse;
GO

USE Datawarehouse;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
