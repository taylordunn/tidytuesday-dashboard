library(shiny)
library(shinydashboard)
library(dplyr)
library(tibble)
library(purrr)
library(pins)
library(magrittr)

source("R/functions.R")
source("R/read-data.R")
source("R/value-box-custom.R")

register_pins_board()

server <- function(input, output, session) {
  # Read data ---------------------------------------------------------------
  tweets <- read_tweets_reactive(session)

  tidytuesday_datasets <- reactive({
    get_tidytuesday_datasets() %>%
      filter(date > min(tweets()$created_at))
  })

  # Tweet options -----------------------------------------------------------
  tweets_selected <- reactive({
    tweets() %>%
      filter(created_at >= input$tweets_date_range[1],
             created_at < input$tweets_date_range[2])
  })

  observe({
    updateSelectInput(session, "tidytuesday_data_select",
                      choices = tidytuesday_datasets()$week_data)
  })

  observe({
    start_date <- tidytuesday_datasets() %>%
      filter(week_data == input$tidytuesday_data_select) %>%
      pull(date)
    max_date <- as.Date(max(tweets()$created_at)) + 1
    end_date <- min(c(start_date + 6, max_date))

    updateDateRangeInput(session, "tweets_date_range",
                         start = start_date, end = end_date,
                         max = max_date)

  })

  # Header summary ----------------------------------------------------------
  n_tweets <- reactive({
    nrow(tweets_selected()) %>% scales::comma()
  })
  n_users <- reactive({
    n_distinct(tweets_selected()$screen_name) %>% scales::comma()
  })
  n_images <- reactive({
    tweets_selected() %>%
      mutate(n_images = purrr::map_int(images, ~ sum(!is.na(.x$id)))) %>%
      pull(n_images) %>%
      sum() %>%
      scales::comma()
  })
  n_favorites <- reactive({
    tweets_selected() %>%
      pull(retweet_count) %>%
      sum() %>%
      scales::comma()
  })

  output$n_tweets_box <- renderValueBox({
    valueBoxCustom(n_tweets(), "Tweets", icon = icon("twitter"),
                   background = var_colors_custom$tweets)
  })
  output$n_users_box <- renderValueBox({
    valueBoxCustom(n_users(), "Users", icon = icon("user"),
                   background = var_colors_custom$users)
  })
  output$n_images_box <- renderValueBox({
    valueBoxCustom(n_images(), "Images", icon = icon("image"),
                   background = var_colors_custom$images)
  })
  output$n_favorites_box <- renderValueBox({
    valueBoxCustom(n_favorites(), "Favorites", icon = icon("heart"),
                   background = var_colors_custom$favorites)
  })

  # Info box ----------------------------------------------------------------
  output$info <- renderUI({
    htmltools::HTML(
      "<p>This dashboard displays tweets using the #TidyTuesday hashtag.",
      "<a href='https://github.com/rfordatascience/tidytuesday'>Tidy Tuesday</a>",
      "is a weekly data project in which a raw data set is posted by the <a href='https://www.rfordatasci.com/'>R4DS community</a>",
      "for participants to explore, wrangle, analyze, and visualize (usually in R).</p>",
      "<p>",
      "The source code for this dashboard can be found <a href='https://github.com/taylordunn/tidytuesday-dashboard'>here</a>.",
      "The tweets are downloaded via the Twitter API and stored <a href='https://github.com/taylordunn/tidytuesday-scraper'>here</a>.",
      "</p>",
      "<p>Created by <a href='https://tdunn.ca/'>Taylor Dunn</a>.",
      "Inspiration for this project came from Neal Grantham's <a href='https://shiny.rstudio.com/gallery/tidy-tuesday.html'>tidytuesday.rocks</a> app (which is no longer updated).",
      "Also helpful for writing the code were the",
      "<a href='https://shiny.rstudio.com/gallery/conference-tweet-dashboard.html'>rstudio::conf 2019</a> and",
      "<a href='https://thinkr.shinyapps.io/tweetstorm/'>useR! 2017</a> tweets dashboards.",
      "</p>"
    )
  })

  # Tweet display -----------------------------------------------------------
  most_favorites <- reactive({
    tweets_selected() %>%
      arrange(desc(favorite_count)) %>%
      select(tweet_embedded) %>%
      DT::datatable(rownames = FALSE, colnames = c("Most favorites"),
                    options = list(pageLength = 5))
  })
  most_retweets <- reactive({
    tweets_selected() %>%
      arrange(desc(retweet_count)) %>%
      select(tweet_embedded) %>%
      DT::datatable(
        rownames = FALSE, colnames = c("Most retweets"),
        options = list(pageLength = 5)
      )
  })
  most_recent <- reactive({
    tweets_selected() %>%
      arrange(desc(created_at)) %>%
      select(tweet_embedded) %>%
      DT::datatable(
        rownames = FALSE, colnames = c("Most recent"),
        options = list(pageLength = 5)
      )
  })

  output$most_favorites_table_left <- DT::renderDataTable(most_favorites())
  output$most_favorites_table_right <- DT::renderDataTable(most_favorites())
  output$most_retweets_table_left <- DT::renderDataTable(most_retweets())
  output$most_retweets_table_right <- DT::renderDataTable(most_retweets())
  output$most_recent_table_left <- DT::renderDataTable(most_recent())
  output$most_recent_table_right <- DT::renderDataTable(most_recent())
  # output$tweets_embedded <- renderUI({
  #   validate(
  #     need(nrow(tweets_data) > 0,
  #          paste("No tweets to display."))
  #   )
  #
  #   tweets_data %>%
  #     slice(1) %>%
  #     pmap(get_tweet_blockquote) %>%
  #     .[[1]] %>%
  #     HTML()
  # })
}
