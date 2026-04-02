# Sampling Plan Calculator (AQL)

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Shiny](https://img.shields.io/badge/Shiny-00B4D8?style=for-the-badge&logo=rstudio&logoColor=white)
![Posit Connect](https://img.shields.io/badge/Posit_Connect-447099?style=for-the-badge&logo=rstudio&logoColor=white)
![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-testthat-blue?style=for-the-badge)

Aplicacion Shiny para el calculo de planes de muestreo por aceptacion segun las normas **ANSI/ASQ Z1.4** (atributos) y **ANSI/ASQ Z1.9** (variables).

Desarrollada por **Quality Analytics**, esta herramienta facilita la seleccion de planes de inspeccion, la interpretacion de su desempeno mediante curvas OC y ASN, y la exportacion de resultados para documentacion y seguimiento.

## Demo en vivo

Accede a la aplicacion publicada:

https://019d4f32-2bc5-e940-157a-3ed183ea7d78.share.connect.posit.cloud/

## Caracteristicas

- **Muestreo por Variables (Z1.9)**: calculo de planes basados en mediciones continuas.
- **Muestreo por Atributos (Z1.4)**: soporte para planes `Single`, `Double` y `Multiple`.
- **Curvas OC y ASN**: visualizacion interactiva del comportamiento del plan de muestreo.
- **Interfaz bilingue**: soporte en espanol e ingles desde la misma aplicacion.
- **UI modernizada**: uso de `bslib`, `page_navbar()` y componentes Bootstrap 5.
- **Exportacion a Excel**: generacion de archivos `.xlsx` con parametros y resultados en hojas separadas.
- **Cobertura de pruebas**: tests para funciones, UI y logica de servidor.

## Funcionalidades principales

### Muestreo por Variables (Z1.9)

- **Tipos de inspeccion**: `Normal`, `Tightened`, `Reduced`
- **Niveles de inspeccion**: `S-3`, `S-4`, `I`, `II`, `III`
- **Tamanos de lote**: desde `2-8` hasta `500,001 and over`
- **Valores AQL**: 11 opciones, desde `0.10` hasta `10`
- **Resultados**:
  - `n`: tamano de muestra
  - `k`: constante de aceptabilidad
  - `M`: maxima proporcion no conforme permitida
- **Analisis visual**:
  - Curva OC
  - Curva ASN
- **Exportacion**: archivo Excel con parametros de entrada y resultados calculados

### Muestreo por Atributos (Z1.4)

- **Tipos de plan**: `Single`, `Double` y `Multiple`
- **Tipos de inspeccion**: `Normal`, `Tightened`, `Reduced`
- **Niveles de inspeccion**: `S-1`, `S-2`, `S-3`, `S-4`, `I`, `II`, `III`
- **Tamanos de lote**: desde `2-8` hasta `500,001 and over`
- **Valores AQL**: 26 opciones, desde `0.010` hasta `1000`
- **Resultados detallados**:
  - Plan simple: `n`, `c`, `r`
  - Plan doble: decisiones para dos muestras
  - Plan multiple: secuencias de aceptacion y rechazo por etapa
- **Analisis visual**:
  - Curva OC
  - Curva ASN
- **Exportacion**: archivo Excel formateado segun el plan seleccionado

## Ultimos cambios incorporados

El README ahora refleja los cambios recientes de la aplicacion:

- selector de idioma en la parte superior de la interfaz
- textos internacionalizados mediante el catalogo `i18n`
- tema visual y construccion principal de la interfaz centralizados en `global.R`
- navegacion unificada para los modulos de Variables y Atributos
- descarga de resultados en Excel con `openxlsx`
- exportacion con hojas separadas para parametros y resultados
- formateo automatico de encabezados y anchos de columna en los archivos exportados

## Tecnologias utilizadas

- **R** (>= 4.0.0)
- **shiny** (>= 1.7.0)
- **bslib** (>= 0.4.0)
- **AcceptanceSampling** (>= 1.0-6)
- **openxlsx** (>= 4.2.8)
- **testthat** (>= 3.0.0)

### Atribucion de codigo

Las funciones de calculo de planes de muestreo en `aql_functions.R` fueron adaptadas para su integracion con esta aplicacion a partir del paquete `AQLSchemes`, manteniendo la fidelidad a los estandares ANSI/ASQ Z1.4 y Z1.9.

## Instalacion local

### Requisitos previos

- `R >= 4.0.0`
- RStudio o Positron (recomendado)

### Instalacion de dependencias

```r
install.packages(c(
  "shiny",
  "bslib",
  "AcceptanceSampling",
  "openxlsx"
))
```

### Dependencias opcionales para desarrollo y pruebas

```r
install.packages(c("testthat", "devtools", "covr"))
```

### Ejecucion de la aplicacion

Desde la raiz del proyecto:

```r
shiny::runApp()
```

## Estructura del proyecto

```text
muestreo/
|-- ui.R
|-- server.R
|-- global.R
|-- aql_functions.R
|-- DESCRIPTION
|-- LICENSE
|-- README.md
|-- run_tests.R
`-- tests/
    |-- README.md
    |-- testthat.R
    `-- testthat/
        |-- helper-load_app.R
        |-- test-aql_functions.R
        |-- test-app_ui.R
        |-- test-app_server.R
        `-- _snaps/
```

### Archivos principales

- `ui.R`: contenedor principal de la aplicacion y selector de idioma
- `global.R`: catalogos, traducciones, tema visual y construccion de la interfaz
- `server.R`: logica reactiva, tablas, graficas y exportacion a Excel
- `aql_functions.R`: funciones de calculo para Z1.4 y Z1.9

## Testing

La aplicacion incluye pruebas para funciones de calculo, estructura de interfaz y comportamiento del servidor.

### Ejecutar toda la bateria

```r
source("run_tests.R")
```

### Ejecutar tests especificos

```r
testthat::test_file("tests/testthat/test-aql_functions.R")
testthat::test_file("tests/testthat/test-app_ui.R")
testthat::test_file("tests/testthat/test-app_server.R")
```

### Entry point estandar de testthat

```r
testthat::test_dir("tests/testthat")
```

## Uso de la aplicacion

### Paso a paso

1. Selecciona el metodo de muestreo: Variables o Atributos.
2. Define el tipo de inspeccion, el nivel, el tamano de lote y el AQL.
3. En atributos, selecciona tambien el tipo de plan: `Single`, `Double` o `Multiple`.
4. Revisa la tabla del plan calculado.
5. Analiza las curvas OC y ASN para entender el comportamiento esperado del plan.
6. Descarga el resultado en Excel para documentacion o seguimiento.

## Exportacion de resultados

La exportacion actual genera archivos `.xlsx` con formato pensado para uso operativo y documental:

- hoja de parametros de entrada
- hoja de resultados
- encabezados formateados
- ajuste automatico de ancho de columnas
- nombres de hojas segun el idioma seleccionado

## Referencias normativas

Esta aplicacion implementa procedimientos basados en:

- **ANSI/ASQ Z1.4**: inspeccion por atributos
- **ANSI/ASQ Z1.9**: inspeccion por variables

Adicionalmente, utiliza el paquete `AcceptanceSampling` para el calculo y trazado de curvas asociadas a los planes de muestreo.

## Autores y contacto

**Quality Analytics**

- Web: https://qualityanalytics.net
- Email: info@qualityanalytics.net
- Desarrollador: Francisco Gonzalez

### Repositorio

- GitHub: https://github.com/fjgonzalezmgt/muestreo
- Demo: https://019d4f32-2bc5-e940-157a-3ed183ea7d78.share.connect.posit.cloud/

## Licencia

Este proyecto esta bajo la licencia **CC BY 4.0**.

Ver `LICENSE` para el texto completo.
