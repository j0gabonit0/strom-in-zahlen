tabItem(tabName = "dash_ui",
        fluidRow(
          tabBox(id="tabchart1",width = 12,
                 tabPanel("Day ahead Price Tagesdurchschnitt", plotlyOutput("day_ah_pr_grpd_chart_output")),
                 tabPanel("Day ahead Price Monatsdurchschnitt", plotlyOutput("day_ah_pr_avg_month")),
                 tabPanel("Day ahead Price", plotlyOutput("day_ah_pr_chart_output")))
        ))