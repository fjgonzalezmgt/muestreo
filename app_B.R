#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Load packages ----------------------------------------------------------------

library(shiny)
library(bslib)
# library(AQLSchemesCust)  # Replaced with sourced functions
library(AcceptanceSampling)

# Source AQL functions directly
source("aql_functions.R")

# Catálogos ---------------------------------------------------------------

choice_types <- data.frame(
  name = c("Normal", "Tightened", "Reduced"),
  id = c(1, 2, 3)
)

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


# Load data --------------------------------------------------------------------



# Define UI --------------------------------------------------------------------

ui <- fluidPage(
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
      HTML("\n        body { background-color: #eef2f7; }
        .app-shell { padding: 28px 0 44px; }
        .app-card { background: #fff; border-radius: 18px; padding: 20px 22px; box-shadow: 0 10px 24px rgba(12,95,126,0.08); }
        .app-card h4 { margin-top: 4px; margin-bottom: 14px; font-weight: 700; color: #0c5f7e; }
        .app-title { font-weight: 700; font-size: 20px; color: #0f3a4c; }
        .app-label { font-weight: 600; color: #1f2937; }
        .helper-text { color: #6b7280; font-size: 13px; }
        .parameter-card { min-height: 460px; }
        .plan-table th { background: #f8fafc; font-weight: 700; color: #0f3a4c; }
        .plan-table td { color: #111827; font-weight: 600; }
        .tab-pane { padding-top: 6px; }
        .download-btn { margin-top: 16px; }
      ")
    )
  ),
  div(
    class = "container-fluid app-shell",
    fluidRow(
      column(
        width = 4,
        div(
          class = "app-card parameter-card",
          h4("Parámetros"),
          selectInput(
            inputId = "plan",
            label = "Plan de muestreo",
            choices = choice_plans$name,
            selected = "Single"
          ),
          selectInput(
            inputId = "type",
            label = "Tipo de muestreo",
            choices = choice_types$name,
            selected = "Normal"
          ),
          selectInput(
            inputId = "level",
            label = "Nivel de inspección",
            choices = choice_levels$name,
            selected = "II"
          ),
          selectInput(
            inputId = "lot_size",
            label = "Tamaño de lote",
            choices = choice_lots$name,
            selected = "3,201-10,000"
          ),
          selectInput(
            inputId = "aql",
            label = "AQL (% no conformes / 100)",
            choices = choice_aql$name,
            selected = "1.5"
          ),
          div(class = "helper-text mt-2", "Norma ANSI/ASQ Z1.4: muestreo por atributos (no por variables)."),
          downloadButton("download_plan", "Descargar plan (CSV)", class = "btn-primary download-btn")
        )
      ),
      column(
        width = 8,
        div(
          class = "app-card",
          tabsetPanel(
            type = "tabs",
            tabPanel(
              title = "Plan",
              h4("Plan de muestreo por atributos (ANSI/ASQ Z1.4)"),
              tableOutput("plan_table"),
              verbatimTextOutput("plan_text")
            ),
            tabPanel(
              title = "Curvas",
              plotOutput(outputId = "samplingPlot", height = "420px")
            )
          )
        )
      )
    )
  )
)

# Define server ----------------------------------------------------------------

server <- function(input, output, session) {

  plan_data <- reactive({
    idPlan <- lookup_id(choice_plans, input$plan)
    idType <- lookup_id(choice_types, input$type)
    idLevel <- lookup_id(choice_levels, input$level)
    idLot <- lookup_id(choice_lots, input$lot_size)
    idAql <- lookup_id(choice_aql, input$aql)

    samplePlan <- switch(idPlan,
      `1` = AAZ14Single(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql),
      `2` = AAZ14Double(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql),
      `3` = AAZ14Multiple(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql)
    )

    # Verificar si es un mensaje de error (caracter) en lugar de data frame
    if (is.character(samplePlan)) {
      return(data.frame(
        Mensaje = samplePlan,
        stringsAsFactors = FALSE
      ))
    }
    
    # Para planes simples, dobles y múltiples (todos son data frames)
    samplePlan
  })

  output$plan_table <- renderTable(
    plan_data(),
    striped = TRUE,
    bordered = FALSE,
    hover = TRUE,
    spacing = "s",
    class = "plan-table",
    digits = 5
  )

  output$plan_text <- renderPrint({
    df <- plan_data()
    writeLines("Sample size (n), Acceptability constant (k) and maximum proportion nonconforming (M)")
    print(df)
  })

  output$download_plan <- downloadHandler(
    filename = function() {
      paste0("plan_variables_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(plan_data(), file, row.names = FALSE)
    }
  )

  output$samplingPlot <- renderPlot({
    idPlan <- lookup_id(choice_plans, input$plan)
    idType <- lookup_id(choice_types, input$type)
    idLevel <- lookup_id(choice_levels, input$level)
    idLot <- lookup_id(choice_lots, input$lot_size)
    idAql <- lookup_id(choice_aql, input$aql)

    samplePlan <- switch(idPlan,
      `1` = AAZ14Single(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql),
      `2` = AAZ14Double(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql),
      `3` = AAZ14Multiple(PLAN = idType, dINSL = idLevel, dLOTS = idLot, dAQL = idAql)
    )
    
    # Si es un mensaje de error, mostrar mensaje en lugar de gr\u00e1fica
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