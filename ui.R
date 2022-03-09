library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "#TidyTuesday tweets"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      valueBoxOutput("n_tweets_box", width = 4),
      valueBoxOutput("n_users_box", width = 4),
      valueBoxOutput("n_images_box", width = 4)
    ),

    fluidRow(
      box(DT::dataTableOutput("most_favorited"),
          title = "Most favorites", width = 6)
    )
  )
)
