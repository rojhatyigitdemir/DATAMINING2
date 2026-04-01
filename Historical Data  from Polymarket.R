library(httr)

test_id <- "1473090" 
test_url <- paste0("https://gamma-api.polymarket.com/markets/", test_id, "/prices?interval=day")

print(paste("Connecting:", test_url))
response <- GET(test_url)

print(paste("status control (Status Code):", status_code(response)))

print(content(response, "text", encoding = "UTF-8"))
