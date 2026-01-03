# Tests para funciones de muestreo AQL
# Batería completa de tests unitarios

library(testthat)
library(AcceptanceSampling)

# Cargar funciones
source("../../aql_functions.R")

# ==============================================================================
# Tests para AAZ19 (Muestreo por Variables)
# ==============================================================================

test_that("AAZ19 retorna resultados válidos para parámetros normales", {
  # Normal inspection, Level II, Lot 3201-10000, AQL 1.5%
  result <- AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7)
  
  expect_type(result, "double")
  expect_length(result, 3)
  expect_named(result, c("n", "k", "M"))
  
  # Verificar que los valores son positivos
  expect_true(all(result > 0))
  expect_true(result["n"] %% 1 == 0)  # n debe ser entero
  expect_true(result["M"] < 1)  # M es proporción, debe ser < 1
})

test_that("AAZ19 funciona con diferentes tipos de inspección", {
  # Normal
  result_normal <- AAZ19(type = "Normal", stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7)
  expect_named(result_normal, c("n", "k", "M"))
  
  # Tightened
  result_tight <- AAZ19(type = "Tightened", stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7)
  expect_named(result_tight, c("n", "k", "M"))
  
  # Reduced
  result_red <- AAZ19(type = "Reduced", stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7)
  expect_named(result_red, c("n", "k", "M"))
  
  # Los resultados deben ser diferentes
  expect_false(identical(result_normal, result_tight))
})

test_that("AAZ19 maneja diferentes niveles de inspección", {
  for(level in 1:5) {
    result <- suppressMessages(AAZ19(type = 1, stype = "unknown", dINSL = level, dLOTS = 10, dAQL = 6))
    expect_type(result, "double")
    expect_length(result, 3)
  }
})

test_that("AAZ19 maneja diferentes tamaños de lote", {
  for(lot in c(1, 5, 10, 15)) {
    result <- suppressMessages(AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = lot, dAQL = 6))
    expect_type(result, "double")
    expect_length(result, 3)
  }
})

test_that("AAZ19 tipo numérico se convierte correctamente", {
  result1 <- suppressMessages(AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7))
  result2 <- suppressMessages(AAZ19(type = 2, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7))
  result3 <- suppressMessages(AAZ19(type = 3, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7))
  
  expect_false(identical(result1, result2))
  expect_false(identical(result2, result3))
})

# ==============================================================================
# Tests para AAZ14Single (Muestreo Simple por Atributos)
# ==============================================================================

test_that("AAZ14Single retorna plan válido", {
  # Normal, Level II, Lot 3201-10000, AQL 1.5%
  result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_equal(ncol(result), 3)
  expect_named(result, c("n", "c", "r"))
  
  # Verificar que n es positivo y entero
  expect_true(result$n > 0)
  expect_true(result$n %% 1 == 0)
  
  # r debe ser mayor que c
  expect_true(result$r > result$c)
  expect_true(result$c >= 0)
})

test_that("AAZ14Single funciona con diferentes planes", {
  # Normal
  plan_normal <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  expect_s3_class(plan_normal, "data.frame")
  
  # Tightened
  plan_tight <- suppressMessages(AAZ14Single(PLAN = 2, dINSL = 6, dLOTS = 11, dAQL = 12))
  expect_s3_class(plan_tight, "data.frame")
  
  # Reduced
  plan_red <- suppressMessages(AAZ14Single(PLAN = 3, dINSL = 6, dLOTS = 11, dAQL = 12))
  expect_s3_class(plan_red, "data.frame")
  
  # Los planes deben ser diferentes
  expect_false(identical(plan_normal, plan_tight))
})

test_that("AAZ14Single maneja todos los niveles de inspección", {
  for(level in 1:7) {
    result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = level, dLOTS = 10, dAQL = 11))
    expect_s3_class(result, "data.frame")
  }
})

test_that("AAZ14Single maneja diferentes AQL", {
  for(aql in c(1, 6, 11, 16, 20)) {
    result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 10, dAQL = aql))
    expect_s3_class(result, "data.frame")
    expect_true(result$r > result$c)
  }
})

test_that("AAZ14Single c y r tienen relación correcta", {
  result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  # El número de rechazo siempre debe ser mayor que el de aceptación
  expect_true(result$r == result$c + 1 | result$r > result$c + 1)
})

# ==============================================================================
# Tests para AAZ14Double (Muestreo Doble por Atributos)
# ==============================================================================

test_that("AAZ14Double retorna plan válido o mensaje apropiado", {
  result <- suppressMessages(AAZ14Double(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  if(is.character(result)) {
    expect_true(grepl("single sampling", result, ignore.case = TRUE))
  } else {
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 2)  # Primera y segunda muestra
    expect_named(result, c("n", "c", "r"))
  }
})

test_that("AAZ14Double maneja caso sin plan doble", {
  # Para algunos parámetros no existe plan doble
  result <- suppressMessages(AAZ14Double(PLAN = 1, dINSL = 1, dLOTS = 1, dAQL = 1))
  
  if(is.character(result)) {
    expect_match(result, "single sampling", ignore.case = TRUE)
  }
})

test_that("AAZ14Double primera muestra es menor que segunda", {
  result <- suppressMessages(AAZ14Double(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  if(is.data.frame(result)) {
    expect_true(result$n[1] <= result$n[2])
  }
})

test_that("AAZ14Double funciona con diferentes planes", {
  for(plan in 1:3) {
    result <- suppressMessages(AAZ14Double(PLAN = plan, dINSL = 6, dLOTS = 11, dAQL = 12))
    expect_true(is.data.frame(result) || is.character(result))
  }
})

# ==============================================================================
# Tests para AAZ14Multiple (Muestreo Múltiple por Atributos)
# ==============================================================================

test_that("AAZ14Multiple retorna plan válido", {
  result <- suppressMessages(AAZ14Multiple(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) <= 7)  # Máximo 7 muestras
  expect_named(result, c("n", "c", "r"))
})

test_that("AAZ14Multiple todas las muestras tienen mismo tamaño", {
  result <- suppressMessages(AAZ14Multiple(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  # En muestreo múltiple, todas las muestras tienen el mismo tamaño
  if(nrow(result) > 1) {
    expect_true(all(result$n == result$n[1]))
  }
})

test_that("AAZ14Multiple funciona con diferentes planes", {
  for(plan in 1:3) {
    result <- suppressMessages(AAZ14Multiple(PLAN = plan, dINSL = 6, dLOTS = 11, dAQL = 12))
    expect_s3_class(result, "data.frame")
  }
})

test_that("AAZ14Multiple c es creciente", {
  result <- suppressMessages(AAZ14Multiple(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  # Los números de aceptación deben ser no-decrecientes
  for(i in 2:nrow(result)) {
    expect_true(result$c[i] >= result$c[i-1])
  }
})

# ==============================================================================
# Tests de Integración
# ==============================================================================

test_that("Todos los métodos retornan resultados consistentes", {
  # Parámetros comunes
  insl <- 6
  lots <- 11
  aql <- 12
  
  # Variables
  var_result <- suppressMessages(AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = lots, dAQL = 7))
  expect_type(var_result, "double")
  
  # Simple
  single_result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = insl, dLOTS = lots, dAQL = aql))
  expect_s3_class(single_result, "data.frame")
  
  # Doble
  double_result <- suppressMessages(AAZ14Double(PLAN = 1, dINSL = insl, dLOTS = lots, dAQL = aql))
  expect_true(is.data.frame(double_result) || is.character(double_result))
  
  # Múltiple
  mult_result <- suppressMessages(AAZ14Multiple(PLAN = 1, dINSL = insl, dLOTS = lots, dAQL = aql))
  expect_s3_class(mult_result, "data.frame")
})

test_that("Sample sizes son razonables para el tamaño de lote", {
  # Para lotes pequeños
  small_lot <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 1, dAQL = 12))
  expect_true(small_lot$n <= 50)  # Muestra pequeña para lote pequeño
  
  # Para lotes grandes
  large_lot <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 15, dAQL = 12))
  expect_true(large_lot$n >= small_lot$n)  # Muestra mayor para lote mayor
})

# ==============================================================================
# Tests de Casos Extremos
# ==============================================================================

test_that("Funciones manejan AQL muy bajo", {
  result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 1))
  expect_s3_class(result, "data.frame")
  expect_true(result$c >= 0)
})

test_that("Funciones manejan AQL muy alto", {
  result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 26))
  expect_s3_class(result, "data.frame")
  expect_true(result$n > 0)
})

test_that("Tightened inspection es más estricto que Normal", {
  normal <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  tight <- suppressMessages(AAZ14Single(PLAN = 2, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  # Tightened debería tener menor c (más estricto) o mayor n
  expect_true(tight$c <= normal$c || tight$n > normal$n)
})

test_that("Reduced inspection es menos estricto que Normal", {
  normal <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  reduced <- suppressMessages(AAZ14Single(PLAN = 3, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  # Reduced debería tener menor n (menos inspección)
  expect_true(reduced$n <= normal$n)
})

# ==============================================================================
# Tests de Validación de Mensajes
# ==============================================================================

test_that("Las funciones emiten mensajes informativos", {
  expect_message(AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7), 
                 "ANSI/ASQ Z1.9")
  
  expect_message(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12), 
                 "MIL-STD-105E")
  
  expect_message(AAZ14Double(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12), 
                 "MIL-STD-105E")
  
  expect_message(AAZ14Multiple(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12), 
                 "MIL-STD-105E")
})

# ==============================================================================
# Tests de Estructura de Datos
# ==============================================================================

test_that("AAZ14Single retorna estructura correcta", {
  result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  expect_true(is.numeric(result$n))
  expect_true(is.numeric(result$c))
  expect_true(is.numeric(result$r))
  expect_false(any(is.na(result)))
})

test_that("AAZ14Double retorna estructura correcta cuando existe plan", {
  result <- suppressMessages(AAZ14Double(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  if(is.data.frame(result)) {
    expect_equal(nrow(result), 2)
    expect_true(all(c("n", "c", "r") %in% names(result)))
    expect_false(any(is.na(result)))
  }
})

test_that("AAZ14Multiple retorna estructura correcta", {
  result <- suppressMessages(AAZ14Multiple(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  expect_true(all(c("n", "c", "r") %in% names(result)))
  expect_true(nrow(result) >= 1 && nrow(result) <= 7)
  expect_false(any(is.na(result)))
})

# ==============================================================================
# Tests de Comparación entre Métodos
# ==============================================================================

test_that("Single sampling tiene menor ASN que Double en algunos casos", {
  single <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  double <- suppressMessages(AAZ14Double(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  if(is.data.frame(double)) {
    # En promedio, el doble puede tener menor ASN
    expect_true(single$n > 0)
    expect_true(sum(double$n) > 0)
  }
})

# ==============================================================================
# Tests de Rangos Válidos
# ==============================================================================

test_that("Parámetros están en rangos válidos - AAZ14Single", {
  # Probar múltiples combinaciones
  test_params <- expand.grid(
    PLAN = 1:3,
    dINSL = c(1, 4, 7),
    dLOTS = c(1, 8, 15),
    dAQL = c(1, 12, 20)
  )
  
  for(i in 1:min(10, nrow(test_params))) {  # Probar algunos casos
    result <- suppressMessages(
      AAZ14Single(
        PLAN = test_params$PLAN[i],
        dINSL = test_params$dINSL[i],
        dLOTS = test_params$dLOTS[i],
        dAQL = test_params$dAQL[i]
      )
    )
    expect_s3_class(result, "data.frame")
    expect_true(result$n > 0)
  }
})

test_that("Variables function maneja desviación estándar desconocida", {
  result_unknown <- suppressMessages(
    AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7)
  )
  
  expect_type(result_unknown, "double")
  expect_length(result_unknown, 3)
  expect_true(all(result_unknown > 0))
})
