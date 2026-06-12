# ============================================================
# 03_combine_youtube_search_outputs.R
# Combines per-batch REG/GEO API outputs and writes the raw filenames
# expected by the downstream manuscript workflow / old scripts.
# ============================================================

if (!exists("CONFIG", inherits = FALSE)) source(file.path("scripts", "00_youtube_search_config.R"), encoding = "UTF-8")
source(file.path("scripts", "01_youtube_api_helpers.R"), encoding = "UTF-8")

read_all_csvs <- function(dir, pattern) {
  files <- list.files(dir, pattern = pattern, recursive = TRUE, full.names = TRUE)
  if (length(files) == 0) return(tibble::tibble())
  purrr::map_dfr(files, function(f) {
    readr::read_csv(
      f,
      show_col_types = FALSE,
      guess_max = 100000,
      col_types = readr::cols(.default = readr::col_character())
    ) %>%
      dplyr::mutate(source_file = basename(f), .before = 1)
  })
}

normalise_video_table <- function(x) {
  # Ensure optional columns exist before mutate(). This avoids type/column
  # problems when one batch has zero rows or when readr guesses dates
  # differently across batch files.
  needed <- c("video_id", "video_url", "title", "description",
              "channelTitle", "TaxonName", "query", "publishedAt",
              "search_type", "search_unit", "regionCode", "geo_id",
              "location", "locationRadius", "viewCount", "likeCount",
              "commentCount", "duration", "source_file")
  for (nm in needed) {
    if (!nm %in% names(x)) x[[nm]] <- NA_character_
  }

  x <- x %>%
    dplyr::mutate(
      dplyr::across(dplyr::everything(), as.character),
      video_url = dplyr::if_else(
        is.na(.data$video_url) | .data$video_url == "",
        paste0("https://www.youtube.com/watch?v=", .data$video_id),
        .data$video_url
      )
    )

  if (nrow(x) == 0) return(x)

  x %>%
    dplyr::filter(!is.na(.data$video_id), .data$video_id != "")
}

make_all_character <- function(x) {
  if (ncol(x) == 0) return(x)
  x %>% dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
}

combine_mode <- function(mode) {
  mode_dir <- file.path(YT_PER_LIST_DIR, mode)
  videos <- read_all_csvs(mode_dir, "_videos[.]csv$") %>% normalise_video_table()
  comments <- read_all_csvs(mode_dir, "_comments_long[.]csv$")
  comments_joined <- read_all_csvs(mode_dir, "_comments_joined[.]csv$")

  if (nrow(videos) > 0) {
    # Old scripts deduplicated by video_id, title, and video_url.
    # We keep first occurrence but preserve TaxonName/query from the first retained match.
    videos_dedup <- videos %>%
      dplyr::arrange(.data$TaxonName, .data$query, .data$video_id) %>%
      dplyr::distinct(.data$video_id, .data$title, .data$video_url, .keep_all = TRUE)
  } else {
    videos_dedup <- empty_search_tbl()
  }

  list(videos = videos_dedup, comments = comments, comments_joined = comments_joined)
}

reg <- combine_mode("REG")
geo <- combine_mode("GEO")

if (CONFIG$overwrite_final_outputs || !file.exists(CONFIG$reg_final_file)) {
  readr::write_csv(reg$videos, CONFIG$reg_final_file, na = "")
}
if (CONFIG$overwrite_final_outputs || !file.exists(CONFIG$geo_final_file)) {
  readr::write_csv(geo$videos, CONFIG$geo_final_file, na = "")
}

# Combine comments only when comment files contain the expected columns.
# This guard is important when CONFIG$extract_comments = FALSE: empty comment
# CSVs may exist, but no comment_id/is_reply values are available.
comments_pieces <- list()
if (nrow(reg$comments) > 0 && all(c("video_id", "comment_id", "is_reply") %in% names(reg$comments))) {
  comments_pieces[["REG"]] <- reg$comments %>% dplyr::mutate(search_type = "REG", .before = 1)
}
if (nrow(geo$comments) > 0 && all(c("video_id", "comment_id", "is_reply") %in% names(geo$comments))) {
  comments_pieces[["GEO"]] <- geo$comments %>% dplyr::mutate(search_type = "GEO", .before = 1)
}

if (length(comments_pieces) > 0) {
  comments_all <- dplyr::bind_rows(comments_pieces) %>%
    dplyr::distinct(.data$video_id, .data$comment_id, .data$is_reply, .keep_all = TRUE)
} else {
  comments_all <- empty_comments_tbl() %>% dplyr::mutate(search_type = character(), .before = 1)
}

# Always write the final comments file, even if empty, so downstream checks can
# distinguish “not extracted/no comments” from “script failed”.
readr::write_csv(comments_all, CONFIG$comments_final_file, na = "")

# Additional raw combined exports for auditing/reproducibility.
combined_videos <- dplyr::bind_rows(make_all_character(reg$videos), make_all_character(geo$videos))
readr::write_csv(combined_videos, CONFIG$combined_alias_file, na = "")
readr::write_csv(make_all_character(reg$videos), CONFIG$reg_alias_file, na = "")
readr::write_csv(make_all_character(geo$videos), CONFIG$geo_alias_file, na = "")

summary_tbl <- tibble::tibble(
  dataset = c("REG", "GEO", "COMMENTS"),
  output_file = c(CONFIG$reg_final_file, CONFIG$geo_final_file, CONFIG$comments_final_file),
  n_rows = c(nrow(reg$videos), nrow(geo$videos), nrow(comments_all)),
  n_unique_videos = c(
    dplyr::n_distinct(reg$videos$video_id),
    dplyr::n_distinct(geo$videos$video_id),
    dplyr::n_distinct(comments_all$video_id)
  )
)
readr::write_csv(summary_tbl, file.path(YT_OUTPUT_DIR, "api_search_output_summary.csv"), na = "")
print(summary_tbl)

cat("\nFinal raw API outputs written to data_raw/:\n")
cat(" REG:", CONFIG$reg_final_file, "\n")
cat(" GEO:", CONFIG$geo_final_file, "\n")
if (nrow(comments_all) > 0) cat(" Comments:", CONFIG$comments_final_file, "\n")
cat("\nNote: these are API raw outputs. The manually validated final LABEL/ENRICHED dataset is created later after filtering and manual review.\n")
