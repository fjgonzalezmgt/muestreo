# Helper file para cargar la aplicación correctamente en los tests
# Este archivo se ejecuta automáticamente antes de los tests

# Función para encontrar la ruta correcta al archivo
find_file <- function(filename) {
  possible_paths <- c(
    file.path("..", "..", filename),  # Desde tests/testthat/
    filename,                          # Desde raíz
    file.path(".", filename)           # Current dir
  )
  
  for (path in possible_paths) {
    if (file.exists(path)) {
      return(normalizePath(path, winslash = "/"))
    }
  }
  
  warning(paste("No se pudo encontrar:", filename))
  return(NULL)
}

# Guardar directorio actual
old_wd <- getwd()

# Cargar aql_functions.R si existe
aql_path <- find_file("aql_functions.R")
if (!is.null(aql_path)) {
  tryCatch({
    source(aql_path, local = FALSE)
    cat("✓ aql_functions.R cargado correctamente\n")
  }, error = function(e) {
    warning(paste("Error cargando aql_functions.R:", e$message))
  })
}

# Cargar app.R desde su directorio para que encuentre aql_functions.R
app_path <- find_file("app.R")
if (!is.null(app_path)) {
  tryCatch({
    # Cambiar al directorio de app.R temporalmente
    app_dir <- dirname(app_path)
    setwd(app_dir)
    
    # Suprimir mensajes de carga
    suppressMessages({
      source(basename(app_path), local = FALSE)
    })
    
    # Restaurar directorio original
    setwd(old_wd)
    
    cat("✓ app.R cargado correctamente\n")
  }, error = function(e) {
    # Restaurar directorio en caso de error
    setwd(old_wd)
    warning(paste("Error cargando app.R:", e$message))
  })
}
