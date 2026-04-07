# Script 7: Creating daily expected time series from historical data- EV
library(dplyr)

# Reading the massive historical data we collected in the previous session
hist_data <- read.csv("01-data_raw/all_tiers_historical_probs.csv")

# Finding the unique dates
unique_dates <- sort(unique(hist_data$Date))
daily_ev_results <- list()

# Starting a loop for each day
for (current_date in unique_dates) {
  
  # Filtering the days
  daily_data <- hist_data %>% filter(Date == current_date)
  
  
  # 1. REACH- UP
  reach_m <- daily_data %>% filter(direction == "Reach") %>% arrange(target_price)
  if(nrow(reach_m) > 0) {
    reach_m$marginal_p <- c(abs(diff(reach_m$p)), tail(reach_m$p, 1))
    reach_m$marginal_p <- pmax(reach_m$marginal_p, 0)
  }
  
  # 2. DIP - Down
  dip_m <- daily_data %>% filter(direction == "Dip") %>% arrange(desc(target_price))
  if(nrow(dip_m) > 0) {
    dip_m$marginal_p <- c(abs(diff(dip_m$p)), tail(dip_m$p, 1))
    dip_m$marginal_p <- pmax(dip_m$marginal_p, 0)
  }
  
  # 3. Middle Area
  max_dip_prob <- ifelse(nrow(dip_m) > 0, head(dip_m$p, 1), 0)
  min_reach_prob <- ifelse(nrow(reach_m) > 0, head(reach_m$p, 1), 0)
  
  middle_prob <- max(1 - (max_dip_prob + min_reach_prob), 0)
  
  target_dip_head <- ifelse(nrow(dip_m) > 0, head(dip_m$target_price, 1), NA)
  target_reach_head <- ifelse(nrow(reach_m) > 0, head(reach_m$target_price, 1), NA)
  middle_target <- mean(c(target_dip_head, target_reach_head), na.rm = TRUE)
  
  middle_zone <- data.frame(target_price = middle_target, marginal_p = middle_prob)
  
  # Merge and Calculate EV
  full_day_market <- bind_rows(
    if(nrow(dip_m) > 0) select(dip_m, target_price, marginal_p) else NULL,
    middle_zone,
    if(nrow(reach_m) > 0) select(reach_m, target_price, marginal_p) else NULL
  )
  
  # Calculate expected value of that day - EV of each day
  full_day_market$ev_contrib <- full_day_market$target_price * full_day_market$marginal_p
  daily_ev <- sum(full_day_market$ev_contrib, na.rm = TRUE)
  
  # List the results
  daily_ev_results[[as.character(current_date)]] <- data.frame(
    Date = as.Date(current_date),
    Polymarket_Expected_Price = round(daily_ev, 2)
  )
}

# Merge the time series data frame
ev_timeseries <- bind_rows(daily_ev_results) %>% arrange(Date)


print(head(ev_timeseries, 10))

# Independent Variabl (EV Time Series) has saved on preprocessed doc.
write.csv(ev_timeseries, "02-data_preprocessed/polymarket_ev_timeseries.csv", row.names = FALSE)
print("DATA '02-data_preprocessed/polymarket_ev_timeseries.csv' has been saved.!")
