library(tools)
library(shiny)
library(DT)
library(sqldf)
library(shinyAce)

shinyAce:::initResourcePaths()
shiny::shinyApp(ui, server)
