# Script 2 (Updated): API data retrievel with looping in R
library(httr)
library(jsonlite)
library(dplyr)

# Empty list to able to collect data from looping
all_events <- list()
base_url <- "https://gamma-api.polymarket.com/events"

# Looping -5 pages- ( 500 active event)
# offset = 0, 100, 200, 300, 400
for (i in seq(0, 400, by = 100)) {
  
  query_params <- list(
    active = "true",
    limit = 100,
    offset = i 
  )
  
  response <- GET(url = base_url, query = query_params)
  
  if (status_code(response) == 200) {
    # flatten = TRUE , Fixing the lists
    raw_data <- fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE)
    all_events[[as.character(i)]] <- as.data.frame(raw_data)
  }
  
  # Waiting 1 sec. everytime to avoid getting ban
  Sys.sleep(1) 
}

# Creating one big table with whole data we collect
market_df <- bind_rows(all_events)
print(paste("Toplam", nrow(market_df), "Events collecting has done, now filtering...."))

# I'm filtering here
target_markets <- market_df %>%
  select(id, title, startDate, endDate, volume) %>%
  mutate(
    endDate = as.Date(endDate),
    startDate = as.Date(startDate)
  ) %>%
  # I'm interesting just BTC or Bitcoin titles
  filter(grepl("Bitcoin|BTC", title, ignore.case = TRUE)) %>%
  # 2026 Date Filter 
  filter(format(endDate, "%Y") == "2026") %>%
  arrange(desc(volume)) # Popular Volumed events filter 

print("Filtering has Done, here is the events I found:")
print(head(target_markets))

# Sonucu klasöre kaydet
if(nrow(target_markets) > 0) {
  write.csv(target_markets, "01-data_raw/filtered_2026_btc_markets.csv", row.names = FALSE)
  print("File succesfully saved as '01-data_raw/filtered_2026_btc_markets.csv'")
} else {
  print("There are no event related with BTC/BITCOIN")
}
