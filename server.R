library(tools)
library(markdown)

library(shiny)
library(shinydashboard)
library(shinyTree)


server <- function(input, output, session) {
  uploaded_data <- reactive({
    req(input$csv_files)

    df_list <- lapply(input$csv_files$datapath, read.csv)

    clean_names <- basename(input$csv_files$name)
    clean_names <- tools::file_path_sans_ext(clean_names)
    names(df_list) <- clean_names

    df_list
  })

  output$dataframe_tree <- renderTree({
    lapply(uploaded_data(), \(x) build_df_tree_item(x))
  })

  output$table_tree <- renderUI({
    req(uploaded_data())

    tags$div(
      h3("Available tables:"),
      shinyTree(
        "dataframe_tree",
        theme = "proton",
        themeIcons = FALSE,
        search = TRUE
      ),
      HTML("<h6>table names pulled from file names (i.e. <code>C:/Users/cooldude42/customers.csv</code> will become a table named <code>customers</code>)</h6>"),
      hr()
    )
  })

  output$how_to_use <- renderUI({
    includeMarkdown("how-to-use.md")
  })

  output$download_app_btn_ui <- renderUI({
    req(uploaded_data())
    tags$div(
      downloadButton(
        outputId = "download_app_btn",
        label = "Download SQL app",
        icon = icon(
          name = "download",
          class = "fa-pull-right",
          style = "font-size: 1.3em"
        ),
        class = "btn-info"
      )
    )
  })

  output$download_app_btn <- downloadHandler(
    filename = function() {
      "sql_simulator.zip"
    },
    content = function(file) {
      req(uploaded_data())

      assign(
        x = "dataframe_tree_list",
        value = lapply(uploaded_data(), \(x) build_df_tree_item(x)),
        envir = globalenv()
      )

      save_items <- c(
        names(uploaded_data()),
        "sqlEmulatorUI",
        "sqlEmulatorServer",
        "trunc_char_vec",
        "trunc_df_char_cols",
        "dataframe_tree_list"
      )

      tmp <- tempdir()
      setwd(tmp)

      save(list = save_items, file = "sql-simulator-resources.Rdata")
      writeLines(SQL_SIMULATOR_STARTER_CODE, con = "sql-simulator-app.R")

      zip(zipfile = file, files = c("sql-simulator-resources.Rdata", "sql-simulator-app.R"))
    },
    contentType = "application/zip"
  )

  output$test_emulator_ui <- renderUI({
    req(uploaded_data())

    list2env(uploaded_data(), globalenv())
    sqlEmulatorUI(id = "test_emulator")
  })

  sqlEmulatorServer(id = "test_emulator")
}
