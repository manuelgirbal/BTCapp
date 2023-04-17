library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)
library(plotly)

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

# Clean environment
rm(list = setdiff(ls(), "btcprice"))


#Computing daily variation:
btcprice <- btcprice %>%
                  arrange(date) %>%
                  mutate(var = round((price/lag(price)-1)*100,1))

btcprice[is.na(btcprice)]<-0


#Plot 1 - Price:
ggplotly(ggplot(btcprice, aes(date, price)) +
                geom_line() +
                ylab("USD Value") +
                xlab("Date") +
                scale_x_date(date_breaks = "1 year", date_labels = "%Y")
        )


#Plot 2 - Price variation:

