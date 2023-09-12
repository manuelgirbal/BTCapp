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
  title =
      div(
        "A Bitcoin Shiny app",
        div(
          HTML("<a href='https://github.com/manuelgirbal/BTCapp'>Find the source code here</a>"),
          style = "font-size: 12px"
        )
      ),
  tabPanel("Price",
           div(style = "width: 80%; margin: auto;", plotlyOutput("price")),
           div(style = "width: 60%; margin: auto;", dataTableOutput("yearly"))
  ),
  tabPanel("Network",
           fluidRow(
             column(
               width = 4, # Adjust the width as needed
               offset = 3,
               valueBoxOutput("vbox1")
             ),
             column(
               width = 4, # Adjust the width as needed
               offset = 1,
               valueBoxOutput("vbox1.1")
             )
           ),
           div(style = "width: 80%; margin: auto;", plotlyOutput("nodes")),
           fluidRow(
             column(
               width = 5, # Adjust the width as needed
               offset = 5, # Adjust the offset as needed
               valueBoxOutput("vbox2")
             )
           ),
           div(style = "width: 80%; margin: auto;", plotlyOutput("txs"))
  )
)



## Server

server <- function(input, output, session) {

output$price <- renderPlotly({
  ggplotly(
    btcprice_plot
  ) %>%
    layout(title = list(text = paste0("Bitcoin's average yearly USD price",
                                      "<br>",
                                      "<sup>",
                                      "Source: https://www.coingecko.com/",
                                      "</sup>" )))
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

  output$vbox1.1 <- renderValueBox({
    valueBox(
      value = nrow(nodes_df[nodes_df$asn == "TOR", ]),
      subtitle = "Tor nodes",
      icon = icon("fa-sharp fa-solid fa-globe"),
    )
  })


  output$nodes <- renderPlotly({
    ggplotly(nodes_map) %>%
      layout(title = list(text = paste0("Bitcoin's currently running nodes by country",
                                        "<br>",
                                        "<sup>",
                                        "Source: https://bitnodes.io/",
                                        "</sup>" )))
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
    ggplotly(
      btctxs_plot
      ) %>%
      layout(title = list(text = paste0("Bitcoin's monthly transactions",
                                        "<br>",
                                        "<sup>",
                                        "Source: https://flipsidecrypto.xyz/",
                                        "</sup>" )))
  }) %>%
    bindCache(df_txs, Sys.Date())

}

shinyApp(ui = ui, server = server)
