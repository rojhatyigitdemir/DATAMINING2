# Script 1: real bitcoin prices (Dependent Variable)
library(quantmod)

# BTC-USD from 2016 until today (daily)
getSymbols("BTC-USD", src = "yahoo", from = "2026-01-01", periodicity = "daily")

# RAW DATA TO DATAFRAME
btc_daily <- data.frame(Date = index(`BTC-USD`), coredata(`BTC-USD`))

# I NEED JUST CLOSING PRICES
btc_clean <- btc_daily[, c("Date", "BTC.USD.Close")]
colnames(btc_clean) <- c("Date", "BTC_Spot_Price")

btc_clean <- na.omit(btc_clean)

# Let's check the DATA

print(head(btc_clean))

# SAVE DATA TO GITIGNORE instead of directly to hitgub
if(!dir.exists("01-data_raw")) dir.create("01-data_raw")
write.csv(btc_clean, "01-data_raw/btc_spot_daily.csv", row.names = FALSE)
