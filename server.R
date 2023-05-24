library(shiny)
library(shinydashboard)
library(tools)

server <- function(input, output, session) {
  uploaded_data <- reactive({
    req(input$csv_files)

    df_list <- lapply(input$csv_files$datapath, read.csv)

    clean_names <- basename(input$csv_files$name)
    clean_names <- tools::file_path_sans_ext(clean_names)
    names(df_list) <- clean_names

    df_list
  })

  table_list_html <- reactive({
    req(uploaded_data())

    list_items <- lapply(names(uploaded_data()), function(name_i) {
      tags$li(name_i)
    })

    do.call(tags$ul, list_items)
  })

  output$table_name_list <- renderUI({
    req(table_list_html())

    tags$div(
      h3("Available tables:"),
      table_list_html(),
      HTML("<h6>names pulled from file names (i.e. <code>path/to/data.csv</code> will become a table named <code>data</code>)</h6>"),
      hr()
    )
  })

  output$table_name_list_again <- renderUI({
    req(table_list_html())

    tags$div(
      h3("Available tables:"),
      table_list_html(),
      HTML("<h6>names pulled from file names (i.e. <code>path/to/data.csv</code> will become a table named <code>data</code>)</h6>"),
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
      ),
      hr()
    )
  })

  output$download_app_btn <- downloadHandler(
    filename = function() {
      "sql_simulator.Rdata"
    },
    content = function(file) {
      req(uploaded_data())

      ui <- fluidPage(
        tags$link(
          rel = "stylesheet",
          type = "text/css",
          href = "https://raw.githubusercontent.com/trestletech/shinyAce/master/inst/www/shinyAce.css"
        ),
        tags$div(
          h3("Available tables:"),
          table_list_html(),
          hr()
        ),
        sqlEmulatorUI(id = "sql_emulator")
      )
      server <- function(input, output, session) sqlEmulatorServer(id = "sql_emulator")

      save_items <- c(
        names(uploaded_data()),
        "ui",
        "server",
        "sqlEmulatorUI",
        "sqlEmulatorServer"
      )

      save(list = save_items, file = file)
    }
  )

  output$test_emulator_ui <- renderUI({
    req(uploaded_data())

    list2env(uploaded_data(), globalenv())
    sqlEmulatorUI(id = "test_emulator")
  })

  sqlEmulatorServer(id = "test_emulator")
}
