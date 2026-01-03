# Guía Rápida - Batería de Tests

## Inicio Rápido

### 1. Verificación Rápida (30 segundos)
```r
source("quick_test.R")
```
Ejecuta los 14 tests más críticos para verificar que todo funciona.

### 2. Tests Completos (2-3 minutos)
```r
source("run_tests.R")
# Selecciona opción 1 para ejecutar todos los tests
```

### 3. Tests Específicos
```r
# Solo funciones AQL
source("run_tests.R")  # Opción 2

# Solo UI
source("run_tests.R")  # Opción 3

# Solo Server
source("run_tests.R")  # Opción 4
```

## Métodos Alternativos

### Usando testthat directamente
```r
library(testthat)

# Todos los tests
test_dir("tests/testthat")

# Un archivo específico
test_file("tests/testthat/test-aql_functions.R")
```

### Usando devtools (si está configurado como paquete)
```r
devtools::test()
devtools::check()
```

## Interpretar Resultados

### ✓ Todo correcto
```
✓ | F W S  OK | Context
✓ |       135 | Tests passed
Duration: 2.3 s
[ FAIL 0 | WARN 0 | SKIP 0 | PASS 135 ]
```

### ✗ Con errores
```
x | F W S  OK | Context
✓ |   2  133 | 2 tests failed
```
Revisa el detalle de los tests que fallaron.

## Estructura de Archivos

```
muestreo/
├── app.R                      # Aplicación Shiny principal
├── aql_functions.R            # Funciones de muestreo
├── DESCRIPTION                # Metadata del paquete
├── quick_test.R              # ⭐ Verificación rápida
├── run_tests.R               # ⭐ Ejecutar batería completa
│
├── tests/
│   ├── README.md             # Documentación detallada
│   ├── testthat.R            # Configuración de testthat
│   └── testthat/
│       ├── test-aql_functions.R   # 98 tests de funciones
│       ├── test-app_ui.R          # 18 tests de UI
│       └── test-app_server.R      # 22 tests de servidor
│
└── rsconnect/                # Deployment info
```

## Cobertura por Archivo

| Archivo | Tests | Cobertura |
|---------|-------|-----------|
| test-aql_functions.R | 98 | Funciones principales + integración |
| test-app_ui.R | 18 | Catálogos y UI |
| test-app_server.R | 22 | Lógica del servidor |
| **TOTAL** | **138** | **Completa** |

## Solución de Problemas

### "No se encuentra el paquete testthat"
```r
install.packages("testthat")
```

### "No se encuentra el paquete AcceptanceSampling"
```r
install.packages("AcceptanceSampling")
```

### "Error loading app.R"
Verifica que estés en el directorio correcto:
```r
getwd()  # Debe ser el directorio del proyecto
```

### Tests muy lentos
Normal. Algunos tests calculan múltiples planes y curvas OC.
Usa `quick_test.R` para verificación rápida.

## Flujo de Trabajo Recomendado

### Antes de hacer cambios
```r
source("quick_test.R")  # Verificar que todo funciona
```

### Después de hacer cambios
```r
# 1. Verificación rápida
source("quick_test.R")

# 2. Si pasa, ejecutar todos
source("run_tests.R")  # Opción 1

# 3. Si falla algo, investigar
test_file("tests/testthat/test-[archivo].R")
```

### Antes de deployment
```r
# Ejecutar todos los tests con reporte detallado
source("run_tests.R")  # Opción 5
```

## Añadir Nuevos Tests

1. Abre el archivo correspondiente en `tests/testthat/`
2. Añade tu test usando `test_that()`:
```r
test_that("Mi nuevo test", {
  result <- mi_funcion(parametros)
  expect_equal(result$valor, valor_esperado)
  expect_true(result$condicion)
})
```
3. Ejecuta los tests para verificar

## Comandos Útiles

```r
# Ver lista de archivos de test
list.files("tests/testthat", pattern = "^test-")

# Ejecutar con diferentes reporters
test_dir("tests/testthat", reporter = "summary")
test_dir("tests/testthat", reporter = "progress")
test_dir("tests/testthat", reporter = "check")

# Ver cobertura de código (requiere covr)
install.packages("covr")
covr::package_coverage()
```

## Expectativas Comunes

```r
# Igualdad
expect_equal(objeto, valor_esperado)
expect_identical(objeto1, objeto2)

# Tipo/Clase
expect_type(objeto, "double")
expect_s3_class(objeto, "data.frame")

# Verdadero/Falso
expect_true(condicion)
expect_false(condicion)

# Errores/Mensajes
expect_error(codigo, "mensaje de error")
expect_message(codigo, "mensaje esperado")
expect_warning(codigo, "warning esperado")

# Longitud/Nombres
expect_length(vector, 5)
expect_named(objeto, c("nombre1", "nombre2"))
```

## Notas Importantes

- Los errores del linter sobre `test_that` no afectan la ejecución
- Algunos mensajes están suprimidos con `suppressMessages()`
- Los archivos temporales se limpian automáticamente
- La batería completa toma 2-3 minutos en ejecutar

## Referencias

- [testthat documentation](https://testthat.r-lib.org/)
- [R Packages - Testing](https://r-pkgs.org/testing-basics.html)
- Tests README completo: `tests/README.md`
