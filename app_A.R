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
library(AcceptanceSampling)

source("aql_functions.R")


# Load data --------------------------------------------------------------------



type_df <- data.frame(name = c("Normal", "Tightened", "Reduced"), id = c(1, 2, 3), stringsAsFactors = FALSE)
level_df <- data.frame(name = c("S-3", "S-4", "I", "II", "III"), id = c(1, 2, 3, 4, 5), stringsAsFactors = FALSE)
lot_df <- data.frame(
  name = c("2-8", "9-15", "16-25", "26-50", "51-90", "91-150", "151-280", "281-400",
           "401-500", "501-1,200", "1,201-3,200", "3,201-10,000", "10,001-35,000", "35,001-150,000",
           "150,001-500,000", "500,001 and over"),
  id = 1:16,
  stringsAsFactors = FALSE
)
aql_df <- data.frame(
  name = c("0.10", "0.15", "0.25", "0.40", "0.65", "1.0", "1.5", "2.5", "4.0", "6.5", "10"),
  id = 1:11,
  stringsAsFactors = FALSE
)

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
      HTML("\n        body { background-color: #f3f6fb; }\n        .app-shell { padding: 20px 0 40px; }\n        .app-header { background: linear-gradient(90deg, #0c5f7e, #1b9aaa); color: #fff; border-radius: 18px; padding: 20px 24px; box-shadow: 0 12px 24px rgba(12,95,126,0.15); }\n        .app-header h2 { margin: 0 0 6px 0; font-weight: 700; }\n        .app-card { background: #fff; border-radius: 16px; padding: 18px 20px; box-shadow: 0 10px 24px rgba(0,0,0,0.05); }\n        .app-card h4 { margin-top: 4px; margin-bottom: 14px; font-weight: 700; color: #0c5f7e; }\n        .input-title { font-weight: 600; margin-bottom: 6px; color: #4a5568; }\n        .helper-text { color: #6b778c; font-size: 13px; }\n      ")
    )
  ),
  div(
    class = "container-fluid app-shell",
    div(
      class = "app-header mb-4",
      h2("Sampling Plan Calculator"),
      p("MIL-STD-414 / ANSI-ASQ Z1.9 · Variable sampling", class = "mb-0"),
      p("Seleccione los parámetros y visualice las curvas OC y ASN para su plan de muestreo.", class = "mb-0")
    ),
    fluidRow(
      column(
        width = 4,
        div(
          class = "app-card",
          h4("Parámetros"),
          div(class = "input-title", "Tipo de muestreo"),
          selectInput("type", NULL, choices = type_df$name, selected = "Normal"),
          div(class = "input-title mt-2", "Nivel de inspección"),
          selectInput("level", NULL, choices = level_df$name, selected = "II"),
          div(class = "input-title mt-2", "Tamaño de lote"),
          selectInput("lot_size", NULL, choices = lot_df$name, selected = "3,201-10,000"),
          div(class = "input-title mt-2", "AQL (% no conformes / 100)"),
          selectInput("aql", NULL, choices = aql_df$name, selected = "1.5"),
          p("Valores según ANSI/ASQ Z1.9.", class = "helper-text mb-2"),
          downloadButton("download_plan", "Descargar plan (CSV)")
        )
      ),
      column(
        width = 8,
        div(
          class = "app-card",
          tabsetPanel(
            tabPanel(
              "Plan",
              h4("Plan de muestreo por variables"),
              tableOutput("planSummary"),
              verbatimTextOutput("samplingOut")
            ),
            tabPanel(
              "Curvas",
              plotOutput("samplingPlot", height = 400, width = "100%")
            )
          )
        )
      )
    )
  )
)

# Define server ----------------------------------------------------------------

server <- function(input, output, session) {
  ids <- reactive({
    list(
      type = type_df$id[match(input$type, type_df$name)],
      level = level_df$id[match(input$level, level_df$name)],
      lot = lot_df$id[match(input$lot_size, lot_df$name)],
      aql = aql_df$id[match(input$aql, aql_df$name)]
    )
  })
  
  plan_attr <- reactive({
    id_vals <- ids()
    validate(need(!any(is.na(unlist(id_vals))), "Seleccione valores válidos"))
    tryCatch(
      AAZ14Single(PLAN = id_vals$type, dINSL = id_vals$level, dLOTS = id_vals$lot, dAQL = id_vals$aql),
      error = function(e) {
        showNotification("No se pudo calcular el plan de atributos", type = "error")
        NULL
      }
    )
  })
  
  plan_var <- reactive({
    id_vals <- ids()
    validate(need(!any(is.na(unlist(id_vals))), "Seleccione valores válidos"))
    tryCatch(
      AAZ19(type = id_vals$type, dINSL = id_vals$level, dLOTS = id_vals$lot, dAQL = id_vals$aql),
      error = function(e) {
        showNotification("No se pudo calcular el plan por variables", type = "error")
        NULL
      }
    )
  })
  
  output$planSummary <- renderTable({
    plan <- plan_var()
    validate(need(!is.null(plan), ""))
    data.frame(Parametro = names(plan), Valor = unname(plan), row.names = NULL)
  }, striped = TRUE, bordered = TRUE, digits = 5)
  
  output$samplingOut <- renderPrint({
    plan <- plan_var()
    validate(need(!is.null(plan), ""))
    writeLines("Sample size (n), Acceptability constant (k) and maximum proportion nonconforming (M)")
    print(plan)
  })
  
  output$download_plan <- downloadHandler(
    filename = function() "sampling_plan.csv",
    content = function(file) {
      plan <- plan_var()
      validate(need(!is.null(plan), ""))
      df <- data.frame(Parametro = names(plan), Valor = unname(plan), row.names = NULL)
      write.csv(df, file, row.names = FALSE)
    }
  )
  
  output$samplingPlot <- renderPlot({
    plans <- plan_attr()
    planv <- plan_var()
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
}

# Create a Shiny app object ----------------------------------------------------

shinyApp(ui = ui, server = server)