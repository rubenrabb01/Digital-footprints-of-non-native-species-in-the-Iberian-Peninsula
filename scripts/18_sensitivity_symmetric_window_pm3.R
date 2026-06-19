# ============================================================
# 18_sensitivity_symmetric_window_pm3.R
# Exploratory symmetric-window sensitivity analysis (-3 to +3 years)
#
# Purpose:
#   Test whether the main pre/post thematic patterns are similar when
#   retaining only title/description keyword tokens within a balanced
#   time window around each species' official Iberian first-record date.
#
# Recommended placement:
#   Put this file in scripts/ and run it from the project root AFTER the
#   main NO_COMMENTS workflow has created the token tables, or let this
#   script source scripts 00-05 automatically.
#
# Outputs:
#   outputs/intermediate/sensitivity_symmetric_window_pm3/*.csv
#   outputs/figures/supplement/Figure_S10.png/.tiff
# ============================================================

# ------------------------- user options -------------------------
SYM_WINDOW_YEARS <- 3
KW_LEVELS <- c("Invasion", "Detection", "eCommerce", "Threat")

# Optional minimum-data filters for diagnostics only.
# The main symmetric-window result uses min_tokens = 0 and min_videos = 0.
THRESHOLD_GRID <- tibble::tribble(
  ~scenario,              ~min_tokens_per_species_period, ~min_videos_per_species_period,
  "pm3_no_threshold",       0,                              0,
  "pm3_min10_tokens",      10,                              0,
  "pm3_min25_tokens",      25,                              0,
  "pm3_min3_videos",        0,                              3
)

# ------------------------- setup -------------------------
if (!exists("PROJECT_ROOT", inherits = FALSE)) {
  PROJECT_ROOT <- getwd()
}
if (basename(getwd()) == "scripts") {
  setwd(dirname(getwd()))
  PROJECT_ROOT <- getwd()
}

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(lubridate)
  library(ggplot2)
  library(lme4)
  library(emmeans)
})

ensure_dir2 <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}

OUT_DIR <- file.path(PROJECT_ROOT, "outputs", "intermediate", "sensitivity_symmetric_window_pm3")
FIG_DIR <- file.path(PROJECT_ROOT, "outputs", "figures", "supplement")
ensure_dir2(OUT_DIR)
ensure_dir2(FIG_DIR)

# ------------------------- load NO_COMMENTS tokens -------------------------
# Prefer an existing NO_COMMENTS token table. If unavailable, source scripts 00-05.
kw_path_candidates <- c(
  file.path(PROJECT_ROOT, "outputs", "intermediate", "keywords", "token_table_from_BASE_raw_NO_COMMENTS.csv"),
  file.path(PROJECT_ROOT, "outputs", "keywords", "token_table_from_BASE_raw_NO_COMMENTS.csv")
)
kw_path <- kw_path_candidates[file.exists(kw_path_candidates)][1]

if (!is.na(kw_path)) {
  message("Reading NO_COMMENTS token table: ", kw_path)
  kw <- readr::read_csv(kw_path, show_col_types = FALSE)
} else {
  message("NO_COMMENTS token table not found. Sourcing scripts 00-05 to create it...")
  ANALYSIS_MODE <- "NO_COMMENTS"
  source(file.path(PROJECT_ROOT, "scripts", "00_config_paths_mode.R"), encoding = "UTF-8")
  source(file.path(PROJECT_ROOT, "scripts", "00_direct_output_config.R"), encoding = "UTF-8")
  source(file.path(PROJECT_ROOT, "scripts", "00_helpers.R"), encoding = "UTF-8")
  source(file.path(PROJECT_ROOT, "scripts", "01_load_prepare_video_dataset.R"), encoding = "UTF-8")
  source(file.path(PROJECT_ROOT, "scripts", "02_prepare_timestamped_comments.R"), encoding = "UTF-8")
  source(file.path(PROJECT_ROOT, "scripts", "04_tokenization_strict.R"), encoding = "UTF-8")
  source(file.path(PROJECT_ROOT, "scripts", "05_select_analysis_tokens.R"), encoding = "UTF-8")
  kw <- kw_NO_COMMENTS
}

message("Rows read from token table before harmonisation: ", nrow(kw))

# ------------------------- harmonise fields -------------------------
if ("category" %in% names(kw) && !"KeywordCategory" %in% names(kw)) {
  kw <- kw %>% dplyr::rename(KeywordCategory = category)
}
if ("TimePeriod" %in% names(kw) && !"time_period" %in% names(kw)) {
  kw <- kw %>% dplyr::rename(time_period = TimePeriod)
}

needed <- c("video_id", "TaxonName", "created_at", "FirstRecordDate", "KeywordCategory", "time_period")
missing_needed <- setdiff(needed, names(kw))
if (length(missing_needed) > 0) {
  stop("Token table is missing required columns: ", paste(missing_needed, collapse = ", "))
}

# Keep title/description tokens only when a title/description source label is present.
# The NO_COMMENTS table is already title/description-only in the public workflow, so
# this block is deliberately conservative and will not remove all rows if labels differ.
if ("token_source" %in% names(kw)) {
  kw_before_source_filter <- kw
  src <- tolower(as.character(kw$token_source))
  keep_src <- stringr::str_detect(src, "title|description") &
    !stringr::str_detect(src, "comment|reply")
  if (any(keep_src, na.rm = TRUE)) {
    kw <- kw[keep_src %in% TRUE, , drop = FALSE]
    message("Rows after token_source title/description filter: ", nrow(kw))
  } else {
    kw <- kw_before_source_filter
    warning("token_source column found, but no title/description labels matched. Keeping all rows in NO_COMMENTS table.")
  }
}

parse_dt_utc <- function(x) {
  x <- as.character(x)
  x[x %in% c("", "NA", "NaN", "NULL")] <- NA_character_

  out <- suppressWarnings(lubridate::ymd_hms(x, tz = "UTC", quiet = TRUE))

  miss <- is.na(out) & !is.na(x)
  if (any(miss)) {
    out[miss] <- suppressWarnings(lubridate::ymd(x[miss], tz = "UTC", quiet = TRUE))
  }

  miss <- is.na(out) & !is.na(x)
  if (any(miss)) {
    out[miss] <- suppressWarnings(lubridate::parse_date_time(
      x[miss],
      orders = c("ymd HMS z", "ymd HMS", "ymd HM", "ymd", "Ymd HMS z", "Ymd HMS", "Ymd"),
      tz = "UTC"
    ))
  }

  as.POSIXct(out, origin = "1970-01-01", tz = "UTC")
}

kw <- kw %>%
  mutate(
    created_at = parse_dt_utc(.data$created_at),
    FirstRecordDate = parse_dt_utc(.data$FirstRecordDate),
    KeywordCategory = dplyr::case_when(
      as.character(.data$KeywordCategory) %in% c("Ecommerce", "E-commerce", "e-commerce", "ecommerce") ~ "eCommerce",
      TRUE ~ as.character(.data$KeywordCategory)
    ),
    KeywordCategory = factor(.data$KeywordCategory, levels = KW_LEVELS),
    time_period = dplyr::case_when(
      .data$time_period %in% c("Before", "Pre", "Pre-Intro", "Pre-Introduction", "pre", "pre-introduction") ~ "Pre-Introduction",
      .data$time_period %in% c("After", "Post", "Post-Intro", "Post-Introduction", "post", "post-introduction") ~ "Post-Introduction",
      TRUE ~ as.character(.data$time_period)
    ),
    rel_year = as.numeric(difftime(.data$created_at, .data$FirstRecordDate, units = "days")) / 365.25
  )

n_before_clean_filter <- nrow(kw)
clean_drop_summary <- tibble::tibble(
  rows_before_clean_filter = n_before_clean_filter,
  missing_created_at = sum(is.na(kw$created_at)),
  missing_FirstRecordDate = sum(is.na(kw$FirstRecordDate)),
  missing_KeywordCategory = sum(is.na(kw$KeywordCategory)),
  missing_time_period = sum(is.na(kw$time_period)),
  nonfinite_rel_year = sum(!is.finite(kw$rel_year))
)
readr::write_csv(clean_drop_summary, file.path(OUT_DIR, "audit_cleaning_drop_summary_pm3.csv"))
print(clean_drop_summary)

kw <- kw %>%
  filter(!is.na(.data$KeywordCategory), !is.na(.data$time_period), is.finite(.data$rel_year))

# Safety check: recompute period from rel_year so the window boundary is internally consistent.
kw <- kw %>%
  mutate(time_period_pm = if_else(.data$rel_year < 0, "Pre-Introduction", "Post-Introduction"))

# ------------------------- build +/-3-year dataset -------------------------
kw_pm3 <- kw %>%
  filter(.data$rel_year >= -SYM_WINDOW_YEARS, .data$rel_year <= SYM_WINDOW_YEARS)

message("Tokens in full NO_COMMENTS table: ", nrow(kw))
message("Tokens inside +/-", SYM_WINDOW_YEARS, " years: ", nrow(kw_pm3))
message("Species inside window: ", dplyr::n_distinct(kw_pm3$TaxonName))

# ------------------------- audit tables -------------------------
audit_overall <- tibble::tibble(
  window = paste0("-", SYM_WINDOW_YEARS, "/+", SYM_WINDOW_YEARS, " years"),
  n_tokens_full = nrow(kw),
  n_tokens_window = nrow(kw_pm3),
  n_videos_window = dplyr::n_distinct(kw_pm3$video_id),
  n_species_window = dplyr::n_distinct(kw_pm3$TaxonName),
  n_species_with_pre_tokens = kw_pm3 %>% filter(.data$time_period_pm == "Pre-Introduction") %>% summarise(n = n_distinct(.data$TaxonName)) %>% pull(n),
  n_species_with_post_tokens = kw_pm3 %>% filter(.data$time_period_pm == "Post-Introduction") %>% summarise(n = n_distinct(.data$TaxonName)) %>% pull(n),
  n_species_with_both_periods = kw_pm3 %>% distinct(.data$TaxonName, .data$time_period_pm) %>% count(.data$TaxonName) %>% filter(.data$n == 2) %>% nrow()
)
readr::write_csv(audit_overall, file.path(OUT_DIR, "audit_overall_pm3.csv"))
print(audit_overall)

species_period_audit <- kw_pm3 %>%
  group_by(.data$TaxonName, .data$time_period_pm) %>%
  summarise(
    n_tokens = n(),
    n_videos = n_distinct(.data$video_id),
    LifeForm = dplyr::first(.data$LifeForm),
    PresentStatus = dplyr::first(.data$PresentStatus),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    TaxonName,
    time_period_pm = c("Pre-Introduction", "Post-Introduction"),
    fill = list(n_tokens = 0, n_videos = 0)
  )
readr::write_csv(species_period_audit, file.path(OUT_DIR, "audit_species_period_pm3.csv"))

threshold_retention <- THRESHOLD_GRID %>%
  rowwise() %>%
  mutate(
    n_species_retained = {
      tmp <- species_period_audit %>%
        group_by(.data$TaxonName) %>%
        summarise(
          pass = all(.data$n_tokens >= min_tokens_per_species_period &
                       .data$n_videos >= min_videos_per_species_period),
          .groups = "drop"
        ) %>%
        filter(.data$pass)
      nrow(tmp)
    }
  ) %>%
  ungroup()
readr::write_csv(threshold_retention, file.path(OUT_DIR, "audit_threshold_retention_pm3.csv"))
print(threshold_retention)

# ------------------------- helper for scenario analyses -------------------------
run_pm3_scenario <- function(scenario_name, min_tokens_per_species_period = 0, min_videos_per_species_period = 0) {

  keep_species <- species_period_audit %>%
    group_by(.data$TaxonName) %>%
    summarise(
      keep = all(.data$n_tokens >= min_tokens_per_species_period &
                   .data$n_videos >= min_videos_per_species_period),
      .groups = "drop"
    ) %>%
    filter(.data$keep) %>%
    pull(.data$TaxonName)

  dat <- kw_pm3 %>% filter(.data$TaxonName %in% keep_species)

  if (nrow(dat) == 0) {
    warning("No data retained for scenario: ", scenario_name)
    return(invisible(NULL))
  }

  # Overall token proportions by period/category.
  overall_props <- dat %>%
    count(.data$time_period_pm, .data$KeywordCategory, name = "n_tokens") %>%
    group_by(.data$time_period_pm) %>%
    mutate(
      total_tokens_period = sum(.data$n_tokens),
      prop_tokens = .data$n_tokens / .data$total_tokens_period
    ) %>%
    ungroup() %>%
    arrange(.data$time_period_pm, .data$KeywordCategory)

  readr::write_csv(overall_props, file.path(OUT_DIR, paste0("", scenario_name, "_overall_category_props.csv")))

  # Species-period-category count table with zeros for missing categories.
  counts <- dat %>%
    count(.data$TaxonName, .data$LifeForm, .data$PresentStatus, .data$time_period_pm, .data$KeywordCategory, name = "n_cat") %>%
    tidyr::complete(
      tidyr::nesting(TaxonName, LifeForm, PresentStatus, time_period_pm),
      KeywordCategory = factor(KW_LEVELS, levels = KW_LEVELS),
      fill = list(n_cat = 0)
    ) %>%
    group_by(.data$TaxonName, .data$time_period_pm) %>%
    mutate(n_tot = sum(.data$n_cat)) %>%
    ungroup() %>%
    filter(.data$n_tot > 0) %>%
    mutate(
      n_other = pmax(.data$n_tot - .data$n_cat, 0),
      prop = .data$n_cat / .data$n_tot,
      time_period_pm = factor(.data$time_period_pm, levels = c("Pre-Introduction", "Post-Introduction")),
      KeywordCategory = factor(.data$KeywordCategory, levels = KW_LEVELS)
    )

  readr::write_csv(counts, file.path(OUT_DIR, paste0(scenario_name, "_species_period_category_counts.csv")))

  # GLMM analogous to the main period-normalised pre/post model, restricted to +/-3 years.
  model_summary <- NULL
  emm_table <- NULL
  pair_table <- NULL

  if (dplyr::n_distinct(counts$TaxonName) >= 2 && dplyr::n_distinct(counts$time_period_pm) == 2) {
    fit <- tryCatch(
      lme4::glmer(
        cbind(n_cat, n_other) ~ KeywordCategory * time_period_pm + (1 | TaxonName),
        data = counts,
        family = binomial(link = "logit"),
        control = lme4::glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5))
      ),
      error = function(e) e
    )

    if (!inherits(fit, "error")) {
      model_summary <- as.data.frame(coef(summary(fit))) %>%
        tibble::rownames_to_column("term")
      readr::write_csv(model_summary, file.path(OUT_DIR, paste0(scenario_name, "_glmm_coefficients.csv")))

      emm <- emmeans::emmeans(fit, ~ time_period_pm | KeywordCategory, type = "response")
      emm_table <- as.data.frame(emm)
      pair_table <- as.data.frame(emmeans::contrast(emm, method = "revpairwise", by = "KeywordCategory", type = "response"))

      readr::write_csv(emm_table, file.path(OUT_DIR, paste0(scenario_name, "_glmm_emmeans_response.csv")))
      readr::write_csv(pair_table, file.path(OUT_DIR, paste0(scenario_name, "_glmm_prepost_contrasts.csv")))
    } else {
      writeLines(conditionMessage(fit), file.path(OUT_DIR, paste0(scenario_name, "_glmm_error.txt")))
    }
  }

  # Focused eCommerce check: did eCommerce decline in the balanced window?
  ecom_counts <- counts %>%
    filter(.data$KeywordCategory == "eCommerce")

  if (nrow(ecom_counts) > 0 && dplyr::n_distinct(ecom_counts$time_period_pm) == 2) {
    fit_ecom <- tryCatch(
      lme4::glmer(
        cbind(n_cat, n_other) ~ time_period_pm + (1 | TaxonName),
        data = ecom_counts,
        family = binomial(link = "logit"),
        control = lme4::glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5))
      ),
      error = function(e) e
    )
    if (!inherits(fit_ecom, "error")) {
      ecom_emm <- as.data.frame(emmeans::emmeans(fit_ecom, ~ time_period_pm, type = "response"))
      ecom_contrast <- as.data.frame(emmeans::contrast(emmeans::emmeans(fit_ecom, ~ time_period_pm, type = "response"), method = "revpairwise", type = "response"))
      readr::write_csv(ecom_emm, file.path(OUT_DIR, paste0(scenario_name, "_ecommerce_emmeans_response.csv")))
      readr::write_csv(ecom_contrast, file.path(OUT_DIR, paste0(scenario_name, "_ecommerce_prepost_contrast.csv")))
    } else {
      writeLines(conditionMessage(fit_ecom), file.path(OUT_DIR, paste0(scenario_name, "_ecommerce_glmm_error.txt")))
    }
  }

  invisible(list(overall_props = overall_props, counts = counts, emm_table = emm_table, pair_table = pair_table))
}

# Run all diagnostic scenarios.
scenario_outputs <- purrr::pmap(
  THRESHOLD_GRID,
  function(scenario, min_tokens_per_species_period, min_videos_per_species_period) {
    run_pm3_scenario(scenario, min_tokens_per_species_period, min_videos_per_species_period)
  }
)

# ------------------------- simple figure for the no-threshold +/-3-year subset -------------------------
plot_file <- file.path(OUT_DIR, "pm3_no_threshold_overall_category_props.csv")

if (file.exists(plot_file)) {
  plot_df <- readr::read_csv(plot_file, show_col_types = FALSE) %>%
    mutate(
      KeywordCategory = factor(.data$KeywordCategory, levels = KW_LEVELS),
      time_period_pm = factor(.data$time_period_pm, levels = c("Pre-Introduction", "Post-Introduction"))
    )

  pm_cols <- c("Pre-Introduction" = "#332288", "Post-Introduction" = "#88CCEE")

  p_pm3 <- ggplot(plot_df, aes(x = KeywordCategory, y = prop_tokens, fill = time_period_pm)) +
    geom_col(position = position_dodge(width = 0.75), width = 0.65, colour = "grey25", linewidth = 0.20) +
    scale_fill_manual(values = pm_cols) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    labs(
      x = NULL,
      y = "Share of classified keyword tokens",
      fill = NULL,
      title = NULL,
      subtitle = NULL
    ) +
    theme_light(base_size = 12) +
    theme(
      legend.position = "top",
      legend.text = element_text(size = 11),
      axis.text.x = element_text(angle = 30, hjust = 1, size = 11),
      axis.text.y = element_text(size = 11),
      axis.title.y = element_text(size = 13, margin = margin(r = 10)),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      plot.margin = margin(8, 12, 8, 8)
    )

  ggsave(file.path(FIG_DIR, "Figure_S10.png"), p_pm3, width = 7, height = 5, dpi = 300)
  ggsave(file.path(FIG_DIR, "Figure_S10.tiff"), p_pm3, width = 7, height = 5, dpi = 300, compression = "lzw")
  message("Figure written to: ", FIG_DIR)
} else {
  warning("No no-threshold +/-3-year output table was produced, so no figure was generated. Check audit_overall_pm3.csv and audit_cleaning_drop_summary_pm3.csv.")
}

message("Symmetric-window sensitivity complete.")
message("Tables written to: ", OUT_DIR)
