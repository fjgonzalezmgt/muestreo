# Tests para la lógica del servidor de la aplicación Shiny

library(testthat)
library(shiny)
library(AcceptanceSampling)

# Las funciones y la app se cargan automáticamente via helper-load_app.R

test_that("Server function existe", {
  skip_if_not(exists("server"), "server.R no cargado correctamente")
  
  expect_true(is.function(server))
  expect_equal(length(formals(server)), 3)  # input, output, session
})

# ==============================================================================
# Tests de Funciones Auxiliares
# ==============================================================================

test_that("Función lookup_id existe y funciona correctamente", {
  skip_if_not(exists("lookup_id"), "global.R no cargado correctamente")
  
  # Verificar que la función existe
  expect_true(is.function(lookup_id))
  
  # Probar con type_df
  expect_equal(lookup_id(type_df, "Normal"), 1)
  expect_equal(lookup_id(type_df, "Tightened"), 2)
  expect_equal(lookup_id(type_df, "Reduced"), 3)
  
  # Probar con choice_plans
  expect_equal(lookup_id(choice_plans, "Single"), 1)
  expect_equal(lookup_id(choice_plans, "Double"), 2)
  expect_equal(lookup_id(choice_plans, "Multiple"), 3)
})

test_that("Funciones de aql_functions.R están disponibles", {
  # Verificar que las funciones AAZ14* están disponibles del paquete AcceptanceSampling
  expect_true(exists("AAZ14Single"))
  expect_true(exists("AAZ14Double"))
  expect_true(exists("AAZ14Multiple"))
  expect_true(exists("AAZ19"))
})

# ==============================================================================
# Tests de Validación de Inputs
# ==============================================================================

test_that("Combinaciones de parámetros producen resultados válidos", {
  skip_if_not(exists("type_df"), "Catálogos no cargados")
  
  # Simular inputs para variables
  test_inputs <- list(
    var_type = "Normal",
    var_level = "II",
    var_lot_size = "3,201-10,000",
    var_aql = "1.5"
  )
  
  # Obtener IDs
  type_id <- type_df$id[match(test_inputs$var_type, type_df$name)]
  level_id <- level_var_df$id[match(test_inputs$var_level, level_var_df$name)]
  lot_id <- lot_var_df$id[match(test_inputs$var_lot_size, lot_var_df$name)]
  aql_id <- aql_var_df$id[match(test_inputs$var_aql, aql_var_df$name)]
  
  expect_false(is.na(type_id))
  expect_false(is.na(level_id))
  expect_false(is.na(lot_id))
  expect_false(is.na(aql_id))
  
  # Calcular plan
  plan <- suppressMessages(AAZ19(type = type_id, stype = "unknown", 
                                 dINSL = level_id, dLOTS = lot_id, dAQL = aql_id))
  expect_type(plan, "double")
  expect_length(plan, 3)
})

test_that("Inputs de atributos producen planes válidos", {
  skip_if_not(exists("choice_plans"), "Catálogos no cargados")
  
  test_inputs <- list(
    attr_plan = "Single",
    attr_type = "Normal",
    attr_level = "II",
    attr_lot_size = "3,201-10,000",
    attr_aql = "1.5"
  )
  
  idPlan <- lookup_id(choice_plans, test_inputs$attr_plan)
  idType <- lookup_id(type_df, test_inputs$attr_type)
  idLevel <- lookup_id(choice_levels, test_inputs$attr_level)
  idLot <- lookup_id(choice_lots, test_inputs$attr_lot_size)
  idAql <- lookup_id(choice_aql, test_inputs$attr_aql)
  
  expect_equal(idPlan, 1)
  expect_equal(idType, 1)
  
  plan <- suppressMessages(AAZ14Single(PLAN = idType, dINSL = idLevel, 
                                       dLOTS = idLot, dAQL = idAql))
  expect_s3_class(plan, "data.frame")
})

# ==============================================================================
# Tests de Conversión de Datos
# ==============================================================================

test_that("Conversión de plan a data.frame para display", {
  plan <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  # Verificar que se puede convertir a formato de tabla
  df_display <- as.data.frame(plan)
  expect_s3_class(df_display, "data.frame")
  expect_true(all(c("n", "c", "r") %in% names(df_display)))
})

test_that("Conversión de resultados de variables a data.frame", {
  plan <- suppressMessages(AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7))
  
  # Convertir a data.frame para mostrar
  df_display <- data.frame(Parametro = names(plan), Valor = unname(plan))
  expect_s3_class(df_display, "data.frame")
  expect_equal(nrow(df_display), 3)
  expect_equal(df_display$Parametro, c("n", "k", "M"))
})

# ==============================================================================
# Tests de Descarga de Datos
# ==============================================================================

test_that("Plan puede ser exportado a CSV", {
  plan <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  # Simular exportación
  temp_file <- tempfile(fileext = ".csv")
  write.csv(plan, temp_file, row.names = FALSE)
  
  expect_true(file.exists(temp_file))
  
  # Leer y verificar
  imported <- read.csv(temp_file)
  expect_equal(nrow(imported), 1)
  expect_equal(ncol(imported), 3)
  
  # Limpiar
  unlink(temp_file)
})

test_that("Plan de variables puede ser exportado", {
  plan <- suppressMessages(AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7))
  df <- data.frame(Parametro = names(plan), Valor = unname(plan))
  
  temp_file <- tempfile(fileext = ".csv")
  write.csv(df, temp_file, row.names = FALSE)
  
  expect_true(file.exists(temp_file))
  
  imported <- read.csv(temp_file)
  expect_equal(nrow(imported), 3)
  
  unlink(temp_file)
})

# ==============================================================================
# Tests de Validación de Rangos
# ==============================================================================

test_that("Todas las combinaciones de type producen resultados", {
  skip_if_not(exists("type_df"), "Catálogos no cargados")
  
  for(type_name in type_df$name) {
    type_id <- lookup_id(type_df, type_name)
    result <- suppressMessages(AAZ19(type = type_id, stype = "unknown", 
                                     dINSL = 4, dLOTS = 12, dAQL = 7))
    expect_type(result, "double")
    expect_length(result, 3)
  }
})

test_that("Todos los tipos de plan de atributos funcionan", {
  skip_if_not(exists("choice_plans"), "Catálogos no cargados")
  
  for(plan_name in choice_plans$name) {
    plan_id <- lookup_id(choice_plans, plan_name)
    
    if(plan_name == "Single") {
      result <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
      expect_s3_class(result, "data.frame")
    } else if(plan_name == "Double") {
      result <- suppressMessages(AAZ14Double(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
      expect_true(is.data.frame(result) || is.character(result))
    } else if(plan_name == "Multiple") {
      result <- suppressMessages(AAZ14Multiple(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
      expect_s3_class(result, "data.frame")
    }
  }
})

# ==============================================================================
# Tests de Casos de Error
# ==============================================================================

test_that("Manejo de IDs inválidos", {
  # IDs fuera de rango deberían dar error o resultado inválido
  # PLAN debe ser 1 (Normal), 2 (Tightened), o 3 (Reduced)
  expect_error(AAZ14Single(PLAN = 99, dINSL = 6, dLOTS = 11, dAQL = 12))
})

test_that("Valores NA en lookup_id se manejan correctamente", {
  skip_if_not(exists("lookup_id"), "lookup_id no disponible")
  
  result <- lookup_id(type_df, "NoExiste")
  expect_true(length(result) == 0 || is.na(result))
})

# ==============================================================================
# Tests de Integración con AcceptanceSampling
# ==============================================================================

test_that("Planes generados son compatibles con AcceptanceSampling::OC2c", {
  plan <- suppressMessages(AAZ14Single(PLAN = 1, dINSL = 6, dLOTS = 11, dAQL = 12))
  
  # Crear curva OC para atributos (OC2c)
  pd_seq <- seq(0, 0.1, 0.01)
  oc <- OC2c(n = plan$n, c = plan$c, pd = pd_seq)
  
  expect_true(!is.null(oc))
  expect_s4_class(oc, "OC2c")
})

test_that("Planes de variables son compatibles con AcceptanceSampling::OCvar", {
  plan <- suppressMessages(AAZ19(type = 1, stype = "unknown", dINSL = 4, dLOTS = 12, dAQL = 7))
  
  # Crear curva OC para variables
  pd_seq <- seq(0, 0.08, 0.005)
  oc <- OCvar(n = plan[["n"]], k = plan[["k"]], s.type = "unknown", pd = pd_seq)
  
  expect_true(!is.null(oc))
  expect_s4_class(oc, "OCvar")
})

# ==============================================================================
# Tests de Consistencia de Datos
# ==============================================================================

test_that("Los nombres en catálogos no tienen espacios extra", {
  skip_if_not(exists("type_df"), "global.R no cargado correctamente")
  
  expect_true(all(!grepl("^\\s|\\s$", type_df$name)))
  expect_true(all(!grepl("^\\s|\\s$", choice_plans$name)))
})

test_that("Catálogos no contienen valores duplicados", {
  skip_if_not(exists("type_df"), "global.R no cargado correctamente")
  
  expect_equal(length(unique(type_df$name)), nrow(type_df))
  expect_equal(length(unique(choice_plans$name)), nrow(choice_plans))
  expect_equal(length(unique(level_var_df$name)), nrow(level_var_df))
})
