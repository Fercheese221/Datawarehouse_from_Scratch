/*
===============================================================================
Create Database and Schemas
===============================================================================
Script Purpose:
    Crea la base de datos 'DataWarehouse'. Si ya existe, la elimina y la
    vuelve a crear. Después crea los esquemas bronze, silver y gold.

WARNING:
    Ejecutar este script borra TODA la base de datos 'DataWarehouse'
    y sus datos de forma permanente.
===============================================================================
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO