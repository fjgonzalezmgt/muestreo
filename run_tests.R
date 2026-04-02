# Script para ejecutar la bateria completa de tests
# Aplicacion de Muestreo AQL

cat("\014")

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

cat("================================================================================\n")
cat("  BATERIA DE TESTS - APLICACION DE MUESTREO AQL\n")
cat("================================================================================\n\n")
cat("Ejecutando tests unitarios...\n")
cat("Directorio de tests: tests/testthat/\n\n")

if (!dir.exists("tests/testthat")) {
  cat("ERROR: No se encuentra el directorio 'tests/testthat'.\n")
  cat("Asegurate de ejecutar este script desde el directorio raiz del proyecto.\n")
  stop("Directorio de tests no encontrado")
}

options(testthat.default_reporter = "progress")
interactive_session <- interactive()
Sys.setenv(TESTTHAT_CPUS = "1")

ejecutar_tests <- function(archivo = NULL) {
  start_time <- Sys.time()

  if (is.null(archivo)) {
    cat("Ejecutando TODOS los archivos de test...\n\n")
    resultados <- test_dir("tests/testthat", reporter = "summary")
  } else {
    cat(paste0("Ejecutando: ", archivo, "\n\n"))
    resultados <- test_file(archivo, reporter = "summary")
  }

  end_time <- Sys.time()
  tiempo <- difftime(end_time, start_time, units = "secs")

  cat("\n")
  cat("================================================================================\n")
  cat(paste0("  RESUMEN DE EJECUCION (", round(tiempo, 2), " segundos)\n"))
  cat("================================================================================\n")

  resultados
}

if (interactive_session) {
  cat("Opciones:\n")
  cat("  1. Ejecutar todos los tests\n")
  cat("  2. Ejecutar solo tests de funciones AQL\n")
  cat("  3. Ejecutar solo tests de UI\n")
  cat("  4. Ejecutar solo tests de Server\n")
  cat("  5. Ejecutar tests con reporte detallado\n\n")

  opcion <- readline(prompt = "Selecciona una opcion (1-5, Enter para opcion 1): ")
} else {
  cat("Modo no interactivo detectado. Ejecutando todos los tests.\n\n")
  opcion <- "1"
}

if (opcion == "" || opcion == "1") {
  resultados <- ejecutar_tests()
} else if (opcion == "2") {
  resultados <- ejecutar_tests("tests/testthat/test-aql_functions.R")
} else if (opcion == "3") {
  resultados <- ejecutar_tests("tests/testthat/test-app_ui.R")
} else if (opcion == "4") {
  resultados <- ejecutar_tests("tests/testthat/test-app_server.R")
} else if (opcion == "5") {
  cat("\nEjecutando con reporte detallado...\n\n")
  test_dir("tests/testthat", reporter = "check")
} else {
  cat("Opcion no valida. Ejecutando todos los tests...\n")
  resultados <- ejecutar_tests()
}

generar_reporte <- if (interactive_session) {
  readline(prompt = "\nDeseas generar un reporte detallado? (s/n): ")
} else {
  "n"
}

if (tolower(generar_reporte) == "s") {
  cat("\nGenerando reporte detallado...\n")

  output_file <- "test_results.txt"

  sink(output_file)
  cat("================================================================================\n")
  cat("  REPORTE DETALLADO DE TESTS - APLICACION DE MUESTREO AQL\n")
  cat("  Fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
  cat("================================================================================\n\n")
  sink()

  test_dir("tests/testthat", reporter = "location", stop_on_failure = FALSE)

  cat("\nReporte guardado en:", output_file, "\n")

  abrir <- if (interactive_session) {
    readline(prompt = "Abrir reporte? (s/n): ")
  } else {
    "n"
  }

  if (tolower(abrir) == "s") {
    file.show(output_file)
  }
}

cat("\n")
cat("================================================================================\n")
cat("  TESTS COMPLETADOS\n")
cat("================================================================================\n\n")
cat("Archivos de test disponibles:\n")

archivos <- list.files("tests/testthat", pattern = "^test-.*\\.R$", full.names = TRUE)
for (archivo in archivos) {
  cat(paste0("  - ", basename(archivo), "\n"))
}

cat("\n")
cat("Para ejecutar tests individuales, usa:\n")
cat("  testthat::test_file('tests/testthat/test-aql_functions.R')\n\n")
cat("Para ver cobertura de codigo (requiere 'covr'):\n")
cat("  covr::package_coverage()\n\n")
