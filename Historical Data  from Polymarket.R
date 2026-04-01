# Script 6 (updated): CLOB API ve Token ID retreiving the histrical data
library(httr)
library(jsonlite)
library(dplyr)

# reading clean ID data of polymarket
cleaned_tiers <- read.csv("02-data_preprocessed/pm_cleaned_tiers.csv")
all_historical_data <- list()

for (i in 1:nrow(cleaned_tiers)) {
  current_id <- cleaned_tiers$id[i]
  target_p <- cleaned_tiers$Target_Price[i]
  
  # STEP 1: From Gamma API retrieving "Token ID" 
  market_url <- paste0("https://gamma-api.polymarket.com/markets/", current_id)
  market_response <- GET(market_url)
  
  if (status_code(market_response) == 200) {
    market_data <- fromJSON(content(market_response, "text", encoding = "UTF-8"))
    
    # clobTokenIds JSON FORMAT DATA, AND BETS 
    token_ids <- fromJSON(market_data$clobTokenIds)
    yes_token_id <- token_ids[1]
    
    # AŞAMA 2: With Token ID  from CLOB API retrieving historical data
    # interval=max ve fidelity=1440 - 1 days = 1440 minutes
    history_url <- paste0("https://clob.polymarket.com/prices-history?market=", yes_token_id, "&interval=max&fidelity=1440")
    history_response <- GET(history_url)
    
    if (status_code(history_response) == 200) {
      hist_raw <- fromJSON(content(history_response, "text", encoding = "UTF-8"))
      
      if (!is.null(hist_raw$history) && length(hist_raw$history) > 0) {
        # Turning the histrical data into the DATAFRAME
        df <- as.data.frame(hist_raw$history)
        df$market_id <- current_id
        df$target_price <- target_p
        df$direction <- cleaned_tiers$Direction[i]
        
        # T -time codes comes as a seconds, turning them readable form
        df$Date <- as.Date(as.POSIXct(df$t, origin="1970-01-01"))
        
        all_historical_data[[as.character(current_id)]] <- df
        print(paste("Successfull: ID", current_id, "Historical daily data was retrieved."))
      } else {
        print(paste("Warning: ID", current_id, "Data has not generated yet"))
      }
    } else {
      print(paste("CLOB Hatası - ID:", current_id, "- Kod:", status_code(history_response)))
    }
  } else {
    print(paste("Gamma Error - ID:", current_id))
  }
  
  # Measurement against API BAN - 1.sec
  Sys.sleep(1) 
}

# Loop has done. I'm making big dataframe with whole data i've retrieved. 
if (length(all_historical_data) > 0) {
  final_historical_df <- bind_rows(all_historical_data)
  
  # Don't include unnecesserey time codes (t) and list it again after that
  final_historical_df <- final_historical_df %>%
    select(Date, market_id, target_price, direction, p)
  
  print("Historical data has collected successfully, here is the result:")
  print(head(final_historical_df))
  
  # Saving to the raw data  (.gitignore)
  if(!dir.exists("01-data_raw")) dir.create("01-data_raw")
  write.csv(final_historical_df, "01-data_raw/all_tiers_historical_probs.csv", row.names = FALSE)
  print("Big Dataframe with time codes has successfully saved!")
} else {
  print("ERROR: No data has found, empty dataframe")
}
