#Expected Value Masurement with Polymarket Predictions
library(dplyr)

#Only taking account ''dip'' bets (polymarket predictions), sorting from highest price to lowest.

dip_markets <- tiers_data %>%
  filter(Direction == "Dip") %>%
  arrange(desc(Target_Price))

## Subtracting "marginal" probabilities from cumulative probabilities 
#(e.g., the probability of the BTC price remaining between 60k and 65k).

dip_markets$Marginal_Probability <- c(
  abs(diff(dip_markets$Current_Yes_Probability)), 
  tail(dip_markets$Current_Yes_Probability, 1) # Probability of last event is itsself
)

#It shouldnt be negative probability, taking the absolute value
dip_markets$Marginal_Probability <- ifelse(dip_markets$Marginal_Probability < 0, 0, dip_markets$Marginal_Probability)

#Expected Value (Price * Marginal probability)
dip_markets$EV_Contribution <- dip_markets$Target_Price * dip_markets$Marginal_Probability

#Sum of Expected Value Contributions
#There are no all probabilities, eg. over 65k
#Therefore, we take the weighted average of the available probabilities
total_marginal_prob <- sum(dip_markets$Marginal_Probability)
expected_btc_price <- sum(dip_markets$EV_Contribution) / total_marginal_prob

print(dip_markets[, c("Target_Price", "Current_Yes_Probability", "Marginal_Probability", "EV_Contribution")])
print(paste("Expected Bitcoin Prices according to Polymarket Communities: $", round(expected_btc_price, 2)))

#Saving the result of this round, to able to use it later
ev_result <- data.frame(
  Date = Sys.Date(),
  Expected_Price = round(expected_btc_price, 2)
)

write.csv(ev_result, "02-data_preprocessed/current_expected_value.csv", row.names = FALSE)
