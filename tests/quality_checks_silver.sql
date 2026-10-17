/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Verifica consistencia, estandarización y precisión de los datos en Silver.
Expectativa: las consultas de duplicados, espacios, fechas inválidas y
sales = quantity * price NO deben devolver filas. Las consultas DISTINCT
deben mostrar solo valores estandarizados.
===============================================================================
*/

-- ============ silver.crm_cust_info ============
-- Duplicados o NULL en la llave primaria
SELECT cst_id, COUNT(*) AS n
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Espacios sobrantes
SELECT cst_key, cst_firstname, cst_lastname
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key)
   OR cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname);

-- Estandarización (esperado: Single/Married/n/a y Female/Male/n/a)
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;

-- ============ silver.crm_prd_info ============
SELECT prd_id, COUNT(*) AS n
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

SELECT prd_nm FROM silver.crm_prd_info WHERE prd_nm != TRIM(prd_nm);

-- Costos nulos o negativos
SELECT prd_cost FROM silver.crm_prd_info WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Estandarización (esperado: Mountain/Road/Other Sales/Touring/n/a)
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

-- Orden de fechas inválido
SELECT * FROM silver.crm_prd_info WHERE prd_end_dt < prd_start_dt;

-- ============ silver.crm_sales_details ============
-- Orden de fechas inválido
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Consistencia: sales = quantity * price, sin NULL ni valores <= 0
SELECT DISTINCT sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ============ silver.erp_cust_az12 ============
-- Fechas de nacimiento fuera de rango (los futuros ya se pusieron en NULL)
SELECT DISTINCT bdate FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Estandarización (esperado: Female/Male/n/a)
SELECT DISTINCT gen FROM silver.erp_cust_az12;

-- ============ silver.erp_loc_a101 ============
SELECT DISTINCT cntry FROM silver.erp_loc_a101 ORDER BY cntry;

-- ============ silver.erp_px_cat_g1v2 ============
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;