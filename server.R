#
# Server para aplicación Shiny unificada para planes de muestreo
# Combina muestreo por variables (Z1.9) y por atributos (Z1.4)
#

# Load packages ----------------------------------------------------------------

library(shiny)
library(AcceptanceSampling)

source("aql_functions.R")

# Define server ----------------------------------------------------------------

server <- function(input, output, session) {
  
  # ===========================================================================
  # SERVER LOGIC: VARIABLES (Z1.9)
  # ===========================================================================
  
  var_ids <- reactive({
    list(
      type = type_df$id[match(input$var_type, type_df$name)],
      level = level_var_df$id[match(input$var_level, level_var_df$name)],
      lot = lot_var_df$id[match(input$var_lot_size, lot_var_df$name)],
      aql = aql_var_df$id[match(input$var_aql, aql_var_df$name)]
    )
  })
  
  var_plan_var <- reactive({
    id_vals <- var_ids()
    validate(need(!any(is.na(unlist(id_vals))), "Seleccione valores válidos"))
    tryCatch(
      AAZ19(
        type = id_vals$type, 
        stype = "unknown",  # Desviación estándar desconocida (método estándar)
        dINSL = id_vals$level, 
        dLOTS = id_vals$lot, 
        dAQL = id_vals$aql
      ),
      error = function(e) {
        showNotification(paste("Error al calcular plan por variables:", e$message), type = "error")
        NULL
      }
    )
  })
  
  output$var_planSummary <- renderTable({
    plan <- var_plan_var()
    validate(need(!is.null(plan), ""))
    df <- data.frame(Parametro = names(plan), Valor = as.character(unname(plan)), stringsAsFactors = FALSE, row.names = NULL)
    # Formatear n sin decimales
    if ("n" %in% df$Parametro) {
      n_val <- as.numeric(plan[["n"]])
      df$Valor[df$Parametro == "n"] <- as.character(round(n_val, 0))
    }
    # Formatear k y M con 5 decimales
    for (param in c("k", "M")) {
      if (param %in% df$Parametro) {
        param_val <- as.numeric(plan[[param]])
        df$Valor[df$Parametro == param] <- format(round(param_val, 5), nsmall = 5)
      }
    }
    df
  }, striped = TRUE, bordered = TRUE)
  

  
  output$download_var_plan <- downloadHandler(
    filename = function() "sampling_plan_variables.csv",
    content = function(file) {
      plan <- var_plan_var()
      validate(need(!is.null(plan), ""))
      
      # Crear dataframe con parámetros de entrada
      params_df <- data.frame(
        Seccion = c("PARAMETROS_ENTRADA", "", "", "", ""),
        Parametro = c("Norma", "Tipo_Muestreo", "Nivel_Inspeccion", "Tamaño_Lote", "AQL"),
        Valor = c("ANSI/ASQ Z1.9", input$var_type, input$var_level, input$var_lot_size, input$var_aql),
        stringsAsFactors = FALSE
      )
      
      # Crear dataframe con resultados del plan
      plan_df <- data.frame(
        Seccion = c("", rep("RESULTADOS_PLAN", length(plan))),
        Parametro = c("", names(plan)),
        Valor = c("", unname(plan)),
        stringsAsFactors = FALSE
      )
      
      # Combinar ambos dataframes
      final_df <- rbind(params_df, plan_df)
      write.csv(final_df, file, row.names = FALSE, fileEncoding = "UTF-8")
      
      # Agregar BOM para compatibilidad con Excel
      con <- file(file, open = "r+b")
      content <- readBin(con, "raw", n = file.info(file)$size)
      close(con)
      con <- file(file, open = "wb")
      writeBin(as.raw(c(0xef, 0xbb, 0xbf)), con)
      writeBin(content, con)
      close(con)
    }
  )
  
  var_oc_data <- reactive({
    planv <- var_plan_var()
    validate(need(!is.null(planv), "No hay datos del plan"))
    
    # Definir rango de proporciones no conformes
    Pnc <- seq(0, 0.08, 0.005)
    
    # Calcular curva OC para muestreo por variables usando AcceptanceSampling
    V <- OCvar(n = planv[[1]], k = planv[[2]], s.type = "unknown", pd = Pnc)
    OCV <- V@paccept
    
    # Para muestreo por variables, ASN siempre es n (tamaño de muestra constante)
    n_val <- as.numeric(planv[[1]])
    ASNV <- rep(n_val, length(Pnc))
    
    list(Pnc = Pnc, OCV = OCV, ASNV = ASNV, n_val = n_val)
  })
  
  output$var_oc_plot <- renderPlot({
    data <- var_oc_data()
    
    plot(data$Pnc, data$OCV, type = "l", lwd = 2, col = "#0c5f7e",
         xlab = "Proporción no conforme", 
         ylab = "Probabilidad de aceptación",
         main = "Curva OC", 
         ylim = c(0, 1))
    grid()
  })
  
  output$var_asn_plot <- renderPlot({
    data <- var_oc_data()
    
    ylim_range <- c(max(1, data$n_val * 0.8), data$n_val * 1.2)
    plot(data$Pnc, data$ASNV, type = "l", lwd = 2, col = "#1b9aaa",
         xlab = "Proporción no conforme",
         ylab = "Tamaño promedio de muestra",
         main = "Curva ASN",
         ylim = ylim_range)
    abline(h = data$n_val, lty = 2, col = "gray50")
    text(0.04, data$n_val * 1.1, paste0("n = ", data$n_val), col = "gray30")
    grid()
  })
  
  # ===========================================================================
  # SERVER LOGIC: ATRIBUTOS (Z1.4)
  # ===========================================================================
  
  attr_plan_data <- reactive({
    idPlan <- lookup_id(choice_plans, input$attr_plan)
    idType <- lookup_id(type_df, input$attr_type)
    idLevel <- lookup_id(choice_levels, input$attr_level)
    idLot <- lookup_id(choice_lots, input$attr_lot_size)
    idAql <- lookup_id(choice_aql, input$attr_aql)
    
    samplePlan <- switch(idPlan,
                         `1` = AAZ14Single(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql),
                         `2` = AAZ14Double(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql),
                         `3` = AAZ14Multiple(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql)
    )
    
    if (is.character(samplePlan)) {
      return(data.frame(Mensaje = samplePlan, stringsAsFactors = FALSE))
    }
    
    samplePlan
  })
  
  output$attr_plan_table <- renderTable({
    df <- attr_plan_data()
    if ("n" %in% names(df)) {
      df$n <- as.integer(round(df$n, 0))
    }
    df
  },
    striped = TRUE,
    bordered = FALSE,
    hover = TRUE,
    spacing = "s",
    digits = 0,
    rownames = TRUE
  )
  

  
  output$download_attr_plan <- downloadHandler(
    filename = function() {
      paste0("plan_atributos_", Sys.Date(), ".csv")
    },
    content = function(file) {
      plan_data <- attr_plan_data()
      
      # Crear dataframe con parámetros de entrada
      params_df <- data.frame(
        Seccion = c("PARAMETROS_ENTRADA", "", "", "", "", ""),
        Parametro = c("Norma", "Plan_Muestreo", "Tipo_Muestreo", "Nivel_Inspeccion", "Tamaño_Lote", "AQL"),
        Valor = c("ANSI/ASQ Z1.4", input$attr_plan, input$attr_type, input$attr_level, input$attr_lot_size, input$attr_aql),
        stringsAsFactors = FALSE
      )
      
      # Crear dataframe con resultados del plan
      if ("Mensaje" %in% names(plan_data)) {
        # Si hay un mensaje de error, incluirlo
        plan_df <- data.frame(
          Seccion = "RESULTADOS_PLAN",
          Parametro = "Mensaje",
          Valor = plan_data$Mensaje,
          stringsAsFactors = FALSE
        )
      } else {
        # Manejar planes con múltiples filas (Double, Multiple)
        n_rows <- nrow(plan_data)
        plan_names <- names(plan_data)
        
        # Crear lista para almacenar todas las filas
        plan_rows <- list()
        plan_rows[[1]] <- data.frame(Seccion = "", Parametro = "", Valor = "", stringsAsFactors = FALSE)
        
        for (i in 1:n_rows) {
          # Agregar separador de muestra si hay múltiples filas
          if (n_rows > 1) {
            plan_rows[[length(plan_rows) + 1]] <- data.frame(
              Seccion = "RESULTADOS_PLAN",
              Parametro = paste0("=== Muestra_", i, " ==="),
              Valor = "",
              stringsAsFactors = FALSE
            )
          }
          
          # Agregar cada parámetro de la fila actual
          for (j in seq_along(plan_names)) {
            plan_rows[[length(plan_rows) + 1]] <- data.frame(
              Seccion = "RESULTADOS_PLAN",
              Parametro = plan_names[j],
              Valor = as.character(plan_data[i, j]),
              stringsAsFactors = FALSE
            )
          }
        }
        
        plan_df <- do.call(rbind, plan_rows)
      }
      
      # Combinar ambos dataframes
      final_df <- rbind(params_df, plan_df)
      write.csv(final_df, file, row.names = FALSE, fileEncoding = "UTF-8")
      
      # Agregar BOM para compatibilidad con Excel
      con <- file(file, open = "r+b")
      content <- readBin(con, "raw", n = file.info(file)$size)
      close(con)
      con <- file(file, open = "wb")
      writeBin(as.raw(c(0xef, 0xbb, 0xbf)), con)
      writeBin(content, con)
      close(con)
    }
  )
  
  attr_curves_data <- reactive({
    idPlan <- lookup_id(choice_plans, input$attr_plan)
    idType <- lookup_id(type_df, input$attr_type)
    idLevel <- lookup_id(choice_levels, input$attr_level)
    idLot <- lookup_id(choice_lots, input$attr_lot_size)
    idAql <- lookup_id(choice_aql, input$attr_aql)
    
    samplePlan <- switch(idPlan,
                         `1` = AAZ14Single(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql),
                         `2` = AAZ14Double(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql),
                         `3` = AAZ14Multiple(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql)
    )
    
    if (is.character(samplePlan)) {
      return(list(error = samplePlan))
    }
    
    Pnc <- seq(0, .08, .005)
    
    OCASNS <- switch(idPlan,
                     `1` = OCASNZ4S(samplePlan, Pnc),
                     `2` = OCASNZ4D(samplePlan, Pnc),
                     `3` = OCASNZ4M(samplePlan, Pnc)
    )
    
    list(OCASNS = OCASNS, error = NULL)
  })
  
  output$attr_oc_plot <- renderPlot({
    data <- attr_curves_data()
    
    if (!is.null(data$error)) {
      plot.new()
      text(0.5, 0.5, data$error, cex = 1.2)
      return()
    }
    
    plot(data$OCASNS$pd, data$OCASNS$OC, type = "l", lwd = 2, col = "#0c5f7e",
         xlab = "Proporción no conforme", 
         ylab = "Probabilidad de aceptación",
         main = "Curva OC", 
         ylim = c(0, 1))
    grid()
  })
  
  output$attr_asn_plot <- renderPlot({
    data <- attr_curves_data()
    
    if (!is.null(data$error)) {
      plot.new()
      text(0.5, 0.5, data$error, cex = 1.2)
      return()
    }
    
    asn_range <- range(data$OCASNS$ASN, na.rm = TRUE)
    ylim_asn <- c(max(1, asn_range[1] * 0.8), asn_range[2] * 1.2)
    plot(data$OCASNS$pd, data$OCASNS$ASN, type = "l", lwd = 2, col = "#1b9aaa",
         xlab = "Proporción no conforme",
         ylab = "Tamaño promedio de muestra",
         main = "Curva ASN",
         ylim = ylim_asn)
    grid()
  })
}
