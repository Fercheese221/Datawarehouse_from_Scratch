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

> README en construcción: se irá completando conforme avance cada fase.
