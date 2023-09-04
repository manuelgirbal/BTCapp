library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)

## Getting price data from [CoinGecko](https://www.coingecko.com/)

# Define the API endpoint URL
url <- "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=USD&days=max&interval=daily"

# Send the HTTP request to the API endpoint
response <- GET(url)

# Convert the response to a JSON object
json_data <- fromJSON(content(response, "text"))

# Extract the price data from the JSON object
prices <- json_data$prices

# Convert the price data to a data frame
btcprice <- as_tibble(data.frame(date = as.Date(
  as.POSIXct(prices[,1]/1000, origin = "1970-01-01")
),
price = round(prices[,2],1))
)

#Computing yearly variation (of avg price per year):
yearly <- btcprice %>%
  mutate(year = year(date)) %>%
  group_by(year) %>%
  summarise(avg_price = round(mean(price, na.rm = T),2)) %>%
  arrange(year) %>%
  mutate(year_var = round((avg_price/lag(avg_price)-1),2)) %>%
  replace(is.na(.), 0)

# Creating plot
btcprice_plot <- btcprice %>%
  ggplot(aes(date, price)) +
  geom_line() +
  ylab("USD Price") +
  xlab("Date") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme(plot.background = element_rect(fill = "#A6A6A6"),
        panel.background = element_rect(fill = "#A6A6A6"),
        panel.grid.major = element_line(colour = "#7A7A7A"))
