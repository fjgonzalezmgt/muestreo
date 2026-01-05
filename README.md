# Sampling Plan Calculator (AQL) 📊

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Shiny](https://img.shields.io/badge/Shiny-00B4D8?style=for-the-badge&logo=rstudio&logoColor=white)
![Posit Connect](https://img.shields.io/badge/Posit_Connect-447099?style=for-the-badge&logo=rstudio&logoColor=white)
![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg?style=for-the-badge)

Aplicación Shiny para el cálculo de planes de muestreo por aceptación según normas **ANSI/ASQ Z1.4** (atributos) y **ANSI/ASQ Z1.9** (variables).

## 🌐 Demo en vivo

Accede a la aplicación publicada:
**[https://019b8b8e-6aa8-d81c-3d2d-e16a485a8585.share.connect.posit.cloud/](https://019b8b8e-6aa8-d81c-3d2d-e16a485a8585.share.connect.posit.cloud/)**

## 📋 Características

- **Muestreo por Variables (Z1.9)**: Cálculo de planes basados en mediciones continuas
- **Muestreo por Atributos (Z1.4)**: Planes simples, dobles y múltiples
- **Curvas OC y ASN**: Visualización de curvas características de operación y tamaño promedio de muestra
- **Interfaz intuitiva**: Diseño moderno con Bootstrap 5
- **Exportación de resultados**: Descarga de planes en formato CSV

## 🚀 Funcionalidades principales

### Muestreo por Variables (Z1.9)
- Selección de tipo de inspección (Normal, Tightened, Reduced)
- Niveles de inspección (S-3, S-4, I, II, III)
- Tamaños de lote desde 2 hasta más de 500,000 unidades
- AQL desde 0.10% hasta 10%
- Cálculo de tamaño de muestra (n), constante de aceptabilidad (k) y máxima proporción no conforme (M)

### Muestreo por Atributos (Z1.4)
- Planes simple, doble y múltiple
- Mismos parámetros de configuración que variables
- Determinación de números de aceptación y rechazo
- Curvas OC y ASN específicas para cada tipo de plan

## 🛠️ Tecnologías utilizadas

- **R** (>= 4.0.0)
- **shiny** (>= 1.7.0) - Framework de aplicaciones web
- **bslib** (>= 0.4.0) - Temas Bootstrap para Shiny
- **AcceptanceSampling** (>= 1.0-6) - Algoritmos de muestreo por aceptación

## 📦 Instalación local

```r
# Instalar dependencias
install.packages(c("shiny", "bslib", "AcceptanceSampling"))

# Clonar repositorio
git clone https://github.com/fjgonzalezmgt/muestreo.git
cd muestreo

# Ejecutar aplicación
shiny::runApp()
```

## 📂 Estructura del proyecto

```
muestreo/
├── app.R                  # Aplicación principal
├── aql_functions.R        # Funciones de cálculo AQL
├── DESCRIPTION            # Metadatos del paquete
├── README.md              # Este archivo
├── tests/                 # Suite de pruebas
│   ├── testthat/
│   │   ├── test-app_server.R
│   │   ├── test-app_ui.R
│   │   └── test-aql_functions.R
│   └── testthat.R
└── rsconnect/             # Configuración de despliegue
```

## 🧪 Testing

La aplicación cuenta con una batería completa de tests unitarios:

```r
# Ejecutar todos los tests
source("run_tests.R")

# O usar testthat directamente
testthat::test_dir("tests/testthat")
```

## 📊 Uso de la aplicación

1. Selecciona el tipo de muestreo (Variables o Atributos)
2. Configura los parámetros:
   - Tipo de inspección
   - Nivel de inspección
   - Tamaño del lote
   - AQL deseado
3. Visualiza el plan de muestreo calculado
4. Analiza las curvas OC y ASN
5. Descarga el plan en formato CSV

## 📄 Referencias normativas

- **ANSI/ASQ Z1.4-2008**: Sampling Procedures and Tables for Inspection by Attributes
- **ANSI/ASQ Z1.9-2008**: Sampling Procedures and Tables for Inspection by Variables for Percent Nonconforming

## 👥 Autores

**Quality Analytics**
- Email: info@qualityanalytics.net

## 📝 Licencia

Este proyecto está bajo la licencia [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

Eres libre de:
- **Compartir** — copiar y redistribuir el material en cualquier medio o formato
- **Adaptar** — remezclar, transformar y construir a partir del material para cualquier propósito, incluso comercialmente

Bajo los siguientes términos:
- **Atribución** — Debes dar crédito apropiado, proporcionar un enlace a la licencia e indicar si se realizaron cambios

Ver archivo `LICENSE` para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

Desarrollado con ❤️ por Quality Analytics
