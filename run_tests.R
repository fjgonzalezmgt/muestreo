# Script para ejecutar la batería completa de tests
# Aplicación de Muestreo AQL

# Limpiar consola
cat("\014")

# Cargar librerías necesarias
if (!require("testthat")) {
  install.packages("testthat")
  library(testthat)
}

if (!require("shiny")) {
  install.packages("shiny")
  library(shiny)
}

if (!require("AcceptanceSampling")) {
  install.packages("AcceptanceSampling")
  library(AcceptanceSampling)
}

# Mensaje de inicio
cat("================================================================================\n")
cat("  BATERÍA DE TESTS - APLICACIÓN DE MUESTREO AQL\n")
cat("================================================================================\n")
cat("\n")
cat("Ejecutando tests unitarios...\n")
cat("Directorio de tests: tests/testthat/\n")
cat("\n")

# Obtener el directorio del proyecto
project_dir <- getwd()

# Verificar que estamos en el directorio correcto
if (!dir.exists("tests/testthat")) {
  cat("ERROR: No se encuentra el directorio 'tests/testthat'.\n")
  cat("Asegúrate de ejecutar este script desde el directorio raíz del proyecto.\n")
  stop("Directorio de tests no encontrado")
}

# Configurar opciones de testthat
options(testthat.default_reporter = "progress")

# Función para ejecutar tests con resumen
ejecutar_tests <- function(archivo = NULL) {
  start_time <- Sys.time()
  
  if (is.null(archivo)) {
    # Ejecutar todos los tests
    cat("Ejecutando TODOS los archivos de test...\n\n")
    resultados <- test_dir("tests/testthat", reporter = "summary")
  } else {
    # Ejecutar un archivo específico
    cat(paste0("Ejecutando: ", archivo, "\n\n"))
    resultados <- test_file(archivo, reporter = "summary")
  }
  
  end_time <- Sys.time()
  tiempo <- difftime(end_time, start_time, units = "secs")
  
  cat("\n")
  cat("================================================================================\n")
  cat(paste0("  RESUMEN DE EJECUCIÓN (", round(tiempo, 2), " segundos)\n"))
  cat("================================================================================\n")
  
  return(resultados)
}

# Menú de opciones
cat("Opciones:\n")
cat("  1. Ejecutar todos los tests\n")
cat("  2. Ejecutar solo tests de funciones AQL\n")
cat("  3. Ejecutar solo tests de UI\n")
cat("  4. Ejecutar solo tests de Server\n")
cat("  5. Ejecutar tests con reporte detallado\n")
cat("\n")

# Opción por defecto: ejecutar todos
opcion <- readline(prompt = "Selecciona una opción (1-5, Enter para opción 1): ")

if (opcion == "" || opcion == "1") {
  # Ejecutar todos los tests
  resultados <- ejecutar_tests()
  
} else if (opcion == "2") {
  # Solo funciones AQL
  resultados <- ejecutar_tests("tests/testthat/test-aql_functions.R")
  
} else if (opcion == "3") {
  # Solo UI
  resultados <- ejecutar_tests("tests/testthat/test-app_ui.R")
  
} else if (opcion == "4") {
  # Solo Server
  resultados <- ejecutar_tests("tests/testthat/test-app_server.R")
  
} else if (opcion == "5") {
  # Reporte detallado
  cat("\nEjecutando con reporte detallado...\n\n")
  test_dir("tests/testthat", reporter = "check")
  
} else {
  cat("Opción no válida. Ejecutando todos los tests...\n")
  resultados <- ejecutar_tests()
}

# Generar reporte HTML (opcional)
generar_reporte <- readline(prompt = "\n¿Deseas generar un reporte detallado? (s/n): ")

if (tolower(generar_reporte) == "s") {
  cat("\nGenerando reporte detallado...\n")
  
  # Ejecutar tests con reporter detallado
  output_file <- "test_results.txt"
  
  # Capturar salida
  sink(output_file)
  cat("================================================================================\n")
  cat("  REPORTE DETALLADO DE TESTS - APLICACIÓN DE MUESTREO AQL\n")
  cat("  Fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
  cat("================================================================================\n\n")
  sink()
  
  # Ejecutar con reporter detallado
  test_dir("tests/testthat", reporter = "location", 
           stop_on_failure = FALSE)
  
  cat("\nReporte guardado en:", output_file, "\n")
  
  # Abrir reporte
  abrir <- readline(prompt = "¿Abrir reporte? (s/n): ")
  if (tolower(abrir) == "s") {
    file.show(output_file)
  }
}

# Estadísticas finales
cat("\n")
cat("================================================================================\n")
cat("  TESTS COMPLETADOS\n")
cat("================================================================================\n")
cat("\n")
cat("Archivos de test disponibles:\n")
archivos <- list.files("tests/testthat", pattern = "^test-.*\\.R$", full.names = TRUE)
for (archivo in archivos) {
  cat(paste0("  - ", basename(archivo), "\n"))
}

cat("\n")
cat("Para ejecutar tests individuales, usa:\n")
cat("  testthat::test_file('tests/testthat/test-aql_functions.R')\n")
cat("\n")
cat("Para ver cobertura de código (requiere 'covr'):\n")
cat("  covr::package_coverage()\n")
cat("\n")
