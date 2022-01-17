### Ermittlung des letzten Datensatzes

day_ahead_prices_db <- read.csv("api/day_ahead_price_db.csv") %>% 
 mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S")) %>% 
 filter(timestamp > 0)

today <- Sys.Date()

#### Juengstes Datum in der Datenbank
last_day <- max(day_ahead_prices_db$timestamp)

if(last_day > today) {
  day_ahead_prices_db <- day_ahead_prices_db %>% 
    filter(timestamp < today)
  
} else{
  last_day <- last_day
}



last_timestamp <- max(day_ahead_prices_db$timestamp)


day_ahead_prices_db <- day_ahead_prices_db %>% 
  filter(timestamp < last_day)

#### Festlegen des Start und Enddatums für den API Call
start_time <- gsub("-", "", as.character(last_day), 1, 16)
start_time <- gsub(" ", "", as.character(start_time), 1, 16) 
start_time <- gsub(":", "", as.character(start_time), 1, 16) 
start_time <- start_time %>% substr(1, 12)

end_time <- paste0(Sys.Date() + 1)
end_time <- gsub("-", "", as.character(end_time), 1, 16) %>% paste0("0000")


document_type = "A44"
in_Domain = "10YCZ-CEPS-----N"
out_Domain = "10YCZ-CEPS-----N"
period_start = start_time
period_end = end_time

### Ifelse wenn der letzte Eintrag in der Datenbank 

### Einrichten einer leeren Datenbank
day_ahead_prices_db_nw <-
  data_frame(timestamp = character(), value = integer()) %>% 
  mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S"))

api_day_ahead_prices <-
  function(document_type,
           in_Domain,
           out_Domain,
           period_start,
           period_end) {
    api_token_entsoe <- "48ff8b28-8186-4983-8ceb-8a129f4cff44"
    ### API Abruf und Speicherung in XML File ###
    
    api_url <- paste(
      "https://transparency.entsoe.eu//api?documentType=",
      document_type,
      "&in_Domain=",
      in_Domain,
      "&out_Domain=",
      out_Domain,
      "&periodStart=",
      period_start,
      "&periodEnd=",
      period_end,
      "&securityToken=48ff8b28-8186-4983-8ceb-8a129f4cff44",
      sep = ""
    )
    
    day_ahead_api <-
      GET(
        api_url
      )
    day_ahead_content <- content(day_ahead_api, "raw")
    writeBin(day_ahead_content, "myfile.xml")
    
    ### Einlesen des XML Files und formatieren als Dataframe mit 2 Spalten ###
    day_ahead_prices_xml = as_list(read_xml("myfile.xml"))
    
    xml_df = tibble::as_tibble(day_ahead_prices_xml) %>%
      unnest_longer(Publication_MarketDocument)
    
    dap_wider = xml_df %>%
      dplyr::filter(Publication_MarketDocument_id == "Period") %>%
      unnest_wider(Publication_MarketDocument)
    
    dap_df = dap_wider %>%
      # 1st time unnest to release the 2-dimension list?
      unnest(cols = names(.)) %>%
      # Entferne jede zweite Zeile
      slice(which(row_number() %% 2 == 0)) %>%
      # Bennen Namen der Spalte in Uhrzeiten um
      rename(
        "01:00:00" = Point...3,
        "02:00:00" = Point...4,
        "03:00:00" = Point...5,
        "04:00:00" = Point...6,
        "05:00:00" = Point...7,
        "06:00:00" = Point...8,
        "07:00:00" = Point...9,
        "08:00:00" = Point...10,
        "09:00:00" = Point...11,
        "10:00:00" = Point...12,
        "11:00:00" = Point...13,
        "12:00:00" = Point...14,
        "13:00:00" = Point...15,
        "14:00:00" = Point...16,
        "15:00:00" = Point...17,
        "16:00:00" = Point...18,
        "17:00:00" = Point...19,
        "18:00:00" = Point...20,
        "19:00:00" = Point...21,
        "20:00:00" = Point...22,
        "21:00:00" = Point...23,
        "22:00:00" = Point...24,
        "23:00:00" = Point...25,
        "24:00:00" = Point...26,
      ) %>%
      # 2nd time to nest the single list in each cell?
      unnest(cols = names(.)) %>%
      # convert data type
      readr::type_convert() %>%
      select(-Publication_MarketDocument_id,-resolution) %>%
      pivot_longer(!timeInterval, names_to = "timee",
                   values_to = "value") %>%
      mutate(date = timeInterval %>% as.character() %>% substr(1, 10)) %>%
      # Kombiniere der Spalten time und date zu timestamp
      unite(timestamp, date, timee, sep = " ") %>%
      select(-timeInterval) %>%
      mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S")) %>%
      unnest(., value) %>%
      mutate(value = as.numeric(value)) 
      
    
    day_ahead_prices_db_nw <- bind_rows(day_ahead_prices_db_nw, dap_df) %>%
      replace(is.na(.), 0)
    
    day_ahead_prices_db_nw <- day_ahead_prices_db_nw %>% 
      replace(is.na(.), 0) %>% 
      merge(day_ahead_prices_db, ., all = TRUE) %>%
      replace(is.na(.), 0) %>% 
    
    
    write.csv("api/day_ahead_price_db.csv",row.names=FALSE)
    
  }


api_day_ahead_prices(document_type = "A44",
                     in_Domain = "10YCZ-CEPS-----N",
                     out_Domain = "10YCZ-CEPS-----N",
                     period_start = start_time,
                     period_end = end_time)




day_ahead_prices_df <- read.csv("api/day_ahead_price_db.csv")



###--------- Day Ahead Prices ---------###
day_ah_pr_chart <- reactive({
  data <- day_ahead_prices_df
  data %>%
    mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S")) %>%
    plot_ly(type = 'scatter', mode = 'lines') %>%
    add_trace(x = ~ timestamp,
              y = ~ value,
              name = 'time') %>%
    
    layout(
      showlegend = F,
      title = "Day Ahead Price",
      xaxis = list(
        title = "Datum",
        showline = T,
        linewidth = 2,
        linecolor = 'black',
        showgrid = T,
        gridcolor = 'red',
        rangeslider = list(visible = T),
        rangeselector = list(buttons = list(
          list(
            count = 1,
            label = "1m",
            step = "month",
            stepmode = "backward"
          ),
          list(
            count = 6,
            label = "6m",
            step = "month",
            stepmode = "backward"
          ),
          list(
            count = 3,
            label = "3D",
            step = "day",
            stepmode = "backward"
          ),
          list(
            count = 1,
            label = "1y",
            step = "year",
            stepmode = "backward"
          ),
          list(step = "all")
        ))
      ),
      yaxis = list(
        title = "\U20AC/MwH",
        tickprefix="\U20AC",
        showline = T,
        linewidth = 2,
        linecolor = 'black',
        showgrid = T,
        gridcolor = 'blue',
        nticks = 20
      )
    )
})


output$day_ah_pr_chart_output <- renderPlotly({
  day_ah_pr_chart()
})


###--------- Day Ahead Prices gruppiert ---------###
day_ah_pr_grpd_chart <- reactive({
  data <- day_ahead_prices_df
  data %>%
    mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S")) %>%
    group_by(timestamp = floor_date(timestamp, unit = "day")) %>%
    summarise(value = mean(value)) %>%
    plot_ly(type = 'scatter', mode = 'lines') %>%
    add_trace(x = ~ timestamp,
              y = ~ value,
              name = 'time') %>%
    
    layout(
      showlegend = F,
      title = "Day Ahead Price Tagesdurchschnitt",
      xaxis = list(
        title = "Datum",
        showline = T,
        linewidth = 2,
        linecolor = 'black',
        showgrid = T,
        gridcolor = 'red',
        rangeslider = list(visible = T),
        rangeselector = list(buttons = list(
          list(
            count = 1,
            label = "1m",
            step = "month",
            stepmode = "backward"
          ),
          list(
            count = 6,
            label = "6m",
            step = "month",
            stepmode = "backward"
          ),
          list(
            count = 3,
            label = "3D",
            step = "day",
            stepmode = "backward"
          ),
          list(
            count = 1,
            label = "1y",
            step = "year",
            stepmode = "backward"
          ),
          list(step = "all")
        ))
      ),
      yaxis = list(
        title = "\U20AC/MwH",
        tickprefix="\U20AC",
        showline = T,
        linewidth = 2,
        linecolor = 'black',
        showgrid = T,
        gridcolor = 'blue',
        nticks = 20
      )
    )
})


output$day_ah_pr_grpd_chart_output <- renderPlotly({
  day_ah_pr_grpd_chart()
})

day_ah_pr_avg_month <- reactive({
  data <- day_ahead_prices_df
  data %>%
    mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S")) %>%
    group_by(timestamp = floor_date(timestamp, unit = "month")) %>%
    summarise(value = mean(value)) %>%
    plot_ly(type = 'scatter', mode = 'lines') %>%
    add_trace(x = ~ timestamp,
              y = ~ value,
              name = 'time') %>%
    layout(
      showlegend = F,
      title = "Day Ahead Price Tagesdurchschnitt",
      xaxis = list(
        title = "Datum",
        showline = T,
        linewidth = 2,
        linecolor = 'black',
        showgrid = T,
        gridcolor = 'red'
      ),
      yaxis = list(
        title = "\U20AC/MwH",
        tickprefix="\U20AC",
        showline = T,
        linewidth = 2,
        linecolor = 'black',
        showgrid = T,
        gridcolor = 'blue',
        nticks = 20
      )
    )
})

output$day_ah_pr_avg_month <- renderPlotly({
  day_ah_pr_avg_month()
}) 












