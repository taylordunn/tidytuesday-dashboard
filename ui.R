library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "#TidyTuesday tweets"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      box(
        title = "Options", width = 4, height = 250,
        selectInput("tidytuesday_data_select", label = "Data set",
                    choices = c("Loading")),
        dateRangeInput("tweets_date_range", "Date range",
                       start = "2022-03-15", end = "2022-03-21",
                       min = "2022-01-28", max = Sys.Date(),
                       weekstart = 2, separator = " to ")
      ),
      box(
        width = 4, height = 250,
        fluidRow(valueBoxOutput("n_tweets_box", width = 6),
                 valueBoxOutput("n_users_box", width = 6)),
        fluidRow(valueBoxOutput("n_images_box", width = 6),
                 valueBoxOutput("n_favorites_box", width = 6))
      ),
      box(
        title = "Info", width = 4, height = 250,
        uiOutput("info")
      )
    ),

    fluidRow(
      tabBox(
        id = "tabbox_left", width = 6, selected = 1,
        tabPanel(icon("heart"), value = 1,
                 DT::dataTableOutput("most_favorites_table_left")),
        tabPanel(icon("retweet"), value = 2,
                 DT::dataTableOutput("most_retweets_table_left")),
        tabPanel(icon("clock"), value = 3,
                 DT::dataTableOutput("most_recent_table_left"))
      ),
      tabBox(
        id = "tabbox_right", width = 6, selected = 2,
        tabPanel(icon("heart"), value = 1,
                 DT::dataTableOutput("most_favorites_table_right")),
        tabPanel(icon("retweet"), value = 2,
                 DT::dataTableOutput("most_retweets_table_right")),
        tabPanel(icon("clock"), value = 3,
                 DT::dataTableOutput("most_recent_table_right"))
      )
    )
  )
)
