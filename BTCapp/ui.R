library(shiny)
library(bslib)

navbarPage(

  theme = bs_theme(bootswatch = "slate"),
  title = "BTCapp",

  tabPanel("Price",
                 div(style = "width: 80%; margin: auto;", plotlyOutput("price")),
                 div(style = "width: 60%; margin: auto;", dataTableOutput("yearly"))
    ),
  tabPanel("Network",
           div(style = "width: 80%; margin: auto;", plotOutput("nodes")),
  )
)
