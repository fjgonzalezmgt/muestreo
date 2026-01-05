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
