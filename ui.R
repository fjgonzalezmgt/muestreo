#
# UI para aplicación Shiny unificada para planes de muestreo
# Combina muestreo por variables (Z1.9) y por atributos (Z1.4)
#

# Load packages ----------------------------------------------------------------

library(shiny)
library(bslib)

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
          div(
            class = "helper-text mt-3",
            tags$strong("Significado de los parámetros:"),
            tags$ul(
              tags$li(tags$strong("n:"), " Tamaño de muestra"),
              tags$li(tags$strong("k:"), " Constante de aceptabilidad"),
              tags$li(tags$strong("M:"), " Máxima proporción no conforme permitida")
            )
          )
        ),
        nav_panel(
          "Curvas",
          layout_columns(
            col_widths = c(12, 12, 12, 12, 12, 6, 6),
            plotOutput("var_oc_plot", height = 400),
            plotOutput("var_asn_plot", height = 400)
          )
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
          div(
            class = "helper-text mt-3",
            tags$strong("Significado de los parámetros:"),
            tags$ul(
              tags$li(tags$strong("n:"), " Tamaño de muestra"),
              tags$li(tags$strong("c:"), " Número de aceptación (defectos permitidos para aceptar)"),
              tags$li(tags$strong("r:"), " Número de rechazo (defectos que causan rechazo del lote)")
            )
          )
        ),
        nav_panel(
          "Curvas",
          layout_columns(
            col_widths = c(12, 12, 12, 12, 12, 6, 6),
            plotOutput("attr_oc_plot", height = 420),
            plotOutput("attr_asn_plot", height = 420)
          )
        )
      )
    )
  )
)
