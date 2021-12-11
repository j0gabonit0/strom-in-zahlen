tabPanel(title = "Produktion",
         includeCSS("bootstrap.css"),
         fluidPage(
           theme = shinytheme("flatly"),
           fluidPage(
             theme = shinytheme("flatly"),
             
             tabPanel(
               "Dashboard",
               id = "new",
               
               sidebarPanel(
                 width = 4,
                 fluid = TRUE,
                 menuItem("Wulfener Markt 387", tabName = "dash_ui", selected = TRUE),
                 
                 
                 
               )
             ),
             
             mainPanel(width = 8,
                       tabItems(source(
                         file.path("Dashboard/", "dashboard_ui.R"),
                         encoding = "UTF-8",
                         local = TRUE
                       )$value))
           )
         ))


