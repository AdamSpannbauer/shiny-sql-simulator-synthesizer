library(shiny)
library(shinyAce)

library(DT)
library(sqldf)

# Helpers to truncate data table text columns ----------------------------------

#' Truncate character vector elements
#'
#' This function truncates each element of a character vector to a specified
#' maximum number of characters. If an element exceeds the maximum number of
#' characters, it appends a trailing text to indicate truncation.
#'
#' @param x The character vector to truncate.
#' @param max_chars The maximum number of characters allowed for each element.
#' @param trailing_text The text to append when an element is truncated.
#' @return A truncated character vector.
#' @examples
#' trunc_char_vec(c("Hello, world!", "This is a long sentence."), 10)
#' # Output:
#' # [1] "Hello, wor..." "This is a ..."
trunc_char_vec <- function(x, max_chars = 50, trailing_text = "...") {
  vapply(x, function(elmnt) {
    if (nchar(elmnt) <= max_chars) {
      return(elmnt)
    }

    paste0(substr(elmnt, 1, max_chars), trailing_text)
  }, character(1), USE.NAMES = FALSE)
}

#' Truncate character columns in a data frame
#'
#' This function truncates character columns in a data frame to a specified
#' maximum number of characters. If a column contains character values, each
#' element of that column will be truncated using the \code{\link{trunc_char_vec}}
#' function.
#'
#' @param my_df The data frame to truncate.
#' @param max_chars The maximum number of characters allowed for each element.
#' @param trailing_text The text to append when an element is truncated.
#' @return A data frame with truncated character columns.
#' @examples
#' my_df <- data.frame(
#'   name = c("John Doe", "Jane Smith"),
#'   age = c(30, 25),
#'   comment = c("This is a long comment.", "Another comment.")
#' )
#' trunc_df_char_cols(my_df, 3)
#' # Output:
#' #     name age comment
#' # 1 Joh...  30 Thi...
#' # 2 Jan...  25 Ano...
trunc_df_char_cols <- function(my_df, max_chars = 50, trailing_text = "...") {
  truncated <- lapply(my_df, function(clmn) {
    if (!is.character(clmn)) {
      return(clmn)
    }

    trunc_char_vec(
      clmn,
      max_chars = max_chars,
      trailing_text = trailing_text
    )
  })

  as.data.frame(truncated)
}
# ------------------------------------------------------------------------------


# SQL editor and output module -------------------------------------------------

#' SQL Emulator User Interface
#'
#' This function creates a user interface (UI) module for a SQL emulator. It
#' generates an ACE editor for writing SQL queries, along with buttons for
#' running the query and downloading the query results. The query results are
#' displayed in a DataTable from the DT library.
#'
#' @param id The module ID.
#' @param label The label for the ACE editor.
#' @param placeholder The placeholder text for the ACE editor.
#' @param height The height of the ACE editor.
#' @param icon The icon for the download button.
#' @param button_class The class for the run query button.
#' @return A shiny UI module for the SQL emulator.
#' @examples
#' sqlEmulatorUI("sql_emulator", label = "Enter your SQL query")
sqlEmulatorUI <- function(id,
                          label = "Write your query here",
                          placeholder = "SELECT clue FROM evidence;",
                          height = "200px",
                          button_icon = "database",
                          button_class = "info") {
  shiny::div(
    shiny::fluidRow(
      shiny::column(
        width = 8,
        offset = 2,
        shiny::h3(label),
        shinyAce::aceEditor(
          shiny::NS(id, "code"),
          mode = "sql",
          theme = "chrome",
          height = height,
          debounce = 10,
          placeholder = placeholder
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 8,
        offset = 2,
        align = "right",
        shiny::downloadButton(
          outputId = shiny::NS(id, "download_data"),
          label = "Download results",
          icon = shiny::icon(
            name = "download",
            class = "fa-pull-right",
            style = "font-size: 1.3em"
          )
        ),
        shiny::actionButton(
          inputId = shiny::NS(id, "run_query_button"),
          label = "Run query",
          icon = shiny::icon(
            name = button_icon,
            class = "fa-pull-right",
            style = "font-size: 1.3em"
          ),
          class = paste0("btn-", button_class)
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 8,
        offset = 2,
        shiny::br(),
        shiny::uiOutput(shiny::NS(id, "query_results_ui"))
      )
    )
  )
}

#' SQL Emulator Server
#'
#' This function defines the server logic for the SQL emulator module. It
#' handles the reactive behavior and output generation based on user input
#' and actions.
#'
#' @param id The module ID.
#' @import shiny
#' @import DT
#' @import sqldf
#' @export
#' @examples
#' sqlEmulatorServer("sql_emulator")
sqlEmulatorServer <- function(id) {
  shiny::moduleServer(
    id,
    function(input, output, session) {
      query_result <- eventReactive(input$run_query_button, {
        shiny::isolate(query_text <- input$code)

        if (shiny::isTruthy(query_text)) {
          sqldf::sqldf(query_text, envir = globalenv(), method = "raw")
        }
      })

      output$query_results_dt <- DT::renderDataTable(
        {
          shiny::req(query_result())
          trunc_df_char_cols(query_result())
        },
        options = list(scrollX = TRUE)
      )

      output$query_results_ui <- shiny::renderUI({
        shiny::req(query_result())
        shiny::wellPanel(
          DT::dataTableOutput(shiny::NS(id, "query_results_dt"))
        )
      })

      output$download_data <- shiny::downloadHandler(
        filename = function() {
          "query_results.csv"
        },
        content = function(file) {
          shiny::req(query_result())
          write.csv(query_result(), file, row.names = FALSE)
        }
      )
    }
  )
}
# ------------------------------------------------------------------------------
