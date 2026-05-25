/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);


IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);


IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);


IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);


IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);

---inserting the data
---creating the stored procedures

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
   DECLARE @start_time DATETIME, @end_time DATETIME;  
     PRINT '========================================';
     PRINT 'LOADING BRONZE LAYER';
     PRINT '========================================';


     PRINT'-----------------------------------------';
     PRINT'LOADING CRM TABLES';
     PRINT'-----------------------------------------';
  SET @start_time = GETDATE();
TRUNCATE TABLE bronze.crm_cust_info;

 ---- TO REFRESH THE DATA TRUNCATE AND THAT INSERT IS USED TO GET FRESH DATA

BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\hp\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
WITH (
       FIRSTROW = 2,
       FIELDTERMINATOR = ','
);
   SET @end_time = GETDATE();

    SET @start_time = GETDATE();
TRUNCATE TABLE [bronze].[crm_prd_info];


BULK INSERT [bronze].[crm_prd_info]
FROM 'C:\Users\hp\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
WITH (
       FIRSTROW = 2,
       FIELDTERMINATOR = ','
);
    SET @end_time = GETDATE();

     SET @start_time = GETDATE();
TRUNCATE TABLE [bronze].[crm_sales_details];


BULK INSERT [bronze].[crm_sales_details]
FROM 'C:\Users\hp\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
WITH (
       FIRSTROW = 2,
       FIELDTERMINATOR = ','
);
   
PRINT'-----------------------------------------';
PRINT'LOADING ERP TABLES';
PRINT'-----------------------------------------';

 SET @start_time = GETDATE();
TRUNCATE TABLE [bronze].[erp_cust_az12];

BULK INSERT [bronze].[erp_cust_az12]
FROM 'C:\Users\hp\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\cust_az12.csv'
WITH (
       FIRSTROW = 2,
       FIELDTERMINATOR = ','
);
   SET @end_time = GETDATE();

    SET @start_time = GETDATE();
TRUNCATE TABLE [bronze].[erp_loc_a101];

BULK INSERT [bronze].[erp_loc_a101]
FROM 'C:\Users\hp\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
WITH (
       FIRSTROW = 2,
       FIELDTERMINATOR = ','
);
    SET @end_time = GETDATE();

     SET @start_time = GETDATE();
  
TRUNCATE TABLE [bronze].[erp_px_cat_g1v2];

BULK INSERT [bronze].[erp_px_cat_g1v2]
FROM 'C:\Users\hp\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
WITH (
       FIRSTROW = 2,
       FIELDTERMINATOR = ','
); 
    SET @end_time = GETDATE();
END

  -----EXECUTE THE STORED PROCEDURE
 EXEC [bronze].[load_bronze];


SELECT * FROM bronze.crm_cust_info; 
SELECT COUNT(*) FROM bronze.crm_cust_info;
SELECT * FROM bronze.crm_prd_info;
SELECT * FROM [bronze].[crm_sales_details];
SELECT * FROM [bronze].[erp_loc_a101];
SELECT * FROM [bronze].[erp_cust_az12];
SELECT * FROM [bronze].[erp_px_cat_g1v2];

/*
==============================================================================
SILVER LAYER - DATA CLEANING AND TRANSFORMATION 
==============================================================================
- REM0VE DUPLICATE RECORDS
- HANDLE MISSING/NULL VALUES
- STANDARDIZE TEXT
- ENSURE CONSISTENT DATA TRANSFORM
- PREPARE DATA FOR ANALYSIS
*/
 
DROP SCHEMA silver;

CREATE SCHEMA silver;

/*
=============================================================
--Checks for NULLS or DUPLICATE in primary key
=============================================================
*/

SELECT cst_id, count(*) FROM bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null; 

/*
==============================================================
CHECK UNWANTED SPACES
==============================================================
*/
SELECT cst_firstname,cst_lastname
from bronze.crm_cust_info
WHERE cst_firstname ! = TRIM(cst_firstname)
OR cst_lastname != TRIM(cst_lastname)
or cst_gndr != TRIM(cst_gndr);

/*
==============================================================
DATA STANDARDIZATION AND CONSISTENCY
==============================================================
*/

SELECT DISTINCT cst_gndr FROM bronze.crm_cust_info; 
SELECT DISTINCT cst_material_status FROM bronze.crm_cust_info; 


/*
===============================================================
UPPER= IN CASE MIXED- CASE VALUE ARE PRESENT  WE USE UPPER
TRIM = TO REMOVE UNWANTED SPACES
WINDOW FUNCTION = IT IS USE TO RANK THE DUPLICATE ROWS 
AND PRESENT UNIQUE RECORDS ONLY
CASE WNEN = TO ENSYRE DATA STANDARIZATION
===============================================================


*/

TRUNCATE TABLE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info(
    cst_id ,       
    cst_key ,          
    cst_firstname ,   
    cst_lastname   ,     
    cst_gndr  ,  
    cst_material_status ,
    cst_create_date    
)
SELECT 
cst_id ,       
cst_key ,
TRIM(cst_firstname) AS cst_firstname ,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_gndr)) ='F' THEN 'FEMALE'
     WHEN UPPER(TRIM(cst_gndr)) ='M' THEN 'MALE'
     ELSE 'N/A'
END cst_gndr,
CASE WHEN UPPER(TRIM(cst_material_status)) ='S' THEN 'SINGLE'
     WHEN UPPER(TRIM(cst_material_status)) ='M' THEN 'MARRIED'
     ELSE 'N/A'
END cst_marital_status,
cst_create_date
FROM(
             SELECT  *,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rank
FROM bronze.crm_cust_info 
where cst_id is not null
)t WHERE rank = 1;



/*
================================================================================
inserting data from broze layer table to silver layer table
================================================================================
*/

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
select * into silver.crm_cust_info from bronze.crm_cust_info;


IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
select * into silver.crm_prd_info from bronze.crm_prd_info;
 ALTER TABLE silver.crm_prd_info ADD cat_id NVARCHAR(50);
 ALTER TABLE silver.crm_prd_info ALTER COLUMN prd_start_date DATE;
 ALTER TABLE silver.crm_prd_info ALTER COLUMN prd_end_date DATE;

 IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    cat_id       NVARCHAR(50),
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE
);




IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);




IF OBJECT_ID('[silver].[erp_cust_az12]', 'U') IS NOT NULL
    DROP TABLE [silver].[erp_cust_az12];
select * into [silver].[erp_cust_az12] from [bronze].[erp_cust_az12];


IF OBJECT_ID('[silver].[erp_loc_a101]', 'U') IS NOT NULL
    DROP TABLE [silver].[erp_loc_a101];
select * into [silver].[erp_loc_a101] from [bronze].[erp_loc_a101];


IF OBJECT_ID('[silver].[erp_px_cat_g1v2]', 'U') IS NOT NULL
    DROP TABLE [silver].[erp_px_cat_g1v2];
select * into [silver].[erp_px_cat_g1v2] from [bronze].[erp_px_cat_g1v2]




SELECT * FROM [bronze].[erp_loc_a101];
SELECT * FROM [bronze].[erp_px_cat_g1v2];


/*
=============================================================================
CLEAN AND LOAD CRM PRODUCT TABLE AND BUILD SILVER LAYER
=============================================================================
*/

SELECT * FROM bronze.crm_prd_info;

/*
=============================================================
--Checks for NULLS or DUPLICATE in primary key
=============================================================
*/

SELECT prd_id, count(*) FROM bronze.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null; 


/*
=================================================================================
SUBSTRING = EXTRAT THE SPECIFIC PART OF A STRING SO THAT IT CAN BE USED YO JOIN WITH OTHER TABLE
REPLACE = TO REPLACE IN PRIMARY KEY
isnull = replace null with value
case statement = replace value
WINDOW FUNCTION(LEAD)= TO SOLVE THE PROBLEM WITH DATE
==================================================================================
*/

INSERT INTO silver.crm_prd_info(
    cat_id,
    prd_id ,
    prd_key,
    prd_cost ,   
    prd_nm ,
    prd_line ,
    prd_start_date,
    prd_end_date 
    )

SELECT 
REPLACE(SUBSTRING(prd_key,1,5), '-','_') AS cat_id,
prd_id,
SUBSTRING(prd_key,1,LEN(prd_key)) AS prd_key,
ISNULL(prd_cost , 0) AS prd_cost,
prd_nm,
CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'MOUNTAIN'
     WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'ROAD'
     WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'OTHER STATE'
     WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'TOURING'
ELSE 'N/A'
END prd_line,
CAST(prd_start_date AS DATE) AS prd_start_date,
CAST(LEAD(prd_start_date) OVER(PARTITION BY prd_key ORDER BY prd_start_date) -1 AS DATE) AS prd_end_date
from bronze.crm_prd_info;

/*
==============================================================
CHECK UNWANTED SPACES
==============================================================
*/

SELECT prd_nm
from bronze.crm_prd_info
WHERE prd_nm ! = TRIM(prd_nm);

/*
==============================================================
CHECK FOE NULLS AND NEGATIVE VALUES
=============================================================
*/
SELECT prd_cost
from bronze.crm_prd_info
WHERE prd_cost is null or prd_cost < 0;


/*
==============================================================
DATA STANDARDIZATION AND CONSISTENCY
==============================================================
*/

SELECT DISTINCT prd_line FROM bronze.crm_prd_info; 

/*
==============================================================
CHEXK FOR INVALID DATE ORDERS
==============================================================
*/
select * from bronze.crm_prd_info 
WHERE prd_end_date < prd_start_date;

--- in the dataset end date smaller than start date which is the problem that
     need to be fixed using window fuction.

SELECT *from silver.crm_prd_info;


/*
=============================================================================
CLEAN AND LOAD SALES DATA FROM BRONZE LAYER TO SILVER LAYER
================================================================================
*/


SELECT * FROM [bronze].[crm_sales_details];

/*
============================================================================
CHECH THE INVALID DATES
============================================================================
*/

SELECT NULLIF(sls_order_id,0) AS sls_order_id
FROM [bronze].[crm_sales_details]
WHERE sls_order_id < = 0
OR LEN(sls_order_id) ! = 8
OR sls_order_id > 20500101;

/*
============================================================================
CHECK THE INVALID DATES ORDER
==========================================================================
*/

SELECT* FROM [bronze].[crm_sales_details];
WHERE sls_order_id > sls_ship_dt or sls_order_id > sls_due_dt;

/*
==========================================================================
Chech Consistency :Between Sales, Quantity,and Price
Sales = price * Quantity
values must not be null,negitave or zero
ABS = return the absolute value of the number...converting negative number to positive
===========================================================================
*/

SELECT DISTINCT
sls_sales AS old_sales,
sls_quantity,
sls_price  AS old_sales,
CASE WHEN sls_sales IS NULL OR sls_sales < = 0 OR sls_sales ! = sls_quantity * ABS(sls_price)
     then sls_quantity * ABS(sls_price)
     ELSE sls_sales
END as sls_sales,
CASE WHEN sls_price IS NULL OR sls_price < = 0 
     THEN sls_sales/ NULLIF(sls_quantity,0)
     else sls_price 
END AS sls_price
FROM [bronze].[crm_sales_details]
WHERE sls_sales ! = sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales < = 0
OR sls_quantity < = 0
OR sls_price < = 0
ORDER BY sls_sales,sls_quantity,
sls_price ;


/*===========================================================================
 correct the invalid dates
 use CAST to chance the data type 
 Chech Consistency :Between Sales, Quantity,and Price
Sales = price * Quantity
values must not be null,negitave or zero
ABS = return the absolute value of the number...converting negative number to positive

============================================================================
*/

INSERT INTO silver.crm_sales_details (
sls_ord_num  ,
    sls_prd_key  ,
    sls_cust_id  ,
    sls_order_dt ,
    sls_ship_dt  ,
    sls_due_dt   ,
    sls_sales    ,
    sls_quantity ,
    sls_price    
)
 SELECT 
 sls_ord_num,
 sls_prd_keys,
 sls_cust_id,
 CASE WHEN sls_order_id = 0 OR LEN(sls_order_id) != 8 then null
      ELSE CAST(CAST( sls_order_id AS VARCHAR) AS DATE)
 END AS sls_order_dt,
 CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 then null
      ELSE CAST(CAST( sls_ship_dt AS VARCHAR) AS DATE)
 END AS sls_ship_dt,
 CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 then null
      ELSE CAST(CAST( sls_due_dt AS VARCHAR) AS DATE)
 END AS sls_due_dt,
 CASE WHEN sls_sales IS NULL OR sls_sales < = 0 OR sls_sales ! = sls_quantity * ABS(sls_price)
     then sls_quantity * ABS(sls_price)
     ELSE sls_sales
END as sls_sales,
CASE WHEN sls_price IS NULL OR sls_price < = 0 
     THEN sls_sales/ NULLIF(sls_quantity,0)
     else sls_price 
END AS sls_price,
sls_quantity

 FROM [bronze].[crm_sales_details];

 
/*
=============================================================================
CLEAN AND LOAD erp customer DATA FROM BRONZE LAYER TO SILVER LAYER
================================================================================
*/

SELECT * FROM bronze.erp_cust_az12;


/*
===============================================================================
MAKE CHANGES IN THE PRIMARY KEY 
MAKE CHANGES FOR INVALID DATE
NORMALIZE GENDER VALUE AND HANDLE UNKNOWN CASES
================================================================================
*/


INSERT INTO silver.erp_cust_az12(
cid,
bdate,
gen
)
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END cid,
CASE WHEN bdate > GETDATE() THEN NULL
     ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen))IN ('F', 'MALE') THEN 'Male'
     ELSE 'N/A'
END gen
from bronze.erp_cust_az12;

 
/*
=============================================================================
data standarisation and consistency
================================================================================
*/

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;


 
/*
=============================================================================
CLEAN AND LOAD erp LOCATION DATA FROM BRONZE LAYER TO SILVER LAYER
----Normalize and Handle missing or blank country codes
================================================================================
*/
INSERT INTO silver.erp_loc_a101(
cid,
cntry
)
SELECT 
REPLACE(cid,'-', '') AS cid ,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US','USA','United States') THEN 'United States'
     WHEN TRIM(cntry) = '' or cntry IS NULL THEN 'N/A'
     ELSE TRIM(cntry)
END AS cntry

from bronze.erp_loc_a101;

 
/*
=============================================================================
CLEAN AND LOAD erp Product category information DATA FROM BRONZE LAYER TO SILVER LAYER
================================================================================
*/


INSERT INTO silver.[erp_px_cat_g1v2](
id,
cat,
subcat,
maintenance
)
SELECT * FROM [bronze].[erp_px_cat_g1v2];

/*
==============================================================
CHECK UNWANTED SPACES
==============================================================
*/

SELECT *
from [bronze].[erp_px_cat_g1v2]
WHERE cat ! = TRIM(cat) OR subcat!= trim(subcat) OR maintenance != TRIM(maintenance);

/*
=============================================================================
data standarisation and consistency
================================================================================
*/

SELECT DISTINCT cat 
FROM [bronze].[erp_px_cat_g1v2];
 
/*
================================================================================
STORED PROCEDURE FOR SILVER LAYER
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
PRINT '>> Truncating table ; silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
PRINT'>> INSERTING DATA INTO SILVER LAYER';
INSERT INTO silver.crm_cust_info(
    cst_id ,       
    cst_key ,          
    cst_firstname ,   
    cst_lastname   ,     
    cst_gndr  ,  
    cst_material_status ,
    cst_create_date    
)
SELECT 
cst_id ,       
cst_key ,
TRIM(cst_firstname) AS cst_firstname ,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_gndr)) ='F' THEN 'FEMALE'
     WHEN UPPER(TRIM(cst_gndr)) ='M' THEN 'MALE'
     ELSE 'N/A'
END cst_gndr,
CASE WHEN UPPER(TRIM(cst_material_status)) ='S' THEN 'SINGLE'
     WHEN UPPER(TRIM(cst_material_status)) ='M' THEN 'MARRIED'
     ELSE 'N/A'
END cst_marital_status,
cst_create_date
FROM(
             SELECT  *,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rank
FROM bronze.crm_cust_info 
where cst_id is not null
)t WHERE rank = 1;



TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info(
    cat_id,
    prd_id ,
    prd_key,
    prd_cost ,   
    prd_nm ,
    prd_line ,
    prd_start_dt,
    prd_end_dt 
    )

SELECT 
REPLACE(SUBSTRING(prd_key,1,5), '-','_') AS cat_id,
prd_id,
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
ISNULL(prd_cost , 0) AS prd_cost,
prd_nm,
CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'MOUNTAIN'
     WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'ROAD'
     WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'OTHER STATE'
     WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'TOURING'
ELSE 'N/A'
END prd_line,
CAST(prd_start_date AS DATE) AS prd_start_date,
CAST(LEAD(prd_start_date) OVER(PARTITION BY prd_key ORDER BY prd_start_date) -1 AS DATE) AS prd_end_date
from bronze.crm_prd_info;


TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details (
sls_ord_num  ,
    sls_prd_key  ,
    sls_cust_id  ,
    sls_order_dt ,
    sls_ship_dt  ,
    sls_due_dt   ,
    sls_sales    ,
    sls_quantity ,
    sls_price    
)
 SELECT 
 sls_ord_num,
 sls_prd_keys,
 sls_cust_id,
 CASE WHEN sls_order_id = 0 OR LEN(sls_order_id) != 8 then null
      ELSE CAST(CAST( sls_order_id AS VARCHAR) AS DATE)
 END AS sls_order_dt,
 CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 then null
      ELSE CAST(CAST( sls_ship_dt AS VARCHAR) AS DATE)
 END AS sls_ship_dt,
 CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 then null
      ELSE CAST(CAST( sls_due_dt AS VARCHAR) AS DATE)
 END AS sls_due_dt,
 CASE WHEN sls_sales IS NULL OR sls_sales < = 0 OR sls_sales ! = sls_quantity * ABS(sls_price)
     then sls_quantity * ABS(sls_price)
     ELSE sls_sales
END as sls_sales,
CASE WHEN sls_price IS NULL OR sls_price < = 0 
     THEN sls_sales/ NULLIF(sls_quantity,0)
     else sls_price 
END AS sls_price,
sls_quantity

 FROM [bronze].[crm_sales_details];

 TRUNCATE TABLE silver.erp_cust_az12;

 INSERT INTO silver.erp_cust_az12(
cid,
bdate,
gen
)
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END cid,
CASE WHEN bdate > GETDATE() THEN NULL
     ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen))IN ('F', 'MALE') THEN 'Male'
     ELSE 'N/A'
END gen
from bronze.erp_cust_az12;

TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101(
cid,
cntry
)
SELECT 
REPLACE(cid,'-', '') AS cid ,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US','USA','United States') THEN 'United States'
     WHEN TRIM(cntry) = '' or cntry IS NULL THEN 'N/A'
     ELSE TRIM(cntry)
END AS cntry

from bronze.erp_loc_a101;


TRUNCATE TABLE silver.[erp_px_cat_g1v2]
INSERT INTO silver.[erp_px_cat_g1v2](
id,
cat,
subcat,
maintenance
)
SELECT * FROM [bronze].[erp_px_cat_g1v2];
END


EXEC silver.load_silver;
EXEC bronze.load_bronze;

/*
==================================================================
BUILD GOELD LAYER - DATA INTEGRATION --create dimension customer
=================================================================
*/
CREATE SCHEMA gold;
DROP VIEW gold.dim_customers;
CREATE VIEW gold.dim_customers AS ------create the view
SELECT
ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,------create the serrogate key that can be usefull for conecting the data model
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
ci.cst_material_status AS marital_status,
ci.cst_create_date AS create_date,
ca.bdate AS birthday,
CASE WHEN ci.cst_gndr ! = 'n/a' then ci.cst_gndr ---having gender in two table with different data
     ELSE COALESCE(ca.gen,'n/a')                 ---and thinking that crm table data is right
END AS genger,     
la.cntry AS country
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
on ci.cst_key =la.cid


SELECT *FROM gold.dim_customers;

/*
==================================================================
BUILD GOELD LAYER - DATA INTEGRATION --create dimension Product
=================================================================
*/
drop view gold.dim_product;
CREATE VIEW gold.dim_product AS
SELECT 
ROW_NUMBER() OVER(ORDER BY prd_start_dt,prd_key  ) AS product_key,---create the serrogate key that can be usefull for conecting the data model
pm.prd_id AS product_id,
pm.prd_key AS product_number,
pm.prd_nm AS product_name,
pm.prd_cost AS cost,
pm.prd_LINE AS product_line,
pm.prd_start_dt AS start_date ,
pm.cat_id AS category_id,
pc.cat AS category,
pc.subcat AS sub_category,
pc.maintenance
FROM silver.crm_prd_info AS pm
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pm.cat_id = pc.id
WHERE prd_end_dt IS NULL ;

SELECT *FROM  gold.dim_product;

/*
==================================================================
BUILD GOELD LAYER - DATA INTEGRATION --create fact SALES
=================================================================
*/
DROP VIEW gold.fact_sales

CREATE VIEW gold.fact_sales AS
select 
    sl.sls_ord_num AS order_number,
    pr.product_key ,
    cu.customer_key,
    sl.sls_order_dt AS order_date,
    sl.sls_ship_dt AS shiping_date,
    sl.sls_due_dt AS due_date,
    sl.sls_sales AS sales_amount,                                             
    sl.sls_quantity AS price,
    sl.sls_price AS quantity

from silver.crm_sales_details AS sl
LEFT JOIN gold.dim_product AS pr
ON sl.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers as cu
ON sl.sls_cust_id = cu.customer_id


SELECT*FROM gold.fact_sales;

/*
====================================================================
checking thr datatype and null value
and converting datatype
===================================================================
*/

    SELECT DISTINCT sl.sls_prd_key
FROM silver.crm_sales_details sl
WHERE sl.sls_prd_key NOT IN (SELECT product_number FROM gold.dim_product);


SELECT 
    DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_sales_details' AND COLUMN_NAME = 'sls_prd_key';


SELECT 
    DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_product' AND COLUMN_NAME = 'product_number';



SELECT TOP 20 sl.sls_prd_key, pr.product_number
FROM silver.crm_sales_details sl
LEFT JOIN gold.dim_product pr
    ON CONVERT(NVARCHAR(100), sl.sls_prd_key) = CONVERT(NVARCHAR(100), pr.product_number)
WHERE pr.product_number IS NOT NULL;


-- Check against product_id
SELECT TOP 20 sl.sls_prd_key, pr.product_id
FROM silver.crm_sales_details sl
INNER JOIN gold.dim_product pr
    ON CONVERT(NVARCHAR(100), sl.sls_prd_key) = CONVERT(NVARCHAR(100), pr.product_id);



-- Check against product_number
SELECT TOP 20 sl.sls_prd_key, pr.product_number
FROM silver.crm_sales_details sl
INNER JOIN gold.dim_product pr
    ON CONVERT(NVARCHAR(100), sl.sls_prd_key) = CONVERT(NVARCHAR(100), pr.product_number);

    /*
    ======================================================================================
    CHECK AFTER JOINING 
    ---FOREIGN KEY INTERGRITY
    =====================================================================================
    */
    SELECT *FROM gold.fact_sales AS S
    LEFT JOIN gold.dim_customers AS C
    ON s.customer_key = c.customer_key
    LEFT JOIN gold.dim_product AS p
    ON p.product_key = s.product_key
    WHERE p.product_key IS NULL;

/*
=======================================================================================
<<<<<Exploratory Data Analysis(EDA)
======================================================================================
*/
----Explore All Ojects in the Database 
SELECT * FROM INFORMATION_SCHEMA.TABLES;

----Explore All COLUMN in the Database 
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

----Dimension exploration
----(identifying the unique value in each dimension)
----how data might be grouped or segmented

--explore country 
SELECT DISTINCT country from gold.dim_customers

---explore all product categories
SELECT DISTINCT category,sub_category,product_name FROM gold.dim_product
ORDER BY 1,2,3
/*==================================================================
---DATE EXPLORATION
*/===================================================================


--Find the date of first and last order
--How many yeas of sales are available
SELECT 
MAX(order_date) first_order_date,
MIN(order_date) last_order_date,
DATEDIFF(year,MIN(order_date),MAX(order_date)) AS order_range
FROM gold.fact_sales



--Find the youngest and the oldest customer
SELECT MIN(birthday) as oldest_customer,
MAX(birthday)AS Youngest_customer,
DATEDIFF(year,MIN(birthday),GETDATE()),
DATEDIFF(year,MAX(birthday),GETDATE())
FROM gold.dim_customers

/*==============================================================
MEASURE EXPLORATION
==============================================================
*/

---Find the total sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

---Find how many items are sold
SELECT count(quantity) AS TOTAL_QUANTITY FROM gold.fact_sales

---Find the average selling price
SELECT AVG(price) AS average_price from gold.fact_sales 

---Find the total number of orders
SELECT COUNT(order_number) AS total_order from gold.fact_sales 
SELECT COUNT( DISTINCT order_number) AS total_order from gold.fact_sales 

---Find the total number of product
SELECT COUNT(product_key) AS total_products FROM gold.dim_product

---Find the total number of product
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers
SELECT COUNT( DISTINCT customer_key) AS total_customers FROM gold.dim_customers

--Find the total number of customers who placed the orders
SELECT COUNT( DISTINCT customer_key) AS total_customers FROM gold.fact_sales


-----COMBINE ALL THE QUERY TOGETHER
SELECT  'TOTAL SALES' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT  'TOTAL QUANTITY' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT  'AVERAGE PRICE' AS measure_name,AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT  'TOTAL ORDER' AS measure_name,COUNT( DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT  'TOTAL PRODUCTS' AS measure_name,COUNT(product_key) AS measure_value FROM gold.dim_product
UNION ALL
SELECT  'TOTAL CUSTOMER' AS measure_name,COUNT( DISTINCT customer_key) AS measure_value FROM gold.dim_customers


/*================================================================================================
----MAGNITUDE ANALYSIS -campare the measure value by dimensions
===================================================================================================
*/

---Find total number of customers by countries
SELECT country,
COUNT(customer_key) AS total_customer
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customer DESC

---FIND TOTAL CUSTOER BY GENDER
SELECT genger,
COUNT(customer_key) AS total_customer
FROM gold.dim_customers
GROUP BY genger
ORDER BY total_customer DESC

---Find total product by categories
SELECT 
category,
COUNT(product_key) AS TOTAL_PRODUCTS
FROM gold.dim_product
GROUP BY category
ORDER BY TOTAL_PRODUCTS

---What is the average cost in each caregory
SELECT 
category,
AVG(cost) AS avg_cost
FROM gold.dim_product
GROUP BY category
ORDER BY avg_cost

--WHAT IS THE TOTAL REVENUE GENERATED FOR EACH CATEGORY
SELECT 
SUM(F.sales_amount) AS TOTAL_REVENUE,
p.category
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
on f.product_key = p.product_key
GROUP BY p.category
ORDER BY TOTAL_REVENUE

--WHAT IS THE TOTAL REVENUE GENERATED FOR EACH CUSTOMER
select 
c.customer_key,
c.first_name,
c.last_name,
SUM(F.sales_amount) AS TOTAL_REVENUE
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name
ORDER BY TOTAL_REVENUE


--What is the distribution of items sold across countries
select 
c.country,
SUM(F.quantity) AS TOTAL_
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY TOTAL_REVENUE

/*
============================================================
Ranking analysis
============================================================
*/
---Which 5 products generate the highest revenue
SELECT TOP 5
SUM(F.sales_amount) AS TOTAL_REVENUE,
p.product_name
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
on f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY TOTAL_REVENUE desc


 --What is the 5 worst performng products
SELECT TOP 5
SUM(F.sales_amount) AS TOTAL_REVENUE,
p.product_name
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
on f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY TOTAL_REVENUE asc
 
 ---top  10 customers with higest revenue
 select TOP 10
c.customer_key,
c.first_name,
c.last_name,
SUM(F.sales_amount) AS TOTAL_REVENUE
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name
ORDER BY TOTAL_REVENUE desc

-- 3 CUSTOMERS WITH FEWEST ORDERS
 select TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number) AS TOTAL_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name
ORDER BY TOTAL_orders ASC

/*
================================================================
ADVANCE ANALYTICS PROJECT
================================================================
*/
---Change over time ANALYSIS
---Analyse sales performance over time

SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customer,----2013 IS THE BEST YEAR
SUM(quantity) as total_quantity                 -----2014 THEIR IS DRASTIC FALL IN SALES
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) 
ORDER BY YEAR(order_date)


SELECT
MONTH(order_date) AS order_MONTH, -----SEASONALITY OF THE BUSINESS......
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customer,---DECEMBER IS THE BEST MONTH 
SUM(quantity) as total_quantity                ----FEB IS THE WORST MONTH IN TERM OF SALES
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date) 
ORDER BY MONTH(order_date)

SELECT
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_MONTH, --.....
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customer,-
SUM(quantity) as total_quantity                ---
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) ,MONTH(order_date) 
ORDER BY YEAR(order_date) ,MONTH(order_date) 
         ----or
SELECT
DATETRUNC(month,order_date) as order_date,---ROUND A DAYE OR TIMESTAMP TO SPECIFIED DATE PART
SUM(sales_amount) AS total_sales,          ---IN THIS MONTH AND YESR ARE IN ONE COLUMN INSTEAD OF TWO
COUNT(DISTINCT customer_key) as total_customer,-
SUM(quantity) as total_quantity                ---
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month,order_date)
ORDER BY DATETRUNC(month,order_date)

/*
=========================================================
Cumulative Analysis
=========================================================
*/
----Calculate the total sales per month
----and the running total

SELECT order_date,total_sales,
SUM(total_sales) over(ORDER BY order_date) AS RUNNING_TOTAL_SALES
FROM(
SELECT
DATETRUNC(month,order_date) AS order_date,
SUM(sales_amount) AS total_sales          ----month wise
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY DATETRUNC(month,order_date))t

SELECT order_date,total_sales,
SUM(total_sales) over(ORDER BY order_date) AS RUNNING_TOTAL_SALES,
AVG(avg_price) OVER(ORDER BY order_date ) AS moving_average_price
FROM(
SELECT
DATETRUNC(year,order_date) AS order_date,    ------year WISE 
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(year,order_date) ) t   
 
/*
===============================================
Performance analysis -comparing the current value with the target value
=========================================================================
*/

--analyse the yearly performane of products by comperaing each product sales
--to its average performance and the perivios year sales
WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_product p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT
    order_year,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0  THEN 'Above_avg'
         WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below_avg'
         ELSE 'Avg'
    END avg_change,
    LAG (current_sales) over (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales -  LAG (current_sales) over (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE WHEN current_sales - LAG (current_sales) over (PARTITION BY product_name ORDER BY order_year) > 0  THEN 'increasing'
         WHEN current_sales - LAG (current_sales) over (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'decreasing'
         ELSE 'NO change'
    END py_change,
    product_name
FROM yearly_product_sales;

/*\==========================================================================
PART TO WHOLE ANALYSIS
===========================================================================
*/
----What category contributes the most to overall sales
WITH category_sales AS(
SELECT
category,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON f.product_key = p.product_key
GROUP BY category
)

SELECT                                           ------BIKES CATEGORY IS LEADING IN OVERALL PERCENTAGE AND CONTRIIBUTRS THE MOST                                                                        
                                                  ------ WITH 96.46% OF TOTAL PERCENTAGE OF CONTRIBUTION
category,                                          ----accessories 2.39%
total_sales,                                       ----Clothing 1.16%
SUM(total_sales) OVER() overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT)/ SUM(total_sales) OVER()) * 100, 2) , '%' )AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC  


/*
=======================================================================
Data Segmentation- grouping the data based on specific range
====================================================================
*/
 -----Segment product into cost range and count how many fall into each segment

WITH product_segments AS(
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END cost_range
from gold.dim_product 

)
SELECT                            ----their are more products that fall below 100 range of cost(110 total product)
cost_range,                       ----then 100-500 with 101 products
COUNT(product_key) AS total_products  -----at last its above average range
FROM product_segments
GROUP BY cost_range
ORDER BY total_products desc

/*
=======================================================================
Group customers into three segment based on their spending behaviour
VIP = at least 12 month of history and spend more then 5000
REGULAR= at least 12 month of history and spend 5000 or less
NEW = lifespan less than 12 month
=======================================================================
*/
WITH customer_spending AS(
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) as firat_order,
MAX(order_date) AS last_order,
DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT 
customer_segment,
COUNT(customer_key) AS total_customers   --------in customer segmentation new customer are more
FROM(                                    --------then regular and after that vip customer
    SELECT
    customer_key,
    CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
         WHEN lifespan >= 12 AND total_spending < = 5000 THEN 'Regular'
         ELSE 'NEW'
    END AS customer_segment
    FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers desc

/*
=========================================================================
Customer REPORT
=========================================================================
*/
----1) Gathers essentail fields such as names,ages and transaction details.
----2) segmentation customer into categories(vip,regular.new) and age groups.
----3) aggregation customers level metrics-
      --total orders
      --total sales
      --total quantity purchased
      --total product
      --lifespan(in months)
----4)calculate KPIs;
      --recency(month last order)
      --average order value
      --average monthaly spend

============================================================================
CREATE VIEW gold.report_customers AS
WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        f.price,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        DATEDIFF(year, c.birthday, GETDATE()) AS customer_age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL
)

,coustomer_aggregation AS(
SELECT 
    customer_key,
    customer_number,
    customer_name,
    customer_age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order,
    DATEDIFF(YEAR,MIN(order_date),MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_number, customer_name, customer_age,customer_key
)

SELECT
customer_number, 
customer_name,
CASE WHEN customer_age < 20 THEN 'Under 20'
     WHEN customer_age BETWEEN 20 AND 29 THEN '20-29'
     WHEN customer_age BETWEEN 30 AND 39 THEN '30-39'
     WHEN customer_age BETWEEN 40 AND 49 THEN '40-49'
     ELSE '50 and Above'
END AS age_group,
customer_key,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
customer_age,
    CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
         WHEN lifespan >= 12 AND total_sales < = 5000 THEN 'Regular'
         ELSE 'NEW'
    END AS customer_segment,
last_order,
DATEDIFF(MONTH, last_order, getdate()) AS recency,
---compute average order value
CASE WHEN total_orders = 0 THEN 0
     ELSE total_sales/total_orders 
END AS avg_order_value,
--COMPUTE AVERGE MONTHLY SPEND
CASE WHEN lifespan = 0 then total_sales
     ELSE total_sales/lifespan
END AS avg_monthly_spend
FROM coustomer_aggregation


SELECT 
age_group,                          -----CUSTOMER ARE MORE OF AGE GROUP 50 AND ABOVE ABOUT 12846 CUSTOMER WITH TOTAL SALES OF 20686539
COUNT(customer_number) AS total_customers,----AND THAN 40-49 ABOUT 5639 CUSTOMERS AND SALES 8664719
SUM(total_sales) total_sales                ---NO ONE IS LESS THAN 40 YEARS OF AGE
FROM gold.report_customers
GROUP BY age_group

/*
=========================================================================
PRODUCT REPORT
=========================================================================
*/
----1) Gathers essentail fields such as names,category,subcategory ans cost.
----2) segmentation customer into high performance ,mid-range and low-performance
----3) aggregation customers level metrics-
      --total orders
      --total sales
      --total quantity sold
      --total customers(unique)
      --lifespan(in months)
----4)calculate KPIs;
      --recency(month last sales)
      --average order revenue
      --average monthaly revenue

============================================================================
CREATE VIEW gold.report_product AS
WITH base_query AS(
SELECT
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.sub_category,
p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL -----only considered valid orders dates
)

,product_aggregation AS (
SELECT
product_key,
product_name,
category,
sub_category,
cost,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
MAX(order_date) AS last_sales_date,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) AS avg_selling_price
FROM base_query 
GROUP BY product_key,
product_name,
category,
sub_category,
cost
) 

SELECT
product_key,
product_name,
category,
sub_category,
cost,
last_sales_date,
DATEDIFF(MONTH,last_sales_date , GETDATE()) AS recency_in_months,
CASE WHEN total_sales > 50000 THEN 'HIGHER_PERFORMER'
     WHEN total_sales >= 10000 THEN 'MID_RANGE'
     ELSE 'LOW_PERFORMER'
END AS product_performer,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
---average order revenue
CASE WHEN lifespan = 0 THEN total_sales
     ELSE total_sales / lifespan
END AS avg_monthly_revenue
FROM product_aggregation





