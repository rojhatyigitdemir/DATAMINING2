# Script 8: Combining Datasets and Creating Lag/ Day of Expiration=Control Variables
library(dplyr)

# 1. Uploading the data
btc_data <- read.csv("01-data_raw/btc_spot_daily.csv")
pm_data <- read.csv("02-data_preprocessed/polymarket_ev_timeseries.csv")

# Fixing data formats
btc_data$Date <- as.Date(btc_data$Date)
pm_data$Date <- as.Date(pm_data$Date)

# 2. Inner Join to two dataset according to time DATE
# Matches only the days in March for which Polymarket data is available
merged_data <- inner_join(pm_data, btc_data, by = "Date")

# 3. Control variables= day to Expiration
# Day of expiration=31.03.2026
expiration_date <- as.Date("2026-03-31")
merged_data$Days_to_Expiration <- as.numeric(expiration_date - merged_data$Date)

# 4. Creating Lag Variables
# The lag() function shifts the data down one row, bringing the previous day’s data to the current day
merged_data <- merged_data %>%
  arrange(Date) %>%
  mutate(
    EV_Lag_1 = lag(Polymarket_Expected_Price, 1), # Polymarket prediction of yesterday
    EV_Lag_3 = lag(Polymarket_Expected_Price, 3), # Polymarket prediction 3 days ago
    EV_Lag_7 = lag(Polymarket_Expected_Price, 7)  # Polymarket prediction 1 week ago
  )

# 5. Checking the results
print(head(merged_data, 10))

# 6. Saving the final dataset
write.csv(merged_data, "02-data_preprocessed/final_analysis_dataset.csv", row.names = FALSE)
print("Nihai veri '02-data_preprocessed/final_analysis_dataset.csv' olarak kaydedildi!")