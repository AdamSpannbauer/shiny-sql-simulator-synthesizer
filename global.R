library(tools)

library(shiny)
library(shinydashboard)
library(shinyAce)
library(markdown)

library(DT)
library(sqldf)

source("modules/sql-emulator-module.R")

SQL_SIMULATOR_STARTER_CODE <- readLines("www/sql-simulator-starter-app-code.R")
