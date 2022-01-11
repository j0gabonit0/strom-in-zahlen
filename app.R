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
library(httr)
library(xml2)
library(lubridate)
library(plotly)
library(stringr)


# Put them together into a dashboardPage

ui <- uiOutput("mainpanel")
server <- function(input, output, session) {
  # ---- UI Files ---- #
  output$mainpanel <- renderUI({
    navbarPage(title = "Strom in Zahlen",
               source(
                 file.path("Allgemein_ui.R"),
                 encoding = "UTF-8",
                 local = TRUE
               )$value)
  })
  
  # ---- Global Files ---- #
  
  source(file.path("C:/Users/corvi/strom-in-zahlen/api/","globale.R"), encoding = "UTF-8", local = TRUE)$value
 
  # ---- API Files ---- #
  
  source(file.path("api","prices_entsoe_server.R"), encoding = "UTF-8", local = TRUE)$value
  
  # ---- Server Files --- #
  
}

shinyApp(ui = ui, server = server)

