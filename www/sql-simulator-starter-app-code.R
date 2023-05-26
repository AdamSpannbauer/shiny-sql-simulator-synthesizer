# Load ui, server, data, and more!
load(
  file = "sql-simulator-resources.Rdata",
  envir = globalenv()
)

# Helper function to install needed packages if not available
install_and_load <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    require(pkg, character.only = TRUE)
  }
}

# Load needed packages (install then load as backup)
install_and_load("tools")
install_and_load("shiny")
install_and_load("DT")
install_and_load("sqldf")
install_and_load("shinyAce")
install_and_load("shinyTree")

# Load some fancy stuff for SQL editor
shinyAce:::initResourcePaths()

# Modify this code if you know what you're doing,
# and want to spruce things up!
ui <- fluidPage(
  title = "SQL Simulator",
  tags$head(
    tags$link(
      rel = "shortcut icon",
      href = "https://raw.githubusercontent.com/AdamSpannbauer/shiny-sql-simulator-synthesizer/master/www/favicon.ico"
    )
  ),
  tags$div(
    h3("Available tables:"),
    shinyTree(
      "dataframe_tree",
      theme = "proton",
      themeIcons = FALSE,
      search = TRUE
    ),
    hr()
  ),
  sqlEmulatorUI(id = "sql_emulator")
)

server <- function(input, output, session) {
  sqlEmulatorServer(id = "sql_emulator")

  output$dataframe_tree <- renderTree({
    dataframe_tree_list
  })
}

shiny::shinyApp(ui, server)
