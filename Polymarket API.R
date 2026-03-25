# Script 2: Retrieving Bitcoin Market Data from the Polymarket API
# Install the required packages
library(httr)
library(jsonlite)
library(dplyr)

# Polymarket Gamma API Endpoint
base_url <- "https://gamma-api.polymarket.com/events"

# I'am looking for only active events
query_params <- list(
  active = "true",
  query = "Bitcoin"
)

# API GET (request)
response <- GET(url = base_url, query = query_params)

# checking the git
if (status_code(response) == 200) {
  print("Polymarket API Bağlantısı Başarılı! Veriler işleniyor...")
  
  # converting the complex JSON data from the API into an R data frame
  # flatten = TRUE Parametres, fixing the lines
  raw_data <- fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE)
  
  # Let's make the raw data as Dataframe
  market_df <- as.data.frame(raw_data)
  
  # Let’s simplify the data and keep only the columns we need
  btc_markets <- market_df %>%
    select(id, title, startDate, endDate, volume) %>%
    arrange(desc(volume)) # Let’s sort them from largest to smallest by trading volume
  
  # Print first 5 line
  print(head(btc_markets))
  
  # Saving the raw data
  if(!dir.exists("01-data_raw")) dir.create("01-data_raw")
  write.csv(btc_markets, "01-data_raw/polymarket_btc_markets.csv", row.names = FALSE)
  
  print("The Polymarket data was successfully retrieved and saved as '01-data_raw/polymarket_btc_markets.csv'!")
  
} else {
  print(paste("API ERROR", status_code(response)))
}
