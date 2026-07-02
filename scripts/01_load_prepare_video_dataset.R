# ============================================================
# 01_load_prepare_video_dataset.R
# Loads/prepares the final Iberian-validated video-level dataset.
# Keeps the submitted-paper object name for downstream figure scripts:
#   combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN
# ============================================================

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(stringr); library(lubridate)
})

ensure_dir(DATA_RAW_DIR)

# If object already exists (e.g., loaded interactively or by a previous script), keep it.
if (!exists("combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN", inherits = FALSE)) {
  candidate_files <- c(
    file.path(DATA_RAW_DIR, "videos_validated.csv")
  )
  video_path <- first_existing_file(candidate_files)
  if (is.na(video_path)) {
    stop(
      "Video-level dataset not found. Put one of these files in data/paper_input/ or load the object before sourcing this script:\n - ",
      paste(candidate_files, collapse = "\n - ")
    )
  }
  message("Reading video-level dataset: ", video_path)
  combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN <- readr::read_csv(video_path, show_col_types = FALSE)
}

base_df <- combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN

# Harmonise only when columns exist; do not rename away submitted names.
if (!"created_at" %in% names(base_df)) {
  date_candidates <- intersect(c("publishedAt", "published_at", "published", "publish_date"), names(base_df))
  if (length(date_candidates) > 0) base_df$created_at <- base_df[[date_candidates[1]]]
}

if (!"video_id" %in% names(base_df)) {
  vid_candidates <- intersect(c("videoId", "videoID", "id", "yt_video_id"), names(base_df))
  if (length(vid_candidates) > 0) base_df$video_id <- base_df[[vid_candidates[1]]]
}

if (!"CleanName" %in% names(base_df) && "TaxonName" %in% names(base_df)) {
  base_df$CleanName <- gsub("_", " ", as.character(base_df$TaxonName))
}

if ("is_iberian" %in% names(base_df)) {
  base_df <- base_df %>%
    dplyr::filter(.data$is_iberian %in% c(TRUE, 1, "TRUE", "true"))
}

# Parse core dates and numeric metrics robustly.
if ("created_at" %in% names(base_df)) {
  base_df <- base_df %>%
    dplyr::mutate(created_at = suppressWarnings(lubridate::ymd_hms(as.character(.data$created_at), tz = "UTC", quiet = TRUE)))
}

for (cc in c("viewCount", "likeCount", "commentCount", "FirstRecord")) {
  if (cc %in% names(base_df)) base_df[[cc]] <- suppressWarnings(as.numeric(base_df[[cc]]))
}

if (!"FirstRecordDate" %in% names(base_df) && "FirstRecord" %in% names(base_df)) {
  base_df <- base_df %>%
    dplyr::mutate(FirstRecordDate = as.POSIXct(paste0(as.integer(.data$FirstRecord), "-06-01 12:00:00"), tz = "UTC"))
}

# Deduplicate by video_id when available, preserving the first retained row.
# This removes duplicate query-level records for the same YouTube video while
# keeping rows with missing/empty video_id unchanged.
if ("video_id" %in% names(base_df)) {
  n_before <- nrow(base_df)

  base_df <- base_df %>%
    dplyr::mutate(
      .row_order__ = dplyr::row_number(),
      .video_id_chr__ = stringr::str_trim(as.character(.data$video_id))
    )

  dup_summary <- base_df %>%
    dplyr::filter(!is.na(.data$.video_id_chr__), .data$.video_id_chr__ != "") %>%
    dplyr::count(.data$.video_id_chr__, name = "n_rows") %>%
    dplyr::filter(.data$n_rows > 1)

  if (nrow(dup_summary) > 0) {
    n_duplicate_rows <- sum(dup_summary$n_rows - 1)
    message(
      "Duplicate video_id rows detected: ",
      n_duplicate_rows, " duplicate row(s) across ",
      nrow(dup_summary), " duplicated video_id(s). ",
      "Keeping the first row for each video_id."
    )

    # Optional diagnostic: report whether duplicated video_id rows differ in columns
    # other than query and temporary helper columns.
    dup_rows <- base_df %>%
      dplyr::semi_join(dup_summary, by = c(".video_id_chr__" = ".video_id_chr__"))

    diagnostic_cols <- setdiff(names(dup_rows), c(".row_order__", ".video_id_chr__"))
    differing_cols <- lapply(split(as.data.frame(dup_rows), dup_rows$.video_id_chr__), function(xx) {
      differing <- diagnostic_cols[
        vapply(diagnostic_cols, function(cc) {
          dplyr::n_distinct(xx[[cc]], na.rm = FALSE) > 1
        }, logical(1))
      ]

      data.frame(
        .video_id_chr__ = xx$.video_id_chr__[1],
        differing_columns = paste(differing, collapse = ", "),
        stringsAsFactors = FALSE
      )
    }) %>%
      dplyr::bind_rows()

    if (nrow(differing_cols) > 0 && any(differing_cols$differing_columns != "")) {
      message(
        "Duplicated video_id rows differ in these columns: ",
        paste(
          paste0(differing_cols$.video_id_chr__, " [", differing_cols$differing_columns, "]"),
          collapse = "; "
        )
      )
    }
  }

  base_df_with_id <- base_df %>%
    dplyr::filter(!is.na(.data$.video_id_chr__), .data$.video_id_chr__ != "") %>%
    dplyr::arrange(.data$.row_order__) %>%
    dplyr::distinct(.data$.video_id_chr__, .keep_all = TRUE)

  base_df_without_id <- base_df %>%
    dplyr::filter(is.na(.data$.video_id_chr__) | .data$.video_id_chr__ == "")

  base_df <- dplyr::bind_rows(base_df_with_id, base_df_without_id) %>%
    dplyr::arrange(.data$.row_order__) %>%
    dplyr::select(-.data$.row_order__, -.data$.video_id_chr__)

  message(
    "Video-level deduplication: ",
    n_before, " row(s) -> ", nrow(base_df), " retained video record(s)."
  )
}

combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN <- base_df
RAW_FLAGGED_IS_IBERIAN <- base_df

# Denominators used by Figure 3 if Zenodo metadata is present.
if (!exists("zenodo_grouped", inherits = FALSE)) {
  zeno_candidates <- c(
    file.path(DATA_RAW_DIR, "zenodo_grouped.csv"),
    file.path(DATA_RAW_DIR, "zenodo_filtered.csv"),
    file.path(DATA_RAW_DIR, "ASFRD_zenodo_filtered.csv")
  )
  zeno_path <- first_existing_file(zeno_candidates)
  if (!is.na(zeno_path)) {
    message("Reading Zenodo/species metadata: ", zeno_path)
    zenodo_grouped <- readr::read_csv(zeno_path, show_col_types = FALSE)
  } else {
    # Fall back to species metadata carried in the final video dataset.
    zcols <- intersect(c("TaxonName", "LifeForm", "PresentStatus", "FirstRecord", "CleanName", "Region"), names(base_df))
    if (length(zcols) >= 2) {
      zenodo_grouped <- base_df %>%
        dplyr::select(dplyr::all_of(zcols)) %>%
        dplyr::distinct(.data$TaxonName, .keep_all = TRUE)
      message("zenodo_grouped created from video dataset columns.")
    }
  }
}

if (exists("zenodo_grouped", inherits = FALSE) && !exists("denom_by_lifeform", inherits = FALSE) &&
    all(c("TaxonName", "LifeForm") %in% names(zenodo_grouped))) {
  denom_by_lifeform <- zenodo_grouped %>%
    dplyr::mutate(TaxonName = as.character(.data$TaxonName)) %>%
    dplyr::distinct(.data$TaxonName, .keep_all = TRUE) %>%
    dplyr::count(.data$LifeForm, name = "Searched")
}

message("Video dataset ready: ", nrow(combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN), " deduplicated video records")
if ("TaxonName" %in% names(combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN)) {
  message("Species represented: ", dplyr::n_distinct(combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN$TaxonName))
}
