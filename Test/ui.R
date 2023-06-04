library(shiny)
library(bslib)
library(shinydashboard)

navbarPage(

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
