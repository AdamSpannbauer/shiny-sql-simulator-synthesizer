library(tools)

library(shiny)
library(shinydashboard)
library(shinyAce)
library(markdown)

library(DT)
library(sqldf)

source("modules/sql-emulator-module.R")

clean_table_name <- function(table_name) {
  # 1) Only have alphanumeric and underscore chars
  #    replacing other chars with underscore
  table_name <- gsub("[^[:alnum:]_]", "_", table_name)

  # 2) Don't end in trailing underscore
  #    removing underscore if at end of word
  table_name <- gsub("_+$", "", table_name)

  # 3) Should begin with a letter
  if (!(substr(table_name, 1, 1) %in% c(letters, LETTERS))) {
    # add "utk_" to start of table name
    table_name <- paste0("utk_", table_name)
  }

  table_name
}

clean_table_names <- function(table_names) {
  table_names <- vapply(table_names, clean_table_name, character(1))

  # De-duplicate names by adding underscore + unique number at end
  is_dup <- duplicated(table_names)
  dup_id <- cumsum(is_dup)
  table_names <- ifelse(is_dup, paste0(table_names, "_", dup_id), table_names)

  table_names
}

build_df_tree_item <- function(tbl) {
  str_output <- capture.output(str(tbl))
  str_output <- tail(str_output, -1)
  str_output <- substring(str_output, 4)
  str_list <- lapply(str_output, \(x) list(""))
  names(str_list) <- str_output

  df_summary <- paste0(nrow(tbl), " obs. of ", ncol(tbl), " variable")
  if (ncol(tbl) > 1) df_summary <- paste0(df_summary, "s")

  tree_item <- list("", str_list)
  names(tree_item) <- c(df_summary, "variables")

  tree_item
}

SQL_SIMULATOR_STARTER_CODE <- readLines("www/sql-simulator-starter-app-code.R")
