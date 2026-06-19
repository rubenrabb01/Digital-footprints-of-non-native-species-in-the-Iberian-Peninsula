# ============================================================
# 02_prepare_timestamped_comments.R
# Loads/prepares timestamped comments/replies as comments_joined.
# This is required only for ANALYSIS_MODE == "COMMENTS_TIMESTAMPS" or when
# rebuilding all token tables. It does not alter the no-comments branch.
# ============================================================

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(lubridate); library(stringr)
})

if (!exists("comments_joined", inherits = FALSE)) {
  candidate_files <- c(
    file.path(DATA_RAW_DIR, "comments_timestamped.csv"),
    file.path(DATA_RAW_DIR, "comments_joined.csv"),
    file.path(DATA_RAW_DIR, "comments_timestamped_clean.csv")
  )
  comments_path <- first_existing_file(candidate_files)
  if (!is.na(comments_path)) {
    message("Reading timestamped comments: ", comments_path)
    comments_joined <- readr::read_csv(comments_path, show_col_types = FALSE)
  } else if (isTRUE(BUILD_COMMENTS_TOKENS)) {
    stop(
      "COMMENTS_TIMESTAMPS mode requires timestamped comments. Put one of these in data_raw/ or load comments_joined before sourcing this script:\n - ",
      paste(candidate_files, collapse = "\n - ")
    )
  } else {
    message("No timestamped comments file found; continuing because ANALYSIS_MODE is NO_COMMENTS.")
  }
}

if (exists("comments_joined", inherits = FALSE)) {
  cd <- comments_joined

  # Harmonise common column variants without discarding original columns.
  if (!"video_id" %in% names(cd)) {
    vid <- intersect(c("videoId", "videoID", "yt_video_id", "id_video"), names(cd))
    if (length(vid) > 0) cd$video_id <- cd[[vid[1]]]
  }
  if (!"publishedAt" %in% names(cd)) {
    dt <- intersect(c("comment_publishedAt", "reply_publishedAt", "created_at", "published_at"), names(cd))
    if (length(dt) > 0) cd$publishedAt <- cd[[dt[1]]]
  }
  if (!"text" %in% names(cd)) {
    tx <- intersect(c("comment_text", "reply_text", "textOriginal", "body"), names(cd))
    if (length(tx) > 0) cd$text <- cd[[tx[1]]]
  }
  if (!"is_reply" %in% names(cd)) {
    cd$is_reply <- if ("parent_id" %in% names(cd)) !is.na(cd$parent_id) & nzchar(as.character(cd$parent_id)) else FALSE
  }

  cd <- cd %>%
    dplyr::mutate(
      publishedAt = suppressWarnings(lubridate::ymd_hms(as.character(.data$publishedAt), tz = "UTC", quiet = TRUE)),
      text = as.character(.data$text)
    ) %>%
    dplyr::filter(!is.na(.data$video_id), !is.na(.data$publishedAt), !is.na(.data$text), nzchar(.data$text))

  # If comments lack species metadata, join it from the video table.
  need_join <- !all(c("TaxonName", "FirstRecord", "FirstRecordDate", "Region", "LifeForm", "PresentStatus") %in% names(cd))
  if (need_join && exists("combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN", inherits = FALSE)) {
    meta_cols <- intersect(
      c("video_id", "TaxonName", "FirstRecord", "FirstRecordDate", "Region", "LifeForm", "PresentStatus", "is_iberian"),
      names(combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN)
    )
    cd <- cd %>%
      dplyr::left_join(
        combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN %>%
          dplyr::select(dplyr::all_of(meta_cols)) %>%
          dplyr::distinct(.data$video_id, .keep_all = TRUE),
        by = "video_id",
        suffix = c("", ".video")
      )
  }

  comments_joined <- cd
  ensure_dir(file.path(TABLES_ROOT, "audit"))
  comments_timestamp_audit <- tibble::tibble(
    n_rows = nrow(cd),
    n_videos = dplyr::n_distinct(cd$video_id),
    n_comments = if ("is_reply" %in% names(cd)) sum(!cd$is_reply, na.rm = TRUE) else NA_integer_,
    n_replies = if ("is_reply" %in% names(cd)) sum(cd$is_reply, na.rm = TRUE) else NA_integer_,
    min_timestamp = suppressWarnings(min(cd$publishedAt, na.rm = TRUE)),
    max_timestamp = suppressWarnings(max(cd$publishedAt, na.rm = TRUE))
  )
  readr::write_csv(comments_timestamp_audit, file.path(TABLES_ROOT, "audit", "comments_timestamp_audit.csv"))
  print(comments_timestamp_audit)
}
