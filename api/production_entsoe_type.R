### Aggregierte Produktion pro Typ


# https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html

Code
Solar = B17


GET https: /  / transparency.entsoe.eu /  / api ? documentType = A75 &
  processType = A16 &
  psrType = B02 &
  in_Domain = 10YCZ - CEPS-----N &
  periodStart = 201512312300 & periodEnd = 201612312300


document_type = "A75"
processType = "A16"
psrType = "B17"
in_Domain = "10Y1001A1001A82H"
period_start = "202101010000"
period_end = "202101050000"

prod_api_url <- paste(
  "https://transparency.entsoe.eu//api?documentType=",
  document_type,
  "&processType=",
  processType,
  "&psrType=",
  psrType,
  "&in_Domain=",
  in_Domain,
  "&periodStart=",
  period_start,
  "&periodEnd=",
  period_end,
  "&securityToken=48ff8b28-8186-4983-8ceb-8a129f4cff44",
  sep = ""
)

prod_api <-
  GET(prod_api_url)

prod_content <- content(prod_api, "raw")
writeBin(prod_content, "myfile_prod.xml")

### Einlesen des XML Files und formatieren als Dataframe mit 2 Spalten ###
prod_xml = as_list(read_xml("myfile_prod.xml"))

prod_xml_df = tibble::as_tibble(prod_xml) %>%
  unnest_longer(GL_MarketDocument)

pro_dap_wider = prod_xml_df %>%
  dplyr::filter(GL_MarketDocument_id == "Period") %>%
  unnest_wider(GL_MarketDocument)

prod_dap_df = pro_dap_wider %>%
  unnest(cols = names(.)) %>%
  unnest(cols = names(.)) %>%
  select(-resolution, -GL_MarketDocument_id) %>%
  slice(2) %>%
  pivot_longer(!timeInterval, names_to = "time", values_to = "mw") %>%
  select(mw) %>%
  mutate(timestamp = seq.POSIXt(
    ymd_hms("2021-01-01 00:00:00"),
    ymd_hms("2021-01-04 23:45:00"),
    by = "15 mins"
  )) %>%
  unnest(., mw)

day_ahead_prices_db_nw <-
  bind_rows(day_ahead_prices_db, prod_dap_df)



write.csv(prod_dap_df, "api/data/prod_db.csv", row.names = FALSE)


################################################################################

today <- Sys.Date()


### Ermittlung des letzten Datensatzes

prod_db <- read.csv("api/data/prod_db.csv") %>%
  mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S")) %>%
  mutate(mw = as.character(mw)) %>% 
  filter(timestamp > 0) %>%
  filter(timestamp < today)

#### Juengstes Datum in der Datenbank
last_day <- max(prod_db$timestamp) %>%
  substr(1, 11) %>%
  paste0("0000")


last_timestamp <- max(prod_db$timestamp)
prod_db <- prod_db %>%
  filter(timestamp < last_day)

last_date <- last_timestamp %>% as.character() %>% substr(1, 10)
last_date <- gsub("-", "", as.character(last_date), 1, 10) %>%  paste0("0000")

#### Festlegen des Start und Enddatums für den API Call
start_time <- gsub("-", "", as.character(last_day), 1, 16)
start_time <- gsub(" ", "", as.character(start_time), 1, 16)
start_time <- gsub(":", "", as.character(start_time), 1, 16)
start_time <- start_time %>% substr(1, 12)

end_time <- (last_timestamp + 604800) %>% as.character() %>% substr(1, 10) 
end_time <- gsub(" ", "", as.character(end_time), 1, 16)
end_time <- gsub(":", "", as.character(end_time), 1, 16)
end_time <-  gsub("-", "", as.character(end_time), 1, 16) %>% paste0("0000")

end_timestamp <- last_timestamp + 604800

### Einrichten einer leeren Datenbank
prod_db_nw <-
  data_frame(timestamp = character(), value = integer()) %>%
  mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S"))


api_prod <-
  function(document_type,
           processType,
           psrType,
           in_Domain,
           period_start,
           period_end) {
    prod_api_url <- paste(
      "https://transparency.entsoe.eu//api?documentType=",
      document_type,
      "&processType=",
      processType,
      "&psrType=",
      psrType,
      "&in_Domain=",
      in_Domain,
      "&periodStart=",
      period_start,
      "&periodEnd=",
      period_end,
      "&securityToken=48ff8b28-8186-4983-8ceb-8a129f4cff44",
      sep = ""
    )
    
    prod_api <-
      GET(prod_api_url)
    
    prod_content <- content(prod_api, "raw")
    writeBin(prod_content, "myfile_prod.xml")
    
    ### Einlesen des XML Files und formatieren als Dataframe mit 2 Spalten ###
    prod_xml = as_list(read_xml("myfile_prod.xml"))
    
    prod_xml_df = tibble::as_tibble(prod_xml) %>%
      unnest_longer(GL_MarketDocument)
    
    pro_dap_wider = prod_xml_df %>%
      dplyr::filter(GL_MarketDocument_id == "Period") %>%
      unnest_wider(GL_MarketDocument)
    
    prod_dap_df = pro_dap_wider %>%
      unnest(cols = names(.)) %>%
      select(-resolution, -GL_MarketDocument_id) %>%
      slice(2) %>%
      pivot_longer(!timeInterval, names_to = "time", values_to = "mw") %>%
      select(mw) #%>%
      mutate(timestamp = seq.POSIXt(
        ymd_hms(last_timestamp),
        ymd_hms(end_timestamp),
        by = "15 mins"
      )) %>%
      unnest(., mw) %>% 
      mutate(mw = as.character(mw))
    
    prod_db_nw <- bind_rows(prod_db, prod_dap_df)
    
    write.csv(prod_db_nw, "api/data/prod_db.csv", row.names = FALSE)
    
    
  }


### Funktion API Produktion Entsoe

api_prod(
  document_type = "A75",
  processType = "A16",
  psrType = "B17",
  in_Domain = "10Y1001A1001A82H",
  period_start = 202101040000,
  period_end = 202112310000
)

document_type = "A75"
processType = "A16"
psrType = "B17"
in_Domain = "10Y1001A1001A82H"
period_start = start_time
period_end = end_time


