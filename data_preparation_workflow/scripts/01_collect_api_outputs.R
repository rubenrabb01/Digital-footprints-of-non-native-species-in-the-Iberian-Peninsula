# 01_collect_api_outputs.R
# Collect raw API files and put them in one preparation folder.

source(file.path("scripts", "00_config_paths_mode.R"), encoding = "UTF-8")

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(stringr)
  library(lubridate)
  library(tibble)
})

PREP_DIR <- file.path(PROJECT_ROOT, "data", "preparation_input")
API_DIR  <- file.path(PROJECT_ROOT, "optional_youtube_api_preworkflow", "data_raw")
TEST_DIR <- file.path(PROJECT_ROOT, "data", "api_test_input")
dir.create(PREP_DIR, recursive = TRUE, showWarnings = FALSE)

if (!exists("USE_API_TEST_INPUT", inherits = FALSE)) USE_API_TEST_INPUT <- FALSE

read_csv_chr <- function(path) {
  if (!file.exists(path)) return(tibble())
  readr::read_csv(path, col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE)
}

standardise_video_cols <- function(x, source_label) {
  if (nrow(x) == 0) return(x)

  # Make the fields used downstream explicit, even if one API output lacks them.
  if (!"video_id" %in% names(x)) x$video_id <- NA_character_
  if (!"TaxonName" %in% names(x)) x$TaxonName <- NA_character_
  if (!"query" %in% names(x)) x$query <- NA_character_
  if (!"video_url" %in% names(x)) x$video_url <- NA_character_
  if (!"created_at" %in% names(x)) x$created_at <- NA_character_
  if (!"publishedAt" %in% names(x)) x$publishedAt <- NA_character_

  x %>%
    mutate(
      api_source = source_label,
      video_id = as.character(.data$video_id),
      TaxonName = as.character(.data$TaxonName),
      query = as.character(.data$query),
      video_url = dplyr::if_else(
        !is.na(.data$video_url) & .data$video_url != "",
        as.character(.data$video_url),
        dplyr::if_else(
          !is.na(.data$video_id) & .data$video_id != "",
          paste0("https://www.youtube.com/watch?v=", .data$video_id),
          NA_character_
        )
      ),
      created_at = dplyr::coalesce(
        dplyr::na_if(as.character(.data$created_at), ""),
        dplyr::na_if(as.character(.data$publishedAt), "")
      )
    )
}

if (USE_API_TEST_INPUT) {
  message("Using test API input files in data/api_test_input/.")
  reg_path <- file.path(TEST_DIR, "test_api_regioncode_videos.csv")
  geo_path <- file.path(TEST_DIR, "test_api_geotagged_videos.csv")
  comments_path <- file.path(TEST_DIR, "test_api_comments.csv")
} else {
  message("Using API files in optional_youtube_api_preworkflow/data_raw/.")
  reg_path <- file.path(API_DIR, "yt_species_videos_ES_PT_regioncode_scientific_common_dedup.csv")
  geo_path <- file.path(API_DIR, "yt_species_videos_ES_PT_geotagged_dedup_1200km_new_locs_espanded.csv")
  comments_path <- file.path(API_DIR, "YT_comments_with_timestamps_long.csv")
}

reg_raw <- read_csv_chr(reg_path) %>% standardise_video_cols("REG")
geo_raw <- read_csv_chr(geo_path) %>% standardise_video_cols("GEO")
comments_raw <- read_csv_chr(comments_path)

readr::write_csv(reg_raw, file.path(PREP_DIR, "api_regioncode_raw.csv"), na = "")
readr::write_csv(geo_raw, file.path(PREP_DIR, "api_geotagged_raw.csv"), na = "")
readr::write_csv(comments_raw, file.path(PREP_DIR, "api_comments_raw.csv"), na = "")

api_raw_all <- bind_rows(reg_raw, geo_raw) %>%
  filter(!is.na(.data$video_id), .data$video_id != "")
readr::write_csv(api_raw_all, file.path(PREP_DIR, "api_all_raw_videos.csv"), na = "")

summary_tbl <- tibble(
  dataset = c("REG raw", "GEO raw", "Comments raw", "All raw videos"),
  file = c(reg_path, geo_path, comments_path, file.path(PREP_DIR, "api_all_raw_videos.csv")),
  n_rows = c(nrow(reg_raw), nrow(geo_raw), nrow(comments_raw), nrow(api_raw_all)),
  n_unique_videos = c(
    if ("video_id" %in% names(reg_raw)) n_distinct(reg_raw$video_id, na.rm = TRUE) else 0,
    if ("video_id" %in% names(geo_raw)) n_distinct(geo_raw$video_id, na.rm = TRUE) else 0,
    if ("video_id" %in% names(comments_raw)) n_distinct(comments_raw$video_id, na.rm = TRUE) else 0,
    if ("video_id" %in% names(api_raw_all)) n_distinct(api_raw_all$video_id, na.rm = TRUE) else 0
  )
)
readr::write_csv(summary_tbl, file.path(PREP_DIR, "api_collection_summary.csv"), na = "")
print(summary_tbl)
message("Collected API files in: ", PREP_DIR)
