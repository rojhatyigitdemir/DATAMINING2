# Script 9: GRAPH Time Series (Spot Price vs. Polymarket EV)
library(ggplot2)
library(dplyr)
library(tidyr)

# Reading final data set
data <- read.csv("02-data_preprocessed/final_analysis_dataset.csv")
data$Date <- as.Date(data$Date)

print("Getting ready - Visualization")

# converting the data to the ‘Long’ format for GGPLOT graph generator
plot_data <- data %>%
  select(Date, BTC_Spot_Price, Polymarket_Expected_Price) %>%
  pivot_longer(cols = c(BTC_Spot_Price, Polymarket_Expected_Price),
               names_to = "Price_Type",
               values_to = "Price")

# Generating the graph
p <- ggplot(plot_data, aes(x = Date, y = Price, color = Price_Type)) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(
    values = c("BTC_Spot_Price" = "gold3", "Polymarket_Expected_Price" = "steelblue"),
    labels = c("Bitcoin Spot Prices", "Polymarket Expected Value EV")
  ) +
  labs(
    title = "Comparison of Bitcoin Spot Prices and Polymarket Predictions",
    subtitle = "March 2026: As Date Approaches, Forecasts Converge on Reality",
    x = "Date",
    y = "Price (USD)",
    color = "Variables"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Print the plot
print(p)

# Saving the plot
if(!dir.exists("05-plots")) dir.create("05-plots")
ggsave("05-plots/01_btc_vs_ev_timeseries.png", plot = p, width = 10, height = 6, dpi = 300)

print("The plot has drafted and '05-plots/01_btc_vs_ev_timeseries.png' saved!")