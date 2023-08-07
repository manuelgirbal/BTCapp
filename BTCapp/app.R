library(shiny)
library(tidyverse)
library(plotly)
library(DT)
library(shinydashboard)
library(bslib)

options(scipen=999)

### bitnodes.R needs to be run manually because of "Could not resolve host: bitnodes.io" error in logs


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
           div(style = "width: 80%; margin: auto;", plotlyOutput("nodes")),
           fluidRow(
             column(
               offset = 5,
               width = 5,
               valueBoxOutput("vbox2")
             )
           ),
           div(style = "width: 80%; margin: auto;", plotlyOutput("txs"))
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
            panel.grid.major = element_line(colour = "#7A7A7A"))+
              labs(title = "Bitcoin's average yearly USD price",
                   subtitle = "Source: https://www.coingecko.com/")
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
      icon = icon("fa-sharp fa-solid fa-globe"),
    )
  })


  output$nodes <- renderPlotly({
    nodes_map
  }) %>%
    bindCache(nodes_map, Sys.Date())


  output$vbox2 <- renderValueBox({
    valueBox(
      value = df_txs %>% summarise(total_txs = sum(txs)),
      subtitle = "Total txs",
      icon = icon("fa-sharp fa-solid fa-users"),
    )
  })


  output$txs <- renderPlotly({
    ggplot(df_txs, aes(date, txs)) +
      geom_line() +
      ylab("Transactions") +
      xlab("Date") +
      labs(title = "Bitcoin's monthly transactions",
           caption = "Source: https://flipsidecrypto.xyz/") +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
      theme(plot.background = element_rect(fill = "#A6A6A6"),
            panel.background = element_rect(fill = "#A6A6A6"),
            panel.grid.major = element_line(colour = "#7A7A7A")
      )
  }) %>%
    bindCache(df_txs, Sys.Date())

}

shinyApp(ui = ui, server = server)
