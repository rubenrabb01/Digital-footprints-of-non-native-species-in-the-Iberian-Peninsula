# ============================================================
# 15_validation_audits.R
# Ecological Informatics YouTube/NNS major revision
#
# Purpose
#   Fill the validation placeholders added in the revised manuscript and
#   supplementary material, and provide validator-requested audit outputs:
#
#   A) Iberia-relevance validation / LABEL audit
#      - Creates a manual recheck template if no completed validation file exists.
#      - Computes agreement, estimated false-positive rate, uncertainty rate,
#        and evidence/exclusion summaries if a completed template is supplied.
#
#   B) Keyword/thematic classifier validation
#      - Creates a stratified keyword-occurrence validation template.
#      - Computes confusion matrix, overall agreement, Cohen's kappa,
#        category-specific precision/recall/F1 if a completed template is supplied.
#
#   C) Exploratory first-record / first-YouTube comparison
#      - Compares each species' first official Iberian record with the first
#        Iberia-relevant YouTube video in the final LABEL dataset.
#      - This is exploratory and should be framed as a descriptive supplementary
#        analysis, not as proof of operational early warning.
#
#   D) Comments-only sensitivity summary
#      - Summarises the limited comments-only token corpus if it exists.
#
# How to use
#   1. Run the main workflow first:
#        source("scripts/14_run_all.R")
#      or source this script after the main workflow in the same project root.
#   2. Run:
#        source("scripts/15_validation_audits.R")
#   3. Coauthor validation files are exported to:
#        outputs/validation/validation_files_by_validator/
#      Returned coauthor files should be saved in:
#        outputs/validation/completed/validation_files_by_validator/
#   4. The pre-record context template is exported to:
#        outputs/validation/lead_lag_context/
#      Save the completed version as:
#        outputs/validation/lead_lag_context/completed/lead_lag_prerecord_context_completed.csv
#   5. Re-run this script to compute final metrics.
# ============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(lubridate)
  library(purrr)
  library(ggplot2)
})

# -----------------------------
# Minimal project setup
# -----------------------------
if (!exists("PROJECT_ROOT", inherits = FALSE)) PROJECT_ROOT <- getwd()
if (!exists("SCRIPTS_DIR", inherits = FALSE)) SCRIPTS_DIR <- file.path(PROJECT_ROOT, "scripts")
if (!exists("DATA_RAW_DIR", inherits = FALSE)) DATA_RAW_DIR <- file.path(PROJECT_ROOT, "data", "paper_input")
if (!exists("TABLES_ROOT", inherits = FALSE)) TABLES_ROOT <- file.path(PROJECT_ROOT, "outputs", "intermediate")
if (!exists("OUTPUTS_ROOT", inherits = FALSE)) OUTPUTS_ROOT <- file.path(PROJECT_ROOT, "outputs", "intermediate")
if (!exists("KW_TABLES_DIR", inherits = FALSE)) KW_TABLES_DIR <- file.path(TABLES_ROOT, "keywords")
if (!exists("KW_OUTPUTS_DIR", inherits = FALSE)) KW_OUTPUTS_DIR <- file.path(OUTPUTS_ROOT, "keywords")
if (!exists("TOKEN_FILE_BASENAME", inherits = FALSE)) TOKEN_FILE_BASENAME <- "token_table_from_BASE_raw_NO_COMMENTS.csv"

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}

first_existing_file <- function(paths) {
  paths <- paths[!is.na(paths) & nzchar(paths)]
  hit <- paths[file.exists(paths)]
  if (length(hit) == 0) return(NA_character_)
  hit[[1]]
}

coalesce_chr <- function(...) {
  vals <- list(...)
  out <- NULL
  for (v in vals) {
    if (is.null(out)) out <- as.character(v)
    else out <- dplyr::coalesce(out, as.character(v))
  }
  out
}

normalise_bool <- function(x) {
  y <- tolower(trimws(as.character(x)))
  dplyr::case_when(
    y %in% c("true", "t", "yes", "y", "1", "si", "sí", "iberian", "relevant", "include", "included") ~ TRUE,
    y %in% c("false", "f", "no", "n", "0", "non-iberian", "not relevant", "exclude", "excluded") ~ FALSE,
    TRUE ~ NA
  )
}

cohen_kappa_simple <- function(truth, estimate) {
  truth <- as.character(truth)
  estimate <- as.character(estimate)
  ok <- !is.na(truth) & !is.na(estimate) & nzchar(truth) & nzchar(estimate)
  truth <- truth[ok]
  estimate <- estimate[ok]
  if (length(truth) == 0) return(NA_real_)
  lev <- sort(unique(c(truth, estimate)))
  tab <- table(factor(truth, levels = lev), factor(estimate, levels = lev))
  n <- sum(tab)
  po <- sum(diag(tab)) / n
  pe <- sum(rowSums(tab) * colSums(tab)) / (n^2)
  if (isTRUE(all.equal(1, pe))) return(NA_real_)
  (po - pe) / (1 - pe)
}

metric_line <- function(x, digits = 3) {
  ifelse(is.na(x), "not estimated", as.character(round(x, digits)))
}

short_text <- function(x, n = 450) {
  x <- as.character(x)
  x <- str_replace_all(x, "\\s+", " ")
  ifelse(nchar(x) > n, paste0(substr(x, 1, n), "..."), x)
}


# Read and combine validation files returned by coauthors. The workflow accepts
# either a single completed file with the canonical name or several validator-
# specific files whose filenames contain the validation stem. It then creates a
# consensus file so downstream summaries are based on unique records rather than
# over-weighting the shared validation subset.
read_validation_files <- function(completed_dir, canonical_file, include_patterns, exclude_patterns = character()) {
  canonical_path <- file.path(completed_dir, canonical_file)
  files <- list.files(completed_dir, pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)
  if (length(files) == 0) return(list(path = canonical_path, rows = NULL, files = character()))

  base <- basename(files)
  keep <- rep(FALSE, length(files))
  for (pat in include_patterns) keep <- keep | str_detect(base, regex(pat, ignore_case = TRUE))
  for (pat in exclude_patterns) keep <- keep & !str_detect(base, regex(pat, ignore_case = TRUE))
  files <- files[keep]
  if (length(files) == 0 && file.exists(canonical_path)) files <- canonical_path
  if (length(files) == 0) return(list(path = canonical_path, rows = NULL, files = character()))

  rows <- purrr::map_dfr(files, function(f) {
    readr::read_csv(f, show_col_types = FALSE) %>%
      dplyr::mutate(
        validation_source_file = basename(f),
        validator_id = tools::file_path_sans_ext(basename(f)) %>%
          stringr::str_replace("_LABEL_Iberia_relevance_validation$", "") %>%
          stringr::str_replace("_LABEL_iberian_relevance_validation$", "") %>%
          stringr::str_replace("_keyword_category_validation$", "") %>%
          stringr::str_replace("_keyword_occurrence_validation$", "") %>%
          stringr::str_replace_all("^(LABEL_iberian_relevance_validation_|keyword_occurrence_validation_|video_validation_|keyword_validation_)", "") %>%
          stringr::str_replace_all("(_completed|completed|_template|template)$", "")
      )
  })
  list(path = canonical_path, rows = rows, files = files)
}

# Write validator-specific validation files with a shared subset plus validator-specific
# extra rows. These are the files sent to coauthors and later returned completed.
write_validator_validation_files <- function(template_df, out_dir, file_stem, validators = c("Ana", "Loreto", "Gabriel", "Valerio"), shared_n = 50) {
  if (is.null(template_df) || nrow(template_df) == 0) return(invisible(NULL))
  ensure_dir(out_dir)
  template_df <- template_df %>% dplyr::arrange(.data$validation_id)
  shared_n <- min(shared_n, nrow(template_df))
  shared <- template_df[seq_len(shared_n), , drop = FALSE]
  extra <- if (nrow(template_df) > shared_n) template_df[(shared_n + 1):nrow(template_df), , drop = FALSE] else template_df[0, , drop = FALSE]
  split_index <- rep(seq_along(validators), length.out = nrow(extra))
  assignment <- purrr::map_dfr(seq_along(validators), function(i) {
    validator <- validators[[i]]
    validator_dir <- file.path(out_dir, validator)
    ensure_dir(validator_dir)
    extra_i <- extra[split_index == i, , drop = FALSE]
    out_i <- dplyr::bind_rows(shared, extra_i)
    out_file <- file.path(validator_dir, paste0(validator, "_", file_stem, ".csv"))
    readr::write_csv(out_i, out_file, na = "")
    tibble::tibble(
      validator = validator,
      shared_rows = if (shared_n > 0) paste0("1-", shared_n) else "",
      extra_rows = if (nrow(extra_i) > 0) paste0(min(which(split_index == i)) + shared_n, "-", max(which(split_index == i)) + shared_n) else "",
      total_rows = nrow(out_i),
      file = out_file
    )
  })
  assignment_path <- file.path(out_dir, paste0(file_stem, "_assignment_summary.csv"))
  readr::write_csv(assignment, assignment_path, na = "")
  invisible(assignment)
}


consensus_from_decisions <- function(df, id_cols, decision_col, uncertain_values = c("uncertain", "unsure", "unknown", "ambiguous")) {
  id_cols <- id_cols[id_cols %in% names(df)]
  if (length(id_cols) == 0) stop("No usable ID columns found for consensus calculation.")

  df %>%
    dplyr::mutate(
      .decision_raw = as.character(.data[[decision_col]]),
      .decision_norm = dplyr::case_when(
        is.na(.data$.decision_raw) | !nzchar(trimws(.data$.decision_raw)) ~ NA_character_,
        stringr::str_detect(tolower(trimws(.data$.decision_raw)), paste(uncertain_values, collapse = "|")) ~ "UNCERTAIN",
        TRUE ~ as.character(.data$.decision_raw)
      )
    ) %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(id_cols))) %>%
    dplyr::summarise(
      n_validators = dplyr::n(),
      validator_files = paste(unique(.data$validation_source_file), collapse = "; "),
      decisions_all = paste(.data$.decision_norm, collapse = "; "),
      .decision_consensus = {
        vals <- .data$.decision_norm[!is.na(.data$.decision_norm)]
        if (length(vals) == 0) NA_character_ else {
          tb <- sort(table(vals), decreasing = TRUE)
          if (length(tb) > 1 && tb[1] == tb[2]) "UNCERTAIN" else names(tb)[1]
        }
      },
      dplyr::across(dplyr::everything(), ~ dplyr::first(.x)),
      .groups = "drop"
    )
}

pairwise_agreement <- function(df, id_cols, decision_col) {
  id_cols <- id_cols[id_cols %in% names(df)]
  if (length(id_cols) == 0 || !decision_col %in% names(df)) return(NA_real_)
  d <- df %>%
    dplyr::filter(!is.na(.data[[decision_col]]), nzchar(as.character(.data[[decision_col]]))) %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(id_cols))) %>%
    dplyr::summarise(vals = list(as.character(.data[[decision_col]])), .groups = "drop")
  pairs <- purrr::map_dfr(d$vals, function(v) {
    if (length(v) < 2) return(tibble::tibble(agree = logical()))
    cmb <- utils::combn(seq_along(v), 2)
    tibble::tibble(agree = v[cmb[1, ]] == v[cmb[2, ]])
  })
  if (nrow(pairs) == 0) return(NA_real_)
  mean(pairs$agree, na.rm = TRUE)
}

fleiss_kappa_from_rows <- function(df, id_cols, decision_col) {
  id_cols <- id_cols[id_cols %in% names(df)]
  if (length(id_cols) == 0 || !decision_col %in% names(df)) return(NA_real_)
  d <- df %>%
    dplyr::mutate(.decision = as.character(.data[[decision_col]])) %>%
    dplyr::filter(!is.na(.data$.decision), nzchar(.data$.decision)) %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(id_cols))) %>%
    dplyr::filter(dplyr::n() > 1) %>%
    dplyr::ungroup()
  if (nrow(d) == 0) return(NA_real_)
  cats <- sort(unique(d$.decision))
  mat <- d %>%
    dplyr::count(dplyr::across(dplyr::all_of(id_cols)), .data$.decision, name = "n") %>%
    tidyr::pivot_wider(names_from = .data$.decision, values_from = n, values_fill = 0) %>%
    dplyr::select(dplyr::all_of(cats)) %>%
    as.matrix()
  n_i <- rowSums(mat)
  valid <- n_i > 1
  mat <- mat[valid, , drop = FALSE]
  n_i <- n_i[valid]
  if (nrow(mat) == 0) return(NA_real_)
  P_i <- rowSums(mat * (mat - 1)) / (n_i * (n_i - 1))
  P_bar <- mean(P_i)
  p_j <- colSums(mat) / sum(mat)
  P_e <- sum(p_j^2)
  if (isTRUE(all.equal(P_e, 1))) return(NA_real_)
  (P_bar - P_e) / (1 - P_e)
}

# -----------------------------
# Output folders
# -----------------------------
VALIDATION_DIR <- file.path(PROJECT_ROOT, "outputs", "validation")
REV_DIR <- VALIDATION_DIR
COMPLETED_DIR <- file.path(REV_DIR, "completed")
TABLE_DIR <- file.path(REV_DIR, "tables")
REVIEWER_FILES_DIR <- file.path(REV_DIR, "validation_files_by_validator")
COMPLETED_REVIEWER_DIR <- file.path(COMPLETED_DIR, "validation_files_by_validator")
LEAD_LAG_DIR <- file.path(REV_DIR, "lead_lag_context")
LEAD_LAG_COMPLETED_DIR <- file.path(LEAD_LAG_DIR, "completed")
# Paper-ready output folders. These match 00_direct_output_config.R but are
# defined here as fallbacks so the audit script can also run standalone.
FIG_SUPP_DIR <- if (exists("FIG_SUPP_DIR", inherits = TRUE)) FIG_SUPP_DIR else file.path(PROJECT_ROOT, "outputs", "figures", "supplement")
TAB_SUPP_DIR <- if (exists("TAB_SUPP_DIR", inherits = TRUE)) TAB_SUPP_DIR else file.path(PROJECT_ROOT, "outputs", "tables", "supplement")
invisible(lapply(c(REV_DIR, COMPLETED_DIR, TABLE_DIR, REVIEWER_FILES_DIR, COMPLETED_REVIEWER_DIR, LEAD_LAG_DIR, LEAD_LAG_COMPLETED_DIR, FIG_SUPP_DIR, TAB_SUPP_DIR), ensure_dir))
# Older workflow folders are left untouched here. Some completed validation files
# may have been saved in legacy folders, so the script searches those locations
# before copying the completed files to the current canonical folders.

# -----------------------------
# Load final video-level LABEL dataset
# -----------------------------
if (!exists("combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN", inherits = FALSE)) {
  candidate_files <- c(
    file.path(DATA_RAW_DIR, "videos_validated.csv")
  )  video_path <- first_existing_file(candidate_files)
  if (is.na(video_path)) {
    stop("Video-level dataset not found. Place the final LABEL CSV in data_raw/ or run 01_load_prepare_video_dataset.R first.")
  }
  message("Reading video-level dataset: ", video_path)
  combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN <- readr::read_csv(video_path, show_col_types = FALSE)
}

video_df_raw <- combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN

# Harmonise expected fields without destroying original names.
if (!"video_id" %in% names(video_df_raw)) {
  vid_candidates <- intersect(c("videoId", "videoID", "id", "yt_video_id"), names(video_df_raw))
  if (length(vid_candidates) > 0) video_df_raw$video_id <- video_df_raw[[vid_candidates[1]]]
}
if (!"created_at" %in% names(video_df_raw)) {
  date_candidates <- intersect(c("publishedAt", "published_at", "published", "publish_date"), names(video_df_raw))
  if (length(date_candidates) > 0) video_df_raw$created_at <- video_df_raw[[date_candidates[1]]]
}
if (!"CleanName" %in% names(video_df_raw) && "TaxonName" %in% names(video_df_raw)) {
  video_df_raw$CleanName <- gsub("_", " ", as.character(video_df_raw$TaxonName))
}
if (!"channelTitle" %in% names(video_df_raw) && "channel" %in% names(video_df_raw)) {
  video_df_raw$channelTitle <- video_df_raw$channel
}
if (!"url" %in% names(video_df_raw) && "video_url" %in% names(video_df_raw)) {
  video_df_raw$url <- video_df_raw$video_url
}
for (cc in c("FirstRecord", "FirstRecordDate", "source_flag", "is_iberian", "title", "description",
             "channelTitle", "url", "TaxonName", "CleanName", "LifeForm", "PresentStatus", "Region")) {
  if (!cc %in% names(video_df_raw)) video_df_raw[[cc]] <- NA
}

video_df_raw <- video_df_raw %>%
  mutate(
    created_at = suppressWarnings(lubridate::ymd_hms(as.character(.data$created_at), tz = "UTC", quiet = TRUE)),
    FirstRecord = suppressWarnings(as.integer(.data$FirstRecord)),
    FirstRecordDate = suppressWarnings(as.POSIXct(.data$FirstRecordDate, tz = "UTC")),
    FirstRecordDate = dplyr::coalesce(.data$FirstRecordDate, as.POSIXct(paste0(.data$FirstRecord, "-06-01 12:00:00"), tz = "UTC")),
    source_flag = as.character(.data$source_flag),
    is_iberian = dplyr::coalesce(normalise_bool(.data$is_iberian), TRUE),
    title = as.character(.data$title),
    description = as.character(.data$description),
    channelTitle = as.character(.data$channelTitle),
    url = as.character(.data$url)
  )

label_df <- video_df_raw %>%
  filter(is.na(.data$is_iberian) | .data$is_iberian %in% TRUE) %>%
  distinct(.data$video_id, .keep_all = TRUE)

message("Final LABEL-like dataset available for audit: ", nrow(label_df), " unique videos.")

# ============================================================
# A) Iberia-relevance validation template + completed metrics
# ============================================================
set.seed(20260602)
N_IBERIA_AUDIT <- getOption("validation.n_iberia_audit", 200)

make_evidence_hint <- function(df) {
  has_geo <- if ("latitude" %in% names(df) | "lat" %in% names(df) | "location" %in% names(df)) TRUE else FALSE
  sf <- if ("source_flag" %in% names(df)) as.character(df$source_flag) else rep(NA_character_, nrow(df))
  region <- if ("Region" %in% names(df)) as.character(df$Region) else rep(NA_character_, nrow(df))
  lang <- if ("language" %in% names(df)) as.character(df$language) else if ("detected_language" %in% names(df)) as.character(df$detected_language) else rep(NA_character_, nrow(df))
  dplyr::case_when(
    !is.na(sf) & str_detect(toupper(sf), "GEO") ~ "GEO/geographic API filter or geotag evidence",
    !is.na(region) & str_detect(tolower(region), "spain|portugal|iber|andorra|azores|madeira|canary|balear") ~ "Regional metadata/textual cue",
    !is.na(lang) & lang %in% c("es", "pt", "ca", "gl", "eu") ~ "Iberian-language cue; requires contextual confirmation",
    TRUE ~ "Manual metadata/text context required"
  )
}

label_audit_pool <- label_df %>%
  mutate(
    audit_stratum = paste(
      ifelse(is.na(.data$source_flag) | !nzchar(.data$source_flag), "UNKNOWN_SOURCE", .data$source_flag),
      ifelse("LifeForm" %in% names(.), as.character(.data$LifeForm), "UNKNOWN_LIFEFORM"),
      sep = "__"
    ),
    evidence_hint = make_evidence_hint(dplyr::pick(dplyr::everything())),
    description_short = short_text(.data$description),
    title_short = short_text(.data$title, n = 220)
  )

n_per_stratum <- max(1, ceiling(N_IBERIA_AUDIT / max(1, n_distinct(label_audit_pool$audit_stratum))))
label_template <- label_audit_pool %>%
  dplyr::group_by(.data$audit_stratum) %>%
  dplyr::group_modify(~ dplyr::slice_sample(.x, n = min(n_per_stratum, nrow(.x)), replace = FALSE)) %>%
  dplyr::ungroup() %>%
  dplyr::slice_head(n = min(N_IBERIA_AUDIT, nrow(.))) %>%
  dplyr::mutate(validation_id = sprintf("IBERIA_%04d", dplyr::row_number())) %>%
  dplyr::select(
    validation_id,
    dplyr::any_of(c("video_id", "url", "title_short", "description_short", "channelTitle", "created_at",
                    "TaxonName", "CleanName", "LifeForm", "PresentStatus", "FirstRecord", "FirstRecordDate",
                    "source_flag", "Region", "is_iberian")),
    evidence_hint
  ) %>%
  dplyr::rename(auto_final_in_LABEL = dplyr::any_of("is_iberian")) %>%
  dplyr::mutate(
    validator2_is_iberian = NA_character_,
    validator2_evidence = NA_character_,
    validator2_exclusion_reason = NA_character_,
    validator2_confidence = NA_character_,
    validator2_notes = NA_character_
  )

label_template_path <- file.path(REVIEWER_FILES_DIR, "LABEL_iberian_relevance_validation_template_all_records.csv")
write_csv(label_template, label_template_path, na = "")
label_assignment <- write_validator_validation_files(label_template, REVIEWER_FILES_DIR, "LABEL_Iberia_relevance_validation", shared_n = 50)

criteria <- tibble::tribble(
  ~decision, ~meaning,
  "TRUE", "Retain: metadata indicates geotagged Iberia, Iberian uploader/channel, filmed in Iberia, or explicit reference to Iberian places/events/monitoring/trade/management/discourse.",
  "FALSE", "Exclude: species mention unrelated, geographic context clearly non-Iberian, not biologically/ecologically relevant, or Iberian relevance cannot be established.",
  "UNCERTAIN", "Use only when the record cannot be confidently retained or excluded; these records are counted separately as uncertainty, not as confirmed positives."
)
write_csv(criteria, file.path(REVIEWER_FILES_DIR, "LABEL_iberian_relevance_validation_decision_rules.csv"), na = "")

completed_label_path <- file.path(COMPLETED_REVIEWER_DIR, "LABEL_iberian_relevance_validation_completed.csv")
label_multi <- read_validation_files(
  COMPLETED_REVIEWER_DIR,
  canonical_file = "LABEL_iberian_relevance_validation_completed.csv",
  include_patterns = c("LABEL_iberian_relevance_validation.*\\.csv$", "LABEL_Iberia_relevance_validation.*\\.csv$", "LABEL.*Iberia.*relevance.*validation.*\\.csv$", "video.*validation.*\\.csv$"),
  exclude_patterns = c("decision_rules", "template", "context", "completed_consensus")
)
if (!is.null(label_multi$rows) && nrow(label_multi$rows) > 0) {
  label_rows_all <- label_multi$rows
  if (!"validation_id" %in% names(label_rows_all)) label_rows_all$validation_id <- label_rows_all$video_id
  label_rows_all <- label_rows_all %>%
    mutate(validator2_is_iberian_norm = case_when(
      str_detect(tolower(trimws(as.character(.data$validator2_is_iberian))), "uncertain|unsure|unknown|doubt") ~ "UNCERTAIN",
      normalise_bool(.data$validator2_is_iberian) %in% TRUE ~ "TRUE",
      normalise_bool(.data$validator2_is_iberian) %in% FALSE ~ "FALSE",
      TRUE ~ NA_character_
    ))
  write_csv(label_rows_all, file.path(TABLE_DIR, "LABEL_iberian_relevance_validation_all_validation_rows.csv"), na = "")

  shared_id_cols <- intersect(c("validation_id", "video_id"), names(label_rows_all))
  label_pairwise_agreement <- pairwise_agreement(label_rows_all, shared_id_cols, "validator2_is_iberian_norm")
  label_fleiss_kappa <- fleiss_kappa_from_rows(label_rows_all, shared_id_cols, "validator2_is_iberian_norm")
  write_csv(tibble(pairwise_agreement = label_pairwise_agreement, fleiss_kappa = label_fleiss_kappa),
            file.path(TABLE_DIR, "LABEL_iberian_relevance_validation_interrater_agreement.csv"), na = "")

  label_consensus <- consensus_from_decisions(label_rows_all, shared_id_cols, "validator2_is_iberian_norm") %>%
    mutate(
      validator2_is_iberian = case_when(
        .data$.decision_consensus == "TRUE" ~ "TRUE",
        .data$.decision_consensus == "FALSE" ~ "FALSE",
        .data$.decision_consensus == "UNCERTAIN" ~ "UNCERTAIN",
        TRUE ~ as.character(.data$.decision_consensus)
      )
    )
  completed_label_path <- file.path(COMPLETED_DIR, "LABEL_iberian_relevance_validation_completed_consensus.csv")
  write_csv(label_consensus, completed_label_path, na = "")
}
# If only the consensus validation file is included (as in a compact public
# release), use it directly. This avoids needing reviewer-specific files.
if (!file.exists(completed_label_path)) {
  consensus_label_path <- file.path(COMPLETED_DIR, "LABEL_iberian_relevance_validation_completed_consensus.csv")
  if (file.exists(consensus_label_path)) completed_label_path <- consensus_label_path
}

if (file.exists(completed_label_path)) {
  label_completed_raw <- read_csv(completed_label_path, show_col_types = FALSE)
  if (!"auto_final_in_LABEL" %in% names(label_completed_raw)) label_completed_raw$auto_final_in_LABEL <- TRUE
  label_completed <- label_completed_raw %>%
    mutate(
      auto_final_in_LABEL_bool = normalise_bool(.data$auto_final_in_LABEL),
      validator2_is_iberian_raw = as.character(.data$validator2_is_iberian),
      validator2_is_iberian_bool = normalise_bool(.data$validator2_is_iberian),
      validator2_uncertain = str_detect(tolower(trimws(.data$validator2_is_iberian_raw)), "uncertain|unsure|unknown|doubt")
    )

  label_valid <- label_completed %>%
    filter(!is.na(.data$auto_final_in_LABEL_bool), !is.na(.data$validator2_is_iberian_bool) | .data$validator2_uncertain)

  n_validationed <- nrow(label_valid)
  n_scored <- sum(!is.na(label_valid$validator2_is_iberian_bool))
  n_false_positive <- sum(label_valid$auto_final_in_LABEL_bool %in% TRUE & label_valid$validator2_is_iberian_bool %in% FALSE, na.rm = TRUE)
  n_uncertain <- sum(label_valid$validator2_uncertain | is.na(label_valid$validator2_is_iberian_bool), na.rm = TRUE)
  agreement <- mean(label_valid$auto_final_in_LABEL_bool == label_valid$validator2_is_iberian_bool, na.rm = TRUE)
  false_positive_rate <- ifelse(n_scored > 0, n_false_positive / n_scored, NA_real_)
  uncertainty_rate <- ifelse(n_validationed > 0, n_uncertain / n_validationed, NA_real_)
  kappa <- cohen_kappa_simple(label_valid$auto_final_in_LABEL_bool, label_valid$validator2_is_iberian_bool)

  label_metrics <- tibble(
    n_validationed = n_validationed,
    n_scored_non_uncertain = n_scored,
    agreement = agreement,
    cohen_kappa = kappa,
    intervalidator_pairwise_agreement = if (exists("label_pairwise_agreement")) label_pairwise_agreement else NA_real_,
    intervalidator_fleiss_kappa = if (exists("label_fleiss_kappa")) label_fleiss_kappa else NA_real_,
    false_positive_n = n_false_positive,
    false_positive_rate = false_positive_rate,
    uncertain_n = n_uncertain,
    uncertainty_rate = uncertainty_rate
  )
  write_csv(label_metrics, file.path(TABLE_DIR, "LABEL_iberian_relevance_validation_metrics.csv"), na = "")

  label_confusion <- label_valid %>%
    mutate(
      auto = ifelse(.data$auto_final_in_LABEL_bool, "Retained in LABEL", "Excluded/not retained"),
      validator = case_when(
        .data$validator2_uncertain | is.na(.data$validator2_is_iberian_bool) ~ "Uncertain",
        .data$validator2_is_iberian_bool ~ "Retain/relevant",
        TRUE ~ "Exclude/not relevant"
      )
    ) %>%
    count(.data$auto, .data$validator, name = "n")
  write_csv(label_confusion, file.path(TABLE_DIR, "LABEL_iberian_relevance_validation_confusion.csv"), na = "")
  # Replacement text files are no longer written; use the exported metrics tables directly for manuscript/response updates.
} else {
  message("Iberia audit template created. Complete it and save as: ", completed_label_path)
}

# ============================================================
# B) Keyword/thematic classifier validation template + metrics
# ============================================================
# Load NO_COMMENTS token table first. This is the primary manuscript corpus.
token_candidates <- c(
  file.path(KW_TABLES_DIR, "token_table_from_BASE_raw_NO_COMMENTS.csv"),
  file.path(KW_OUTPUTS_DIR, "token_table_from_BASE_raw_NO_COMMENTS.csv"),
  file.path(KW_TABLES_DIR, TOKEN_FILE_BASENAME),
  file.path(KW_OUTPUTS_DIR, TOKEN_FILE_BASENAME)
)
token_path <- first_existing_file(token_candidates)
if (is.na(token_path)) {
  warning("No token table found. Run scripts/14_run_all.R in NO_COMMENTS mode before keyword validation.")
  kw_df <- tibble()
} else {
  message("Reading token table for keyword validation: ", token_path)
  kw_df <- read_csv(token_path, show_col_types = FALSE)
}

if (nrow(kw_df) > 0) {
  if (!"KeywordCategory" %in% names(kw_df) && "category" %in% names(kw_df)) kw_df$KeywordCategory <- kw_df$category
  if (!"category" %in% names(kw_df) && "KeywordCategory" %in% names(kw_df)) kw_df$category <- kw_df$KeywordCategory

  kw_context <- kw_df %>%
    left_join(
      label_df %>%
        dplyr::select(dplyr::any_of(c("video_id", "title", "description", "channelTitle", "url"))) %>%
        dplyr::distinct(.data$video_id, .keep_all = TRUE),
      by = "video_id"
    ) %>%
    mutate(
      text_context = short_text(paste(.data$title, .data$description, sep = " | "), n = 600),
      KeywordCategory = as.character(.data$KeywordCategory),
      word = as.character(.data$word)
    ) %>%
    filter(!is.na(.data$KeywordCategory), !is.na(.data$word), nzchar(.data$word))

  set.seed(20260602)
  N_PER_CATEGORY <- getOption("validation.n_keyword_per_category", 100)
  keyword_template <- kw_context %>%
    dplyr::group_by(.data$KeywordCategory) %>%
    dplyr::group_modify(~ dplyr::slice_sample(.x, n = min(N_PER_CATEGORY, nrow(.x)), replace = FALSE)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(validation_id = sprintf("KEYWORD_%04d", dplyr::row_number())) %>%
    dplyr::select(
      validation_id,
      dplyr::any_of(c("video_id", "url", "TaxonName", "LifeForm", "PresentStatus", "created_at", "time_period",
                      "word", "KeywordCategory", "token_source", "title", "text_context"))
    ) %>%
    dplyr::mutate(
      manual_category = NA_character_,
      manual_valid = NA_character_,
      manual_ambiguous = NA_character_,
      manual_notes = NA_character_
    )

  keyword_template_path <- file.path(REVIEWER_FILES_DIR, "keyword_occurrence_validation_template_all_records.csv")
  write_csv(keyword_template, keyword_template_path, na = "")
keyword_assignment <- write_validator_validation_files(keyword_template, REVIEWER_FILES_DIR, "keyword_category_validation", shared_n = 50)
if (exists("label_assignment") && exists("keyword_assignment") && !is.null(label_assignment) && !is.null(keyword_assignment)) {
  assignment_summary <- label_assignment %>%
    dplyr::select(validator, video_shared_rows = shared_rows, video_extra_rows = extra_rows,
                  video_total_rows = total_rows, video_file = file) %>%
    dplyr::left_join(
      keyword_assignment %>%
        dplyr::select(validator, keyword_shared_rows = shared_rows, keyword_extra_rows = extra_rows,
                      keyword_total_rows = total_rows, keyword_file = file),
      by = "validator"
    )
  readr::write_csv(assignment_summary, file.path(REVIEWER_FILES_DIR, "validation_file_assignment_summary.csv"), na = "")
}

  category_rules <- tibble::tribble(
    ~manual_category, ~definition,
    "Invasion", "Terms framing invasion, invasive status, spread, colonisation, alien/non-native status, or management of invasion processes.",
    "Detection", "Terms indicating observation, reporting, monitoring, surveillance, first records, identification, discovery, or early-detection contexts.",
    "eCommerce", "Terms indicating buying, selling, trade, breeding/cultivation for sale, prices, shops, markets, pets/aquarium/horticulture commerce.",
    "Threat", "Terms indicating harm, impact, risk, damage, disease, predation, toxicity, nuisance, or ecological/economic/social threat.",
    "None", "The occurrence is not meaningfully related to any of the four categories in context.",
    "Ambiguous", "The occurrence cannot be confidently assigned from the available context."
  )
  write_csv(category_rules, file.path(REVIEWER_FILES_DIR, "keyword_validation_category_rules.csv"), na = "")

  completed_keyword_path <- file.path(COMPLETED_REVIEWER_DIR, "keyword_occurrence_validation_completed.csv")
  keyword_multi <- read_validation_files(
    COMPLETED_REVIEWER_DIR,
    canonical_file = "keyword_occurrence_validation_completed.csv",
    include_patterns = c("keyword_occurrence_validation.*\\.csv$", "keyword_category_validation.*\\.csv$", "keyword.*validation.*\\.csv$"),
    exclude_patterns = c("decision_rules", "template", "category_rules", "completed_consensus")
  )
  if (!is.null(keyword_multi$rows) && nrow(keyword_multi$rows) > 0) {
    kw_rows_all <- keyword_multi$rows
    if (!"validation_id" %in% names(kw_rows_all)) kw_rows_all$validation_id <- paste(kw_rows_all$video_id, kw_rows_all$word, sep = "__")
    kw_rows_all <- kw_rows_all %>%
      mutate(manual_category_norm = case_when(
        tolower(trimws(as.character(.data$manual_category))) %in% c("invasion") ~ "Invasion",
        tolower(trimws(as.character(.data$manual_category))) %in% c("detection") ~ "Detection",
        tolower(trimws(as.character(.data$manual_category))) %in% c("ecommerce", "e-commerce", "commerce", "trade") ~ "eCommerce",
        tolower(trimws(as.character(.data$manual_category))) %in% c("threat") ~ "Threat",
        tolower(trimws(as.character(.data$manual_category))) %in% c("none", "no", "not valid", "invalid") ~ "None",
        tolower(trimws(as.character(.data$manual_category))) %in% c("ambiguous", "uncertain", "unknown") ~ "Ambiguous",
        TRUE ~ as.character(.data$manual_category)
      ))
    write_csv(kw_rows_all, file.path(TABLE_DIR, "keyword_occurrence_validation_all_validation_rows.csv"), na = "")
    keyword_pairwise_agreement <- pairwise_agreement(kw_rows_all, c("validation_id", "video_id", "word"), "manual_category_norm")
    keyword_fleiss_kappa <- fleiss_kappa_from_rows(kw_rows_all, c("validation_id", "video_id", "word"), "manual_category_norm")
    write_csv(tibble(pairwise_agreement = keyword_pairwise_agreement, fleiss_kappa = keyword_fleiss_kappa),
              file.path(TABLE_DIR, "keyword_validation_interrater_agreement.csv"), na = "")

    kw_consensus <- consensus_from_decisions(kw_rows_all, c("validation_id", "video_id", "word"), "manual_category_norm") %>%
      mutate(manual_category = .data$.decision_consensus)
    completed_keyword_path <- file.path(COMPLETED_DIR, "keyword_occurrence_validation_completed_consensus.csv")
    write_csv(kw_consensus, completed_keyword_path, na = "")
  }
  # If only the consensus validation file is included (as in a compact public
  # release), use it directly. This avoids needing reviewer-specific files.
  if (!file.exists(completed_keyword_path)) {
    consensus_keyword_path <- file.path(COMPLETED_DIR, "keyword_occurrence_validation_completed_consensus.csv")
    if (file.exists(consensus_keyword_path)) completed_keyword_path <- consensus_keyword_path
  }

  if (file.exists(completed_keyword_path)) {
    kw_completed <- read_csv(completed_keyword_path, show_col_types = FALSE) %>%
      mutate(
        auto_category = as.character(.data$KeywordCategory),
        manual_category = str_trim(as.character(.data$manual_category)),
        manual_category = case_when(
          tolower(.data$manual_category) %in% c("invasion") ~ "Invasion",
          tolower(.data$manual_category) %in% c("detection") ~ "Detection",
          tolower(.data$manual_category) %in% c("ecommerce", "e-commerce", "commerce", "trade") ~ "eCommerce",
          tolower(.data$manual_category) %in% c("threat") ~ "Threat",
          tolower(.data$manual_category) %in% c("none", "no", "not valid", "invalid") ~ "None",
          tolower(.data$manual_category) %in% c("ambiguous", "uncertain", "unknown") ~ "Ambiguous",
          TRUE ~ .data$manual_category
        ),
        manual_valid_bool = normalise_bool(.data$manual_valid),
        manual_ambiguous_bool = normalise_bool(.data$manual_ambiguous) %in% TRUE | .data$manual_category %in% "Ambiguous"
      ) %>%
      filter(!is.na(.data$auto_category), !is.na(.data$manual_category), nzchar(.data$manual_category))

    kw_scored <- kw_completed %>%
      filter(!.data$manual_category %in% c("Ambiguous"))

    kw_confusion <- kw_scored %>%
      count(.data$manual_category, .data$auto_category, name = "n") %>%
      arrange(.data$manual_category, .data$auto_category)
    write_csv(kw_confusion, file.path(TABLE_DIR, "keyword_validation_confusion_matrix_long.csv"), na = "")

    categories <- c("Invasion", "Detection", "eCommerce", "Threat")
    kw_metrics_by_cat <- purrr::map_dfr(categories, function(cat) {
      tp <- sum(kw_scored$manual_category == cat & kw_scored$auto_category == cat, na.rm = TRUE)
      fp <- sum(kw_scored$manual_category != cat & kw_scored$auto_category == cat, na.rm = TRUE)
      fn <- sum(kw_scored$manual_category == cat & kw_scored$auto_category != cat, na.rm = TRUE)
      precision <- ifelse(tp + fp > 0, tp / (tp + fp), NA_real_)
      recall <- ifelse(tp + fn > 0, tp / (tp + fn), NA_real_)
      f1 <- ifelse(!is.na(precision + recall) && (precision + recall) > 0, 2 * precision * recall / (precision + recall), NA_real_)
      tibble(category = cat, tp = tp, fp = fp, fn = fn, precision = precision, recall = recall, f1 = f1)
    })

    overall_accuracy <- mean(kw_scored$manual_category == kw_scored$auto_category, na.rm = TRUE)
    kappa_kw <- cohen_kappa_simple(kw_scored$manual_category, kw_scored$auto_category)
    ambiguous_rate <- mean(kw_completed$manual_category %in% c("Ambiguous") | kw_completed$manual_ambiguous_bool, na.rm = TRUE)
    invalid_rate <- mean(kw_completed$manual_category %in% c("None") | kw_completed$manual_valid_bool %in% FALSE, na.rm = TRUE)

    kw_overall <- tibble(
      n_validationed = nrow(kw_completed),
      n_scored_excluding_ambiguous = nrow(kw_scored),
      overall_accuracy = overall_accuracy,
      cohen_kappa = kappa_kw,
      intervalidator_pairwise_agreement = if (exists("keyword_pairwise_agreement")) keyword_pairwise_agreement else NA_real_,
      intervalidator_fleiss_kappa = if (exists("keyword_fleiss_kappa")) keyword_fleiss_kappa else NA_real_,
      ambiguous_rate = ambiguous_rate,
      invalid_or_none_rate = invalid_rate
    )
    write_csv(kw_overall, file.path(TABLE_DIR, "keyword_validation_overall_metrics.csv"), na = "")
    write_csv(kw_metrics_by_cat, file.path(TABLE_DIR, "keyword_validation_category_metrics.csv"), na = "")

    low_precision_terms <- kw_completed %>%
      filter(.data$manual_category %in% c("None", "Ambiguous") | .data$manual_valid_bool %in% FALSE | .data$manual_category != .data$auto_category) %>%
      count(.data$word, .data$auto_category, .data$manual_category, name = "n_problem_cases") %>%
      arrange(desc(.data$n_problem_cases), .data$word)
    write_csv(low_precision_terms, file.path(TABLE_DIR, "keyword_validation_terms_to_validation_or_remove.csv"), na = "")
    # Replacement text files are no longer written; use the exported keyword validation tables directly.
  } else {
    message("Keyword validation template created. Complete it and save as: ", completed_keyword_path)
  }
}

# ============================================================
# C) Exploratory first-YouTube / official first-record comparison
# ============================================================
# Validator 2 requested a species-level comparison between official Iberian
# first records and the first Iberia-relevant YouTube record. This block keeps
# the analysis explicitly exploratory: it provides the species-level comparison table, year-level
# before/same/after summaries, figures, and a manual context-audit template for
# the subset of species whose first retained YouTube video predates the official
# first-record anchor. The context audit is essential because pre-record videos
# may represent trade/captivity/media/general discourse rather than wild Iberian
# occurrence.

first_non_missing <- function(x) {
  x <- x[!is.na(x) & nzchar(as.character(x))]
  if (length(x) == 0) return(NA)
  x[[1]]
}

first_video_by_species <- label_df %>%
  filter(!is.na(.data$TaxonName), !is.na(.data$created_at), !is.na(.data$FirstRecordDate)) %>%
  arrange(.data$TaxonName, .data$created_at, .data$video_id) %>%
  group_by(.data$TaxonName) %>%
  slice_head(n = 1) %>%
  ungroup() %>%
  transmute(
    TaxonName,
    first_video_id = .data$video_id,
    first_youtube_date = .data$created_at,
    first_youtube_year = lubridate::year(.data$created_at),
    first_youtube_title = short_text(.data$title, n = 220),
    first_youtube_description = short_text(.data$description, n = 600),
    first_youtube_channel = .data$channelTitle,
    first_youtube_url = .data$url
  )

first_pre_record_video <- label_df %>%
  filter(!is.na(.data$TaxonName), !is.na(.data$created_at), !is.na(.data$FirstRecordDate),
         .data$created_at < .data$FirstRecordDate) %>%
  arrange(.data$TaxonName, .data$created_at, .data$video_id) %>%
  group_by(.data$TaxonName) %>%
  slice_head(n = 1) %>%
  ungroup() %>%
  transmute(
    TaxonName,
    first_pre_record_video_id = .data$video_id,
    first_pre_record_youtube_date = .data$created_at,
    first_pre_record_youtube_year = lubridate::year(.data$created_at),
    first_pre_record_title = short_text(.data$title, n = 220),
    first_pre_record_description = short_text(.data$description, n = 600),
    first_pre_record_channel = .data$channelTitle,
    first_pre_record_url = .data$url
  )

lead_lag_base <- label_df %>%
  filter(!is.na(.data$TaxonName), !is.na(.data$created_at), !is.na(.data$FirstRecordDate)) %>%
  group_by(.data$TaxonName) %>%
  summarise(
    CleanName = first_non_missing(.data$CleanName),
    LifeForm = first_non_missing(.data$LifeForm),
    PresentStatus = first_non_missing(.data$PresentStatus),
    FirstRecord = first_non_missing(.data$FirstRecord),
    FirstRecordDate = min(.data$FirstRecordDate, na.rm = TRUE),
    official_first_record_year = suppressWarnings(as.integer(first_non_missing(.data$FirstRecord))),
    n_videos_total = n_distinct(.data$video_id),
    n_videos_pre_record = n_distinct(.data$video_id[.data$created_at < .data$FirstRecordDate]),
    n_videos_same_year_as_record = n_distinct(.data$video_id[lubridate::year(.data$created_at) == lubridate::year(.data$FirstRecordDate)]),
    n_videos_post_record = n_distinct(.data$video_id[.data$created_at >= .data$FirstRecordDate]),
    .groups = "drop"
  ) %>%
  left_join(first_video_by_species, by = "TaxonName") %>%
  left_join(first_pre_record_video, by = "TaxonName") %>%
  mutate(
    official_first_record_year = dplyr::coalesce(.data$official_first_record_year, lubridate::year(.data$FirstRecordDate)),
    lead_lag_days = as.numeric(difftime(.data$first_youtube_date, .data$FirstRecordDate, units = "days")),
    lead_lag_years = .data$lead_lag_days / 365.25,
    lead_lag_years_rounded = round(.data$lead_lag_years, 2),
    year_lag = .data$first_youtube_year - .data$official_first_record_year,
    youtube_before_first_record = .data$lead_lag_days < 0,
    year_category = case_when(
      is.na(.data$year_lag) ~ NA_character_,
      .data$year_lag < 0 ~ "YouTube before official first-record year",
      .data$year_lag == 0 ~ "YouTube in same year as official first record",
      .data$year_lag > 0 ~ "YouTube after official first-record year"
    ),
    day_category = case_when(
      is.na(.data$lead_lag_days) ~ NA_character_,
      .data$lead_lag_days < 0 ~ "YouTube before official first-record anchor",
      .data$lead_lag_days == 0 ~ "YouTube on official first-record anchor",
      .data$lead_lag_days > 0 ~ "YouTube after official first-record anchor"
    ),
    interpretation = case_when(
      .data$youtube_before_first_record ~ "First retained YouTube video predates official first-record anchor; manual context inspection required before interpretation.",
      .data$lead_lag_days == 0 ~ "First retained YouTube video occurs on the same day as the temporal anchor.",
      TRUE ~ "First retained YouTube video occurs after the official first-record anchor."
    )
  ) %>%
  arrange(.data$lead_lag_days)

# Manual context audit template for pre-record species -------------------------
# Only the species/videos with first_youtube_date < FirstRecordDate need this
# extra contextual validation. Do not interpret these cases as early detection until
# the context field has been completed.
lead_lag_context_template <- lead_lag_base %>%
  filter(.data$youtube_before_first_record %in% TRUE) %>%
  transmute(
    validation_id = sprintf("LEADLAG_%04d", row_number()),
    TaxonName,
    CleanName,
    LifeForm,
    PresentStatus,
    official_first_record_year,
    FirstRecordDate,
    first_youtube_year,
    first_youtube_date,
    year_lag,
    lead_lag_years = .data$lead_lag_years_rounded,
    first_video_id,
    first_youtube_url,
    first_youtube_channel,
    first_youtube_title,
    first_youtube_description,
    pre_record_context_category = NA_character_,
    plausible_wild_iberian_occurrence = NA_character_,
    confidence = NA_character_,
    validator_notes = NA_character_
  )

lead_lag_context_template_path <- file.path(LEAD_LAG_DIR, "lead_lag_prerecord_context_template.csv")
write_csv(lead_lag_context_template, lead_lag_context_template_path, na = "")

lead_lag_context_rules <- tibble::tribble(
  ~pre_record_context_category, ~meaning,
  "Plausible Iberian detection / observation", "The pre-record video appears to document the focal species in the Iberian region, or provides a plausible wild/local observation context.",
  "Trade / pet / aquarium / ornamental", "The pre-record video mainly concerns sale, trade, pet keeping, aquarium/terrarium keeping, ornamental use, nursery/horticulture, or other captive/commercial contexts.",
  "Media / news / institutional communication", "The pre-record video is primarily a news, institutional, management, awareness, or public communication item, rather than direct evidence of occurrence.",
  "General species information", "The pre-record video gives general educational/natural-history/species information without clear wild Iberian occurrence evidence.",
  "Non-occurrence / unclear Iberian relevance", "The pre-record video does not provide a clear Iberian wild occurrence context, or the relevant context is unclear/non-occurrence based.",
  "Uncertain", "Available information is insufficient for confident classification. Use this only after checking metadata and, if needed, the linked video."
)
write_csv(lead_lag_context_rules, file.path(LEAD_LAG_DIR, "lead_lag_prerecord_context_decision_rules.csv"), na = "")

# If the context template has been completed, merge it back into the species-level comparison table.
# Preferred location: outputs/validation/lead_lag_context/completed/
# Legacy location outputs/validation/completed/ is also supported.
completed_context_candidates <- c(
  file.path(LEAD_LAG_COMPLETED_DIR, "lead_lag_prerecord_context_completed.csv"),
  file.path(COMPLETED_DIR, "lead_lag_prerecord_context_completed.csv"),
  # Legacy/accidental locations from earlier workflow versions. These make the
  # script robust if the completed file was saved before the folders were cleaned.
  file.path(REV_DIR, "templates", "lead_lag_prerecord_context_completed.csv"),
  file.path(REV_DIR, "lead_lag_prerecord_context_completed.csv"),
  file.path(PROJECT_ROOT, "lead_lag_prerecord_context_completed.csv")
)
# Also search recursively in outputs/validation in case the completed
# file was copied into a validator/template subfolder by mistake.
recursive_context_hits <- list.files(
  REV_DIR,
  pattern = "^lead_lag_prerecord_context_completed\\.csv$",
  recursive = TRUE,
  full.names = TRUE
)
completed_context_candidates <- unique(c(completed_context_candidates, recursive_context_hits))
completed_context_path <- first_existing_file(completed_context_candidates)
if (!is.na(completed_context_path) && file.exists(completed_context_path)) {
  # Keep one canonical copy for future runs.
  canonical_context_path <- file.path(LEAD_LAG_COMPLETED_DIR, "lead_lag_prerecord_context_completed.csv")
  if (!identical(normalizePath(completed_context_path, mustWork = FALSE),
                 normalizePath(canonical_context_path, mustWork = FALSE))) {
    dir.create(dirname(canonical_context_path), recursive = TRUE, showWarnings = FALSE)
    file.copy(completed_context_path, canonical_context_path, overwrite = TRUE)
    message("Copied lead/first-record context file to canonical location: ", canonical_context_path)
  }
  lead_lag_context_completed <- read_csv(completed_context_path, show_col_types = FALSE)

  # Older completed templates used reviewer_notes instead of validator_notes.
  # Add any missing columns before standardising them.
  if (!"validator_notes" %in% names(lead_lag_context_completed) &&
      "reviewer_notes" %in% names(lead_lag_context_completed)) {
    lead_lag_context_completed$validator_notes <- lead_lag_context_completed$reviewer_notes
  }
  for (cc in c("pre_record_context_category",
               "plausible_wild_iberian_occurrence",
               "confidence",
               "validator_notes")) {
    if (!cc %in% names(lead_lag_context_completed)) lead_lag_context_completed[[cc]] <- NA_character_
  }

  lead_lag_context_completed <- lead_lag_context_completed %>%
    mutate(
      pre_record_context_category = as.character(.data$pre_record_context_category),
      plausible_wild_iberian_occurrence = as.character(.data$plausible_wild_iberian_occurrence),
      confidence = as.character(.data$confidence),
      validator_notes = as.character(.data$validator_notes)
    )

  lead_lag_context_summary <- lead_lag_context_completed %>%
    filter(!is.na(.data$pre_record_context_category), nzchar(trimws(.data$pre_record_context_category))) %>%
    count(.data$pre_record_context_category, name = "n_species") %>%
    mutate(pct_species = 100 * .data$n_species / sum(.data$n_species)) %>%
    arrange(desc(.data$n_species), .data$pre_record_context_category)
  write_csv(lead_lag_context_summary, file.path(TABLE_DIR, "lead_lag_prerecord_context_summary.csv"), na = "")

  lead_lag <- lead_lag_base %>%
    left_join(
      lead_lag_context_completed %>%
        dplyr::select(TaxonName, pre_record_context_category, plausible_wild_iberian_occurrence, confidence, validator_notes),
      by = "TaxonName"
    )
} else {
  lead_lag <- lead_lag_base %>%
    mutate(
      pre_record_context_category = ifelse(.data$youtube_before_first_record, "Pending manual context validation", NA_character_),
      plausible_wild_iberian_occurrence = NA_character_,
      confidence = NA_character_,
      validator_notes = NA_character_
    )
  message("Lead/first-record context template created. Complete it and save as: ", file.path(LEAD_LAG_COMPLETED_DIR, "lead_lag_prerecord_context_completed.csv"))
}

lead_lag_export <- lead_lag %>%
  dplyr::select(
    TaxonName, CleanName, LifeForm, PresentStatus,
    official_first_record_year, FirstRecordDate,
    first_youtube_year, first_youtube_date, first_video_id, first_youtube_url,
    year_lag, lead_lag_days, lead_lag_years, lead_lag_years_rounded,
    day_category, year_category,
    n_videos_total, n_videos_pre_record, n_videos_same_year_as_record, n_videos_post_record,
    first_pre_record_video_id, first_pre_record_youtube_date, first_pre_record_youtube_year,
    first_pre_record_url,
    pre_record_context_category, plausible_wild_iberian_occurrence, confidence, validator_notes,
    interpretation
  ) %>%
  arrange(.data$lead_lag_days)

write_csv(lead_lag_export, file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record.csv"), na = "")
write_csv(lead_lag_export, file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record_with_context.csv"), na = "")

lead_lag_day_summary <- lead_lag %>%
  summarise(
    n_species = n(),
    n_species_with_youtube_before_first_record = sum(.data$youtube_before_first_record, na.rm = TRUE),
    pct_species_with_youtube_before_first_record = 100 * mean(.data$youtube_before_first_record, na.rm = TRUE),
    n_species_with_youtube_same_anchor = sum(.data$lead_lag_days == 0, na.rm = TRUE),
    pct_species_with_youtube_same_anchor = 100 * mean(.data$lead_lag_days == 0, na.rm = TRUE),
    n_species_with_youtube_after_first_record = sum(.data$lead_lag_days > 0, na.rm = TRUE),
    pct_species_with_youtube_after_first_record = 100 * mean(.data$lead_lag_days > 0, na.rm = TRUE),
    median_lead_lag_years = median(.data$lead_lag_years, na.rm = TRUE),
    min_lead_lag_years = min(.data$lead_lag_years, na.rm = TRUE),
    max_lead_lag_years = max(.data$lead_lag_years, na.rm = TRUE)
  )
write_csv(lead_lag_day_summary, file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record_summary.csv"), na = "")

lead_lag_year_summary <- lead_lag %>%
  filter(!is.na(.data$year_category)) %>%
  count(.data$year_category, name = "n_species") %>%
  mutate(pct_species = 100 * .data$n_species / sum(.data$n_species)) %>%
  arrange(match(.data$year_category, c(
    "YouTube before official first-record year",
    "YouTube in same year as official first record",
    "YouTube after official first-record year"
  )))
write_csv(lead_lag_year_summary, file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record_year_category_summary.csv"), na = "")

# Optional compact summary by life form, useful for checking taxonomic bias.
lead_lag_lifeform_summary <- lead_lag %>%
  filter(!is.na(.data$LifeForm), nzchar(as.character(.data$LifeForm))) %>%
  count(.data$LifeForm, .data$year_category, name = "n_species") %>%
  group_by(.data$LifeForm) %>%
  mutate(pct_within_lifeform = 100 * .data$n_species / sum(.data$n_species)) %>%
  ungroup() %>%
  arrange(.data$LifeForm, .data$year_category)
write_csv(lead_lag_lifeform_summary, file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record_by_lifeform.csv"), na = "")

# Replacement text with both exact-date and year-level summaries.
year_before_n <- lead_lag_year_summary$n_species[lead_lag_year_summary$year_category == "YouTube before official first-record year"]
year_same_n   <- lead_lag_year_summary$n_species[lead_lag_year_summary$year_category == "YouTube in same year as official first record"]
year_after_n  <- lead_lag_year_summary$n_species[lead_lag_year_summary$year_category == "YouTube after official first-record year"]
year_before_pct <- lead_lag_year_summary$pct_species[lead_lag_year_summary$year_category == "YouTube before official first-record year"]
year_same_pct   <- lead_lag_year_summary$pct_species[lead_lag_year_summary$year_category == "YouTube in same year as official first record"]
year_after_pct  <- lead_lag_year_summary$pct_species[lead_lag_year_summary$year_category == "YouTube after official first-record year"]
for (obj in c("year_before_n","year_same_n","year_after_n","year_before_pct","year_same_pct","year_after_pct")) {
  if (length(get(obj)) == 0) assign(obj, 0, inherits = FALSE)
}

context_sentence <- "Manual context classification of pre-record videos has not yet been completed; these cases should therefore be treated as pending contextual validation."
if (exists("lead_lag_context_summary")) {
  context_sentence <- paste0(
    "Manual context classification of the pre-record cases gave the following distribution: ",
    paste0(lead_lag_context_summary$pre_record_context_category, " ",
           lead_lag_context_summary$n_species, " species (",
           round(lead_lag_context_summary$pct_species, 1), "%)", collapse = "; "),
    "."
  )
}

# Replacement text files are no longer written; use the exported tables and manuscript wording.

# Supplementary Fig. S8: species-level first-YouTube vs first-record dot plot (all species).
p_lead <- lead_lag %>%
  mutate(CleanName_plot = ifelse(is.na(.data$CleanName) | !nzchar(.data$CleanName), .data$TaxonName, .data$CleanName)) %>%
  arrange(.data$lead_lag_years) %>%
  mutate(CleanName_plot = factor(.data$CleanName_plot, levels = .data$CleanName_plot)) %>%
  ggplot(aes(x = lead_lag_years, y = CleanName_plot)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_point() +
  labs(x = "First YouTube video relative to official first record (years)", y = NULL) +
  theme_light(base_size = 10)

FIG_S8_HEIGHT_IN <- max(5, 0.11 * nrow(lead_lag))
ggsave(file.path(FIG_SUPP_DIR, "Figure_S8.png"),
       p_lead, width = 8.0, height = FIG_S8_HEIGHT_IN, dpi = 300, bg = "white")
ggsave(file.path(FIG_SUPP_DIR, "Figure_S8.tiff"),
       p_lead, width = 8.0, height = FIG_S8_HEIGHT_IN, dpi = 300,
       device = "tiff", compression = "lzw", bg = "white")
message("Saved Figure S8 to: ", file.path(FIG_SUPP_DIR, "Figure_S8.png"))

# Supplementary Fig. S7: manual context classification of earliest pre-record videos.
# Change these values if a different exported size is needed.
FIG_S7_WIDTH_MM  <- 230
FIG_S7_HEIGHT_MM <- 120

# If the completed context file was already processed in a previous run, the
# summary table can be used to recreate the figure without repeating the audit.
if (!exists("lead_lag_context_summary")) {
  context_summary_path <- file.path(TABLE_DIR, "lead_lag_prerecord_context_summary.csv")
  if (file.exists(context_summary_path)) {
    lead_lag_context_summary <- readr::read_csv(context_summary_path, show_col_types = FALSE)
    message("Using existing context summary to recreate Figure S7: ", context_summary_path)
  }
}

# This is the figure referenced in the Supplementary Material caption.
if (exists("lead_lag_context_summary") && nrow(lead_lag_context_summary) > 0) {
  context_cols <- c(
    "Trade / pet / aquarium / ornamental" = "#6F4685",
    "Plausible Iberian detection / observation" = "#A6FF4D",
    "Media / news / institutional communication" = "#959BFF",
    "General species information" = "#FDB863",
    "Non-occurrence / unclear Iberian relevance" = "#B2ABD2",
    "Uncertain" = "#999999"
  )
  p_context <- lead_lag_context_summary %>%
    mutate(
      pre_record_context_category = factor(.data$pre_record_context_category, levels = rev(.data$pre_record_context_category)),
      label = paste0(.data$n_species, " (", round(.data$pct_species, 1), "%)")
    ) %>%
    ggplot(aes(x = n_species, y = pre_record_context_category, fill = as.character(pre_record_context_category))) +
    geom_col(width = 0.7) +
    geom_text(aes(label = label), hjust = -0.08, size = 4.2) +
    scale_fill_manual(values = context_cols, guide = "none") +
    labs(x = "Number of pre-record species", y = NULL) +
    coord_cartesian(xlim = c(0, max(lead_lag_context_summary$n_species, na.rm = TRUE) * 1.22), clip = "off") +
    theme_light(base_size = 13) +
    theme(
      axis.text.x = element_text(size = 12),
      axis.text.y = element_text(size = 12),
      axis.title.x = element_text(size = 14),
      plot.margin = margin(10, 20, 10, 10)
    )
  ggsave(file.path(FIG_SUPP_DIR, "Figure_S7.png"),
         p_context, width = FIG_S7_WIDTH_MM, height = FIG_S7_HEIGHT_MM, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(FIG_SUPP_DIR, "Figure_S7.tiff"),
         p_context, width = FIG_S7_WIDTH_MM, height = FIG_S7_HEIGHT_MM, units = "mm", dpi = 300,
         device = "tiff", compression = "lzw", bg = "white")
  message("Saved Figure S7 to: ", file.path(FIG_SUPP_DIR, "Figure_S7.png"))
} else {
  message("Figure S7 was not created because no completed pre-record context summary was found.")
  message("Expected completed file: ", file.path(LEAD_LAG_COMPLETED_DIR, "lead_lag_prerecord_context_completed.csv"))
}

# Paper-ready Supplementary Table S17 and additional complete audit tables.
readr::write_csv(lead_lag_export, file.path(TAB_SUPP_DIR, "Table_S17_first_youtube_vs_first_record_with_context.csv"), na = "")
readr::write_csv(
  lead_lag_export %>% dplyr::filter(.data$day_category == "YouTube before official first-record anchor" | .data$year_category == "YouTube in same year as official first record"),
  file.path(TAB_SUPP_DIR, "Table_S17_prerecord_context_cases.csv"),
  na = ""
)

# ============================================================
# D) Comments-only sensitivity summary, if produced by 99 workflow
# ============================================================
comments_token_candidates <- c(
  file.path(KW_TABLES_DIR, "token_table_from_BASE_raw_COMMENTS.csv"),
  file.path(KW_OUTPUTS_DIR, "token_table_from_BASE_raw_COMMENTS.csv"),
  file.path(KW_TABLES_DIR, "token_table_from_BASE_raw_COMMENTS_ONLY.csv"),
  file.path(KW_OUTPUTS_DIR, "token_table_from_BASE_raw_COMMENTS_ONLY.csv")
)
comments_token_path <- first_existing_file(comments_token_candidates)
if (!is.na(comments_token_path)) {
  comments_toks <- read_csv(comments_token_path, show_col_types = FALSE)
  if (!"KeywordCategory" %in% names(comments_toks) && "category" %in% names(comments_toks)) comments_toks$KeywordCategory <- comments_toks$category
  comments_summary <- comments_toks %>%
    filter(!is.na(.data$KeywordCategory)) %>%
    count(.data$KeywordCategory, name = "n_tokens") %>%
    mutate(prop = .data$n_tokens / sum(.data$n_tokens)) %>%
    arrange(desc(.data$n_tokens))
  write_csv(comments_summary, file.path(TABLE_DIR, "comments_only_thematic_summary.csv"), na = "")
  # Comments-only replacement text files are no longer written; use comments_only_thematic_summary.csv.
} else {
  message("No comments-only token table found; skipping comments sensitivity summary. Run scripts/99_run_main_plus_comments_sensitivity.R if needed.")
}

# ============================================================
# Final index of outputs
# ============================================================
index_paths <- c(
  label_template_path,
  file.path(REVIEWER_FILES_DIR, "LABEL_iberian_relevance_validation_decision_rules.csv"),
  file.path(REVIEWER_FILES_DIR, "keyword_occurrence_validation_template_all_records.csv"),
  file.path(REVIEWER_FILES_DIR, "keyword_validation_category_rules.csv"),
  lead_lag_context_template_path,
  file.path(LEAD_LAG_DIR, "lead_lag_prerecord_context_decision_rules.csv"),
  file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record.csv"),
  file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record_with_context.csv"),
  file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record_summary.csv"),
  file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record_year_category_summary.csv"),
  file.path(TABLE_DIR, "exploratory_species_first_youtube_vs_first_record_by_lifeform.csv"),
  file.path(TABLE_DIR, "lead_lag_prerecord_context_summary.csv"),
  file.path(FIG_SUPP_DIR, "Figure_S7.png"),
  file.path(FIG_SUPP_DIR, "Figure_S8.png"),
  file.path(TAB_SUPP_DIR, "Table_S17_first_youtube_vs_first_record_with_context.csv"),
  file.path(TAB_SUPP_DIR, "Table_S17_prerecord_context_cases.csv"),
  file.path(TABLE_DIR, "comments_only_thematic_summary.csv")
)
output_index <- tibble(
  output_type = dplyr::case_when(
    stringr::str_detect(index_paths, "validation_files_by_validator|lead_lag_context|_template|decision_rules") ~ "template_or_rules",
    stringr::str_detect(index_paths, "\\.png$|\\.tiff$") ~ "figure",
    TRUE ~ "table"
  ),
  path = index_paths,
  exists = file.exists(index_paths)
)
write_csv(output_index, file.path(REV_DIR, "validation_output_index.csv"), na = "")
print(output_index)

message("Validation/audit script completed. See: ", REV_DIR)
