# Script 4: Data Mining and cleaning (Data Preprocessing)

library(dplyr)
library(stringr)
library(jsonlite)

#Let's read the data from last step
tiers_data <- read.csv("01-data_raw/pm_march_2026_tiers.csv", stringsAsFactors = FALSE)


# 1. Extracting a target price (Regex )
# e.g.: "Will Bitcoin reach $150,000 in March?" I'm going to extract number -> 150000 
tiers_data$Target_Price <- as.numeric(gsub("[^0-9]", "", str_extract(tiers_data$question, "\\$[0-9,]+")))

# 2. Breaking down the outcomePrices column (Extracting only the probability of 'Yes' from polymarket data)
# outcomePrices is currently in text format: '["0.0005", "0.9995"]'
# Converting this to a numerical probability that R can understand
parse_yes_prob <- function(price_string) {
  # If there are no data turn to the NA value
  if(is.na(price_string) || price_string == "") return(NA)
  prices <- fromJSON(price_string)
  return(as.numeric(prices[1])) # The first element is the price of the 'Yes' share.
}

# I'm applying the function I created in the previous line to all columns in the polymarket data.
tiers_data$Current_Yes_Probability <- sapply(tiers_data$outcomePrices, parse_yes_prob)

# 3. Determining the directon of event(bet): Reach or Dip questining
tiers_data$Direction <- ifelse(grepl("dip to", tiers_data$question, ignore.case = TRUE), "Dip", "Reach")

# 4. Let’s select only the cleaned columns I will use in the analysis

cleaned_tiers <- tiers_data %>%
  select(id, Direction, Target_Price, Current_Yes_Probability) %>%
  arrange(Target_Price) # sort the prices from lowest to highest

print(head(cleaned_tiers, 10))

# I am saving the cleaned data to the  preprocessed file
if(!dir.exists("02-data_preprocessed")) dir.create("02-data_preprocessed")
write.csv(cleaned_tiers, "02-data_preprocessed/pm_cleaned_tiers.csv", row.names = FALSE)
