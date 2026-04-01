library(httr)
library(jsonlite)
library(dplyr)

# Temizlenmiş verimizi okuyoruz
cleaned_tiers <- read.csv("02-data_preprocessed/pm_cleaned_tiers.csv")

# Geçmiş verileri toplayacağımız boş liste
all_historical_data <- list()


# Her bir ID için geçmiş veriyi çeken döngü
for (i in 1:nrow(cleaned_tiers)) {
  current_id <- cleaned_tiers$id[i]
  target_p <- cleaned_tiers$Target_Price[i]
  
  history_url <- paste0("https://gamma-api.polymarket.com/markets/", current_id, "/prices?interval=day")
  response <- GET(history_url)
  
  if (status_code(response) == 200) {
    hist_raw <- fromJSON(content(response, "text", encoding = "UTF-8"))
    
    if (length(hist_raw) > 0) {
      df <- as.data.frame(hist_raw)
      df$market_id <- current_id
      df$target_price <- target_p
      df$direction <- cleaned_tiers$Direction[i]
      df$Date <- as.Date(as.POSIXct(df$t, origin="1970-01-01"))
      
      all_historical_data[[as.character(current_id)]] <- df
    }
  }
  Sys.sleep(0.5)  
}

# Verileri birleştir ve temizle
final_historical_df <- bind_rows(all_historical_data)
final_historical_df <- final_historical_df %>%
  select(Date, market_id, target_price, direction, p)

print(head(final_historical_df))

# Veriyi kaydedelim
write.csv(final_historical_df, "01-data_raw/all_tiers_historical_probs.csv", row.names = FALSE)