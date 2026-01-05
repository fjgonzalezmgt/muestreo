#' Interfaz de Usuario para Calculadora de Planes de Muestreo
#'
#' @description
#' Interfaz de usuario unificada de aplicación Shiny para planes de muestreo.
#' Combina muestreo por variables (ANSI/ASQ Z1.9) y muestreo por atributos (ANSI/ASQ Z1.4).
#'
#' @details
#' La UI consta de dos paneles principales:
#' \describe{
#'   \item{Variables (Z1.9)}{Panel de muestreo por variables con parámetros para tipo de muestra,
#'   nivel de inspección, tamaño de lote y AQL. Muestra resumen del plan de muestreo y curvas OC/ASN.}
#'   \item{Atributos (Z1.4)}{Panel de muestreo por atributos con parámetros para plan de muestreo,
#'   tipo de muestra, nivel de inspección, tamaño de lote y AQL. Muestra resumen del plan de muestreo y curvas OC/ASN.}
#' }
#'
#' @section Componentes de UI:
#' \itemize{
#'   \item Página con barra de navegación y tema personalizado usando bslib
#'   \item Tarjetas de entrada de parámetros para cada método de muestreo
#'   \item Paneles de resultados con pestañas mostrando:
#'     \itemize{
#'       \item Tablas resumen del plan
#'       \item Curvas de Característica Operativa (OC)
#'       \item Curvas de Número Promedio de Muestra (ASN)
#'     }
#'   \item Botones de descarga para exportar planes a CSV
#' }
#'
#' @section Estilo:
#' Utiliza Bootstrap 5 con tema Flatly y CSS personalizado para:
#' \itemize{
#'   \item Componentes de tarjeta con bordes redondeados y sombras
#'   \item Esquema de color personalizado (primario: #0c5f7e, secundario: #1b9aaa)
#'   \item Google Fonts: Inter e Inter Tight
#'   \item Diseño responsivo con cuadrícula basada en columnas
#' }
#'
#' @section Parámetros:
#' \strong{Variables (Z1.9):}
#' \itemize{
#'   \item \code{var_type}: Tipo de muestreo (Normal, Tightened, Reduced)
#'   \item \code{var_level}: Nivel de inspección
#'   \item \code{var_lot_size}: Rango de tamaño de lote
#'   \item \code{var_aql}: Nivel de Calidad Aceptable (porcentaje no conforme por 100)
#' }
#'
#' \strong{Atributos (Z1.4):}
#' \itemize{
#'   \item \code{attr_plan}: Plan de muestreo (Single, Double, Multiple)
#'   \item \code{attr_type}: Tipo de muestreo (Normal, Tightened, Reduced)
#'   \item \code{attr_level}: Nivel de inspección
#'   \item \code{attr_lot_size}: Rango de tamaño de lote
#'   \item \code{attr_aql}: Nivel de Calidad Aceptable (porcentaje no conforme por 100)
#' }
#'
#' @section Salidas:
#' \strong{Panel de Variables:}
#' \itemize{
#'   \item \code{var_planSummary}: Tabla mostrando n (tamaño de muestra), k (constante de aceptabilidad), M (proporción máxima no conforme)
#'   \item \code{var_oc_plot}: Curva de Característica Operativa
#'   \item \code{var_asn_plot}: Curva de Número Promedio de Muestra
#'   \item \code{download_var_plan}: Controlador de descarga para datos del plan
#' }
#'
#' \strong{Panel de Atributos:}
#' \itemize{
#'   \item \code{attr_plan_table}: Tabla mostrando n (tamaño de muestra), c (número de aceptación), r (número de rechazo)
#'   \item \code{attr_oc_plot}: Curva de Característica Operativa
#'   \item \code{attr_asn_plot}: Curva de Número Promedio de Muestra
#'   \item \code{download_attr_plan}: Controlador de descarga para datos del plan
#' }
#'
#' @references
#' \itemize{
#'   \item ANSI/ASQ Z1.9: Procedimientos y Tablas de Muestreo para Inspección por Variables
#'   \item ANSI/ASQ Z1.4: Procedimientos y Tablas de Muestreo para Inspección por Atributos
#' }
#'
#' @seealso \code{\link{server}} para la lógica del lado del servidor
#'
#' @export
#' @name ui

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
