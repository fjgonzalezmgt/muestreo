#' User Interface for Sampling Plan Calculator
#'
#' @description
#' Unified Shiny user interface for sampling plans with language selection.
#' Combines variables sampling (ANSI/ASQ Z1.9) and attributes sampling
#' (ANSI/ASQ Z1.4).
#'
#' @export
#' @name ui

library(shiny)
library(bslib)

ui <- tagList(
  tags$head(
    tags$style(
      HTML("
        body { background-color: #f3f6fb; }
        .app-shell { padding: 16px 18px 24px; }
        .language-bar {
          display: flex;
          justify-content: flex-end;
          align-items: center;
          gap: 12px;
          margin-bottom: 12px;
        }
        .language-bar .shiny-input-container {
          margin-bottom: 0;
          min-width: 220px;
        }
        .helper-text { color: #6b778c; font-size: 13px; }
      ")
    )
  ),
  div(
    class = "app-shell",
    div(
      class = "language-bar",
      selectInput(
        "lang",
        label = tr("es", "language"),
        choices = c("Espanol" = "es", "English" = "en"),
        selected = "es"
      )
    ),
    uiOutput("app_ui")
  )
)
