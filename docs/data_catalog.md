# Catálogo de datos: capa Gold

La capa Gold es la representación final y lista para análisis del data warehouse. Está formada por tres **vistas** que implementan un **esquema estrella**: una tabla de hechos (`fact_sales`) conectada a dos dimensiones (`dim_customers` y `dim_products`). Todas se construyen sobre la capa Silver (`scripts/gold/ddl_gold.sql`).

---

## 1. gold.dim_customers

**Propósito:** información de los clientes, integrando datos demográficos y de ubicación.

**Fuentes (Silver):** `crm_cust_info` (principal), `erp_cust_az12` (fecha de nacimiento y género de respaldo) y `erp_loc_a101` (país). Los JOIN usan `cst_key = cid`.

**Granularidad:** una fila por cliente.

| Columna | Tipo de dato | Descripción |
|---|---|---|
| `customer_key` | BIGINT | Llave sustituta generada con `ROW_NUMBER() OVER (ORDER BY cst_id)`. Identifica de forma única cada fila de la dimensión y es la que usa `fact_sales`. |
| `customer_id` | INT | Identificador numérico del cliente en el CRM. |
| `customer_number` | NVARCHAR(50) | Llave de negocio alfanumérica del cliente (por ejemplo, `AW00011000`). |
| `first_name` | NVARCHAR(50) | Nombre del cliente, sin espacios sobrantes. |
| `last_name` | NVARCHAR(50) | Apellido del cliente, sin espacios sobrantes. |
| `country` | NVARCHAR(50) | País de residencia, estandarizado (por ejemplo, `Australia`, `Germany`, `United States`). `n/a` si no se conoce. |
| `marital_status` | NVARCHAR(50) | Estado civil: `Single`, `Married` o `n/a`. |
| `gender` | NVARCHAR(50) | Género: `Female`, `Male` o `n/a`. El CRM es la fuente principal; si el CRM trae `n/a`, se usa el valor del ERP. |
| `birthdate` | DATE | Fecha de nacimiento. Es `NULL` si el cliente no existe en el ERP o si la fecha original era futura. |
| `create_date` | DATE | Fecha en que se creó el registro del cliente en el CRM. |

---

## 2. gold.dim_products

**Propósito:** información de los productos y sus atributos de clasificación.

**Fuentes (Silver):** `crm_prd_info` (principal) y `erp_px_cat_g1v2` (categoría, subcategoría y mantenimiento). El JOIN usa `cat_id = id`.

**Granularidad:** una fila por producto vigente. Se filtran los registros históricos (`prd_end_dt IS NULL`), por lo que la dimensión **no conserva historial**.

| Columna | Tipo de dato | Descripción |
|---|---|---|
| `product_key` | BIGINT | Llave sustituta generada con `ROW_NUMBER() OVER (ORDER BY prd_start_dt, prd_key)`. Es la que usa `fact_sales`. |
| `product_id` | INT | Identificador numérico del producto en el CRM. |
| `product_number` | NVARCHAR(50) | Llave de negocio del producto (por ejemplo, `BK-R93R-62`). Con ella se une `fact_sales` en origen. |
| `product_name` | NVARCHAR(50) | Nombre descriptivo del producto. |
| `category_id` | NVARCHAR(50) | Identificador de la categoría, derivado de los primeros caracteres de la llave original (por ejemplo, `CO_RF`). |
| `category` | NVARCHAR(50) | Categoría general (por ejemplo, `Bikes`, `Components`). |
| `subcategory` | NVARCHAR(50) | Subcategoría del producto. |
| `maintenance` | NVARCHAR(50) | Indica si el producto requiere mantenimiento: `Yes` o `No`. |
| `cost` | INT | Costo base del producto. Los valores nulos se cargan como 0. |
| `product_line` | NVARCHAR(50) | Línea de producto: `Mountain`, `Road`, `Touring`, `Other Sales` o `n/a`. |
| `start_date` | DATE | Fecha de inicio de vigencia del producto. |

---

## 3. gold.fact_sales

**Propósito:** transacciones de venta para análisis (ventas por cliente, producto, periodo, etc.).

**Fuente (Silver):** `crm_sales_details`, enlazada con las dimensiones mediante `sls_prd_key = product_number` y `sls_cust_id = customer_id`.

**Granularidad:** una fila por línea de pedido.

| Columna | Tipo de dato | Descripción |
|---|---|---|
| `order_number` | NVARCHAR(50) | Identificador del pedido (por ejemplo, `SO54496`). |
| `product_key` | BIGINT | Llave sustituta que referencia a `dim_products.product_key`. |
| `customer_key` | BIGINT | Llave sustituta que referencia a `dim_customers.customer_key`. |
| `order_date` | DATE | Fecha en que se realizó el pedido. |
| `shipping_date` | DATE | Fecha en que se envió el pedido. |
| `due_date` | DATE | Fecha límite de pago o entrega. |
| `sales_amount` | INT | Monto total de la línea. Se recalcula como `quantity * ABS(price)` cuando el original es nulo, no positivo o inconsistente. |
| `quantity` | INT | Número de unidades vendidas. |
| `price` | INT | Precio por unidad. |

---

## Relaciones del modelo

| Tabla de hechos | Llave | Dimensión | Llave | Cardinalidad |
|---|---|---|---|---|
| `fact_sales` | `customer_key` | `dim_customers` | `customer_key` | muchos a uno |
| `fact_sales` | `product_key` | `dim_products` | `product_key` | muchos a uno |

## Validaciones realizadas

Los resultados de `tests/quality_checks_gold.sql` confirmaron:

- Llaves sustitutas únicas en ambas dimensiones.
- Sin duplicados por llave de negocio (`customer_id`, `product_number`).
- Valores de `gender` estandarizados (`Female`, `Male`, `n/a`).
- Integridad referencial completa: las 60,398 filas de `fact_sales` tienen `customer_key` y `product_key`.
