#
# Definiciones globales compartidas para la aplicación Shiny
# Catálogos de datos utilizados por UI y Server
#

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

# Helper function --------------------------------------------------------------

lookup_id <- function(df, value) {
  df[df$name == value, "id", drop = TRUE]
}
