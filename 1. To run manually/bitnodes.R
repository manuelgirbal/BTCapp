library(tidyverse)
library(httr)
library(jsonlite)

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

write.csv(nodes_df, file = "BTCapp/R/nodes.csv")
