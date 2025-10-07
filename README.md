# proyecto_jardineria data warehouse 

Este repositorio contiene el desarrollo del proceso ETL y la creación del Data Warehouse para el sistema de jardinería.

## 📁 Estructura de carpetas

- **/base_datos** → Scripts SQL de staging (`stg_jardineria.sql`) y del DW (`dim_jardineria.sql`).
- **/calidad_datos** → Pruebas de calidad, resultados y reportes.
- **/diagramas** → Diagramas star model
- **/documentacion** → Informes y documentación técnica.

## 🧪 Pruebas de calidad
En `calidad_datos/pruebas_calidad_datos.sql` se encuentran las consultas para validar:
- Valores nulos
- Duplicados
- Fechas inconsistentes
- Rangos de valores
