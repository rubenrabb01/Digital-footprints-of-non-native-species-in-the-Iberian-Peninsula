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
    file.path(DATA_RAW_DIR, "videos_validated.csv"),
    file.path(DATA_RAW_DIR, "videos_validated.csv"),
    file.path(DATA_RAW_DIR, "ENRICHED_deduped.csv"),
    file.path(DATA_RAW_DIR, "ENRICHED_final_relaxed_with_is_iberian.csv")
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

# Deduplicate by video_id when available, preserving first row.
if ("video_id" %in% names(base_df)) {
  base_df <- base_df %>% dplyr::distinct(.data$video_id, .keep_all = TRUE)
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

message("Video dataset ready: ", nrow(combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN), " unique videos")
if ("TaxonName" %in% names(combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN)) {
  message("Species represented: ", dplyr::n_distinct(combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN$TaxonName))
}
