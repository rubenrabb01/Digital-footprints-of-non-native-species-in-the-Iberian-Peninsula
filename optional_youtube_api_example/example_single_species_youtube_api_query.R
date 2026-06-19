# ============================================================
# Minimal illustrative YouTube Data API query
# ============================================================
# This script is provided only as a small example of how a YouTube
# Data API search request can be made from R. It is not required to
# reproduce the manuscript analyses, and it does not implement the
# full retrieval, batching, filtering, or validation workflow used in
# the study.
#
# Requirements:
#   Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
#
# Output:
#   optional_youtube_api_example/outputs/example_single_query_results.csv
# ============================================================

suppressPackageStartupMessages({
  library(jsonlite)
  library(readr)
  library(dplyr)
  library(stringr)
})

PROJECT_ROOT <- getwd()
OUT_DIR <- file.path(PROJECT_ROOT, "optional_youtube_api_example", "outputs")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

api_key <- Sys.getenv("YOUTUBE_API_KEY")
if (!nzchar(api_key)) {
  stop("Please set a YouTube Data API key first, for example: Sys.setenv(YOUTUBE_API_KEY = 'YOUR_KEY_HERE')")
}

# A single, harmless example query. Users can replace this with their own term.
query_term <- "Vespa velutina"
region_code <- "ES"
max_results <- 10
published_after <- "2005-03-01T00:00:00Z"

base_url <- "https://www.googleapis.com/youtube/v3/search"
query <- paste0(
  base_url,
  "?part=snippet",
  "&type=video",
  "&maxResults=", max_results,
  "&order=relevance",
  "&regionCode=", region_code,
  "&publishedAfter=", utils::URLencode(published_after, reserved = TRUE),
  "&q=", utils::URLencode(query_term, reserved = TRUE),
  "&key=", api_key
)

message("Running one illustrative YouTube API query for: ", query_term)
res <- jsonlite::fromJSON(query, flatten = TRUE)

if (!"items" %in% names(res) || nrow(res$items) == 0) {
  warning("No items returned by the API for this example query.")
  out <- tibble::tibble()
} else {
  out <- tibble::tibble(
    query_term = query_term,
    region_code = region_code,
    video_id = res$items$id.videoId,
    published_at = res$items$snippet.publishedAt,
    title = res$items$snippet.title,
    channel_title = res$items$snippet.channelTitle,
    description = res$items$snippet.description
  ) %>%
    dplyr::mutate(
      # Keep the example compact. Do not treat this as a study input file.
      description = stringr::str_squish(as.character(.data$description))
    )
}

out_file <- file.path(OUT_DIR, "example_single_query_results.csv")
readr::write_csv(out, out_file, na = "")
message("Example output written to: ", out_file)
