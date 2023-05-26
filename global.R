library(tools)

library(shiny)
library(shinydashboard)
library(shinyAce)
library(markdown)

library(DT)
library(sqldf)

source("modules/sql-emulator-module.R")


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
