# Retrieving the Submarkets of a Specific Polymarket Event
library(httr)
library(jsonlite)
library(dplyr)

# Slug
slug <- "what-price-will-bitcoin-hit-in-march-2026"
base_url <- paste0("https://gamma-api.polymarket.com/events?slug=", slug)

response <- GET(url = base_url)

# transform the data to the R script
if (status_code(response) == 200) {
  event_data <- fromJSON(content(response, "text", encoding = "UTF-8"))
  
  # Dataframe and data cleanning
  if ("markets" %in% colnames(event_data)) {
    markets_df <- event_data$markets[[1]]
    
    # Let’s select and clean only the columns needed for our analysis
    # question: Subheadings like Bitcoin > $70k?
    # id: The ID of this specific subheading, for old version data of the event
    # outcomePrices: current prices of each possibilities
    clean_markets <- markets_df %>%
      select(id, question, active, outcomePrices) %>%
      filter(active == TRUE)
    
    print(clean_markets)
    
    # save data to raw file
    if(!dir.exists("01-data_raw")) dir.create("01-data_raw")
    write.csv(clean_markets, "01-data_raw/pm_march_2026_tiers.csv", row.names = FALSE)
    print("Market data has been saved '01-data_raw/pm_march_2026_tiers.csv'")
    
  } else {
    print("ERROR: not found.")
  }
} else {
  print(paste("API ERROR:", status_code(response)))
}
