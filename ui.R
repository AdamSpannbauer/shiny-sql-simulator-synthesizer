library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  skin = "black",
  title = "SQL Simulator Synthesizer",
  dashboardHeader(
    title = "SQL Simulator Synthesizer"
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        text = "Upload and test",
        tabName = "upload",
        icon = icon("cloud-arrow-up")
      ),
      menuItem(
        text = "Download app",
        tabName = "download",
        icon = icon("download")
      )
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "style.css"
      ),
      tags$link(
        rel = "shortcut icon",
        href = "favicon.ico"
      ),
      tags$meta(
        name = "title",
        content = "SQL Simulator Synthesizer"
      ),
      tags$meta(
        name = "description",
        content = "Generate shiny apps to simulate SQL for students."
      ),
      tags$meta(
        property = "og:type",
        content = "website"
      ),
      tags$meta(
        property = "og:url",
        content = "https://spannbaueradam.shinyapps.io/sql-simulator-synthesizer/"
      ),
      tags$meta(
        property = "og:title",
        content = "SQL Simulator Synthesizer"
      ),
      tags$meta(
        property = "og:description",
        content = "Generate shiny apps to simulate SQL for students."
      ),
      tags$meta(
        property = "og:image",
        content = "social-preview.png"
      ),
      tags$meta(
        property = "twitter:card",
        content = "summary_large_image"
      ),
      tags$meta(
        property = "twitter:url",
        content = "https://spannbaueradam.shinyapps.io/sql-simulator-synthesizer/"
      ),
      tags$meta(
        property = "twitter:title",
        content = "SQL AirbnBandit!"
      ),
      tags$meta(
        property = "twitter:description",
        content = "Hunt down the AirbnBandit armed with a SQL database, a series of clues, and your own ingenuity!"
      ),
      tags$meta(
        property = "twitter:image",
        content = "social-preview.png"
      ),
    ),
    tabItems(
      tabItem(
        tabName = "upload",
        fileInput(
          inputId = "csv_files",
          label = "Upload CSV files",
          multiple = TRUE,
          accept = c(
            "text/csv",
            "text/comma-separated-values,text/plain",
            ".csv"
          )
        ),
        uiOutput("table_name_list"),
        uiOutput("test_emulator_ui")
      ),
      tabItem(
        tabName = "download",
        uiOutput("download_app_btn_ui"),
        uiOutput("how_to_use")
      )
    )
  )
)
