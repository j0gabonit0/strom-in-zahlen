#### API ENTSOE MArket Data Energy Prices ###

library(httr)
library(jsonlite)
library(urltools)
library(scales)
library(xml2)
library(tidyverse)




### API Zugansg Daten ENTSOE ###
api_token_entsoe <- "48ff8b28-8186-4983-8ceb-8a129f4cff44"

### API Abruf und Speicherung in XML File ###
day_ahead_api <- GET("https://transparency.entsoe.eu//api?documentType=A44&in_Domain=10YCZ-CEPS-----N&out_Domain=10YCZ-CEPS-----N&periodStart=201512312300&periodEnd=201612312300&securityToken=48ff8b28-8186-4983-8ceb-8a129f4cff44")
day_ahead_content <- content(day_ahead_api, "raw")
writeBin(day_ahead_content, "C:/Users/sascha/myfile.xml")

### Einlesen des XML Files und formatieren als Dataframe mit 2 Spalten ###
day_ahead_prices_xml = as_list(read_xml("C:/Users/sascha/myfile.xml"))

xml_df = tibble::as_tibble(day_ahead_prices_xml) %>%
  unnest_longer(Publication_MarketDocument)

dap_wider = xml_df %>%
  dplyr::filter(Publication_MarketDocument_id == "Period") %>%
  unnest_wider(Publication_MarketDocument) 

dap_df = lp_wider %>%
  # 1st time unnest to release the 2-dimension list?
  unnest(cols = names(.)) %>%
  # Entferne jede zweite Zeile
  slice(which(row_number() %% 2 == 0)) %>%
  # Bennen Namen der Spalte in Uhrzeiten um
  rename("01:00:00" = Point...3,
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
         "24:00:00" = Point...26,) %>% 
  # 2nd time to nest the single list in each cell?
  unnest(cols = names(.)) %>%
  # convert data type
  readr::type_convert() %>% 
  select(-Point...27,-Publication_MarketDocument_id,-resolution) %>% 
  pivot_longer(!timeInterval, names_to = "timee",
               values_to = "value") %>% 
  mutate(date = timeInterval %>% as.character() %>% substr(1, 10)) %>% 
  # Kombiniere der Spalten time und date zu timestamp
  unite(timestamp, date, timee, sep =" ") %>% 
  select(-timeInterval) %>% 
  mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S")) %>% 
  unnest(., value) %>% 
  mutate(value = as.numeric(value))