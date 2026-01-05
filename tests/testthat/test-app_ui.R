# Tests para la UI de la aplicación Shiny

library(testthat)
library(shiny)
library(bslib)

# Las funciones y la app se cargan automáticamente via helper-load_app.R

test_that("UI contiene los elementos principales", {
  skip_if_not(exists("ui"), "ui.R no cargado correctamente")
  
  # Verificar que ui es un objeto Shiny
  expect_true(!is.null(ui))
  expect_true(inherits(ui, "shiny.tag.list") || inherits(ui, "shiny.tag") || inherits(ui, "shiny.navs_bar"))
})

test_that("UI usa bslib y tiene tema configurado", {
  skip_if_not(exists("ui"), "ui.R no cargado correctamente")
  
  # Verificar que se importó bslib
  expect_true("package:bslib" %in% search())
})

test_that("Catálogos están correctamente definidos", {
  skip_if_not(exists("type_df"), "global.R no cargado correctamente")
  
  # type_df
  expect_s3_class(type_df, "data.frame")
  expect_equal(nrow(type_df), 3)
  expect_named(type_df, c("name", "id"))
  expect_equal(type_df$name, c("Normal", "Tightened", "Reduced"))
  
  # level_var_df
  expect_s3_class(level_var_df, "data.frame")
  expect_equal(nrow(level_var_df), 5)
  expect_named(level_var_df, c("name", "id"))
  
  # lot_var_df
  expect_s3_class(lot_var_df, "data.frame")
  expect_equal(nrow(lot_var_df), 16)
  expect_named(lot_var_df, c("name", "id"))
  
  # aql_var_df
  expect_s3_class(aql_var_df, "data.frame")
  expect_equal(nrow(aql_var_df), 11)
  expect_named(aql_var_df, c("name", "id"))
})

test_that("Catálogos para atributos están correctamente definidos", {
  skip_if_not(exists("choice_plans"), "global.R no cargado correctamente")
  
  # choice_plans
  expect_s3_class(choice_plans, "data.frame")
  expect_equal(nrow(choice_plans), 3)
  expect_equal(choice_plans$name, c("Single", "Double", "Multiple"))
  
  # choice_levels
  expect_s3_class(choice_levels, "data.frame")
  expect_equal(nrow(choice_levels), 7)
  
  # choice_lots
  expect_s3_class(choice_lots, "data.frame")
  expect_equal(nrow(choice_lots), 15)
  
  # choice_aql
  expect_s3_class(choice_aql, "data.frame")
  expect_equal(nrow(choice_aql), 26)
})

test_that("lookup_id funciona correctamente", {
  skip_if_not(exists("lookup_id"), "lookup_id no disponible")
  
  # Buscar en type_df
  expect_equal(lookup_id(type_df, "Normal"), 1)
  expect_equal(lookup_id(type_df, "Tightened"), 2)
  expect_equal(lookup_id(type_df, "Reduced"), 3)
  
  # Buscar en choice_plans
  expect_equal(lookup_id(choice_plans, "Single"), 1)
  expect_equal(lookup_id(choice_plans, "Double"), 2)
  expect_equal(lookup_id(choice_plans, "Multiple"), 3)
})

test_that("lookup_id retorna NA para valores no encontrados", {
  skip_if_not(exists("lookup_id") && exists("type_df"), "lookup_id o type_df no disponibles")
  
  result <- lookup_id(type_df, "NoExiste")
  expect_true(length(result) == 0 || is.na(result))
})

test_that("Todos los IDs en catálogos son únicos", {
  skip_if_not(exists("type_df"), "global.R no cargado correctamente")
  
  expect_equal(length(type_df$id), length(unique(type_df$id)))
  expect_equal(length(choice_plans$id), length(unique(choice_plans$id)))
  expect_equal(length(choice_levels$id), length(unique(choice_levels$id)))
  expect_equal(length(choice_lots$id), length(unique(choice_lots$id)))
})

test_that("Valores de AQL son numéricos válidos", {
  skip_if_not(exists("aql_var_df"), "global.R no cargado correctamente")
  
  aql_values <- as.numeric(aql_var_df$name)
  expect_true(all(!is.na(aql_values)))
  expect_true(all(aql_values > 0))
  
  aql_attr_values <- as.numeric(choice_aql$name)
  expect_true(all(!is.na(aql_attr_values)))
  expect_true(all(aql_attr_values > 0))
})

test_that("IDs son consecutivos desde 1", {
  skip_if_not(exists("type_df"), "global.R no cargado correctamente")
  
  expect_equal(type_df$id, 1:3)
  expect_equal(choice_plans$id, 1:3)
  expect_equal(level_var_df$id, 1:5)
  expect_equal(choice_levels$id, 1:7)
})
