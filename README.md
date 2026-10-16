# Datawarehouse_from_Scratch
Data warehouse construido desde cero en SQL Server con arquitectura Medallion
(Bronze, Silver, Gold), basado en el curso de Data with Baraa.

## Objetivo
Consolidar datos de ventas de dos sistemas fuente (CRM y ERP) en un modelo
estrella listo para análisis y reportes.

## Arquitectura
- **Bronze:** datos crudos cargados desde CSV con `BULK INSERT`.
- **Silver:** datos limpios y estandarizados.
- **Gold:** vistas con modelo estrella (`dim_customers`, `dim_products`, `fact_sales`).

## Estructura del repositorio
- `datasets/`: archivos CSV de CRM y ERP
- `docs/`: diagramas y catálogo de datos
- `scripts/`: scripts SQL por capa (bronze, silver, gold)
- `tests/`: validaciones de calidad de datos
- `docker-compose.yml`: SQL Server 2022 en contenedor

## Equipo
- Fernando Tapia Martínez
- Adam Edmundo León Navarrete

## Requisitos
- Windows con **Docker Desktop**
- Git
- Un cliente SQL (DBeaver o la extensión SQL Server de VS Code), opcional: también se puede trabajar con `sqlcmd` desde la terminal

## Cómo levantar el entorno
1. Clonar el repositorio y abrir PowerShell en la raíz del proyecto.
2. Levantar SQL Server:
```powershell
   docker compose up -d
```
3. Verificar que el contenedor ve los datasets:
```powershell
   docker exec sql-dwh-project ls /datasets/source_crm /datasets/source_erp
```
4. Probar la conexión:
```powershell
   docker exec sql-dwh-project /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'SqlServer!2026' -C -Q "SELECT @@VERSION"
```

Conexión desde un cliente SQL: servidor `localhost,1433`, usuario `sa`, contraseña `SqlServer!2026` (activar *Trust server certificate*).

## Orden de ejecución de los scripts
Los scripts de `scripts/` están montados dentro del contenedor en `/scripts`. Se ejecutan en este orden:

| Paso | Script | Descripción |
|---|---|---|
| 1 | `scripts/init_database.sql` | Crea la base `DataWarehouse` y los esquemas `bronze`, `silver` y `gold` |
| 2 | `scripts/bronze/ddl_bronze.sql` | Crea las tablas de la capa Bronze |
| 3 | `scripts/bronze/proc_load_bronze.sql` | Crea el procedimiento `bronze.load_bronze` |
| 4 | `EXEC bronze.load_bronze;` | Carga los CSV en Bronze |

Ejemplo de ejecución de un script:
```powershell
docker exec sql-dwh-project /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'SqlServer!2026' -C -d DataWarehouse -i /scripts/bronze/ddl_bronze.sql
```

> `init_database.sql` **elimina y recrea** la base `DataWarehouse`. Ejecutarlo borra todos los datos.

## Adaptaciones respecto al proyecto original
El proyecto original usa SQL Server en Windows. Aquí SQL Server corre en un contenedor Linux, por lo que se hicieron estos cambios:

- **Rutas del `BULK INSERT`:** en `proc_load_bronze.sql` se cambiaron las rutas `C:\sql\dwh_project\01_datasets\...` por `/datasets/...`. La carpeta `datasets/` del repo se monta en el contenedor mediante `docker-compose.yml`.
- **Nombres de archivo en mayúsculas:** Linux distingue mayúsculas de minúsculas. Los archivos del ERP se llaman `CUST_AZ12.csv`, `LOC_A101.csv` y `PX_CAT_G1V2.csv`, y las rutas del procedimiento usan exactamente esos nombres.
- **Saltos de línea:** el archivo `.gitattributes` evita que Git convierta los CSV a formato CRLF, ya que SQL Server en Linux podría leer mal la última columna de cada fila.
- **Contenedor:** se usa la imagen `mcr.microsoft.com/mssql/server:2022-latest` con `platform: linux/amd64`.

## Estado del proyecto
- [x] Estructura del repositorio y entorno Docker
- [x] Inicialización de la base de datos y esquemas
- [x] Capa Bronze
- [ ] Capa Silver
- [ ] Capa Gold
- [ ] Documentación (diagramas y catálogo de datos)


> README en construcción: se irá completando conforme avance cada fase.
