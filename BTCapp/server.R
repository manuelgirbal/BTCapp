library(shiny)
library(DT)
library(tidyverse)
library(plotly)

function(input, output, session) {

  output$price <- renderPlotly({
    ggplotly(ggplot(btcprice, aes(date, price)) +
               geom_line() +
               ylab("USD Value") +
               xlab("Date") +
               scale_x_date(date_breaks = "1 year", date_labels = "%Y")
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


}
