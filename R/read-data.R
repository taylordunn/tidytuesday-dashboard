register_pins_board <- function() {
  pins::board_register_github(
    name = "tidytuesday-tweets", repo = "taylordunn/tidytuesday-scraper",
    path = "data", token = Sys.getenv("GITHUB_PAT")
  )
}

read_tweets_data <- function(board_name = "tidytuesday-tweets") {
  pins::pin_get("tidytuesday-tweets", board = board_name)
}

#' A function to reactively update the tweets data from the pins board
#'
#' Adapted from the `pins:::pin_reactive_read()` function to work with the
#' legacy API.
read_tweets_reactive <- function(session, interval_minutes = 30,
                                 board_name = "tidytuesday-tweets") {
  reactivePoll(
    # Convert the given `interval_minutes` to milliseconds
    intervalMillis = interval_minutes * 60 * 1000,
    session = session,
    checkFunc = function() {
      # Currently, I don't think this is working properly. It is just
      #  returning the time that the command is run, not the time that the pin
      #  was modified. Once the GitHub pins is updated to the new API,
      #  this should be edited to use `pin_meta()` instead
      changed_time <- pins:::pin_changed_time(
        "tidytuesday-tweets", board = board_name, extract = NULL
      )
      message("Checking for updated tweets.")
      changed_time

    }, valueFunc = function() {
      message("Updating tweets.")

      pins::pin_get("tidytuesday-tweets", board = board_name) %>%
        filter(is.na(possibly_sensitive) | !possibly_sensitive)
    }
  )
}

get_tidytuesday_datasets <- function(year = 2022) {
  d <- tidytuesdayR::tt_datasets(2022)

  tibble(week = d$Week, date = as.Date(d$Date), data = d$Data) %>%
    mutate(week_data = paste0("Week ", week, ": ", data))
}
