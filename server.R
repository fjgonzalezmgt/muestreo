#' Server logic for Sampling Plan Calculator
#'
#' @import shiny
#' @import AcceptanceSampling
#' @import openxlsx

library(shiny)
library(AcceptanceSampling)

source("aql_functions.R")

format_export_value <- function(value, digits = 5) {
  if (length(value) == 0 || is.null(value) || is.na(value)) {
    return("")
  }

  if (is.numeric(value)) {
    rounded <- round(value, digits)
    return(format(rounded, nsmall = ifelse(rounded %% 1 == 0, 0, digits), trim = TRUE))
  }

  as.character(value)
}

build_input_export <- function(lang, rows) {
  data.frame(
    Field = rows$Field,
    Value = rows$Value,
    stringsAsFactors = FALSE
  )
}

build_results_export <- function(fields, values) {
  data.frame(
    Field = fields,
    Value = values,
    stringsAsFactors = FALSE
  )
}

build_plan_table_export <- function(plan_data, lang) {
  export_df <- as.data.frame(plan_data, stringsAsFactors = FALSE)

  if (!is.null(rownames(export_df)) && any(nzchar(rownames(export_df)))) {
    export_df <- cbind(
      Sample = rownames(export_df),
      export_df,
      stringsAsFactors = FALSE
    )
    rownames(export_df) <- NULL
  }

  export_df[] <- lapply(export_df, function(column) {
    vapply(column, format_export_value, character(1))
  })

  names(export_df)[1] <- tr(lang, "sample_label")
  export_df
}

estimate_column_widths <- function(data, padding = 3, min_width = 14, max_width = 40) {
  vapply(seq_along(data), function(index) {
    column_values <- c(names(data)[index], as.character(data[[index]]))
    width <- max(nchar(column_values, type = "width"), na.rm = TRUE) + padding
    min(max(width, min_width), max_width)
  }, numeric(1))
}

style_workbook_sheet <- function(wb, sheet, data, lang, title) {
  header_style <- openxlsx::createStyle(
    fgFill = "#0C5F7E",
    fontColour = "#FFFFFF",
    halign = "center",
    textDecoration = "bold",
    border = "Bottom"
  )
  title_style <- openxlsx::createStyle(
    textDecoration = "bold",
    fontSize = 14,
    fontColour = "#0C5F7E"
  )
  text_style <- openxlsx::createStyle(
    valign = "top"
  )

  openxlsx::addWorksheet(wb, sheet)
  openxlsx::writeData(wb, sheet, title, startRow = 1, startCol = 1)
  openxlsx::addStyle(wb, sheet, title_style, rows = 1, cols = 1, gridExpand = TRUE)
  openxlsx::writeData(wb, sheet, data, startRow = 3, startCol = 1, withFilter = FALSE)
  openxlsx::addStyle(
    wb, sheet, header_style,
    rows = 3, cols = seq_len(ncol(data)),
    gridExpand = TRUE, stack = TRUE
  )
  openxlsx::addStyle(
    wb, sheet, text_style,
    rows = 4:(nrow(data) + 3), cols = seq_len(ncol(data)),
    gridExpand = TRUE, stack = TRUE
  )
  openxlsx::addFilter(wb, sheet, rows = 3, cols = seq_len(ncol(data)))
  openxlsx::freezePane(wb, sheet, firstActiveRow = 4)
  openxlsx::setColWidths(
    wb, sheet,
    cols = seq_len(ncol(data)),
    widths = estimate_column_widths(data)
  )
}

write_formatted_workbook <- function(file, lang, input_data, result_sheets, title) {
  wb <- openxlsx::createWorkbook()

  names(input_data) <- c(tr(lang, "field_col"), tr(lang, "value_col"))
  style_workbook_sheet(
    wb = wb,
    sheet = tr(lang, "workbook_sheet_inputs"),
    data = input_data,
    lang = lang,
    title = paste(title, "-", tr(lang, "input_parameters_section"))
  )

  for (sheet_name in names(result_sheets)) {
    sheet_data <- result_sheets[[sheet_name]]
    if (identical(names(sheet_data), c("Field", "Value"))) {
      names(sheet_data) <- c(tr(lang, "field_col"), tr(lang, "value_col"))
    }
    style_workbook_sheet(
      wb = wb,
      sheet = sheet_name,
      data = sheet_data,
      lang = lang,
      title = paste(title, "-", sheet_name)
    )
  }

  openxlsx::saveWorkbook(wb, file, overwrite = TRUE)
}

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
    filename = function() {
      paste0(tr(current_lang(), "sample_plan_variables_file"), "_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      plan <- var_plan_var()
      validate(need(!is.null(plan), ""))

      lang <- current_lang()

      inputs_df <- build_input_export(lang, data.frame(
        Field = c(
          tr(lang, "generated_on"),
          tr(lang, "standard"),
          tr(lang, "sampling_type"),
          tr(lang, "inspection_level_file"),
          tr(lang, "lot_size_file"),
          "AQL"
        ),
        Value = c(
          format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          "ANSI/ASQ Z1.9",
          input$var_type,
          input$var_level,
          input$var_lot_size,
          input$var_aql
        ),
        stringsAsFactors = FALSE
      ))

      results_df <- build_results_export(
        fields = names(plan),
        values = vapply(unname(plan), format_export_value, character(1))
      )

      write_formatted_workbook(
        file = file,
        lang = lang,
        input_data = inputs_df,
        result_sheets = setNames(
          list(results_df),
          tr(lang, "workbook_sheet_results")
        ),
        title = tr(lang, "variables_plan_title")
      )
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
      paste0(tr(current_lang(), "sample_plan_attributes_file"), Sys.Date(), ".xlsx")
    },
    content = function(file) {
      plan_data <- attr_plan_data()
      lang <- current_lang()

      inputs_df <- build_input_export(lang, data.frame(
        Field = c(
          tr(lang, "generated_on"),
          tr(lang, "standard"),
          tr(lang, "sampling_plan_file"),
          tr(lang, "sampling_type"),
          tr(lang, "inspection_level_file"),
          tr(lang, "lot_size_file"),
          "AQL"
        ),
        Value = c(
          format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          "ANSI/ASQ Z1.4",
          input$attr_plan,
          input$attr_type,
          input$attr_level,
          input$attr_lot_size,
          input$attr_aql
        ),
        stringsAsFactors = FALSE
      ))

      if ("Message" %in% names(plan_data)) {
        result_sheets <- setNames(
          list(build_results_export("Message", plan_data$Message)),
          tr(lang, "workbook_sheet_results")
        )
      } else {
        result_sheets <- setNames(
          list(build_plan_table_export(plan_data, lang)),
          tr(lang, "workbook_sheet_results")
        )
      }

      write_formatted_workbook(
        file = file,
        lang = lang,
        input_data = inputs_df,
        result_sheets = result_sheets,
        title = tr(lang, "attributes_plan_title")
      )
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
