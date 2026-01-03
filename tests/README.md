# Batería de Tests - Aplicación de Muestreo AQL

Este directorio contiene una batería completa de tests unitarios para la aplicación Shiny de muestreo por aceptación (AQL).

## Estructura de Tests

```
tests/
├── testthat.R              # Archivo principal de configuración
└── testthat/
    ├── test-aql_functions.R    # Tests para funciones AQL (Z1.9 y Z1.4)
    ├── test-app_ui.R           # Tests para elementos de UI
    └── test-app_server.R       # Tests para lógica del servidor
```

## Cobertura de Tests

### 1. Tests de Funciones AQL (`test-aql_functions.R`)

#### AAZ19 (Muestreo por Variables - Z1.9)
- ✅ Validación de resultados con parámetros normales
- ✅ Diferentes tipos de inspección (Normal, Tightened, Reduced)
- ✅ Diferentes niveles de inspección (S-3, S-4, I, II, III)
- ✅ Diferentes tamaños de lote (16 rangos)
- ✅ Conversión correcta de tipos numéricos
- ✅ Manejo de desviación estándar desconocida

#### AAZ14Single (Muestreo Simple por Atributos)
- ✅ Validación de estructura del plan (n, c, r)
- ✅ Diferentes tipos de inspección
- ✅ Todos los niveles de inspección (S-1 a III)
- ✅ Diferentes valores de AQL
- ✅ Relación correcta entre c y r (r > c)
- ✅ Comparación entre tipos de inspección

#### AAZ14Double (Muestreo Doble por Atributos)
- ✅ Validación de estructura del plan (2 muestras)
- ✅ Manejo de casos sin plan doble disponible
- ✅ Verificación de tamaños de muestra
- ✅ Diferentes tipos de inspección

#### AAZ14Multiple (Muestreo Múltiple por Atributos)
- ✅ Validación de estructura del plan (hasta 7 muestras)
- ✅ Tamaños de muestra consistentes
- ✅ Números de aceptación crecientes
- ✅ Diferentes tipos de inspección

### 2. Tests de Integración
- ✅ Consistencia entre todos los métodos
- ✅ Tamaños de muestra razonables vs tamaño de lote
- ✅ Casos extremos (AQL muy bajo/alto)
- ✅ Comparación entre inspección Normal, Tightened y Reduced

### 3. Tests de UI (`test-app_ui.R`)
- ✅ Presencia de elementos principales
- ✅ Catálogos correctamente definidos
- ✅ Función `lookup_id` para conversión de valores
- ✅ Unicidad de IDs en catálogos
- ✅ Validez de valores numéricos de AQL
- ✅ IDs consecutivos desde 1

### 4. Tests del Servidor (`test-app_server.R`)
- ✅ Existencia de función server
- ✅ Integración con paquete AcceptanceSampling
- ✅ Validación de combinaciones de inputs
- ✅ Conversión de datos para display
- ✅ Exportación a CSV
- ✅ Compatibilidad con curvas OC
- ✅ Consistencia de datos

## Cómo Ejecutar los Tests

### Método 1: Desde R/RStudio

```r
# Instalar testthat si no está instalado
install.packages("testthat")

# Cargar testthat
library(testthat)

# Ejecutar todos los tests
test_dir("tests/testthat")

# O ejecutar un archivo específico
test_file("tests/testthat/test-aql_functions.R")
```

### Método 2: Usando el script helper

```r
# Ejecutar desde la consola R
source("run_tests.R")
```

### Método 3: Desde terminal con devtools

```r
# Si el proyecto está configurado como paquete
devtools::test()
```

## Requisitos

Los tests requieren los siguientes paquetes:

```r
install.packages(c(
  "testthat",
  "shiny",
  "bslib",
  "AcceptanceSampling"
))
```

## Interpretación de Resultados

### Resultado Exitoso
```
✓ | F W S  OK | Context
✓ |        98 | aql_functions
✓ |        15 | app_ui
✓ |        22 | app_server

══ Results ════════════════════════════════════════════
Duration: 2.3 s

[ FAIL 0 | WARN 0 | SKIP 0 | PASS 135 ]
```

### Resultado con Errores
```
✓ | F W S  OK | Context
✓ |        95 | aql_functions
x |     2  13 | app_ui

── Failed tests ───────────────────────────────────────
-- Failure: Catálogos están correctamente definidos ───
```

## Estadísticas de Cobertura

- **Total de tests**: 135+
- **Funciones cubiertas**: 4 funciones principales (AAZ19, AAZ14Single, AAZ14Double, AAZ14Multiple)
- **Catálogos validados**: 8 data frames
- **Casos de prueba**: Más de 50 combinaciones de parámetros

## Tests por Categoría

| Categoría | Cantidad | Archivos |
|-----------|----------|----------|
| Funcionalidad básica | 45 | test-aql_functions.R |
| Casos extremos | 15 | test-aql_functions.R |
| Integración | 20 | test-aql_functions.R |
| Validación UI | 18 | test-app_ui.R |
| Validación Server | 22 | test-app_server.R |
| Mensajes/Errores | 10 | test-aql_functions.R |
| Estructura de datos | 10 | test-aql_functions.R, test-app_server.R |

## Notas Importantes

1. **Mensajes Suprimidos**: Algunos tests usan `suppressMessages()` para evitar la salida de mensajes informativos de las funciones.

2. **Dependencias Externas**: Los tests dependen del paquete `AcceptanceSampling` que debe estar instalado.

3. **Tests de Shiny**: Los tests de la aplicación Shiny son pruebas de unidad que verifican la lógica, no pruebas de interfaz completas.

4. **Archivos Temporales**: Los tests de exportación CSV usan archivos temporales que se limpian automáticamente.

## Mantenimiento

Para añadir nuevos tests:

1. Identifica la función o comportamiento a probar
2. Añade el test en el archivo correspondiente
3. Usa nombres descriptivos para los tests
4. Incluye comentarios explicativos si es necesario
5. Ejecuta todos los tests para verificar que no hay regresiones

## Troubleshooting

### Error: "No symbol named 'test_that' in scope"
Este es un error del linter, no afecta la ejecución de tests. Los tests funcionarán correctamente cuando se ejecuten con `testthat::test_dir()`.

### Error: "could not find function"
Verifica que todas las dependencias estén instaladas y que los archivos fuente se carguen correctamente.

### Tests Lentos
Algunos tests pueden tardar debido a:
- Cálculo de múltiples planes de muestreo
- Generación de curvas OC
- Iteración sobre múltiples combinaciones de parámetros

## Contribuir

Al añadir nuevas funcionalidades a la aplicación:

1. Escribe los tests ANTES de implementar (TDD)
2. Asegúrate de que todos los tests existentes pasen
3. Añade tests para casos extremos
4. Documenta cualquier comportamiento especial

## Contacto

Para preguntas sobre los tests o para reportar issues, contacta al equipo de desarrollo.
