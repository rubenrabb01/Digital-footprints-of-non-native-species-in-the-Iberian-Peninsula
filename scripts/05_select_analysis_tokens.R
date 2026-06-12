# ============================================================
# 05_select_analysis_tokens.R
# Reads the token table matching ANALYSIS_MODE and creates stable active
# aliases plus backwards-compatible names used by submitted scripts.
# ============================================================

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(lubridate); library(forcats)
})

# Prefer tables tree, then outputs tree.
kw_ACTIVE <- read_csv_first(c(TOKEN_FILE_TABLES, TOKEN_FILE_OUTPUTS), show_col_types = FALSE) %>%
  harmonize_token_table()

df_ACTIVE <- make_multinom_frame(kw_ACTIVE)

if (ANALYSIS_MODE == "NO_COMMENTS") {
  kw_NO_COMMENTS <- kw_ACTIVE
  df_NO_COMMENTS <- df_ACTIVE
  # Some legacy scripts refer to this optional generic name.
  all_token_optional <- file.path(KW_TABLES_DIR, "token_table_from_BASE_raw.csv")
  if (file.exists(all_token_optional)) {
    kw_ALL_TOKENS <- readr::read_csv(all_token_optional, show_col_types = FALSE) %>%
      harmonize_token_table()
  }
}

if (ANALYSIS_MODE == "COMMENTS_TIMESTAMPS") {
  kw_COMMENTS_TIMESTAMPS <- kw_ACTIVE
  df_COMMENTS_TIMESTAMPS <- df_ACTIVE
  # Backward-compatible aliases used by the uploaded ALL-token scripts.
  kw_ALL <- kw_ACTIVE
  df_ALL <- df_ACTIVE
  kw_ALL_TOKENS <- kw_ACTIVE
}

if (ANALYSIS_MODE == "COMMENTS_ONLY") {
  kw_COMMENTS_ONLY <- kw_ACTIVE
  df_COMMENTS_ONLY <- df_ACTIVE

  # Backward-compatible aliases used by the uploaded ALL-token scripts.
  # In this mode, the "ALL" legacy names deliberately contain comments/replies only.
  kw_ALL <- kw_ACTIVE
  df_ALL <- df_ACTIVE
  kw_ALL_TOKENS <- kw_ACTIVE
}

# Always expose active names for new scripts.
assign(paste0("kw_", OBJECT_SUFFIX), kw_ACTIVE, envir = .GlobalEnv)
assign(paste0("df_", OBJECT_SUFFIX), df_ACTIVE, envir = .GlobalEnv)

ensure_dir(file.path(TABLES_ROOT, "audit"))
token_audit <- tibble::tibble(
  analysis_mode = ANALYSIS_MODE,
  token_file = TOKEN_FILE_BASENAME,
  n_tokens = nrow(kw_ACTIVE),
  n_model_rows = nrow(df_ACTIVE),
  n_videos = dplyr::n_distinct(kw_ACTIVE$video_id),
  n_species = dplyr::n_distinct(kw_ACTIVE$TaxonName)
)
readr::write_csv(token_audit, file.path(TABLES_ROOT, "audit", paste0("token_audit", OUTPUT_SUFFIX, ".csv")))
print(token_audit)

if (all(c("KeywordCategory", "time_period") %in% names(kw_ACTIVE))) {
  token_period_category_audit <- kw_ACTIVE %>%
    dplyr::count(.data$time_period, .data$KeywordCategory, name = "n") %>%
    dplyr::arrange(.data$time_period, .data$KeywordCategory)
  readr::write_csv(token_period_category_audit, file.path(TABLES_ROOT, "audit", paste0("token_period_category_audit", OUTPUT_SUFFIX, ".csv")))
  print(token_period_category_audit)
}
