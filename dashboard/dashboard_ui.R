tabItem(tabName = "dash_ui",
        h2("Dashboard Strom in Zahlen"),
        hr(),
        
        fluidRow(
          tabBox(id="tabchart1",width = 12,
                 tabPanel("Börse gruppiert", plotlyOutput("plot1")),
                 tabPanel("Börse", plotlyOutput("day_ah_pr_chart_output")),
                 tabPanel("Tab3", plotlyOutput("plot3"))),
          h2("Day Ahead Price")
        ))