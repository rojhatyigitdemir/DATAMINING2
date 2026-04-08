# Script 10: Statistical Analysis and Regression (With Time Lags)
library(dplyr)
library(broom)

# Reading final dataset
data <- read.csv("02-data_preprocessed/final_analysis_dataset.csv")

# 1. Correlation Analysis
# Using code:'complete.obs' to deleting NA Values
cor_data <- data %>% select(BTC_Spot_Price, Polymarket_Expected_Price, EV_Lag_1, EV_Lag_3, EV_Lag_7)
correlation_matrix <- cor(cor_data, use = "complete.obs")

print("--- Correlation Matrix ---")
print(round(correlation_matrix, 3))

# 2. Multiple Linear Regression
# dependent Variable: Spot BTC Price
# Independent Variable: Polymarket's forecasts for yesterday (t-1), 3 days ago (t-3), and 7 days ago (t-7) + Days remaining until maturity
model <- lm(BTC_Spot_Price ~ EV_Lag_1 + EV_Lag_3 + EV_Lag_7 + Days_to_Expiration, data = data)

print("--- Regression Model Results ---")
print(summary(model))

# 3. Saving the results of Regression Model
if(!dir.exists("04-results")) dir.create("04-results")

# Let’s convert the regression summary into a neat table and save it.
model_results <- tidy(model)
write.csv(model_results, "04-results/regression_summary.csv", row.names = FALSE)

print("The analysis has done and the results have saved on '04-results' file")