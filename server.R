library(shiny)
library(shinydashboard)

source("R/functions.R")
source("R/read-data.R")
register_pins_board()
# tweets_data <- read_tweets_data()
#
# tweets_data <- tweets_data %>%
#   arrange(desc(favorite_count)) %>%
#   head(1)

server <- function(input, output, session) {
  tweets <- pins::pin_reactive("tidytuesday-tweets",
                               board = "tidytuesday-tweets",
                               # Check for new data every hour
                               interval = 60 * 60 * 1000)

  n_tweets <- reactive({
    nrow(tweets())
  })
  n_users <- reactive({
    n_distinct(tweets()$screen_name)
  })
  n_images <- reactive({
    tweets() %>%
      mutate(n_images = map_int(images, ~sum(!is.na(.x$id)))) %>%
      pull(n_images) %>%
      sum()
  })

  output$n_tweets_box <- renderValueBox({
    valueBox(n_tweets(), "Tweets", icon = icon("twitter"))
  })
  output$n_users_box <- renderValueBox({
    valueBox(n_users(), "Users", icon = icon("user"))
  })
  output$n_images_box <- renderValueBox({
    valueBox(n_images(), "Images", icon = icon("image"))
  })

  get_tweets <- function(id) {
    n_tweets <- length(id)
    withProgress(min = 0, max = n_tweets, message = "Getting tweets", {
      tibble::tibble(
        tweets = map(id, embed_tweet)
      ) %>%
        DT::datatable(options = list(pageLength = 5))
    })
  }
  output$most_favorited <- DT::renderDataTable({
    d <- tweets() %>% arrange(desc(favorite_count))
    get_tweets(d$id)
  })

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
