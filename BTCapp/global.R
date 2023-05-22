library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)
library(plotly)
library(maps)

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


## Getting nodes data from [Bitnodes](https://bitnodes.io/)

# Define the API endpoint URL
url2 <- "https://bitnodes.io/api/v1/snapshots/latest/"

# Send the HTTP request to the API endpoint
response2 <- GET(url2)

# Convert the response to a JSON object
json_data2 <- fromJSON(content(response2, "text"))

# Extract the nodes data from the JSON object
nodes <- json_data2$nodes

node_ids <- names(nodes)

nodes_df <- as_tibble(data.frame(node_ids, do.call(rbind, nodes), stringsAsFactors = FALSE))

colnames(nodes_df) <- c("node_id", "protocol", "user_agent", "connected_since", "services", "height", "hostname", "city", "country_code", "latitude", "longitude", "timezone", "asn", "organization_name")

nodes_df$latitude <- as.numeric(nodes_df$latitude)
nodes_df$longitude <- as.numeric(nodes_df$longitude)

# Creating map
world <- map_data("world")

nodes_map <- ggplot() +
                geom_polygon(data = world, aes(x = long, y = lat, group = group), fill = "white", color = "black") +
                geom_point(data = nodes_df, aes(x = longitude, y = latitude), color = "orange", size = 1.5) +
                xlab("Longitude") +
                ylab("Latitude") +
                theme(plot.background = element_rect(fill = "#A6A6A6"),
                      panel.background = element_rect(fill = "#A6A6A6"),
                      panel.grid.major = element_line(colour = "#7A7A7A")
                )


# Clean environment
rm(list = setdiff(ls(), c("yearly", "btcprice", "nodes_df", "nodes_map")))
