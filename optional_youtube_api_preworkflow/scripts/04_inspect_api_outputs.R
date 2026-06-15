# ============================================================
# 04_inspect_api_outputs.R
# Optional helper to inspect generated YouTube API raw outputs.
# This script does not modify files.
#
# v1.5 logic:
#   A. SEARCH BATCH SUMMARY: what the individual API searches produced.
#   B. COMBINED OUTPUT SUMMARY: what 03_combine_youtube_search_outputs.R reported.
#   C. CURRENT DATA_RAW SUMMARY: what is currently on disk and will enter the next workflow.
#
# The CURRENT DATA_RAW SUMMARY is the final pre-downstream check, but it is
# printed after the search and combiner summaries so the workflow sequence is clear.
# ============================================================

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
  library(lubridate)
  library(tibble)
  library(purrr)
})

if (!exists("CONFIG", inherits = FALSE)) {
  source(file.path("scripts", "00_youtube_search_config.R"), encoding = "UTF-8")
}

read_raw_csv <- function(path) {
  if (!file.exists(path)) return(tibble::tibble())
  readr::read_csv(
    path,
    show_col_types = FALSE,
    col_types = readr::cols(.default = readr::col_character())
  )
}

count_unique_video <- function(df) {
  if (!"video_id" %in% names(df) || nrow(df) == 0) return(0L)
  dplyr::n_distinct(df$video_id, na.rm = TRUE)
}

count_unique_comment <- function(df) {
  if (!"comment_id" %in% names(df) || nrow(df) == 0) return(0L)
  dplyr::n_distinct(df$comment_id, na.rm = TRUE)
}

summarise_video_file <- function(path, dataset, file_level = "batch") {
  df <- read_raw_csv(path)
  tibble::tibble(
    file_level = file_level,
    dataset = dataset,
    file = path,
    n_rows = nrow(df),
    n_unique_videos = count_unique_video(df)
  )
}

summarise_comment_file <- function(path, dataset = "COMMENTS", file_level = "batch") {
  df <- read_raw_csv(path)
  tibble::tibble(
    file_level = file_level,
    dataset = dataset,
    file = path,
    n_rows = nrow(df),
    n_unique_videos = count_unique_video(df),
    n_unique_comments = count_unique_comment(df)
  )
}

# ------------------------------------------------------------
# A) SEARCH BATCH SUMMARY
# ------------------------------------------------------------
# These are the direct outputs from the API search step, before final
# combination/deduplication into data_raw.
# ------------------------------------------------------------

reg_batch_files <- list.files(
  file.path(YT_OUTPUT_DIR, "per_list", "REG"),
  pattern = "\\.csv$",
  full.names = TRUE
)
geo_batch_files <- list.files(
  file.path(YT_OUTPUT_DIR, "per_list", "GEO"),
  pattern = "\\.csv$",
  full.names = TRUE
)
comment_batch_files <- list.files(
  file.path(YT_OUTPUT_DIR, "comments"),
  pattern = "\\.csv$",
  full.names = TRUE,
  recursive = TRUE
)

batch_video_summary <- dplyr::bind_rows(
  purrr::map_dfr(reg_batch_files, summarise_video_file, dataset = "REG", file_level = "batch"),
  purrr::map_dfr(geo_batch_files, summarise_video_file, dataset = "GEO", file_level = "batch")
)

batch_comment_summary <- purrr::map_dfr(
  comment_batch_files,
  summarise_comment_file,
  dataset = "COMMENTS",
  file_level = "batch"
)

cat("\n================ A. SEARCH BATCH SUMMARY ================\n")
cat("Direct files produced by the API search step, before final combination/deduplication.\n\n")

if (nrow(batch_video_summary) > 0) {
  cat("Video batch files:\n")
  batch_video_summary %>%
    dplyr::select(dataset, file, n_rows, n_unique_videos) %>%
    print(n = Inf, width = Inf)

  cat("\nVideo batch totals by search mode:\n")
  batch_video_summary %>%
    dplyr::group_by(dataset) %>%
    dplyr::summarise(
      n_batch_files = dplyr::n(),
      total_rows_across_batches = sum(n_rows, na.rm = TRUE),
      sum_unique_videos_by_file = sum(n_unique_videos, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    print(n = Inf, width = Inf)
} else {
  cat("No REG/GEO video batch files found. Run the API search first.\n")
}

if (nrow(batch_comment_summary) > 0) {
  cat("\nComment batch files:\n")
  batch_comment_summary %>%
    dplyr::select(dataset, file, n_rows, n_unique_videos, n_unique_comments) %>%
    print(n = Inf, width = Inf)

  cat("\nComment batch totals:\n")
  batch_comment_summary %>%
    dplyr::summarise(
      n_comment_files = dplyr::n(),
      total_comment_rows_across_files = sum(n_rows, na.rm = TRUE),
      sum_unique_videos_by_file = sum(n_unique_videos, na.rm = TRUE),
      sum_unique_comments_by_file = sum(n_unique_comments, na.rm = TRUE)
    ) %>%
    print(width = Inf)
} else {
  cat("\nNo comment batch files found. This is expected if comments were not extracted.\n")
}

# ------------------------------------------------------------
# B) COMBINED OUTPUT SUMMARY
# ------------------------------------------------------------
# This is the summary file written by 03_combine_youtube_search_outputs.R.
# ------------------------------------------------------------

cat("\n================ B. COMBINED OUTPUT SUMMARY ================\n")
cat("Summary written by scripts/03_combine_youtube_search_outputs.R.\n\n")

summary_file <- file.path(YT_OUTPUT_DIR, "api_search_output_summary.csv")
if (file.exists(summary_file)) {
  saved_summary <- readr::read_csv(summary_file, show_col_types = FALSE)
  print(saved_summary, n = Inf, width = Inf)
} else {
  saved_summary <- tibble::tibble()
  cat("No api_search_output_summary.csv found. Run the combiner first.\n")
}

# ------------------------------------------------------------
# C) CURRENT DATA_RAW SUMMARY
# ------------------------------------------------------------
# These are the files on disk that the downstream manuscript workflow will use.
# ------------------------------------------------------------

reg_df <- read_raw_csv(CONFIG$reg_final_file)
geo_df <- read_raw_csv(CONFIG$geo_final_file)
comments_df <- read_raw_csv(CONFIG$comments_final_file)
combined_df <- read_raw_csv(file.path(DATA_RAW_DIR, "YT_video_search_raw_REG_GEO_combined.csv"))

summary_current <- tibble::tibble(
  dataset = c("REG", "GEO", "COMMENTS", "COMBINED_VIDEO_RAW"),
  output_file = c(
    CONFIG$reg_final_file,
    CONFIG$geo_final_file,
    CONFIG$comments_final_file,
    file.path(DATA_RAW_DIR, "YT_video_search_raw_REG_GEO_combined.csv")
  ),
  n_rows = c(nrow(reg_df), nrow(geo_df), nrow(comments_df), nrow(combined_df)),
  n_unique_videos = c(
    count_unique_video(reg_df),
    count_unique_video(geo_df),
    count_unique_video(comments_df),
    count_unique_video(combined_df)
  )
)

cat("\n================ C. CURRENT DATA_RAW SUMMARY ================\n")
cat("Files currently present in data_raw/. These are the files that would enter the next workflow.\n\n")
print(summary_current, n = Inf, width = Inf)

# Optional consistency check between the saved combiner summary and current data_raw.
if (nrow(saved_summary) > 0) {
  comparable_current <- summary_current %>%
    dplyr::filter(dataset %in% c("REG", "GEO", "COMMENTS")) %>%
    dplyr::select(dataset, n_rows, n_unique_videos) %>%
    dplyr::mutate(
      n_rows = as.numeric(n_rows),
      n_unique_videos = as.numeric(n_unique_videos)
    )

  comparable_saved <- saved_summary %>%
    dplyr::select(dplyr::any_of(c("dataset", "n_rows", "n_unique_videos"))) %>%
    dplyr::mutate(
      n_rows = suppressWarnings(as.numeric(n_rows)),
      n_unique_videos = suppressWarnings(as.numeric(n_unique_videos))
    )

  if (!identical(comparable_current, comparable_saved)) {
    cat("\nNOTE: The combiner summary differs from the current data_raw files.\n")
    cat("This usually means files from different test runs are present, or data_raw files were copied/edited after combining.\n")
    cat("For downstream workflow readiness, trust the CURRENT DATA_RAW SUMMARY above.\n")
  } else {
    cat("\nConsistency check: combiner summary and current data_raw files agree.\n")
  }
}

# ------------------------------------------------------------
# D) PREVIEWS AND BASIC DIAGNOSTICS
# ------------------------------------------------------------

cat("\n================ D. VIDEO OUTPUT PREVIEWS ================\n")
cat("REG rows:", nrow(reg_df), " unique videos:", count_unique_video(reg_df), "\n")
cat("GEO rows:", nrow(geo_df), " unique videos:", count_unique_video(geo_df), "\n")
cat("Combined raw video rows:", nrow(combined_df), " unique videos:", count_unique_video(combined_df), "\n")

if (nrow(reg_df) > 0) {
  cat("\nREG preview:\n")
  reg_df %>%
    dplyr::select(dplyr::any_of(c("video_id", "TaxonName", "query", "title", "publishedAt", "channelTitle", "viewCount", "likeCount", "commentCount"))) %>%
    utils::head(10) %>%
    print(width = Inf)
}

if (nrow(geo_df) > 0) {
  cat("\nGEO preview:\n")
  geo_df %>%
    dplyr::select(dplyr::any_of(c("video_id", "TaxonName", "query", "geo_id", "location", "locationRadius", "title", "publishedAt", "channelTitle"))) %>%
    utils::head(10) %>%
    print(width = Inf)
}

cat("\n================ E. COMMENTS OUTPUT ================\n")
cat("Comment/reply rows:", nrow(comments_df), "\n")

if (nrow(comments_df) > 0) {
  comments_df %>%
    dplyr::count(is_reply, name = "n") %>%
    print()

  comments_df %>%
    dplyr::count(video_id, sort = TRUE, name = "n_comments") %>%
    utils::head(20) %>%
    print()

  comments_df %>%
    dplyr::count(TaxonName, sort = TRUE, name = "n_comments") %>%
    print()

  cat("\nComments preview:\n")
  comments_df %>%
    dplyr::mutate(text_preview = stringr::str_sub(text, 1, 120)) %>%
    dplyr::select(dplyr::any_of(c("video_id", "TaxonName", "query", "is_reply", "author", "publishedAt", "likeCount", "text_preview"))) %>%
    utils::head(25) %>%
    print(width = Inf)

  comments_dates <- comments_df %>%
    dplyr::mutate(
      publishedAt_chr = as.character(publishedAt),
      publishedAt_parsed = lubridate::ymd_hms(publishedAt_chr, quiet = TRUE)
    )

  cat("\nComment timestamp range:\n")
  comments_dates %>%
    dplyr::summarise(
      min_publishedAt = min(publishedAt_parsed, na.rm = TRUE),
      max_publishedAt = max(publishedAt_parsed, na.rm = TRUE),
      n_missing_dates = sum(is.na(publishedAt_chr) | publishedAt_chr == ""),
      n_unparsed_dates = sum(!is.na(publishedAt_chr) & publishedAt_chr != "" & is.na(publishedAt_parsed))
    ) %>%
    print()
} else {
  cat("No comments were found/extracted, or CONFIG$extract_comments was FALSE.\n")
}

cat("\n================ F. FILES IN data_raw ================\n")
print(list.files(DATA_RAW_DIR, full.names = TRUE))
