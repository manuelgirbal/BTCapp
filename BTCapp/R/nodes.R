library(tidyverse)
library(httr)
library(jsonlite)
library(maps)
library(readr)

## Getting nodes data from [Bitnodes](https://bitnodes.io/)

nodes_df <- read.csv("R/nodes.csv")

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
