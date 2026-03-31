#' Definiciones Globales para la Aplicación Shiny
#'
#' @description
#' Este archivo contiene definiciones globales compartidas para la aplicación Shiny.
#' Incluye catálogos de datos utilizados por los componentes UI y Server para planes
#' de muestreo AQL (Nivel de Calidad Aceptable) según las normas Z1.4 y Z1.9.
#'
#' @details
#' El archivo define:
#' - Catálogos comunes (tipos de inspección)
#' - Catálogos de variables para la norma Z1.9
#' - Catálogos de atributos para la norma Z1.4
#' - Funciones auxiliares para búsqueda en catálogos
#'
#' @author Quality Analytics
#' @name global

# Catálogos comunes -----------------------------------------------------------

#' Catálogo de Tipos de Inspección
#'
#' @description
#' Data frame que contiene los tipos de planes de inspección disponibles en muestreo AQL.
#'
#' @format Un data frame con 3 filas y 2 columnas:
#' \describe{
#'   \item{name}{Carácter. Nombre del tipo de inspección: "Normal", "Tightened" o "Reduced"}
#'   \item{id}{Entero. Identificador único (1-3) para cada tipo de inspección}
#' }
#'
#' @examples
#' type_df
#' # Buscar ID para inspección "Normal"
#' lookup_id(type_df, "Normal")
type_df <- data.frame(
  name = c("Normal", "Tightened", "Reduced"),
  id = c(1, 2, 3),
  stringsAsFactors = FALSE
)

# Catálogos para Variables (Z1.9) ---------------------------------------------

#' Catálogo de Niveles de Inspección para Variables (Z1.9)
#'
#' @description
#' Data frame que contiene los niveles de inspección para planes de muestreo
#' por variables según la norma Z1.9.
#'
#' @format Un data frame con 5 filas y 2 columnas:
#' \describe{
#'   \item{name}{Carácter. Código del nivel de inspección: "S-3", "S-4", "I", "II" o "III"}
#'   \item{id}{Entero. Identificador único (1-5) para cada nivel de inspección}
#' }
#'
#' @details
#' Los niveles S-3 y S-4 son niveles especiales para tamaños de muestra reducidos.
#' Los niveles I, II y III son niveles de inspección generales, siendo II el más común.
level_var_df <- data.frame(
  name = c("S-3", "S-4", "I", "II", "III"),
  id = c(1, 2, 3, 4, 5),
  stringsAsFactors = FALSE
)

#' Catálogo de Rangos de Tamaño de Lote para Variables (Z1.9)
#'
#' @description
#' Data frame que contiene los rangos de tamaño de lote para planes de muestreo
#' por variables según la norma Z1.9.
#'
#' @format Un data frame con 16 filas y 2 columnas:
#' \describe{
#'   \item{name}{Carácter. Rango de tamaño de lote (ej., "2-8", "9-15", "500,001 and over")}
#'   \item{id}{Entero. Identificador único (1-16) para cada rango de tamaño de lote}
#' }
#'
#' @details
#' Utilizado para determinar la letra de código de tamaño de muestra apropiada según el tamaño del lote.
#' Los rangos van desde lotes muy pequeños (2-8 unidades) hasta lotes muy grandes (500,001 y más).
lot_var_df <- data.frame(
  name = c("2-8", "9-15", "16-25", "26-50", "51-90", "91-150", "151-280", "281-400",
           "401-500", "501-1,200", "1,201-3,200", "3,201-10,000", "10,001-35,000", "35,001-150,000",
           "150,001-500,000", "500,001 and over"),
  id = 1:16,
  stringsAsFactors = FALSE
)

#' Catálogo de Valores AQL para Variables (Z1.9)
#'
#' @description
#' Data frame que contiene los valores de Nivel de Calidad Aceptable (AQL) para planes
#' de muestreo por variables según la norma Z1.9.
#'
#' @format Un data frame con 11 filas y 2 columnas:
#' \describe{
#'   \item{name}{Carácter. Valores de porcentaje AQL como cadenas de texto}
#'   \item{id}{Entero. Identificador único (1-11) para cada valor AQL}
#' }
#'
#' @details
#' AQL representa el porcentaje máximo de artículos defectuosos considerado aceptable
#' para características variables. Los valores van desde 0.10% hasta 10%.
aql_var_df <- data.frame(
  name = c("0.10", "0.15", "0.25", "0.40", "0.65", "1.0", "1.5", "2.5", "4.0", "6.5", "10"),
  id = 1:11,
  stringsAsFactors = FALSE
)

# Catálogos para Atributos (Z1.4) ---------------------------------------------

#' Catálogo de Tipos de Plan de Muestreo para Atributos (Z1.4)
#'
#' @description
#' Data frame que contiene los tipos de planes de muestreo para muestreo por
#' atributos según la norma Z1.4.
#'
#' @format Un data frame con 3 filas y 2 columnas:
#' \describe{
#'   \item{name}{Carácter. Tipo de plan de muestreo: "Single", "Double" o "Multiple"}
#'   \item{id}{Entero. Identificador único (1-3) para cada tipo de plan}
#' }
#'
#' @details
#' - Single: Se toma una muestra y se toma una decisión basada en esa muestra
#' - Double: Se pueden tomar hasta dos muestras antes de tomar una decisión
#' - Multiple: Se pueden tomar hasta siete muestras antes de tomar una decisión
choice_plans <- data.frame(
  name = c("Single", "Double", "Multiple"),
  id = c(1, 2, 3)
)

#' Catálogo de Niveles de Inspección para Atributos (Z1.4)
#'
#' @description
#' Data frame que contiene los niveles de inspección para planes de muestreo por
#' atributos según la norma Z1.4.
#'
#' @format Un data frame con 7 filas y 2 columnas:
#' \describe{
#'   \item{name}{Carácter. Código del nivel de inspección: "S-1", "S-2", "S-3", "S-4", "I", "II" o "III"}
#'   \item{id}{Entero. Identificador único (1-7) para cada nivel de inspección}
#' }
#'
#' @details
#' Los niveles S-1 a S-4 son niveles especiales para cuando se necesitan tamaños de muestra pequeños.
#' Los niveles I, II y III son niveles de inspección generales, siendo II el predeterminado.
choice_levels <- data.frame(
  name = c("S-1", "S-2", "S-3", "S-4", "I", "II", "III"),
  id = c(1, 2, 3, 4, 5, 6, 7)
)

#' Catálogo de Rangos de Tamaño de Lote para Atributos (Z1.4)
#'
#' @description
#' Data frame que contiene los rangos de tamaño de lote para planes de muestreo
#' por atributos según la norma Z1.4.
#'
#' @format Un data frame con 15 filas y 2 columnas:
#' \describe{
#'   \item{name}{Carácter. Rango de tamaño de lote (ej., "2-8", "9-15", "500,001 and over")}
#'   \item{id}{Entero. Identificador único (1-15) para cada rango de tamaño de lote}
#' }
#'
#' @details
#' Utilizado para determinar la letra de código de tamaño de muestra apropiada según el tamaño del lote.
#' Los rangos van desde lotes muy pequeños (2-8 unidades) hasta lotes muy grandes (500,001 y más).
choice_lots <- data.frame(
  name = c(
    "2-8", "9-15", "16-25", "26-50", "51-90", "91-150",
    "151-280", "281-500", "501-1,200", "1,201-3,200", "3,201-10,000",
    "10,001-35,000", "35,001-150,000", "150,001-500,000",
    "500,001 and over"
  ),
  id = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
)

#' Catálogo de Valores AQL para Atributos (Z1.4)
#'
#' @description
#' Data frame que contiene los valores de Nivel de Calidad Aceptable (AQL) para planes
#' de muestreo por atributos según la norma Z1.4.
#'
#' @format Un data frame con 26 filas y 2 columnas:
#' \describe{
#'   \item{name}{Carácter. Valores AQL como cadenas de texto (porcentaje o defectos por cien)}
#'   \item{id}{Entero. Identificador único (1-26) para cada valor AQL}
#' }
#'
#' @details
#' AQL representa el porcentaje máximo o defectos por cien unidades considerados
#' aceptables para características de atributos. Los valores van desde 0.010 hasta 1000 defectos
#' por cien unidades. Valores más bajos indican requisitos de calidad más estrictos.
choice_aql <- data.frame(
  name = c(
    "0.010", "0.015", "0.025", "0.040", "0.065", "0.10", "0.15",
    "0.25", "0.40", "0.65", "1.0", "1.5", "2.5", "4.0", "6.5",
    "10", "15", "25", "40", "65", "100", "150", "250", "400",
    "650", "1000"
  ),
  id = seq_len(26)
)

# Helper function --------------------------------------------------------------

#' Buscar ID en Data Frame de Catálogo
#'
#' @description
#' Función auxiliar para recuperar el valor ID de un data frame de catálogo
#' basándose en el campo name.
#'
#' @param df Data frame. Un data frame de catálogo con columnas 'name' e 'id'.
#' @param value Carácter. El valor de nombre a buscar en el data frame.
#'
#' @return Entero. El valor ID correspondiente, o integer(0) si no se encuentra.
#'
#' @examples
#' lookup_id(type_df, "Normal")           # Devuelve 1
#' lookup_id(level_var_df, "II")         # Devuelve 4
#' lookup_id(choice_plans, "Double")     # Devuelve 2
#'
#' @seealso
#' \code{\link{type_df}}, \code{\link{level_var_df}}, \code{\link{choice_plans}}
lookup_id <- function(df, value) {
  df[df$name == value, "id", drop = TRUE]
}

# Internationalization helpers ------------------------------------------------

i18n <- list(
  es = list(
    language = "Idioma",
    language_es = "Espanol",
    language_en = "Ingles",
    app_title = "Calculadora de planes de muestreo",
    variables_tab = "Variables (Z1.9)",
    attributes_tab = "Atributos (Z1.4)",
    variables_card_title = "Parametros - Muestreo por variables",
    attributes_card_title = "Parametros - Muestreo por atributos",
    plan_tab = "Plan",
    curves_tab = "Curvas",
    var_sampling_type = "Tipo de muestreo",
    attr_sampling_plan = "Plan de muestreo",
    inspection_level = "Nivel de inspeccion",
    lot_size = "Tamano de lote",
    aql_label = "AQL (% no conformes / 100)",
    variables_help = "Valores segun ANSI/ASQ Z1.9.",
    attributes_help = "Norma ANSI/ASQ Z1.4: muestreo por atributos.",
    download_plan_csv = "Descargar plan (CSV)",
    variables_plan_title = "Plan de muestreo por variables",
    attributes_plan_title = "Plan de muestreo por atributos (ANSI/ASQ Z1.4)",
    parameter_meaning = "Significado de los parametros:",
    n_label = "Tamano de muestra",
    k_label = "Constante de aceptabilidad",
    m_label = "Maxima proporcion no conforme permitida",
    c_label = "Numero de aceptacion (defectos permitidos para aceptar)",
    r_label = "Numero de rechazo (defectos que causan rechazo del lote)",
    invalid_values = "Seleccione valores validos",
    no_plan_data = "No hay datos del plan",
    var_calc_error = "Error al calcular plan por variables:",
    parameter_col = "Parametro",
    value_col = "Valor",
    oc_curve = "Curva OC",
    asn_curve = "Curva ASN",
    nonconforming_prop = "Proporcion no conforme",
    acceptance_prob = "Probabilidad de aceptacion",
    average_sample_size = "Tamano promedio de muestra",
    sample_plan_variables_file = "plan_muestreo_variables.csv",
    sample_plan_attributes_file = "plan_muestreo_atributos_",
    input_section = "PARAMETROS_ENTRADA",
    plan_section = "RESULTADOS_PLAN",
    standard = "Norma",
    sampling_type = "Tipo_Muestreo",
    inspection_level_file = "Nivel_Inspeccion",
    lot_size_file = "Tamano_Lote",
    sampling_plan_file = "Plan_Muestreo",
    sample_label = "Muestra_",
    normal = "Normal",
    tightened = "Rigurosa",
    reduced = "Reducida",
    single = "Simple",
    double = "Doble",
    multiple = "Multiple"
  ),
  en = list(
    language = "Language",
    language_es = "Spanish",
    language_en = "English",
    app_title = "Sampling Plan Calculator",
    variables_tab = "Variables (Z1.9)",
    attributes_tab = "Attributes (Z1.4)",
    variables_card_title = "Parameters - Variables sampling",
    attributes_card_title = "Parameters - Attributes sampling",
    plan_tab = "Plan",
    curves_tab = "Curves",
    var_sampling_type = "Sampling type",
    attr_sampling_plan = "Sampling plan",
    inspection_level = "Inspection level",
    lot_size = "Lot size",
    aql_label = "AQL (% nonconforming / 100)",
    variables_help = "Values according to ANSI/ASQ Z1.9.",
    attributes_help = "ANSI/ASQ Z1.4 standard: attributes sampling.",
    download_plan_csv = "Download plan (CSV)",
    variables_plan_title = "Variables sampling plan",
    attributes_plan_title = "Attributes sampling plan (ANSI/ASQ Z1.4)",
    parameter_meaning = "Parameter meaning:",
    n_label = "Sample size",
    k_label = "Acceptability constant",
    m_label = "Maximum allowable nonconforming proportion",
    c_label = "Acceptance number (defects allowed to accept)",
    r_label = "Rejection number (defects that reject the lot)",
    invalid_values = "Select valid values",
    no_plan_data = "No plan data available",
    var_calc_error = "Error calculating variables plan:",
    parameter_col = "Parameter",
    value_col = "Value",
    oc_curve = "OC Curve",
    asn_curve = "ASN Curve",
    nonconforming_prop = "Nonconforming proportion",
    acceptance_prob = "Acceptance probability",
    average_sample_size = "Average sample size",
    sample_plan_variables_file = "sampling_plan_variables.csv",
    sample_plan_attributes_file = "sampling_plan_attributes_",
    input_section = "INPUT_PARAMETERS",
    plan_section = "PLAN_RESULTS",
    standard = "Standard",
    sampling_type = "Sampling_Type",
    inspection_level_file = "Inspection_Level",
    lot_size_file = "Lot_Size",
    sampling_plan_file = "Sampling_Plan",
    sample_label = "Sample_",
    normal = "Normal",
    tightened = "Tightened",
    reduced = "Reduced",
    single = "Single",
    double = "Double",
    multiple = "Multiple"
  )
)

tr <- function(lang, key) {
  lang_key <- if (is.null(lang) || !lang %in% names(i18n)) "es" else lang
  value <- i18n[[lang_key]][[key]]
  if (is.null(value)) key else value
}

type_choices_i18n <- function(lang) {
  c(
    setNames("Normal", tr(lang, "normal")),
    setNames("Tightened", tr(lang, "tightened")),
    setNames("Reduced", tr(lang, "reduced"))
  )
}

plan_choices_i18n <- function(lang) {
  c(
    setNames("Single", tr(lang, "single")),
    setNames("Double", tr(lang, "double")),
    setNames("Multiple", tr(lang, "multiple"))
  )
}

app_theme <- bslib::bs_theme(
  version = 5,
  bootswatch = "flatly",
  primary = "#0c5f7e",
  secondary = "#1b9aaa",
  base_font = bslib::font_google("Inter"),
  heading_font = bslib::font_google("Inter Tight")
)

build_app_navbar <- function(lang = "es") {
  bslib::page_navbar(
    title = tr(lang, "app_title"),
    theme = app_theme,
    bslib::nav_panel(
      title = tr(lang, "variables_tab"),
      bslib::layout_columns(
        col_widths = c(4, 8),
        bslib::card(
          bslib::card_header(tr(lang, "variables_card_title")),
          shiny::selectInput(
            "var_type",
            tr(lang, "var_sampling_type"),
            choices = type_choices_i18n(lang),
            selected = "Normal"
          ),
          shiny::selectInput(
            "var_level",
            tr(lang, "inspection_level"),
            choices = level_var_df$name,
            selected = "II"
          ),
          shiny::selectInput(
            "var_lot_size",
            tr(lang, "lot_size"),
            choices = lot_var_df$name,
            selected = "3,201-10,000"
          ),
          shiny::selectInput(
            "var_aql",
            tr(lang, "aql_label"),
            choices = aql_var_df$name,
            selected = "1.5"
          ),
          shiny::p(tr(lang, "variables_help"), class = "helper-text mb-2"),
          shiny::downloadButton("download_var_plan", tr(lang, "download_plan_csv"))
        ),
        bslib::navset_card_tab(
          bslib::nav_panel(
            tr(lang, "plan_tab"),
            shiny::h4(tr(lang, "variables_plan_title")),
            shiny::tableOutput("var_planSummary"),
            shiny::div(
              class = "helper-text mt-3",
              shiny::tags$strong(tr(lang, "parameter_meaning")),
              shiny::tags$ul(
                shiny::tags$li(shiny::tags$strong("n:"), paste(" ", tr(lang, "n_label"))),
                shiny::tags$li(shiny::tags$strong("k:"), paste(" ", tr(lang, "k_label"))),
                shiny::tags$li(shiny::tags$strong("M:"), paste(" ", tr(lang, "m_label")))
              )
            )
          ),
          bslib::nav_panel(
            tr(lang, "curves_tab"),
            bslib::layout_columns(
              col_widths = c(12, 12, 12, 12, 12, 6, 6),
              shiny::plotOutput("var_oc_plot", height = 400),
              shiny::plotOutput("var_asn_plot", height = 400)
            )
          )
        )
      )
    ),
    bslib::nav_panel(
      title = tr(lang, "attributes_tab"),
      bslib::layout_columns(
        col_widths = c(4, 8),
        bslib::card(
          bslib::card_header(tr(lang, "attributes_card_title")),
          shiny::selectInput(
            "attr_plan",
            tr(lang, "attr_sampling_plan"),
            choices = plan_choices_i18n(lang),
            selected = "Single"
          ),
          shiny::selectInput(
            "attr_type",
            tr(lang, "var_sampling_type"),
            choices = type_choices_i18n(lang),
            selected = "Normal"
          ),
          shiny::selectInput(
            "attr_level",
            tr(lang, "inspection_level"),
            choices = choice_levels$name,
            selected = "II"
          ),
          shiny::selectInput(
            "attr_lot_size",
            tr(lang, "lot_size"),
            choices = choice_lots$name,
            selected = "3,201-10,000"
          ),
          shiny::selectInput(
            "attr_aql",
            tr(lang, "aql_label"),
            choices = choice_aql$name,
            selected = "1.5"
          ),
          shiny::div(class = "helper-text mt-2", tr(lang, "attributes_help")),
          shiny::downloadButton("download_attr_plan", tr(lang, "download_plan_csv"), class = "btn-primary download-btn")
        ),
        bslib::navset_card_tab(
          bslib::nav_panel(
            tr(lang, "plan_tab"),
            shiny::h4(tr(lang, "attributes_plan_title")),
            shiny::tableOutput("attr_plan_table"),
            shiny::div(
              class = "helper-text mt-3",
              shiny::tags$strong(tr(lang, "parameter_meaning")),
              shiny::tags$ul(
                shiny::tags$li(shiny::tags$strong("n:"), paste(" ", tr(lang, "n_label"))),
                shiny::tags$li(shiny::tags$strong("c:"), paste(" ", tr(lang, "c_label"))),
                shiny::tags$li(shiny::tags$strong("r:"), paste(" ", tr(lang, "r_label")))
              )
            )
          ),
          bslib::nav_panel(
            tr(lang, "curves_tab"),
            bslib::layout_columns(
              col_widths = c(12, 12, 12, 12, 12, 6, 6),
              shiny::plotOutput("attr_oc_plot", height = 420),
              shiny::plotOutput("attr_asn_plot", height = 420)
            )
          )
        )
      )
    )
  )
}
