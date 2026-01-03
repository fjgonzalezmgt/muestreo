#
# Aplicación Shiny unificada para planes de muestreo
# Combina muestreo por variables (Z1.9) y por atributos (Z1.4)
#

# Load packages ----------------------------------------------------------------

library(shiny)
library(bslib)
library(AcceptanceSampling)

source("aql_functions.R")

# Catálogos comunes -----------------------------------------------------------

type_df <- data.frame(
  name = c("Normal", "Tightened", "Reduced"),
  id = c(1, 2, 3),
  stringsAsFactors = FALSE
)

# Catálogos para Variables (Z1.9) ---------------------------------------------

level_var_df <- data.frame(
  name = c("S-3", "S-4", "I", "II", "III"),
  id = c(1, 2, 3, 4, 5),
  stringsAsFactors = FALSE
)

lot_var_df <- data.frame(
  name = c("2-8", "9-15", "16-25", "26-50", "51-90", "91-150", "151-280", "281-400",
           "401-500", "501-1,200", "1,201-3,200", "3,201-10,000", "10,001-35,000", "35,001-150,000",
           "150,001-500,000", "500,001 and over"),
  id = 1:16,
  stringsAsFactors = FALSE
)

aql_var_df <- data.frame(
  name = c("0.10", "0.15", "0.25", "0.40", "0.65", "1.0", "1.5", "2.5", "4.0", "6.5", "10"),
  id = 1:11,
  stringsAsFactors = FALSE
)

# Catálogos para Atributos (Z1.4) ---------------------------------------------

choice_plans <- data.frame(
  name = c("Single", "Double", "Multiple"),
  id = c(1, 2, 3)
)

choice_levels <- data.frame(
  name = c("S-1", "S-2", "S-3", "S-4", "I", "II", "III"),
  id = c(1, 2, 3, 4, 5, 6, 7)
)

choice_lots <- data.frame(
  name = c(
    "2-8", "9-15", "16-25", "26-50", "51-90", "91-150",
    "151-280", "281-500", "501-1,200", "1,201-3,200", "3,201-10,000",
    "10,001-35,000", "35,001-150,000", "150,001-500,000",
    "500,001 and over"
  ),
  id = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
)

choice_aql <- data.frame(
  name = c(
    "0.010", "0.015", "0.025", "0.040", "0.065", "0.10", "0.15",
    "0.25", "0.40", "0.65", "1.0", "1.5", "2.5", "4.0", "6.5",
    "10", "15", "25", "40", "65", "100", "150", "250", "400",
    "650", "1000"
  ),
  id = seq_len(26)
)

lookup_id <- function(df, value) {
  df[df$name == value, "id", drop = TRUE]
}

# Define UI --------------------------------------------------------------------

ui <- page_navbar(
  title = "Sampling Plan Calculator",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#0c5f7e",
    secondary = "#1b9aaa",
    base_font = font_google("Inter"),
    heading_font = font_google("Inter Tight")
  ),
  tags$head(
    tags$style(
      HTML("
        body { background-color: #f3f6fb; }
        .app-card { background: #fff; border-radius: 16px; padding: 18px 20px; box-shadow: 0 10px 24px rgba(0,0,0,0.05); margin-bottom: 20px; }
        .app-card h4 { margin-top: 4px; margin-bottom: 14px; font-weight: 700; color: #0c5f7e; }
        .input-title { font-weight: 600; margin-bottom: 6px; color: #4a5568; }
        .helper-text { color: #6b778c; font-size: 13px; }
        .parameter-card { min-height: 460px; }
      ")
    )
  ),
  
  # Panel 1: Variables (Z1.9) -------------------------------------------------
  nav_panel(
    title = "Variables (Z1.9)",
    layout_columns(
      col_widths = c(4, 8),
      card(
        card_header("Parámetros - Muestreo por variables"),
        selectInput("var_type", "Tipo de muestreo", choices = type_df$name, selected = "Normal"),
        selectInput("var_level", "Nivel de inspección", choices = level_var_df$name, selected = "II"),
        selectInput("var_lot_size", "Tamaño de lote", choices = lot_var_df$name, selected = "3,201-10,000"),
        selectInput("var_aql", "AQL (% no conformes / 100)", choices = aql_var_df$name, selected = "1.5"),
        p("Valores según ANSI/ASQ Z1.9.", class = "helper-text mb-2"),
        downloadButton("download_var_plan", "Descargar plan (CSV)")
      ),
      navset_card_tab(
        nav_panel(
          "Plan",
          h4("Plan de muestreo por variables"),
          tableOutput("var_planSummary"),
          verbatimTextOutput("var_samplingOut")
        ),
        nav_panel(
          "Curvas",
          plotOutput("var_samplingPlot", height = 400)
        )
      )
    )
  ),
  
  # Panel 2: Atributos (Z1.4) -------------------------------------------------
  nav_panel(
    title = "Atributos (Z1.4)",
    layout_columns(
      col_widths = c(4, 8),
      card(
        card_header("Parámetros - Muestreo por atributos"),
        selectInput("attr_plan", "Plan de muestreo", choices = choice_plans$name, selected = "Single"),
        selectInput("attr_type", "Tipo de muestreo", choices = type_df$name, selected = "Normal"),
        selectInput("attr_level", "Nivel de inspección", choices = choice_levels$name, selected = "II"),
        selectInput("attr_lot_size", "Tamaño de lote", choices = choice_lots$name, selected = "3,201-10,000"),
        selectInput("attr_aql", "AQL (% no conformes / 100)", choices = choice_aql$name, selected = "1.5"),
        div(class = "helper-text mt-2", "Norma ANSI/ASQ Z1.4: muestreo por atributos."),
        downloadButton("download_attr_plan", "Descargar plan (CSV)", class = "btn-primary download-btn")
      ),
      navset_card_tab(
        nav_panel(
          "Plan",
          h4("Plan de muestreo por atributos (ANSI/ASQ Z1.4)"),
          tableOutput("attr_plan_table"),
          verbatimTextOutput("attr_plan_text")
        ),
        nav_panel(
          "Curvas",
          plotOutput("attr_samplingPlot", height = 420)
        )
      )
    )
  )
)

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
  
  var_plan_attr <- reactive({
    id_vals <- var_ids()
    validate(need(!any(is.na(unlist(id_vals))), "Seleccione valores válidos"))
    tryCatch(
      AAZ14Single(PLAN = id_vals$type, dINSL = id_vals$level, dLOTS = id_vals$lot, dAQL = id_vals$aql),
      error = function(e) {
        showNotification("No se pudo calcular el plan de atributos", type = "error")
        NULL
      }
    )
  })
  
  var_plan_var <- reactive({
    id_vals <- var_ids()
    validate(need(!any(is.na(unlist(id_vals))), "Seleccione valores válidos"))
    tryCatch(
      AAZ19(type = id_vals$type, dINSL = id_vals$level, dLOTS = id_vals$lot, dAQL = id_vals$aql),
      error = function(e) {
        showNotification("No se pudo calcular el plan por variables", type = "error")
        NULL
      }
    )
  })
  
  output$var_planSummary <- renderTable({
    plan <- var_plan_var()
    validate(need(!is.null(plan), ""))
    data.frame(Parametro = names(plan), Valor = unname(plan), row.names = NULL)
  }, striped = TRUE, bordered = TRUE, digits = 0)
  
  output$var_samplingOut <- renderPrint({
    plan <- var_plan_var()
    validate(need(!is.null(plan), ""))
    writeLines("Sample size (n), Acceptability constant (k) and maximum proportion nonconforming (M)")
    print(plan)
  })
  
  output$download_var_plan <- downloadHandler(
    filename = function() "sampling_plan_variables.csv",
    content = function(file) {
      plan <- var_plan_var()
      validate(need(!is.null(plan), ""))
      df <- data.frame(Parametro = names(plan), Valor = unname(plan), row.names = NULL)
      write.csv(df, file, row.names = FALSE)
    }
  )
  
  output$var_samplingPlot <- renderPlot({
    plans <- var_plan_attr()
    planv <- var_plan_var()
    validate(need(!is.null(plans), ""), need(!is.null(planv), ""))
    Pnc <- seq(0, 0.08, 0.005)
    V <- OCvar(planv[[1]], planv[[2]], s.type = "unknown", pd = Pnc)
    OCV <- V@paccept
    OCASNS <- OCASNZ4S(plans, Pnc)
    ASNV <- rep(as.numeric(planv[[1]]), length(OCASNS$pd))
    par(mfcol = c(1, 2))
    plot(OCASNS$pd, OCV, type = "l", xlab = "Proportion Nonconforming", ylab = "OC Curves",
         main = "OC - ASN Curves", lty = 1)
    plot(OCASNS$pd, ASNV, type = "l", lty = 1, xlab = "Proportion Nonconforming",
         ylab = "ASN Curves", ylim = c(min(ASNV) * 0.9, max(ASNV) * 1.1))
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
  
  output$attr_plan_table <- renderTable(
    attr_plan_data(),
    striped = TRUE,
    bordered = FALSE,
    hover = TRUE,
    spacing = "s",
    digits = 0
  )
  
  output$attr_plan_text <- renderPrint({
    df <- attr_plan_data()
    writeLines("Sample size (n), Acceptance number (c), Rejection number (r)")
    print(df)
  })
  
  output$download_attr_plan <- downloadHandler(
    filename = function() {
      paste0("plan_atributos_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(attr_plan_data(), file, row.names = FALSE)
    }
  )
  
  output$attr_samplingPlot <- renderPlot({
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
      plot.new()
      text(0.5, 0.5, samplePlan, cex = 1.2)
      return()
    }
    
    par(mfcol = c(1, 2))
    plans <- samplePlan
    Pnc <- seq(0, .08, .005)
    
    OCASNS <- switch(idPlan,
                     `1` = OCASNZ4S(plans, Pnc),
                     `2` = OCASNZ4D(plans, Pnc),
                     `3` = OCASNZ4M(plans, Pnc)
    )
    
    plot(OCASNS$pd, OCASNS$OC, type = "l", xlab = "Proportion Nonconforming", ylab = "OC Curves",
         main = "OC - ASN Curves", lty = 1)
    plot(OCASNS$pd, OCASNS$ASN, type = "l", lty = 1, xlab = "Proportion Nonconforming",
         ylab = "ASN Curves", ylim = c(50, 200))
  }, height = 420, width = 780)
}

# Create a Shiny app object ----------------------------------------------------

shinyApp(ui = ui, server = server)
