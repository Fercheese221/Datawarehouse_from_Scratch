/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Verifica unicidad de llaves sustitutas e integridad referencial del modelo
estrella. Expectativa: todas las consultas deben devolver 0 filas, salvo las
de resumen al final.
===============================================================================
*/

-- ============ gold.dim_customers ============
-- Unicidad de customer_key
SELECT customer_key, COUNT(*) AS n
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Duplicados por cliente (el JOIN con ERP no debe multiplicar filas)
SELECT customer_id, COUNT(*) AS n
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Estandarización de género (esperado: Female/Male/n/a)
SELECT DISTINCT gender FROM gold.dim_customers;

-- ============ gold.dim_products ============
-- Unicidad de product_key
SELECT product_key, COUNT(*) AS n
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Un solo registro vigente por producto
SELECT product_number, COUNT(*) AS n
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- ============ gold.fact_sales ============
-- Ventas sin cliente o sin producto (integridad referencial)
SELECT f.*
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products  p ON p.product_key  = f.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;

-- Resumen: total de ventas vs. ventas con llaves completas
SELECT COUNT(*) AS total_ventas,
       SUM(CASE WHEN customer_key IS NULL OR product_key IS NULL THEN 1 ELSE 0 END) AS sin_llave
FROM gold.fact_sales;