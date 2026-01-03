# Script de verificación rápida de tests
# Ejecuta un subset de tests críticos

library(testthat)
library(AcceptanceSampling)

source("aql_functions.R")

cat("================================================================================\n")
cat("  VERIFICACIÓN RÁPIDA - Tests Críticos\n")
cat("================================================================================\n\n")

# Contador de tests
tests_passed <- 0
tests_failed <- 0

# Helper function
test_critical <- function(description, expr) {
  cat(paste0("Testing: ", description, "... "))
  tryCatch({
    expr
    cat("✓ PASS\n")
    tests_passed <<- tests_passed + 1
  }, error = function(e) {
    cat("✗ FAIL\n")
    cat(paste0("  Error: ", e$message, "\n"))
    tests_failed <<- tests_failed + 1
  })
}

# Tests críticos
cat("\n1. Tests de Funciones Principales\n")
cat("----------------------------------\n")

test_critical("AAZ19 - Variables Normal", {
  result <- suppressMessages(AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7))
  stopifnot(length(result) == 3)
  stopifnot(all(names(result) == c("n", "k", "M")))
  stopifnot(result["n"] > 0)
})

test_critical("AAZ14Single - Atributos Normal", {
  result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  stopifnot(is.data.frame(result))
  stopifnot(nrow(result) == 1)
  stopifnot(result$r > result$c)
})

test_critical("AAZ14Double - Doble", {
  result <- suppressMessages(AAZ14Double(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  stopifnot(is.data.frame(result) || is.character(result))
  if(is.data.frame(result)) {
    stopifnot(nrow(result) == 2)
  }
})

test_critical("AAZ14Multiple - Múltiple", {
  result <- suppressMessages(AAZ14Multiple(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  stopifnot(is.data.frame(result))
  stopifnot(nrow(result) <= 7)
})

cat("\n2. Tests de Diferentes Tipos de Inspección\n")
cat("-------------------------------------------\n")

test_critical("Inspección Normal vs Tightened", {
  normal <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  tight <- suppressMessages(AAZ14Single(PLAN = 2, dINSL = 6, dLOTS = 11, dAQL = 12))
  stopifnot(!identical(normal, tight))
})

test_critical("Inspección Normal vs Reduced", {
  normal <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  reduced <- suppressMessages(AAZ14Single(PLAN = 3, dINSL = 6, dLOTS = 11, dAQL = 12))
  stopifnot(reduced$n <= normal$n)
})

cat("\n3. Tests de Validación de Datos\n")
cat("--------------------------------\n")

test_critical("Catálogos correctamente definidos", {
  source("app.R", local = TRUE)
  stopifnot(nrow(type_df) == 3)
  stopifnot(nrow(choice_plans) == 3)
  stopifnot(nrow(level_var_df) == 5)
})

test_critical("lookup_id funciona", {
  source("app.R", local = TRUE)
  stopifnot(lookup_id(type_df, "Normal") == 1)
  stopifnot(lookup_id(choice_plans, "Single") == 1)
})

cat("\n4. Tests de Integración con AcceptanceSampling\n")
cat("-----------------------------------------------\n")

test_critical("Curva OC para Single sampling", {
  plan <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  oc <- OC2c(n = plan$n, c = plan$c, pd = seq(0, 0.1, 0.01))
  stopifnot(!is.null(oc))
})

test_critical("Curva OC para Variables", {
  plan <- suppressMessages(AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7))
  oc <- OCvar(n = plan[["n"]], k = plan[["k"]], s.type = "unknown", pd = seq(0, 0.08, 0.005))
  stopifnot(!is.null(oc))
})

cat("\n5. Tests de Casos Extremos\n")
cat("---------------------------\n")

test_critical("AQL muy bajo", {
  result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 1))
  stopifnot(is.data.frame(result))
  stopifnot(result$n > 0)
})

test_critical("AQL muy alto", {
  result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 26))
  stopifnot(is.data.frame(result))
  stopifnot(result$n > 0)
})

test_critical("Lote pequeño", {
  result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 1, dAQL = 12))
  stopifnot(result$n > 0)
  stopifnot(result$n <= 50)
})

# Resumen final
cat("\n")
cat("================================================================================\n")
cat("  RESUMEN DE VERIFICACIÓN\n")
cat("================================================================================\n")
cat(paste0("\n  Tests ejecutados: ", tests_passed + tests_failed, "\n"))
cat(paste0("  ✓ Exitosos: ", tests_passed, "\n"))
cat(paste0("  ✗ Fallidos: ", tests_failed, "\n"))

if (tests_failed == 0) {
  cat("\n  ✓ TODOS LOS TESTS CRÍTICOS PASARON\n")
  cat("\n  La aplicación está lista para usar.\n")
} else {
  cat("\n  ✗ ALGUNOS TESTS FALLARON\n")
  cat("\n  Por favor revisa los errores antes de usar la aplicación.\n")
}

cat("\n")
cat("Para ejecutar la batería completa de tests, usa:\n")
cat("  source('run_tests.R')\n")
cat("\n")
cat("================================================================================\n")

# Retornar código de salida
if (tests_failed > 0) {
  quit(status = 1)
}
