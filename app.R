### Strom in Zahlen ###

library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(devtools)
library(DT)
library(tidyr)
library(readr)
library(shinyjs)
library(shinythemes)


# Put them together into a dashboardPage

ui <- uiOutput("mainpanel")
server <- function(input, output, session) {
  # ---- UI Files ---- #
  output$mainpanel <- renderUI({
    navbarPage(title = "Solaredge-Board",
               source(
                 file.path("Allgemein_ui.R"),
                 encoding = "UTF-8",
                 local = TRUE
               )$value,)
  })
  
  # ---- Global Files ---- #
  
  # ---- API Files ---- #
  
  # source(file.path("api","prices_entsoe_server.R"), encoding = "UTF-8", local = TRUE)$value
  
  # ---- Server Files --- #
  
}

shinyApp(ui = ui, server = server)
