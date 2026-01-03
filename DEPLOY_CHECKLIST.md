# Checklist para Deployment a shinyapps.io

## Estado actual
- ✅ `.rscignore` creado para excluir tests
- ✅ `test-hello.R` eliminado
- ❓ Error en deployment: "Your source code could not be updated"

## Posibles causas del error

### 1. Tamaño del código
El archivo `aql_functions.R` es muy grande (~5000 líneas) con matrices enormes.

### 2. Dependencias
Verificar que todas las dependencias estén en DESCRIPTION:
- shiny (>= 1.7.0)
- bslib (>= 0.4.0)
- AcceptanceSampling (>= 1.0-6)

### 3. Archivos que se deben incluir
- ✅ app.R
- ✅ aql_functions.R
- ✅ DESCRIPTION
- ✅ .rscignore

### 4. Archivos excluidos (en .rscignore)
- ❌ tests/
- ❌ test_results.txt
- ❌ TEST_SUMMARY.txt
- ❌ TESTING_GUIDE.md
- ❌ run_tests.R
- ❌ quick_test.R
- ❌ .Rprofile, .Rhistory, .RData
- ❌ .git, .gitignore
- ❌ *.Rproj, .Rproj.user

## Pasos para resolver

### Opción 1: Reintentar deployment
Simplemente volver a intentar hacer deploy desde RStudio o la consola.

### Opción 2: Limpiar y volver a deployar
```r
library(rsconnect)
rsconnect::deployApp(
  appDir = ".",
  appName = "Z1_9",
  account = "fjgonzalezm",
  forceUpdate = TRUE
)
```

### Opción 3: Deployment manual
1. Crear un nuevo proyecto en shinyapps.io
2. Cambiar el nombre del app
3. Hacer deployment limpio

## Comandos útiles

### Ver configuración actual
```r
rsconnect::showLogs()
rsconnect::accounts()
```

### Deployment con logs verbose
```r
options(rsconnect.max.bundle.size = 10485760)  # 10MB max
rsconnect::deployApp(
  appFiles = c("app.R", "aql_functions.R", "DESCRIPTION"),
  appName = "Z1_9",
  forceUpdate = TRUE
)
```

### Si persiste el error
El error "Your source code could not be updated" generalmente significa:
1. Problema de permisos en shinyapps.io
2. Bundle muy grande
3. Caracteres especiales en archivos
4. Problema de red/timeout

**Solución recomendada:** 
- Esperar unos minutos y reintentar
- Verificar que no haya procesos de deployment anteriores corriendo
- Si persiste, contactar soporte de shinyapps.io
