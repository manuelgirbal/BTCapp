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


  output$year_var <- DT::renderDataTable({
    datatable(year_var,
              options = list(
                lengthChange = FALSE,
                searching = FALSE,
                paging = FALSE
              ),
              rownames = FALSE)
  })


}
