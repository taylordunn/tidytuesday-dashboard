#' A function that returns the HTML required to embed a tweet.
#' Copied from the Tweet Conference Dashboard by Garrick Aden-Buie:
#' https://github.com/gadenbuie/tweet-conf-dash/
get_tweet_blockquote <- function(screen_name, id, ...,
                                 null_on_error = TRUE, theme = "light") {
  oembed <- list(...)$oembed
  if (!is.null(oembed) && !is.na(oembed)) return(unlist(oembed))
  oembed_url <- glue::glue("https://publish.twitter.com/oembed?url=https://twitter.com/{screen_name}/status/{id}&omit_script=1&dnt=1&theme={theme}")
  bq <- possibly(httr::GET, list(status_code = 999))(URLencode(oembed_url))
  if (bq$status_code >= 400) {
    if (null_on_error) return(NULL)
    '<blockquote style="font-size: 90%">Sorry, unable to get tweet ¯\\_(ツ)_/¯</blockquote>'
  } else {
    httr::content(bq, "parsed")$html
  }
}

#' Using Twitter's oEmbed API, returns HTML to embed a tweet.
#' Copied from the tweetstorm dashboard by ThinkR:
#' https://github.com/ThinkR-open/tweetstorm
embed_tweet <- function(id) {
  url <- paste0("https://publish.twitter.com/oembed?url=https%3A%2F%2Ftwitter.com%2FInterior%2Fstatus%2F", id)
  #tweet <- HTML(jsonlite::fromJSON(url)$html)
  fromJSON_possibly <- purrr::possibly(~ jsonlite::fromJSON(.)$html,
                                       otherwise = "")
  tweet <- HTML(fromJSON_possibly(url))

  class(tweet) <- c("tweet", class(tweet))
  tweet
}
