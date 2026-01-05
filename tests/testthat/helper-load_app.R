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

# Cargar archivos de la aplicación Shiny (global.R, ui.R, server.R)
# Primero global.R con las definiciones globales
global_path <- find_file("global.R")
if (!is.null(global_path)) {
  tryCatch({
    global_dir <- dirname(global_path)
    setwd(global_dir)
    
    suppressMessages({
      source(basename(global_path), local = FALSE)
    })
    
    cat("✓ global.R cargado correctamente\n")
  }, error = function(e) {
    setwd(old_wd)
    warning(paste("Error cargando global.R:", e$message))
  })
}

# Luego ui.R
ui_path <- find_file("ui.R")
if (!is.null(ui_path)) {
  tryCatch({
    ui_dir <- dirname(ui_path)
    setwd(ui_dir)
    
    suppressMessages({
      source(basename(ui_path), local = FALSE)
    })
    
    cat("✓ ui.R cargado correctamente\n")
  }, error = function(e) {
    setwd(old_wd)
    warning(paste("Error cargando ui.R:", e$message))
  })
}

# Finalmente server.R
server_path <- find_file("server.R")
if (!is.null(server_path)) {
  tryCatch({
    server_dir <- dirname(server_path)
    setwd(server_dir)
    
    suppressMessages({
      source(basename(server_path), local = FALSE)
    })
    
    setwd(old_wd)
    
    cat("✓ server.R cargado correctamente\n")
  }, error = function(e) {
    setwd(old_wd)
    warning(paste("Error cargando server.R:", e$message))
  })
} else {
  # Restaurar directorio si no se encontró server.R
  setwd(old_wd)
}
