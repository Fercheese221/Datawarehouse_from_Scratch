# Convenciones de nombres

Este documento define las reglas de nomenclatura usadas en el proyecto, para mantener consistencia entre capas, scripts y objetos.

## Reglas generales

- **Estilo:** `snake_case` (minúsculas, palabras separadas por guion bajo).
- **Idioma:** inglés para nombres de objetos y columnas. La documentación está en español.
- **Palabras reservadas:** no se usan palabras reservadas de SQL como nombres de objetos.

---

## Esquemas

| Esquema | Contenido |
|---|---|
| `bronze` | Datos crudos, tal como llegan de los CSV |
| `silver` | Datos limpios y estandarizados |
| `gold` | Modelo estrella listo para análisis |

---

## Tablas en Bronze y Silver

**Patrón:** `<sistema>_<entidad>`

- `<sistema>`: sistema de origen (`crm` o `erp`).
- `<entidad>`: nombre de la tabla en el sistema de origen, **sin renombrar**.

Ejemplos: `crm_cust_info`, `crm_prd_info`, `crm_sales_details`, `erp_cust_az12`, `erp_loc_a101`, `erp_px_cat_g1v2`.

Silver mantiene los mismos nombres de tabla y columna que Bronze.

---

## Objetos en Gold

**Patrón:** `<categoría>_<entidad>`

- `<categoría>`: rol del objeto en el modelo.
- `<entidad>`: nombre descriptivo en términos de negocio.

| Categoría | Significado | Ejemplos |
|---|---|---|
| `dim_` | Tabla de dimensión | `dim_customers`, `dim_products` |
| `fact_` | Tabla de hechos | `fact_sales` |

En Gold las columnas se renombran a nombres de negocio (por ejemplo, `cst_firstname` pasa a `first_name`), en lugar de conservar los nombres del sistema de origen. Todos los objetos de Gold son **vistas**.

---

## Columnas

### Llaves sustitutas

**Patrón:** `<entidad>_key`

Se usan para identificar filas en las dimensiones y para relacionarlas con la tabla de hechos.

Ejemplos: `customer_key`, `product_key`.

### Columnas técnicas

**Patrón:** `dwh_<nombre>`

Las columnas generadas por el data warehouse, sin equivalente en los sistemas fuente, llevan el prefijo `dwh_`.

Ejemplo: `dwh_create_date` (fecha y hora en que se cargó el registro en Silver).

### Prefijos de columnas en origen

Las columnas de Bronze y Silver conservan el prefijo del sistema de origen, por ejemplo `cst_` (clientes), `prd_` (productos) y `sls_` (ventas). En Gold estos prefijos desaparecen.

---

## Procedimientos almacenados

**Patrón:** `load_<capa>`

| Procedimiento | Función |
|---|---|
| `bronze.load_bronze` | Carga los CSV en Bronze con `BULK INSERT` |
| `silver.load_silver` | Transforma y carga Bronze en Silver |

---

## Archivos del repositorio

| Elemento | Convención | Ejemplo |
|---|---|---|
| Scripts DDL | `ddl_<capa>.sql` | `ddl_bronze.sql` |
| Procedimientos de carga | `proc_load_<capa>.sql` | `proc_load_silver.sql` |
| Validaciones de calidad | `quality_checks_<capa>.sql` | `quality_checks_gold.sql` |
| Carpetas | minúsculas, sin espacios | `datasets`, `scripts`, `tests`, `docs` |

---

## Valores estandarizados

Para facilitar el análisis, los valores categóricos se normalizan a texto legible y los desconocidos se marcan como `n/a`.

| Campo | Valores |
|---|---|
| Género | `Female`, `Male`, `n/a` |
| Estado civil | `Single`, `Married`, `n/a` |
| Línea de producto | `Mountain`, `Road`, `Touring`, `Other Sales`, `n/a` |
| Mantenimiento | `Yes`, `No` |
| País | Nombre completo (por ejemplo, `Germany`, `United States`), o `n/a` |
