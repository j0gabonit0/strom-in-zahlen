tabItem(tabName = "dash_ui",
        h2("Dashboard Strom in Zahlen"),
        hr(),
        
        fluidRow(
          tabBox(id="tabchart1",width = 12,
                 tabPanel("Day ahead Price gruppiert", plotlyOutput("day_ah_pr_grpd_chart_output")),
                 tabPanel("Day ahead Price", plotlyOutput("day_ah_pr_chart_output")),
                 tabPanel("Day ahead Price Monatsdurchschnitt", plotlyOutput("day_ah_pr_avg_month"))),
          h2("Day Ahead Price")
        ))