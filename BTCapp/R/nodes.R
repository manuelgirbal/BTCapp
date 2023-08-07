sudo su - -c "R -q -e "install.packages('rnaturalearth', repos='http://cran.rstudio.com/')""

library(tidyverse)
library(readr)
library(countrycode)
library(rnaturalearth)

## Reading the csv created by file "bitnodes.r"
nodes_df <- read.csv("R/nodes.csv")

# Get country name
country_name <- countrycode(sourcevar = nodes_df$country_code,
                            origin = 'ecb',
                            destination = 'country.name')

nodes_df <- cbind(nodes_df, country_name)

# Creating a nodes count and joining with world dataframe
node_counts <- nodes_df %>%
  filter(!is.na(country_name)) %>%
  group_by(country_name, country_code) %>%
  summarise(nodes = n())


# Adding polygon data to dataset

world_nodes <- ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(admin != "Antarctica") %>%
  mutate(country_code = iso_a2) %>%
  left_join(node_counts, by = "country_code")

# Creating and plotting map

nodes_map <- world_nodes %>%
  ggplot() +
  geom_sf(aes(fill = nodes)) +
  labs(title = "Bitcoin's currently running nodes by country",
       caption = "Source: https://bitnodes.io/") +
  scale_fill_gradient2(low = "white", mid = "lightgrey", high = "darkorange", na.value = "white") +
  theme(plot.background = element_rect(fill = "#A6A6A6"),
        panel.background = element_rect(fill = "#A6A6A6"),
        panel.grid.major = element_line(colour = "#7A7A7A")
  )


