library(shiny)
library(tidyverse)
library(plotly)
library(httr)
library(jsonlite)
library(lubridate)
library(maps)
library(DT)
library(shinydashboard)
library(bslib)
library(readr)

# source(file = "bitnodes.R") -- because of "Could not resolve host: bitnodes.io" error in logs, this file has to be run first, manually


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

nodes_df <- read.csv("nodes.csv")

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


## UI

ui <- navbarPage(

  theme = bs_theme(bootswatch = "slate"),
  title = "BTCapp",

  tabPanel("Price",
           div(style = "width: 80%; margin: auto;", plotlyOutput("price")),
           div(style = "width: 60%; margin: auto;", dataTableOutput("yearly"))
  ),
  tabPanel("Network",
           fluidRow(
             column(
               offset = 5,
               width = 5,
               valueBoxOutput("vbox1")
             )
           ),
           div(style = "width: 80%; margin: auto;", plotOutput("nodes")),
           div(style = "width: 60%; margin: auto;", dataTableOutput("nodestable"))
  )
)


## Server

server <- function(input, output, session) {

  output$price <- renderPlotly({
    ggplot(btcprice, aes(date, price)) +
      geom_line() +
      ylab("USD Value") +
      xlab("Date") +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
      theme(plot.background = element_rect(fill = "#A6A6A6"),
            panel.background = element_rect(fill = "#A6A6A6"),
            panel.grid.major = element_line(colour = "#7A7A7A")
      )
  })



  output$yearly <- DT::renderDataTable({
    datatable(yearly,
              options = list(
                lengthChange = FALSE,
                searching = FALSE,
                paging = FALSE,
                info = FALSE,
                columnDefs = list(list(className = 'dt-center', targets = "_all"))),
              rownames = FALSE) %>%
      formatPercentage("year_var",
                       2) %>%
      formatStyle("year_var",
                  fontWeight = "bold",
                  backgroundColor = styleInterval(c(-0.01, 0.01),
                                                  c("#FFCDD2", "grey", "#C8E6C9"))) %>%
      formatCurrency("avg_price",
                     currency = "$") %>%
      formatStyle(names(yearly),
                  textAlign = "center",
                  target = "cell")
  })


  output$vbox1 <- renderValueBox({
    valueBox(
      value = nrow(nodes_df),
      subtitle = "Total nodes",
      icon = icon("fa-sharp fa-solid fa-users"),
    )
  })


  output$nodes <- renderPlot({
    nodes_map
  })


  output$nodestable <- DT::renderDataTable({
    datatable(nodes_df %>%
                group_by(city, timezone) %>%
                summarise(n = n()) %>%
                arrange(desc(n)),
              options = list(
                lengthChange = FALSE,
                columnDefs = list(list(className = 'dt-center', targets = "_all"))),
              rownames = FALSE)
  })

}

shinyApp(ui = ui, server = server)
