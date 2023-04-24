library(shiny)
library(bslib)

navbarPage(

  theme = bs_theme(bootswatch = "spacelab"),
  title = "BTCapp",

  tabPanel("Precio",
                 div(style = "width: 80%; margin: auto;", plotlyOutput("price")),
                 div(style = "width: 60%; margin: auto;", dataTableOutput("year_var"))
    )
)
