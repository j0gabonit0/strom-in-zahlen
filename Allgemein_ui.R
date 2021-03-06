tabPanel(title = "Day Ahead Price",
         includeCSS("bootstrap.css"),
         fluidPage(
           theme = shinytheme("flatly"),
           fluidPage(
             theme = shinytheme("flatly"),
             
             tabPanel(
               "Dashboard",
               id = "new",
               
               sidebarPanel(
                 width = 2,
                 fluid = TRUE,
                 menuItem("Boersenpreise EEX", tabName = "dash_ui", selected = TRUE),
               )
             ),
             
             mainPanel(width = 10,
                       tabItems(source(
                         file.path("dashboard", "dashboard_ui.R"),
                         encoding = "UTF-8",
                         local = TRUE
                       )$value))
           )
         ))
