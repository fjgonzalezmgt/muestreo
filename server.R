#' Server logic for Sampling Plan Calculator
#'
#' @import shiny
#' @import AcceptanceSampling

library(shiny)
library(AcceptanceSampling)

source("aql_functions.R")

server <- function(input, output, session) {
  current_lang <- reactive({
    if (is.null(input$lang) || !input$lang %in% c("es", "en")) {
      "es"
    } else {
      input$lang
    }
  })

  output$app_ui <- renderUI({
    build_app_navbar(current_lang())
  })

  var_ids <- reactive({
    list(
      type = type_df$id[match(input$var_type, type_df$name)],
      level = level_var_df$id[match(input$var_level, level_var_df$name)],
      lot = lot_var_df$id[match(input$var_lot_size, lot_var_df$name)],
      aql = aql_var_df$id[match(input$var_aql, aql_var_df$name)]
    )
  })

  var_plan_var <- reactive({
    id_vals <- var_ids()
    validate(need(!any(is.na(unlist(id_vals))), tr(current_lang(), "invalid_values")))

    tryCatch(
      AAZ19(
        type = id_vals$type,
        stype = "unknown",
        dINSL = id_vals$level,
        dLOTS = id_vals$lot,
        dAQL = id_vals$aql
      ),
      error = function(e) {
        showNotification(
          paste(tr(current_lang(), "var_calc_error"), e$message),
          type = "error"
        )
        NULL
      }
    )
  })

  output$var_planSummary <- renderTable({
    plan <- var_plan_var()
    validate(need(!is.null(plan), ""))

    df <- data.frame(
      Parameter = names(plan),
      Value = as.character(unname(plan)),
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    if ("n" %in% df$Parameter) {
      n_val <- as.numeric(plan[["n"]])
      df$Value[df$Parameter == "n"] <- as.character(round(n_val, 0))
    }

    for (param in c("k", "M")) {
      if (param %in% df$Parameter) {
        param_val <- as.numeric(plan[[param]])
        df$Value[df$Parameter == param] <- format(round(param_val, 5), nsmall = 5)
      }
    }

    names(df) <- c(tr(current_lang(), "parameter_col"), tr(current_lang(), "value_col"))
    df
  }, striped = TRUE, bordered = TRUE)

  output$download_var_plan <- downloadHandler(
    filename = function() tr(current_lang(), "sample_plan_variables_file"),
    content = function(file) {
      plan <- var_plan_var()
      validate(need(!is.null(plan), ""))

      params_df <- data.frame(
        Seccion = c(tr(current_lang(), "input_section"), "", "", "", ""),
        Parametro = c(
          tr(current_lang(), "standard"),
          tr(current_lang(), "sampling_type"),
          tr(current_lang(), "inspection_level_file"),
          tr(current_lang(), "lot_size_file"),
          "AQL"
        ),
        Valor = c(
          "ANSI/ASQ Z1.9",
          input$var_type,
          input$var_level,
          input$var_lot_size,
          input$var_aql
        ),
        stringsAsFactors = FALSE
      )

      plan_df <- data.frame(
        Seccion = c("", rep(tr(current_lang(), "plan_section"), length(plan))),
        Parametro = c("", names(plan)),
        Valor = c("", unname(plan)),
        stringsAsFactors = FALSE
      )

      final_df <- rbind(params_df, plan_df)
      write.csv(final_df, file, row.names = FALSE, fileEncoding = "UTF-8")

      con <- file(file, open = "r+b")
      content <- readBin(con, "raw", n = file.info(file)$size)
      close(con)

      con <- file(file, open = "wb")
      writeBin(as.raw(c(0xef, 0xbb, 0xbf)), con)
      writeBin(content, con)
      close(con)
    }
  )

  var_oc_data <- reactive({
    planv <- var_plan_var()
    validate(need(!is.null(planv), tr(current_lang(), "no_plan_data")))

    pnc <- seq(0, 0.08, 0.005)
    oc_values <- OCvar(n = planv[[1]], k = planv[[2]], s.type = "unknown", pd = pnc)@paccept
    n_val <- as.numeric(planv[[1]])
    asn_values <- rep(n_val, length(pnc))

    list(Pnc = pnc, OCV = oc_values, ASNV = asn_values, n_val = n_val)
  })

  output$var_oc_plot <- renderPlot({
    data <- var_oc_data()

    plot(
      data$Pnc, data$OCV,
      type = "l",
      lwd = 2,
      col = "#0c5f7e",
      xlab = tr(current_lang(), "nonconforming_prop"),
      ylab = tr(current_lang(), "acceptance_prob"),
      main = tr(current_lang(), "oc_curve"),
      ylim = c(0, 1)
    )
    grid()
  })

  output$var_asn_plot <- renderPlot({
    data <- var_oc_data()
    ylim_range <- c(max(1, data$n_val * 0.8), data$n_val * 1.2)

    plot(
      data$Pnc, data$ASNV,
      type = "l",
      lwd = 2,
      col = "#1b9aaa",
      xlab = tr(current_lang(), "nonconforming_prop"),
      ylab = tr(current_lang(), "average_sample_size"),
      main = tr(current_lang(), "asn_curve"),
      ylim = ylim_range
    )
    abline(h = data$n_val, lty = 2, col = "gray50")
    text(0.04, data$n_val * 1.1, paste0("n = ", data$n_val), col = "gray30")
    grid()
  })

  attr_plan_data <- reactive({
    id_plan <- lookup_id(choice_plans, input$attr_plan)
    id_type <- lookup_id(type_df, input$attr_type)
    id_level <- lookup_id(choice_levels, input$attr_level)
    id_lot <- lookup_id(choice_lots, input$attr_lot_size)
    id_aql <- lookup_id(choice_aql, input$attr_aql)

    sample_plan <- switch(
      as.character(id_plan),
      `1` = AAZ14Single(PLAN = id_type, dINSL = id_level, dLOTS = id_lot, dAQL = id_aql),
      `2` = AAZ14Double(PLAN = id_type, dINSL = id_level, dLOTS = id_lot, dAQL = id_aql),
      `3` = AAZ14Multiple(PLAN = id_type, dINSL = id_level, dLOTS = id_lot, dAQL = id_aql)
    )

    if (is.character(sample_plan)) {
      return(data.frame(Message = sample_plan, stringsAsFactors = FALSE))
    }

    sample_plan
  })

  output$attr_plan_table <- renderTable({
    df <- attr_plan_data()

    if ("n" %in% names(df)) {
      df$n <- as.integer(round(df$n, 0))
    }

    df
  },
  striped = TRUE,
  bordered = FALSE,
  hover = TRUE,
  spacing = "s",
  digits = 0,
  rownames = TRUE
  )

  output$download_attr_plan <- downloadHandler(
    filename = function() {
      paste0(tr(current_lang(), "sample_plan_attributes_file"), Sys.Date(), ".csv")
    },
    content = function(file) {
      plan_data <- attr_plan_data()

      params_df <- data.frame(
        Seccion = c(tr(current_lang(), "input_section"), "", "", "", "", ""),
        Parametro = c(
          tr(current_lang(), "standard"),
          tr(current_lang(), "sampling_plan_file"),
          tr(current_lang(), "sampling_type"),
          tr(current_lang(), "inspection_level_file"),
          tr(current_lang(), "lot_size_file"),
          "AQL"
        ),
        Valor = c(
          "ANSI/ASQ Z1.4",
          input$attr_plan,
          input$attr_type,
          input$attr_level,
          input$attr_lot_size,
          input$attr_aql
        ),
        stringsAsFactors = FALSE
      )

      if ("Message" %in% names(plan_data)) {
        plan_df <- data.frame(
          Seccion = tr(current_lang(), "plan_section"),
          Parametro = "Message",
          Valor = plan_data$Message,
          stringsAsFactors = FALSE
        )
      } else {
        n_rows <- nrow(plan_data)
        plan_names <- names(plan_data)
        plan_rows <- list(
          data.frame(Seccion = "", Parametro = "", Valor = "", stringsAsFactors = FALSE)
        )

        for (i in seq_len(n_rows)) {
          if (n_rows > 1) {
            plan_rows[[length(plan_rows) + 1]] <- data.frame(
              Seccion = tr(current_lang(), "plan_section"),
              Parametro = paste0("=== ", tr(current_lang(), "sample_label"), i, " ==="),
              Valor = "",
              stringsAsFactors = FALSE
            )
          }

          for (j in seq_along(plan_names)) {
            plan_rows[[length(plan_rows) + 1]] <- data.frame(
              Seccion = tr(current_lang(), "plan_section"),
              Parametro = plan_names[j],
              Valor = as.character(plan_data[i, j]),
              stringsAsFactors = FALSE
            )
          }
        }

        plan_df <- do.call(rbind, plan_rows)
      }

      final_df <- rbind(params_df, plan_df)
      write.csv(final_df, file, row.names = FALSE, fileEncoding = "UTF-8")

      con <- file(file, open = "r+b")
      content <- readBin(con, "raw", n = file.info(file)$size)
      close(con)

      con <- file(file, open = "wb")
      writeBin(as.raw(c(0xef, 0xbb, 0xbf)), con)
      writeBin(content, con)
      close(con)
    }
  )

  attr_curves_data <- reactive({
    id_plan <- lookup_id(choice_plans, input$attr_plan)
    id_type <- lookup_id(type_df, input$attr_type)
    id_level <- lookup_id(choice_levels, input$attr_level)
    id_lot <- lookup_id(choice_lots, input$attr_lot_size)
    id_aql <- lookup_id(choice_aql, input$attr_aql)

    sample_plan <- switch(
      as.character(id_plan),
      `1` = AAZ14Single(PLAN = id_type, dINSL = id_level, dLOTS = id_lot, dAQL = id_aql),
      `2` = AAZ14Double(PLAN = id_type, dINSL = id_level, dLOTS = id_lot, dAQL = id_aql),
      `3` = AAZ14Multiple(PLAN = id_type, dINSL = id_level, dLOTS = id_lot, dAQL = id_aql)
    )

    if (is.character(sample_plan)) {
      return(list(error = sample_plan))
    }

    pnc <- seq(0, 0.08, 0.005)

    ocasn <- switch(
      as.character(id_plan),
      `1` = OCASNZ4S(sample_plan, pnc),
      `2` = OCASNZ4D(sample_plan, pnc),
      `3` = OCASNZ4M(sample_plan, pnc)
    )

    list(OCASNS = ocasn, error = NULL)
  })

  output$attr_oc_plot <- renderPlot({
    data <- attr_curves_data()

    if (!is.null(data$error)) {
      plot.new()
      text(0.5, 0.5, data$error, cex = 1.2)
      return()
    }

    plot(
      data$OCASNS$pd, data$OCASNS$OC,
      type = "l",
      lwd = 2,
      col = "#0c5f7e",
      xlab = tr(current_lang(), "nonconforming_prop"),
      ylab = tr(current_lang(), "acceptance_prob"),
      main = tr(current_lang(), "oc_curve"),
      ylim = c(0, 1)
    )
    grid()
  })

  output$attr_asn_plot <- renderPlot({
    data <- attr_curves_data()

    if (!is.null(data$error)) {
      plot.new()
      text(0.5, 0.5, data$error, cex = 1.2)
      return()
    }

    asn_range <- range(data$OCASNS$ASN, na.rm = TRUE)
    ylim_asn <- c(max(1, asn_range[1] * 0.8), asn_range[2] * 1.2)

    plot(
      data$OCASNS$pd, data$OCASNS$ASN,
      type = "l",
      lwd = 2,
      col = "#1b9aaa",
      xlab = tr(current_lang(), "nonconforming_prop"),
      ylab = tr(current_lang(), "average_sample_size"),
      main = tr(current_lang(), "asn_curve"),
      ylim = ylim_asn
    )
    grid()
  })
}
