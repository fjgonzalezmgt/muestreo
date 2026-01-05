# Sampling Plan Calculator (AQL) 📊

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Shiny](https://img.shields.io/badge/Shiny-00B4D8?style=for-the-badge&logo=rstudio&logoColor=white)
![Posit Connect](https://img.shields.io/badge/Posit_Connect-447099?style=for-the-badge&logo=rstudio&logoColor=white)
![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-138%2B%20passing-success?style=for-the-badge)

Aplicación Shiny para el cálculo de planes de muestreo por aceptación según normas **ANSI/ASQ Z1.4** (atributos) y **ANSI/ASQ Z1.9** (variables).

Desarrollada por **Quality Analytics** para facilitar la implementación de sistemas de control de calidad basados en estándares internacionales.

## 🌐 Demo en vivo

Accede a la aplicación publicada:
**[https://019b8e74-1e2f-e211-efbc-c9f5543838c0.share.connect.posit.cloud/](https://019b8e74-1e2f-e211-efbc-c9f5543838c0.share.connect.posit.cloud/)**

## ✨ Características

- **Muestreo por Variables (Z1.9)**: Cálculo de planes basados en mediciones continuas con desviación estándar conocida o desconocida
- **Muestreo por Atributos (Z1.4)**: Planes simples, dobles y múltiples para inspección por atributos
- **Curvas OC y ASN**: Visualización interactiva de curvas características de operación y tamaño promedio de muestra
- **Interfaz moderna**: Diseño responsivo con Bootstrap 5 y tema Flatly personalizado
- **Exportación de resultados**: Descarga de planes de muestreo en formato CSV
- **Testing completo**: Batería de 138+ tests unitarios con cobertura completa
- **Documentación exhaustiva**: Código completamente documentado con roxygen2

## 🚀 Funcionalidades principales

### Muestreo por Variables (Z1.9)
- **Tipos de inspección**: Normal, Tightened (Rigurosa), Reduced (Reducida)
- **Niveles de inspección**: S-3, S-4, I, II, III
- **Tamaños de lote**: 16 rangos desde 2 unidades hasta más de 500,000
- **Valores AQL**: 11 opciones desde 0.10% hasta 10%
- **Resultados**: Tamaño de muestra (n), constante de aceptabilidad (k) y máxima proporción no conforme (M)
- **Desviación estándar**: Soporta casos con σ conocida y desconocida

### Muestreo por Atributos (Z1.4)
- **Tipos de plan**: Simple (Single), Doble (Double) y Múltiple (Multiple)
- **Tipos de inspección**: Normal, Tightened, Reduced
- **Niveles de inspección**: S-1, S-2, S-3, S-4, I, II, III
- **Tamaños de lote**: 15 rangos desde 2 unidades hasta más de 500,000
- **Valores AQL**: 26 opciones desde 0.010 hasta 1000 defectos por cien unidades
- **Resultados detallados**:
  - Plan simple: n (tamaño de muestra), c (número de aceptación), r (número de rechazo)
  - Plan doble: hasta 2 muestras con decisiones intermedias
  - Plan múltiple: hasta 7 muestras secuenciales

### Análisis y Visualización
- **Curvas OC (Operating Characteristic)**: Probabilidad de aceptación vs proporción defectuosa
- **Curvas ASN (Average Sample Number)**: Tamaño promedio de muestra esperado
- **Comparación de planes**: Evalúa diferentes estrategias de muestreo
- **Exportación a CSV**: Descarga resultados para análisis posterior

## 🛠️ Tecnologías utilizadas

- **R** (>= 4.0.0) - Lenguaje de programación estadística
- **shiny** (>= 1.7.0) - Framework de aplicaciones web interactivas
- **bslib** (>= 0.4.0) - Temas Bootstrap 5 modernos para Shiny
- **AcceptanceSampling** (>= 1.0-6) - Implementación de algoritmos de muestreo por aceptación según normas ANSI/ASQ
- **testthat** (>= 3.0.0) - Framework de testing unitario con 138+ tests

## 📦 Instalación local

### Requisitos previos
- R >= 4.0.0
- RStudio o Positron (recomendado)

### Pasos de instalación

```r
# 1. Instalar dependencias
install.packages(c("shiny", "bslib", "AcceptanceSampling"))

# Opcional: instalar paquetes de desarrollo
install.packages(c("testthat", "devtools", "covr"))

# 2. Clonar el repositorio
# Desde terminal/consola:
git clone https://github.com/fjgonzalezmgt/muestreo.git
cd muestreo

# 3. Ejecutar la aplicación
# Desde R:
shiny::runApp()

# O usando el archivo ui.R y server.R:
shiny::runApp(launch.browser = TRUE)
```

### Ejecución rápida desde R

```r
# Ejecutar directamente desde GitHub (sin clonar)
shiny::runGitHub("muestreo", "fjgonzalezmgt")
```

## 📂 Estructura del proyecto

```
muestreo/
├── ui.R                   # Interfaz de usuario (Bootstrap 5 + bslib)
├── server.R               # Lógica del servidor y cálculos
├── global.R               # Catálogos y definiciones globales
├── aql_functions.R        # Funciones principales de muestreo AQL
│                          #   - AAZ19: Muestreo por variables (Z1.9)
│                          #   - AAZ14Single: Plan simple de atributos (Z1.4)
│                          #   - AAZ14Double: Plan doble de atributos (Z1.4)
│                          #   - AAZ14Multiple: Plan múltiple de atributos (Z1.4)
├── DESCRIPTION            # Metadatos del paquete y dependencias
├── LICENSE                # Licencia CC BY 4.0
├── README.md              # Este archivo
│
├── tests/                 # Suite completa de testing
│   ├── README.md          # Documentación detallada de tests
│   ├── testthat.R         # Configuración de testthat
│   └── testthat/
│       ├── helper-load_app.R        # Helpers para tests
│       ├── test-aql_functions.R     # 98 tests de funciones AQL
│       ├── test-app_ui.R            # 18 tests de interfaz
│       └── test-app_server.R        # 22 tests de servidor
│
├── quick_test.R           # Verificación rápida (14 tests críticos)
├── run_tests.R            # Script interactivo para ejecutar tests
├── TESTING_GUIDE.md       # Guía rápida de testing
├── TEST_SUMMARY.txt       # Resumen de cobertura de tests
│
└── rsconnect/             # Configuración de despliegue en Posit Connect
```

### Archivos principales

| Archivo | Descripción | Líneas |
|---------|-------------|--------|
| `ui.R` | Interfaz de usuario con Bootstrap 5 | ~200 |
| `server.R` | Lógica del servidor y renderizado | ~475 |
| `global.R` | 8 catálogos de datos + helper functions | ~250 |
| `aql_functions.R` | 4 funciones principales de cálculo | ~400 |

### Archivos de testing

| Archivo | Tests | Cobertura |
|---------|-------|-----------|
| `test-aql_functions.R` | 98 | Funciones principales + integración |
| `test-app_ui.R` | 18 | Catálogos y estructura UI |
| `test-app_server.R` | 22 | Lógica reactiva del servidor |
| **TOTAL** | **138+** | **Cobertura completa** |

## 🧪 Testing

La aplicación cuenta con una batería completa de **138+ tests unitarios** que garantizan su correcto funcionamiento:

### Verificación rápida (30 segundos)
```r
source("quick_test.R")
```
Ejecuta los 14 tests más críticos para verificación rápida.

### Tests completos (2-3 minutos)
```r
source("run_tests.R")
# Selecciona opción 1 para ejecutar todos los tests
```

### Tests específicos
```r
# Solo funciones AQL (98 tests)
testthat::test_file("tests/testthat/test-aql_functions.R")

# Solo UI (18 tests)
testthat::test_file("tests/testthat/test-app_ui.R")

# Solo Server (22 tests)
testthat::test_file("tests/testthat/test-app_server.R")
```

### Cobertura de tests

- ✅ **Funciones principales**: AAZ19, AAZ14Single, AAZ14Double, AAZ14Multiple
- ✅ **Tipos de inspección**: Normal, Tightened, Reduced
- ✅ **Todos los niveles de inspección**: S-1 a S-4, I, II, III
- ✅ **Rangos de lote**: Desde 2 hasta >500,000 unidades
- ✅ **Valores AQL**: Completo rango de valores según normas
- ✅ **Casos extremos**: Validación de límites y situaciones especiales
- ✅ **Integración**: Compatibilidad con paquete AcceptanceSampling
- ✅ **UI y Server**: Validación de componentes Shiny

Para más detalles, consulta `TESTING_GUIDE.md` y `tests/README.md`.

## 📊 Uso de la aplicación

### Paso a paso

1. **Selecciona el método de muestreo**
   - Variables (Z1.9): Para características medibles (longitud, peso, temperatura, etc.)
   - Atributos (Z1.4): Para características de pasa/no pasa (defectuoso/no defectuoso)

2. **Configura los parámetros del plan**
   - **Tipo de inspección**: Normal (uso estándar), Tightened (más rigurosa), Reduced (menos rigurosa)
   - **Nivel de inspección**: Determina el tamaño de muestra relativo al lote (II es el más común)
   - **Tamaño del lote**: Selecciona el rango que corresponde a tu lote
   - **AQL (Acceptable Quality Level)**: Nivel de calidad aceptable en porcentaje
   - **Tipo de plan** (solo atributos): Simple, Doble o Múltiple

3. **Visualiza el plan de muestreo**
   - Revisa los parámetros calculados (n, k, M para variables; n, c, r para atributos)
   - Analiza la curva OC para entender el riesgo del productor y consumidor
   - Examina la curva ASN para conocer el tamaño promedio de muestra esperado

4. **Exporta los resultados**
   - Descarga el plan en formato CSV para documentación y uso posterior
   - Incluye todos los parámetros y cálculos realizados

### Ejemplo práctico: Muestreo por Variables

```
Escenario: Inspección de diámetros de tornillos
- Tipo: Variables (medición continua)
- Inspección: Normal
- Nivel: II (general)
- Lote: 501-1,200 unidades
- AQL: 1.0%

Resultado:
- n = 20 (tamaño de muestra)
- k = 1.78 (constante de aceptabilidad)
- M = 3.09% (máxima proporción no conforme)
```

### Ejemplo práctico: Muestreo por Atributos

```
Escenario: Inspección visual de piezas plásticas
- Tipo: Atributos (pasa/no pasa)
- Plan: Simple
- Inspección: Normal
- Nivel: II
- Lote: 501-1,200 unidades
- AQL: 1.0%

Resultado:
- n = 80 (tamaño de muestra)
- c = 2 (número de aceptación)
- r = 3 (número de rechazo)
Decisión: Acepta el lote si encuentra ≤2 defectuosos, rechaza si encuentra ≥3
```

## 📄 Referencias normativas

Esta aplicación implementa los procedimientos y tablas de las siguientes normas internacionales:

- **ANSI/ASQ Z1.4-2008** (equivalente a ISO 2859-1:1999)
  - *Sampling Procedures and Tables for Inspection by Attributes*
  - Planes de muestreo para inspección por atributos
  - Incluye planes simple, doble y múltiple
  - Curvas OC y tablas de números de aceptación

- **ANSI/ASQ Z1.9-2008** (equivalente a ISO 3951-1:2013)
  - *Sampling Procedures and Tables for Inspection by Variables for Percent Nonconforming*
  - Planes de muestreo para inspección por variables
  - Casos con desviación estándar conocida y desconocida
  - Método de la constante de aceptabilidad (k)

### Recursos adicionales

- [ASQ Standards](https://asq.org/quality-resources/standards-101) - American Society for Quality
- [ISO Standards Catalogue](https://www.iso.org/standards.html) - International Organization for Standardization
- Schilling, E. G., & Neubauer, D. V. (2009). *Acceptance Sampling in Quality Control* (2nd ed.). CRC Press.

## 👥 Autores y Contacto

**Quality Analytics**
- 🌐 Web: [qualityanalytics.net](https://qualityanalytics.net)
- 📧 Email: info@qualityanalytics.net
- 👨‍💻 Desarrollador: Francisco González

### Repositorio
- 🔗 GitHub: [fjgonzalezmgt/muestreo](https://github.com/fjgonzalezmgt/muestreo)
- 🚀 Demo: [Posit Connect Cloud](https://019b8e74-1e2f-e211-efbc-c9f5543838c0.share.connect.posit.cloud/)

## 📝 Licencia

Este proyecto está bajo la licencia [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

### Permisos
✅ **Compartir** — copiar y redistribuir el material en cualquier medio o formato  
✅ **Adaptar** — remezclar, transformar y construir a partir del material  
✅ **Uso comercial** — puedes usar el material para propósitos comerciales  

### Condiciones
📋 **Atribución** — Debes dar crédito apropiado, proporcionar un enlace a la licencia e indicar si se realizaron cambios. Puedes hacerlo de cualquier manera razonable, pero no de forma que sugiera que el licenciador te respalda o respalda tu uso.

### Limitaciones
❌ Sin garantía  
❌ El licenciador no puede revocar estas libertades siempre que sigas los términos de la licencia

Ver el archivo [LICENSE](LICENSE) para el texto completo de la licencia.

### Atribución

Si utilizas este proyecto, por favor incluye una referencia:

```
Sampling Plan Calculator (AQL)
Desarrollado por Francisco González - Quality Analytics
https://github.com/fjgonzalezmgt/muestreo
Licencia: CC BY 4.0
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas y apreciadas. Para contribuir:

### Proceso de contribución

1. **Fork** el proyecto en GitHub
2. **Crea una rama** para tu feature o fix
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Realiza tus cambios** y asegúrate de que:
   - El código sigue el estilo del proyecto
   - Todos los tests pasan: `source("quick_test.R")`
   - Añades tests para nuevas funcionalidades
   - Actualizas la documentación si es necesario

4. **Commit** tus cambios con un mensaje descriptivo
   ```bash
   git commit -m 'Add: Nueva funcionalidad increíble'
   ```
5. **Push** a tu rama
   ```bash
   git push origin feature/AmazingFeature
   ```
6. Abre un **Pull Request** en GitHub con:
   - Descripción clara de los cambios
   - Referencia a issues relacionados (si aplica)
   - Screenshots (si hay cambios visuales)

### Guidelines

- 📝 Documenta funciones usando roxygen2
- ✅ Añade tests para código nuevo
- 🎨 Mantén consistencia en el estilo de código
- 📚 Actualiza README.md si añades features
- 🐛 Reporta bugs usando GitHub Issues

### Áreas de contribución

- 🆕 Nuevas funcionalidades
- 🐛 Corrección de bugs
- 📖 Mejoras en documentación
- 🧪 Más tests y mejor cobertura
- 🎨 Mejoras en UI/UX
- 🌍 Traducciones (inglés, etc.)
- ⚡ Optimización de rendimiento

---

Desarrollado con ❤️ por Quality Analytics

## 🚀 Deployment

### Posit Connect / RStudio Connect

La aplicación está optimizada para despliegue en Posit Connect:

```r
# Instalar rsconnect
install.packages("rsconnect")

# Configurar cuenta
rsconnect::setAccountInfo(name="<ACCOUNT>", 
                          token="<TOKEN>", 
                          secret="<SECRET>")

# Desplegar aplicación
rsconnect::deployApp(appFiles = c("ui.R", "server.R", "global.R", 
                                  "aql_functions.R", "DESCRIPTION"))
```

### Checklist pre-deployment

Antes de desplegar, verifica:

- ✅ Todos los tests pasan: `source("run_tests.R")`
- ✅ DESCRIPTION tiene todas las dependencias
- ✅ No hay credenciales hardcoded
- ✅ Funciona correctamente en local
- ✅ README.md está actualizado

Ver `DEPLOY_CHECKLIST.md` para lista completa.

### Shiny Server

Para desplegar en Shiny Server:

1. Copia todos los archivos al directorio del servidor
2. Asegúrate de que las dependencias están instaladas
3. Configura permisos apropiados
4. La aplicación estará disponible en `http://servidor/muestreo`

### Docker (opcional)

```dockerfile
FROM rocker/shiny:latest
RUN install2.r shiny bslib AcceptanceSampling
COPY . /srv/shiny-server/muestreo
EXPOSE 3838
CMD ["/usr/bin/shiny-server"]
```

## 💻 Requisitos del sistema

- **R**: >= 4.0.0
- **Memoria RAM**: Mínimo 2GB recomendado
- **Navegador**: Chrome, Firefox, Safari, Edge (versiones recientes)
- **Resolución**: Optimizado para 1024x768 o superior

## 🐛 Solución de problemas

### Error: Package 'AcceptanceSampling' not found
```r
install.packages("AcceptanceSampling")
```

### Error: Cannot find function from package 'bslib'
```r
install.packages("bslib")
# O actualiza a la última versión
update.packages("bslib")
```

### La aplicación no carga
1. Verifica que estés en el directorio correcto: `getwd()`
2. Asegúrate de que todos los archivos necesarios están presentes
3. Ejecuta `source("quick_test.R")` para verificar funcionalidad

### Tests fallan
1. Actualiza los paquetes: `update.packages(ask = FALSE)`
2. Reinstala testthat: `install.packages("testthat")`
3. Revisa el archivo específico que falla

Para más ayuda, abre un issue en GitHub.

## 📚 Documentación adicional

- 📘 **TESTING_GUIDE.md** - Guía rápida de uso de tests
- 📙 **tests/README.md** - Documentación completa de la batería de tests
- 📕 **TEST_SUMMARY.txt** - Resumen de cobertura y estadísticas

## 🎯 Roadmap

### Próximas funcionalidades
- [ ] Soporte para múltiples idiomas (inglés, portugués)
- [ ] Exportación a PDF de planes de muestreo
- [ ] Historial de cálculos realizados
- [ ] Comparación lado a lado de diferentes planes
- [ ] API REST para integración con otros sistemas
- [ ] Aplicación móvil nativa

### Mejoras planificadas
- [ ] Mayor cobertura de tests (objetivo: 95%+)
- [ ] Optimización de rendimiento en curvas OC
- [ ] Tema oscuro/claro seleccionable
- [ ] Tutorial interactivo para nuevos usuarios

---

**Última actualización**: Enero 2026  
**Versión**: 1.0.0  
**Autor**: Francisco González  
**Desarrollado con ❤️ por Quality Analytics**
