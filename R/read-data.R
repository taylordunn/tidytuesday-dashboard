library(pins)
library(magrittr)
library(dplyr)

register_pins_board <- function() {
  pins::board_register_github(
    name = "tidytuesday-tweets", repo = "taylordunn/tidytuesday-scraper",
    path = "data", token = Sys.getenv("GITHUB_PAT")
  )
}

read_tweets_data <- function(board_name = "tidytuesday-tweets") {
  pins::pin_get("tidytuesday-tweets", board = board_name)
}
