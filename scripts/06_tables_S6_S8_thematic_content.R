if (file.exists("scripts/00_direct_output_config.R")) source("scripts/00_direct_output_config.R", encoding = "UTF-8")
# ============================================================
# 06_tables_S6_S8_thematic_content.R
# COMPLETE DIRECT-CODE VERSION (no wrapper call).
# Generated to follow scripts 00-05 and preserve submitted code/style.
# ============================================================

if (!exists("ANALYSIS_MODE", inherits = FALSE)) ANALYSIS_MODE <- "NO_COMMENTS"
if (!exists("PROJECT_ROOT", inherits = FALSE)) PROJECT_ROOT <- getwd()
if (basename(getwd()) == "scripts") setwd(dirname(getwd()))

MODE_OUTPUT_SUFFIX <- switch(
  ANALYSIS_MODE,
  "NO_COMMENTS" = "",
  "COMMENTS_TIMESTAMPS" = "_COMMENTS_TIMESTAMPS",
  "COMMENTS_ONLY" = "_COMMENTS_ONLY",
  stop("Unsupported ANALYSIS_MODE: ", ANALYSIS_MODE)
)
MODE_OBJECT_SUFFIX <- switch(
  ANALYSIS_MODE,
  "NO_COMMENTS" = "NO_COMMENTS",
  "COMMENTS_TIMESTAMPS" = "COMMENTS_TIMESTAMPS",
  "COMMENTS_ONLY" = "COMMENTS_ONLY",
  stop("Unsupported ANALYSIS_MODE: ", ANALYSIS_MODE)
)
MODE_TOKEN_SOURCE <- switch(
  ANALYSIS_MODE,
  "NO_COMMENTS" = "NO_COMMENTS",
  "COMMENTS_TIMESTAMPS" = "ALL",
  "COMMENTS_ONLY" = "COMMENTS_ONLY",
  stop("Unsupported ANALYSIS_MODE: ", ANALYSIS_MODE)
)

# Generic helper used by several original submitted scripts
safe_print <- function(x, n = Inf, width = Inf, ...) {
  if (inherits(x, "tbl_df") || inherits(x, "tbl")) {
    print(x, n = n, width = width, ...)
  } else {
    print(x, ...)
  }
  invisible(x)
}

ensure_dir <- function(path) if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)

# ============================================================
# Token workflow + S6/S8 tables (single clean script)
# - Reads tokens (NO_COMMENTS for pre/post; ALL_TOKENS optional)
# - Harmonizes columns
# - Computes descriptive stats (period + global)
# - Fits binomial GLMMs (species & lifeform)
# - Exports CSVs, DOCX, and Markdown (S6/S8 exact format)
# ============================================================

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(stringr); library(purrr)
  library(lme4);  library(emmeans); library(readr)
  library(flextable); library(officer)
})

# ------------------ helpers ------------------
ensure_dir <- function(p) if (!dir.exists(p)) dir.create(p, recursive = TRUE, showWarnings = FALSE)

normalize_time_period_vec <- function(x) dplyr::case_when(
  is.na(x) ~ NA_character_,
  x %in% c("Before","Pre-Intro","Pre-Introduction") ~ "Pre-Introduction",
  x %in% c("After","Post-Intro","Post-Introduction") ~ "Post-Introduction",
  TRUE ~ as.character(x)
)

harmonize_tokens <- function(df) {
  if ("KeywordCategory" %in% names(df) && !"category" %in% names(df)) {
    df <- dplyr::rename(df, category = KeywordCategory)
  }
  if ("TimePeriod" %in% names(df) && !"time_period" %in% names(df)) {
    df <- dplyr::rename(df, time_period = TimePeriod)
  }
  need <- c("video_id","TaxonName","LifeForm","PresentStatus",
            "word","category","time_period","Region",
            "created_at","viewCount","likeCount","commentCount",
            "FirstRecord","FirstRecordDate")
  for (cc in need) if (!cc %in% names(df)) df[[cc]] <- NA

  df %>%
    mutate(
      category    = as.character(category),
      time_period = normalize_time_period_vec(time_period),
      TaxonName   = as.character(TaxonName),
      LifeForm    = as.character(LifeForm)
    ) %>%
    filter(!is.na(category), category != "", !is.na(time_period)) %>%
    distinct()
}

read_first_available <- function(paths) {
  for (p in paths) {
    if (!is.null(p) && file.exists(p)) return(readr::read_csv(p, show_col_types = FALSE))
  }
  NULL
}

# Markdown + formatting helpers (single definitions)
to_md_table <- function(df, file) {
  stopifnot(is.data.frame(df))
  hdr <- paste(names(df), collapse = " | ")
  sep <- paste(rep("---", ncol(df)), collapse = " | ")
  rows <- apply(df, 1, function(r) paste(r, collapse = " | "))
  out <- c(paste0("| ", hdr, " |"),
           paste0("| ", sep, " |"),
           paste0("| ", rows, " |"))
  writeLines(out, file)
  invisible(out)
}
fmt_num <- function(x, digits = 1) ifelse(is.na(x), NA, round(x, digits))
fmt_pm_percent <- function(mean, sd, digits = 1) {
  m <- fmt_num(mean, digits); s <- fmt_num(sd, digits)
  if (is.na(m)) return("-")
  paste0(m, " (+/- ", ifelse(is.na(s), "-", s), ") %")
}
fmt_delta <- function(post, pre, digits = 1) {
  d <- fmt_num(post - pre, digits)
  if (is.na(d)) return("-")
  paste0(ifelse(d > 0, "+", ifelse(d < 0, "-", "")), abs(d))
}
fmt_mean_sd_n <- function(mean, sd, n, digits = 1) {
  m <- fmt_num(mean, digits); s <- fmt_num(sd, digits)
  paste0(m, " \u00B1 ", s, " (n=", ifelse(is.na(n), "-", n), ")")
}
fmt_pct <- function(x, digits = 1) round(x, digits)
fmt_ci_row <- function(est, lo, hi, digits = 2) {
  paste0(round(est, digits), " [", round(lo, digits), "\u2013", round(hi, digits), "]")
}

# ------------------ paths ------------------
TABLES_ROOT <- file.path("outputs", "intermediate")
KW_DIR      <- file.path(TABLES_ROOT, "keywords")
OUT_DIR_EST <- file.path(
  TABLES_ROOT,
  switch(
    ANALYSIS_MODE,
    "NO_COMMENTS" = "estimates_fig2",
    "COMMENTS_TIMESTAMPS" = "estimates_fig2_COMMENTS_TIMESTAMPS",
    "COMMENTS_ONLY" = "estimates_fig2_COMMENTS_ONLY",
    "estimates_fig2"
  )
)
ensure_dir(OUT_DIR_EST)

TOK_NO_COMMENTS <- file.path(KW_DIR, "token_table_from_BASE_raw_NO_COMMENTS.csv")
TOK_ALL_TOKENS  <- file.path(KW_DIR, "token_table_from_BASE_raw.csv")
TOK_COMMENTS_ONLY <- file.path(KW_DIR, "token_table_from_BASE_raw_COMMENTS.csv")
LONG_NO_COMMENTS <- file.path(KW_DIR, "keywords_long_before_after_FOR_FIG2_NO_COMMENTS.csv")
LONG_ALL_TOKENS  <- file.path(KW_DIR, "keywords_long_before_after_FOR_FIG2.csv")


# ---- Unified workflow mode patch: pick the selected token table from 00-05 ----
if (exists("kw_ACTIVE", inherits = TRUE)) {
  if (ANALYSIS_MODE == "NO_COMMENTS") {
    kw_NO_COMMENTS <- kw_ACTIVE
  } else {
    # Keep the original object name alive so the submitted S6-S8 code runs unchanged,
    # but the contents are the selected all-token COMMENTS_TIMESTAMPS dataset.
    kw_NO_COMMENTS <- kw_ACTIVE
  }
}

# ------------------ load tokens: selected mode (legacy name kept) ------------------
kw_NO_COMMENTS <- if (exists("kw_NO_COMMENTS")) kw_NO_COMMENTS else read_first_available(c(TOK_NO_COMMENTS, LONG_NO_COMMENTS))
if (is.null(kw_NO_COMMENTS)) {
  stop("Could not find NO_COMMENTS token table. Tried:\n - ", TOK_NO_COMMENTS,
       "\n - ", LONG_NO_COMMENTS, "\nRun your tokenization script first.")
}
kw_NO_COMMENTS <- harmonize_tokens(kw_NO_COMMENTS)

req_cols <- c("video_id","TaxonName","LifeForm","category","time_period")
miss <- setdiff(req_cols, names(kw_NO_COMMENTS))
if (length(miss)) stop("NO_COMMENTS tokens missing columns: ", paste(miss, collapse = ", "))

# ------------------ load tokens: ALL_TOKENS (optional; not used in S6/S8) ------------------
kw_ALL_TOKENS <- if (exists("kw_ALL_TOKENS")) kw_ALL_TOKENS else read_first_available(c(TOK_ALL_TOKENS, LONG_ALL_TOKENS))
if (!is.null(kw_ALL_TOKENS)) kw_ALL_TOKENS <- harmonize_tokens(kw_ALL_TOKENS)

# ------------------ compute species & lifeform period-normalised props ------------------
kdat <- kw_NO_COMMENTS

# species counts per categoryxperiod
sp_cat <- kdat %>% count(TaxonName, category, time_period, name = "n_cat")

sp_tot <- sp_cat %>%
  group_by(TaxonName, time_period) %>%
  summarise(n_tot = sum(n_cat), .groups = "drop")

sp_df <- sp_cat %>%
  left_join(sp_tot, by = c("TaxonName","time_period")) %>%
  mutate(prop_within_period = if_else(n_tot > 0, 100 * n_cat / n_tot, 0))

# lifeform counts per categoryxperiod
lf_cat <- kdat %>% count(LifeForm, category, time_period, name = "n_cat")

lf_tot <- lf_cat %>%
  group_by(LifeForm, time_period) %>%
  summarise(n_tot = sum(n_cat), .groups = "drop")

lf_df <- lf_cat %>%
  left_join(lf_tot, by = c("LifeForm","time_period")) %>%
  mutate(prop_within_period = if_else(n_tot > 0, 100 * n_cat / n_tot, 0))

# ------------------ descriptive summaries (period-normalised) ------------------
est_sp_period <- sp_df %>%
  group_by(category, time_period) %>%
  summarise(
    mean_prop   = mean(prop_within_period, na.rm = TRUE),
    sd_prop     = sd(prop_within_period, na.rm = TRUE),
    median_prop = median(prop_within_period, na.rm = TRUE),
    iqr_prop    = IQR(prop_within_period, na.rm = TRUE),
    n_species   = n_distinct(TaxonName),
    .groups = "drop"
  )
write_csv(est_sp_period, file.path(OUT_DIR_EST, "est_species_periodnorm_descriptives_NO_COMMENTS.csv"))

est_lf_period <- lf_df %>%
  group_by(LifeForm, category, time_period) %>%
  summarise(
    mean_prop   = mean(prop_within_period, na.rm = TRUE),
    sd_prop     = sd(prop_within_period, na.rm = TRUE),
    median_prop = median(prop_within_period, na.rm = TRUE),
    iqr_prop    = IQR(prop_within_period, na.rm = TRUE),
    n_groups    = n(),  # one row per LifeFormxcategoryxperiod
    .groups = "drop"
  )
write_csv(est_lf_period, file.path(OUT_DIR_EST, "est_lifeform_periodnorm_descriptives_NO_COMMENTS.csv"))
                          
# ================================
# Vectorised helpers (drop-in)
# ================================
fmt_num <- function(x, digits = 1) {
  if (length(x) == 0) return(x)
  out <- round(x, digits)
  out
}

# mean (+/- sd) % ; vectorised, prints "-" if mean is NA; prints "+/- -" if sd is NA
fmt_pm_percent <- function(mean, sd, digits = 1) {
  m <- fmt_num(mean, digits)
  s <- fmt_num(sd,   digits)
  out <- paste0(m, " (+/- ", s, ") %")
  out[is.na(mean)] <- "-"
  out[is.na(mean) & is.na(sd)] <- "-"
  out
}

# symmetric delta formatter using both pre and post; vectorised
fmt_delta <- function(post, pre, digits = 1) {
  d <- fmt_num(post - pre, digits)
  signchar <- ifelse(is.na(d), "", ifelse(d > 0, "+", ifelse(d < 0, "-", "")))
  out <- ifelse(is.na(d), "-", paste0(signchar, abs(d)))
  out
}

# asymmetric delta for S8 when only pre or only post exists; vectorised
fmt_delta_asymm <- function(pre, post, digits = 1) {
  both_na   <- is.na(pre) & is.na(post)
  only_pre  <- !is.na(pre) & is.na(post)
  only_post <- is.na(pre) & !is.na(post)
  both      <- !is.na(pre) & !is.na(post)

  out <- character(length(pre))
  out[both_na]   <- "-"
  out[only_pre]  <- paste0("-", fmt_num(pre[only_pre],  digits))
  out[only_post] <- paste0("+", fmt_num(post[only_post], digits))
  out[both]      <- fmt_delta(post[both], pre[both], digits)
  out
}

# Simple GitHub-flavoured markdown table writer
to_md_table <- function(df, file) {
  stopifnot(is.data.frame(df))
  hdr <- paste(names(df), collapse = " | ")
  sep <- paste(rep("---", ncol(df)), collapse = " | ")
  rows <- apply(df, 1, function(r) paste(r, collapse = " | "))
  out <- c(paste0("| ", hdr, " |"),
           paste0("| ", sep, " |"),
           paste0("| ", rows, " |"))
  writeLines(out, file)
  invisible(out)
}

# ================================
# S6 - Species-level (period-normalised)
# ================================
sp_pre <- est_sp_period %>%
  dplyr::filter(time_period == "Pre-Introduction") %>%
  transmute(
    category,
    pre_text = fmt_pm_percent(mean_prop, sd_prop, digits = 1),
    n_pre    = ifelse(is.na(n_species), "-", as.character(n_species)),
    pre_mean = mean_prop
  )

sp_post <- est_sp_period %>%
  dplyr::filter(time_period == "Post-Introduction") %>%
  transmute(
    category,
    post_text = fmt_pm_percent(mean_prop, sd_prop, digits = 1),
    n_post    = ifelse(is.na(n_species), "-", as.character(n_species)),
    post_mean = mean_prop
  )

sp_join <- dplyr::full_join(sp_pre, sp_post, by = "category")
sp_join$category <- factor(sp_join$category,
                           levels = c("Detection","Invasion","Threat","eCommerce"))

table_S6 <- sp_join %>%
  arrange(category) %>%
  transmute(
    `Keyword category`                 = as.character(category),
    `Pre-Introduction mean (+/- SD) %`   = ifelse(is.na(pre_text),  "-", pre_text),
    `n (Pre)`                          = ifelse(is.na(n_pre),     "-", n_pre),
    `Post-Introduction mean (+/- SD) %`  = ifelse(is.na(post_text), "-", post_text),
    `n (Post)`                         = ifelse(is.na(n_post),    "-", n_post),
    `? (Post - Pre)`                   = fmt_delta(post_mean, pre_mean, digits = 1)
  )

cat("\n\n=== Table S6 - Species-level (period-normalised) ===\n")
print(as.data.frame(table_S6), row.names = FALSE)

to_md_table(table_S6,
            file.path(OUT_DIR_EST, "Table_S6_species_periodnorm_EXACT_FORMAT.md"))

# ================================
# S8 - LifeForm-level (period-normalised)
# ================================
lf_pre <- est_lf_period %>%
  dplyr::filter(time_period == "Pre-Introduction") %>%
  transmute(LifeForm, category, pre = mean_prop)

lf_post <- est_lf_period %>%
  dplyr::filter(time_period == "Post-Introduction") %>%
  transmute(LifeForm, category, post = mean_prop)

lf_join <- dplyr::full_join(lf_pre, lf_post, by = c("LifeForm","category"))

lf_join$LifeForm <- factor(lf_join$LifeForm,
  levels = c("Bacteria, Viruses, Fungi","Birds","Crustaceans","Fishes",
             "Herptiles","Insects","Non-arthropod invertebrates","Plants"))
lf_join$category <- factor(lf_join$category,
  levels = c("Invasion","Threat","eCommerce","Detection"))

table_S8 <- lf_join %>%
  arrange(LifeForm, category) %>%
  transmute(
    `LifeForm group`         = as.character(LifeForm),
    `Keyword category`       = as.character(category),
    `Pre-Introduction (%)`   = ifelse(is.na(pre),  "-", sprintf("%.1f", pre)),
    `Post-Introduction (%)`  = ifelse(is.na(post), "-", sprintf("%.1f", post)),
    `? (Post - Pre)`         = fmt_delta_asymm(pre, post, digits = 1)
  )

cat("\n\n=== Table S8 - LifeForm-level (period-normalised) ===\n")
print(as.data.frame(table_S8), row.names = FALSE)

to_md_table(table_S8,
            file.path(OUT_DIR_EST, "Table_S8_lifeform_periodnorm_EXACT_FORMAT.md"))


# ------------------ global-normalised (optional) ------------------
sp_global <- sp_cat %>%
  group_by(TaxonName) %>% mutate(n_sp = sum(n_cat)) %>% ungroup() %>%
  mutate(prop_global = 100 * n_cat / sum(n_cat))

est_sp_global <- sp_global %>%
  group_by(category) %>%
  summarise(
    mean_prop   = mean(prop_global, na.rm = TRUE),
    sd_prop     = sd(prop_global, na.rm = TRUE),
    median_prop = median(prop_global, na.rm = TRUE),
    iqr_prop    = IQR(prop_global, na.rm = TRUE),
    n_species   = n_distinct(TaxonName),
    .groups = "drop"
  )
write_csv(est_sp_global, file.path(OUT_DIR_EST, "est_species_globalnorm_descriptives_NO_COMMENTS.csv"))

lf_global <- lf_cat %>%
  group_by(LifeForm) %>% mutate(n_lf = sum(n_cat)) %>% ungroup() %>%
  mutate(prop_global = 100 * n_cat / sum(n_cat))

est_lf_global <- lf_global %>%
  group_by(LifeForm, category) %>%
  summarise(
    mean_prop   = mean(prop_global, na.rm = TRUE),
    sd_prop     = sd(prop_global, na.rm = TRUE),
    median_prop = median(prop_global, na.rm = TRUE),
    iqr_prop    = IQR(prop_global, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(est_lf_global, file.path(OUT_DIR_EST, "est_lifeform_globalnorm_descriptives_NO_COMMENTS.csv"))

# ------------------ binomial GLMMs (period-normalised) ------------------
# Species-level
sp_glmm_dat <- sp_df %>% filter(n_tot > 0)

m_sp <- glmer(
  cbind(n_cat, n_tot - n_cat) ~ category * time_period + (1 | TaxonName),
  data    = sp_glmm_dat,
  family  = binomial,
  control = glmerControl(optimizer = "bobyqa")
)

emm_sp_tbl <- as.data.frame(emmeans(m_sp, ~ category | time_period, type = "response")) %>%
  mutate(
    estimate_pct = 100 * prob,
    lower_pct    = 100 * asymp.LCL,
    upper_pct    = 100 * asymp.UCL
  ) %>%
  dplyr::select(time_period, category, estimate_pct, lower_pct, upper_pct, SE)

ctr_sp_tbl <- contrast(
  emmeans(m_sp, ~ category * time_period, type = "response"),
  interaction = "pairwise", by = "category", adjust = "holm"
) %>% as.data.frame()

write_csv(emm_sp_tbl, file.path(OUT_DIR_EST, "lsmeans_species_periodnorm_NO_COMMENTS.csv"))
write_csv(ctr_sp_tbl, file.path(OUT_DIR_EST, "contrasts_species_Post_vs_Pre_NO_COMMENTS.csv"))

# LifeForm-level
lf_glmm_dat <- lf_df %>% filter(n_tot > 0)

m_lf <- glmer(
  cbind(n_cat, n_tot - n_cat) ~ category * time_period + (1 | LifeForm),
  data    = lf_glmm_dat,
  family  = binomial,
  control = glmerControl(optimizer = "bobyqa")
)

emm_lf_tbl <- as.data.frame(emmeans(m_lf, ~ category | time_period, type = "response")) %>%
  mutate(
    estimate_pct = 100 * prob,
    lower_pct    = 100 * asymp.LCL,
    upper_pct    = 100 * asymp.UCL
  ) %>%
  dplyr::select(time_period, category, estimate_pct, lower_pct, upper_pct, SE)

ctr_lf_tbl <- contrast(
  emmeans(m_lf, ~ category * time_period, type = "response"),
  interaction = "pairwise", by = "category", adjust = "holm"
) %>% as.data.frame()

# simple markdown writer you already have:
to_md_table <- function(df, file) {
  stopifnot(is.data.frame(df))
  hdr <- paste(names(df), collapse = " | ")
  sep <- paste(rep("---", ncol(df)), collapse = " | ")
  rows <- apply(df, 1, function(r) paste(r, collapse = " | "))
  out <- c(paste0("| ", hdr, " |"),
           paste0("| ", sep, " |"),
           paste0("| ", rows, " |"))
  writeLines(out, file)
  invisible(out)
}

to_md_table(as.data.frame(ctr_sp_tbl),
            file.path(OUT_DIR_EST, "Contrasts_Species_Post_vs_Pre_MARKDOWN.md"))
to_md_table(as.data.frame(ctr_lf_tbl),
            file.path(OUT_DIR_EST, "Contrasts_LifeForm_Post_vs_Pre_MARKDOWN.md"))

write_csv(emm_lf_tbl, file.path(OUT_DIR_EST, "lsmeans_lifeform_periodnorm_NO_COMMENTS.csv"))
write_csv(ctr_lf_tbl, file.path(OUT_DIR_EST, "contrasts_lifeform_Post_vs_Pre_NO_COMMENTS.csv"))

# ------------------ DOCX export ------------------
OUT_DOCX <- file.path(OUT_DIR_EST, "Figure2_estimates_tables_NO_COMMENTS.docx")

add_ft <- function(doc, df, title) {
  if (is.null(df) || !nrow(df)) return(doc)
  ft <- flextable(df) |>
    autofit() |>
    set_table_properties(width = 1, layout = "autofit") |>
    theme_booktabs() |>
    fontsize(size = 9, part = "all") |>
    align(align = "center", part = "all") |>
    bold(part = "header") |>
    color(color = "black", part = "all")
  doc |>
    body_add_par(title, style = "heading 2") |>
    body_add_flextable(ft) |>
    body_add_par("", style = "Normal")
}

doc <- read_docx()
doc <- body_add_par(doc, "Figure 2 - Keyword proportion estimates (titles + descriptions only)", style = "heading 1")
doc <- body_add_par(doc, "Descriptive and GLMM-based summaries for species and LifeForm groups (period- and global-normalised).", style = "Normal")
doc <- body_add_par(doc, "", style = "Normal")

doc <- body_add_par(doc, "Descriptive statistics (mean +/- SD, median, IQR)", style = "heading 1")
doc <- add_ft(doc, est_sp_period, "Species-level (Period-normalised)")
doc <- add_ft(doc, est_lf_period, "LifeForm-level (Period-normalised)")
doc <- add_ft(doc, est_sp_global, "Species-level (Global-normalised)")
doc <- add_ft(doc, est_lf_global, "LifeForm-level (Global-normalised)")

doc <- body_add_par(doc, "Model-based least-squares means (GLMM, binomial link)", style = "heading 1")
doc <- add_ft(doc, emm_sp_tbl, "Species-level LS-means (Period-normalised)")
doc <- add_ft(doc, emm_lf_tbl, "LifeForm-level LS-means (Period-normalised)")

doc <- body_add_par(doc, "Post vs Pre contrasts (Holm-adjusted)", style = "heading 1")
doc <- add_ft(doc, ctr_sp_tbl, "Species-level contrasts")
doc <- add_ft(doc, ctr_lf_tbl, "LifeForm-level contrasts")

print(doc, target = OUT_DOCX)
message("Exported DOCX: ", OUT_DOCX)

# ------------------ S6/S8 EXACT markdown + console prints ------------------
# S6 - species (mean +/- SD with n; ? = Post - Pre)
sp_pre  <- est_sp_period %>%
  filter(time_period == "Pre-Introduction") %>%
  transmute(category,
            pre_text = fmt_pm_percent(mean_prop, sd_prop, digits = 1),
            n_pre    = ifelse(is.na(n_species), "-", as.character(n_species)),
            pre_mean = mean_prop)

sp_post <- est_sp_period %>%
  filter(time_period == "Post-Introduction") %>%
  transmute(category,
            post_text = fmt_pm_percent(mean_prop, sd_prop, digits = 1),
            n_post    = ifelse(is.na(n_species), "-", as.character(n_species)),
            post_mean = mean_prop)

sp_join <- full_join(sp_pre, sp_post, by = "category")
sp_join$category <- factor(sp_join$category, levels = c("Detection","Invasion","Threat","eCommerce"))

table_S6 <- sp_join %>%
  arrange(category) %>%
  transmute(
    `Keyword category` = as.character(category),
    `Pre-Introduction mean (+/- SD) %`  = ifelse(is.na(pre_text),  "-", pre_text),
    `n (Pre)`                         = ifelse(is.na(n_pre),     "-", n_pre),
    `Post-Introduction mean (+/- SD) %` = ifelse(is.na(post_text), "-", post_text),
    `n (Post)`                        = ifelse(is.na(n_post),    "-", n_post),
    `? (Post - Pre)`                  = fmt_delta(post_mean, pre_mean, digits = 1)
  )

cat("\n\n=== Table S6 - Species-level (period-normalised) ===\n")
print(table_S6, row.names = FALSE)
to_md_table(table_S6, file.path(OUT_DIR_EST, "Table_S6_species_periodnorm_EXACT_FORMAT.md"))

# S8 - lifeform (plain % per period; ? = Post - Pre; no +/- SD)
lf_pre <- est_lf_period %>%
  filter(time_period == "Pre-Introduction") %>%
  transmute(LifeForm, category, pre = mean_prop)

lf_post <- est_lf_period %>%
  filter(time_period == "Post-Introduction") %>%
  transmute(LifeForm, category, post = mean_prop)

lf_join <- full_join(lf_pre, lf_post, by = c("LifeForm","category"))

lf_join$LifeForm <- factor(lf_join$LifeForm,
  levels = c("Bacteria, Viruses, Fungi","Birds","Crustaceans","Fishes",
             "Herptiles","Insects","Non-arthropod invertebrates","Plants"))
lf_join$category <- factor(lf_join$category, levels = c("Invasion","Threat","eCommerce","Detection"))

table_S8 <- lf_join %>%
  arrange(LifeForm, category) %>%
  transmute(
    `LifeForm group`         = as.character(LifeForm),
    `Keyword category`       = as.character(category),
    `Pre-Introduction (%)`   = ifelse(is.na(pre),  "-", as.character(fmt_num(pre, 1))),
    `Post-Introduction (%)`  = ifelse(is.na(post), "-", as.character(fmt_num(post, 1))),
    `? (Post - Pre)`         = ifelse(is.na(pre) & is.na(post), "-",
                                      ifelse(is.na(pre), paste0("+", fmt_num(post, 1)),
                                             ifelse(is.na(post), paste0("-", fmt_num(pre, 1)),
                                                    as.character(fmt_delta(post, pre, 1)))))
  )

cat("\n\n=== Table S8 - LifeForm-level (period-normalised) ===\n")
print(table_S8, row.names = FALSE)
to_md_table(table_S8, file.path(OUT_DIR_EST, "Table_S8_lifeform_periodnorm_EXACT_FORMAT.md"))

# ------------------ compact GLMM prints (console + md) ------------------
emm_sp_fmt <- emm_sp_tbl %>%
  mutate(Estimate = fmt_ci_row(estimate_pct, lower_pct, upper_pct, digits = 2),
         category = factor(category, levels = c("Invasion","Detection","eCommerce","Threat"))) %>%
  arrange(time_period, category) %>%
  dplyr::select(`Time period` = time_period, `Keyword category` = category, `Estimate (%, 95% CI)` = Estimate)

emm_lf_fmt <- emm_lf_tbl %>%
  mutate(Estimate = fmt_ci_row(estimate_pct, lower_pct, upper_pct, digits = 2),
         category = factor(category, levels = c("Invasion","Detection","eCommerce","Threat"))) %>%
  arrange(time_period, category) %>%
  dplyr::select(`Time period` = time_period, `Keyword category` = category, `Estimate (%, 95% CI)` = Estimate)

cat("\n\n=== Species LS-means (GLMM) ===\n");   print(emm_sp_fmt, row.names = FALSE)
cat("\n\n=== LifeForm LS-means (GLMM) ===\n"); print(emm_lf_fmt, row.names = FALSE)

# simple markdown writer you already have:
to_md_table <- function(df, file) {
  stopifnot(is.data.frame(df))
  hdr <- paste(names(df), collapse = " | ")
  sep <- paste(rep("---", ncol(df)), collapse = " | ")
  rows <- apply(df, 1, function(r) paste(r, collapse = " | "))
  out <- c(paste0("| ", hdr, " |"),
           paste0("| ", sep, " |"),
           paste0("| ", rows, " |"))
  writeLines(out, file)
  invisible(out)
}

to_md_table(emm_sp_fmt, file.path(OUT_DIR_EST, "Species_LSmeans_MARKDOWN.md"))
to_md_table(emm_lf_fmt, file.path(OUT_DIR_EST, "LifeForm_LSmeans_MARKDOWN.md"))

# quick contrasts
cat("\n\n=== Species contrasts (Post vs Pre; Holm-adjusted) ===\n")
safe_print(ctr_sp_tbl)

cat("\n\n=== LifeForm contrasts (Post vs Pre; Holm-adjusted) ===\n")
safe_print(ctr_lf_tbl)


cat("\nSaved files in:\n",
    "- DOCX: ", OUT_DOCX, "\n",
    "- MD:   ", file.path(OUT_DIR_EST, "Table_S6_species_periodnorm_EXACT_FORMAT.md"), "\n",
    "        ", file.path(OUT_DIR_EST, "Table_S8_lifeform_periodnorm_EXACT_FORMAT.md"), "\n",
    "        ", file.path(OUT_DIR_EST, "Species_LSmeans_MARKDOWN.md"), "\n",
    "        ", file.path(OUT_DIR_EST, "LifeForm_LSmeans_MARKDOWN.md"), "\n",
    sep = "")
                                                      
    
# ============================================================
# DOCX export with EXACT-FORMAT S6 & S8 (flextable)
# ============================================================
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(readr)
  library(flextable); library(officer)
})

# --- Paths (reuse your estimates folder) ---
OUT_DIR_EST <- OUT_DIR_EST
OUT_DOCX_EXACT <- file.path(OUT_DIR_EST, "Figure2_S6_S8_EXACT_FORMAT.docx")

# --- Small helpers (vectorised) ---
fmt_num <- function(x, digits = 1) round(x, digits)
fmt_pm_percent <- function(mean, sd, digits = 1) {
  m <- fmt_num(mean, digits); s <- fmt_num(sd, digits)
  out <- paste0(m, " (+/- ", s, ") %")
  out[is.na(mean)] <- "-"
  out
}
fmt_delta <- function(post, pre, digits = 1) {
  d <- fmt_num(post - pre, digits)
  signchar <- ifelse(is.na(d), "", ifelse(d > 0, "+", ifelse(d < 0, "-", "")))
  ifelse(is.na(d), "-", paste0(signchar, abs(d)))
}
fmt_delta_asymm <- function(pre, post, digits = 1) {
  both_na   <- is.na(pre) & is.na(post)
  only_pre  <- !is.na(pre) & is.na(post)
  only_post <- is.na(pre) & !is.na(post)
  both      <- !is.na(pre) & !is.na(post)
  out <- character(length(pre))
  out[both_na]   <- "-"
  out[only_pre]  <- paste0("-", fmt_num(pre[only_pre],  digits))
  out[only_post] <- paste0("+", fmt_num(post[only_post], digits))
  out[both]      <- fmt_delta(post[both], pre[both], digits)
  out
}

# --- Rebuild S6/S8 if missing (from descriptive CSVs you already wrote) ---
if (!exists("table_S6") || !exists("table_S8")) {
  est_sp_period <- readr::read_csv(file.path(OUT_DIR_EST, "est_species_periodnorm_descriptives_NO_COMMENTS.csv"),
                                   show_col_types = FALSE)
  est_lf_period <- readr::read_csv(file.path(OUT_DIR_EST, "est_lifeform_periodnorm_descriptives_NO_COMMENTS.csv"),
                                   show_col_types = FALSE)

  # S6
  sp_pre <- est_sp_period %>%
    filter(time_period == "Pre-Introduction") %>%
    transmute(category,
              pre_text = fmt_pm_percent(mean_prop, sd_prop, digits = 1),
              n_pre    = ifelse(is.na(n_species), "-", as.character(n_species)),
              pre_mean = mean_prop)
  sp_post <- est_sp_period %>%
    filter(time_period == "Post-Introduction") %>%
    transmute(category,
              post_text = fmt_pm_percent(mean_prop, sd_prop, digits = 1),
              n_post    = ifelse(is.na(n_species), "-", as.character(n_species)),
              post_mean = mean_prop)

  sp_join <- full_join(sp_pre, sp_post, by = "category")
  sp_join$category <- factor(sp_join$category,
                             levels = c("Detection","Invasion","Threat","eCommerce"))
  table_S6 <- sp_join %>%
    arrange(category) %>%
    transmute(
      `Keyword category`                 = as.character(category),
      `Pre-Introduction mean (+/- SD) %`   = ifelse(is.na(pre_text),  "-", pre_text),
      `n (Pre)`                          = ifelse(is.na(n_pre),     "-", n_pre),
      `Post-Introduction mean (+/- SD) %`  = ifelse(is.na(post_text), "-", post_text),
      `n (Post)`                         = ifelse(is.na(n_post),    "-", n_post),
      `? (Post - Pre)`                   = fmt_delta(post_mean, pre_mean, digits = 1)
    )

  # S8
  lf_pre <- est_lf_period %>% filter(time_period == "Pre-Introduction") %>%
    transmute(LifeForm, category, pre = mean_prop)
  lf_post <- est_lf_period %>% filter(time_period == "Post-Introduction") %>%
    transmute(LifeForm, category, post = mean_prop)

  lf_join <- full_join(lf_pre, lf_post, by = c("LifeForm","category"))
  lf_join$LifeForm <- factor(lf_join$LifeForm,
    levels = c("Bacteria, Viruses, Fungi","Birds","Crustaceans","Fishes",
               "Herptiles","Insects","Non-arthropod invertebrates","Plants"))
  lf_join$category <- factor(lf_join$category,
    levels = c("Invasion","Threat","eCommerce","Detection"))

  table_S8 <- lf_join %>%
    arrange(LifeForm, category) %>%
    transmute(
      `LifeForm group`         = as.character(LifeForm),
      `Keyword category`       = as.character(category),
      `Pre-Introduction (%)`   = ifelse(is.na(pre),  "-", sprintf("%.1f", pre)),
      `Post-Introduction (%)`  = ifelse(is.na(post), "-", sprintf("%.1f", post)),
      `? (Post - Pre)`         = fmt_delta_asymm(pre, post, digits = 1)
    )
}

# --- Flextable styling helper ---
ft_ex <- function(df) {
  flextable(df) |>
    autofit() |>
    set_table_properties(width = 1, layout = "autofit") |>
    theme_booktabs() |>
    fontsize(size = 9, part = "all") |>
    align(align = "center", part = "all") |>
    bold(part = "header") |>
    color(color = "black", part = "all")
}

# --- Build DOCX with EXACT S6 & S8 ---
doc <- read_docx()
doc <- body_add_par(doc, "Supplementary Tables - EXACT format", style = "heading 1")

# Table S6 caption (matches your wording)
doc <- body_add_par(
  doc,
  "Table S6. Species-level, period-normalised proportions of keyword categories before and after the first recorded introduction. Values are means (+/- SD) across species; n = number of species per period. Proportions are normalised within each period (totals per period = 100%); ? = percentage-point change (Post - Pre).",
  style = "Normal"
)
doc <- body_add_par(doc, "", style = "Normal")
doc <- body_add_flextable(doc, ft_ex(table_S6))
doc <- body_add_par(doc, "", style = "Normal")

# Table S8 caption
doc <- body_add_par(
  doc,
  "Table S8. Life-form-level, period-normalised proportions of keyword categories before and after the first recorded introduction. Values (%) represent mean token proportions per period (totals per period = 100%); ? = percentage-point change (Post - Pre). Each LifeForm contributes one aggregate record per period (n = 1).",
  style = "Normal"
)
doc <- body_add_par(doc, "", style = "Normal")
doc <- body_add_flextable(doc, ft_ex(table_S8))

print(doc, target = OUT_DOCX_EXACT)
message("Exported DOCX (EXACT S6/S8): ", OUT_DOCX_EXACT)
                                                                                                                                      
                                                  
# ============================================================
# ADD-ON: Export S6/S8 (and LS-means if present) to a DOCX
# ============================================================
suppressPackageStartupMessages({
  library(dplyr); library(readr)
  library(flextable); library(officer)
})

OUT_DIR_EST <- OUT_DIR_EST
OUT_DOCX_EXACT <- file.path(OUT_DIR_EST, "Supplementary_Tables_EXACT_FORMAT.docx")

# Small FT helper (keeps layout clean and consistent)
ft_ex <- function(df) {
  flextable(df) |>
    autofit() |>
    set_table_properties(width = 1, layout = "autofit") |>
    theme_booktabs() |>
    fontsize(size = 9, part = "all") |>
    align(align = "center", part = "all") |>
    bold(part = "header") |>
    color(color = "black", part = "all")
}

# ---------- make sure S6/S8 objects exist; otherwise rebuild from CSVs ----------
need_rebuild <- !exists("table_S6") || !exists("table_S8")
if (need_rebuild) {
  message("Rebuilding table_S6 / table_S8 from descriptive CSVs ...")
  est_sp_period <- readr::read_csv(file.path(OUT_DIR_EST, "est_species_periodnorm_descriptives_NO_COMMENTS.csv"),
                                   show_col_types = FALSE)
  est_lf_period <- readr::read_csv(file.path(OUT_DIR_EST, "est_lifeform_periodnorm_descriptives_NO_COMMENTS.csv"),
                                   show_col_types = FALSE)

  # format helpers (vectorised)
  fmt_num <- function(x, digits = 1) round(x, digits)
  fmt_mean_sd_or_n <- function(mean, sd, n, digits = 1) {
    out <- character(length(mean))
    out[n == 0 | is.na(mean)] <- "- (n=0)"
    one <- n == 1 & !(n == 0 | is.na(mean))
    out[one] <- paste0(round(mean[one], digits), " (n=1)")
    many <- n >= 2 & !(n == 0 | is.na(mean))
    out[many] <- paste0(round(mean[many], digits), " (+/- ", round(sd[many], digits), ") (n=", n[many], ")")
    out
  }
  fmt_delta_asymm <- function(pre, post, digits = 1) {
    both_na   <- is.na(pre) & is.na(post)
    only_pre  <- !is.na(pre) & is.na(post)
    only_post <- is.na(pre) & !is.na(post)
    both      <- !is.na(pre) & !is.na(post)
    out <- character(length(pre))
    out[both_na]   <- "-"
    out[only_pre]  <- paste0("-", round(pre[only_pre],  digits))
    out[only_post] <- paste0("+", round(post[only_post], digits))
    out[both]      <- paste0(ifelse(post[both] - pre[both] > 0, "+",
                                    ifelse(post[both] - pre[both] < 0, "-","")),
                             round(abs(post[both] - pre[both]), digits))
    out
  }

  # S6
  sp_pre <- est_sp_period %>%
    dplyr::filter(time_period == "Pre-Introduction") %>%
    transmute(category,
              pre_text = fmt_mean_sd_or_n(mean_prop, sd_prop, n_species, 1),
              pre_mean = mean_prop)
  sp_post <- est_sp_period %>%
    dplyr::filter(time_period == "Post-Introduction") %>%
    transmute(category,
              post_text = fmt_mean_sd_or_n(mean_prop, sd_prop, n_species, 1),
              post_mean = mean_prop)

  sp_join <- dplyr::full_join(sp_pre, sp_post, by = "category") %>%
    mutate(category = factor(category, levels = c("Detection","Invasion","Threat","eCommerce"))) %>%
    arrange(category)

  table_S6 <- sp_join %>%
    transmute(
      `Keyword category`              = as.character(category),
      `Pre-Introduction (mean +/- SD)`  = pre_text,
      `Post-Introduction (mean +/- SD)` = post_text,
      `? (Post - Pre)`                = ifelse(is.na(pre_mean) & is.na(post_mean), "-",
                                        ifelse(is.na(pre_mean), paste0("+", round(post_mean, 1)),
                                        ifelse(is.na(post_mean), paste0("-", round(pre_mean, 1)),
                                               paste0(ifelse(post_mean - pre_mean > 0, "+",
                                                             ifelse(post_mean - pre_mean < 0, "-","")),
                                                      round(abs(post_mean - pre_mean), 1)))))
    )

  # S8
  lf_pre <- est_lf_period %>%
    dplyr::filter(time_period == "Pre-Introduction") %>%
    transmute(LifeForm, category, pre = mean_prop,
              pre_lab = ifelse(is.na(mean_prop), "- (n=0)", paste0(sprintf("%.1f", mean_prop), " (n=1)")))
  lf_post <- est_lf_period %>%
    dplyr::filter(time_period == "Post-Introduction") %>%
    transmute(LifeForm, category, post = mean_prop,
              post_lab = ifelse(is.na(mean_prop), "- (n=0)", paste0(sprintf("%.1f", mean_prop), " (n=1)")))
  lf_join <- dplyr::full_join(lf_pre, lf_post, by = c("LifeForm","category"))
  lf_join$LifeForm <- factor(lf_join$LifeForm,
    levels = c("Bacteria, Viruses, Fungi","Birds","Crustaceans","Fishes",
               "Herptiles","Insects","Non-arthropod invertebrates","Plants"))
  lf_join$category <- factor(lf_join$category,
    levels = c("Invasion","Threat","eCommerce","Detection"))

  table_S8 <- lf_join %>%
    arrange(LifeForm, category) %>%
    transmute(
      `LifeForm group`         = as.character(LifeForm),
      `Keyword category`       = as.character(category),
      `Pre-Introduction (%)`   = pre_lab,
      `Post-Introduction (%)`  = post_lab,
      `? (Post - Pre)`         = fmt_delta_asymm(pre, post, digits = 1)
    )
}

# ---------- Build DOCX (S6 + S8; add LS-means if present) ----------
doc <- read_docx()
doc <- body_add_par(doc, "Supplementary Tables - EXACT format", style = "heading 1")

# S6 caption
doc <- body_add_par(
  doc,
  "Table S6. Species-level, period-normalised proportions of keyword categories before and after the first recorded introduction. Values are means (+/- SD) across species; n indicates the number of species contributing to each cell. Proportions are normalised within each period (totals per period = 100%); ? = percentage-point change (Post - Pre).",
  style = "Normal"
)
doc <- body_add_par(doc, "", style = "Normal")
doc <- body_add_flextable(doc, ft_ex(table_S6))
doc <- body_add_par(doc, "", style = "Normal")

# S8 caption
doc <- body_add_par(
  doc,
  "Table S8. Life-form-level, period-normalised proportions of keyword categories before and after the first recorded introduction. Values (%) represent mean token proportions per period (totals per period = 100%); ? = percentage-point change (Post - Pre). Each LifeForm contributes one aggregate record per period (n=1 if present; - (n=0) if no tokens were recorded).",
  style = "Normal"
)
doc <- body_add_par(doc, "", style = "Normal")
doc <- body_add_flextable(doc, ft_ex(table_S8))

# Optionally append LS-means if you created these objects; otherwise silently skip
if (exists("emm_sp_fmt")) {
  doc <- body_add_par(doc, "", style = "Normal")
  doc <- body_add_par(doc, "GLMM LS-means - Species (period-normalised)", style = "heading 2")
  doc <- body_add_flextable(doc, ft_ex(emm_sp_fmt))
}
if (exists("emm_lf_fmt")) {
  doc <- body_add_par(doc, "", style = "Normal")
  doc <- body_add_par(doc, "GLMM LS-means - LifeForm (period-normalised)", style = "heading 2")
  doc <- body_add_flextable(doc, ft_ex(emm_lf_fmt))
}

print(doc, target = OUT_DOCX_EXACT)
message("Exported DOCX: ", OUT_DOCX_EXACT)
                                                                                                                                                                                                                                          
# ================================
# Ensure LS-means & contrasts are loaded
# ================================
suppressPackageStartupMessages({ library(readr); library(dplyr); library(tibble) })

OUT_DIR_EST <- OUT_DIR_EST

load_or_read <- function(obj_name, file_name) {
  if (!exists(obj_name, inherits = FALSE)) {
    f <- file.path(OUT_DIR_EST, file_name)
    if (!file.exists(f)) stop("Missing file: ", f,
                              "\nRun the estimates script to create it, then re-run this block.")
    assign(obj_name, readr::read_csv(f, show_col_types = FALSE), envir = .GlobalEnv)
  }
  get(obj_name, envir = .GlobalEnv)
}

# Load if needed
emm_sp_tbl <- load_or_read("emm_sp_tbl", "lsmeans_species_periodnorm_NO_COMMENTS.csv")
ctr_sp_tbl <- load_or_read("ctr_sp_tbl", "contrasts_species_Post_vs_Pre_NO_COMMENTS.csv")
emm_lf_tbl <- load_or_read("emm_lf_tbl", "lsmeans_lifeform_periodnorm_NO_COMMENTS.csv")
ctr_lf_tbl <- load_or_read("ctr_lf_tbl", "contrasts_lifeform_Post_vs_Pre_NO_COMMENTS.csv")

# Quick column check (helpful error if something's off)
need_cols_emas <- c("time_period","category","estimate_pct","lower_pct","upper_pct")
need_cols_ctr  <- c("category","odds.ratio","p.value")
stopifnot(all(need_cols_emas %in% names(emm_sp_tbl)),
          all(need_cols_emas %in% names(emm_lf_tbl)),
          all(need_cols_ctr  %in% names(ctr_sp_tbl)),
          all(need_cols_ctr  %in% names(ctr_lf_tbl)))

# Safe print helper (avoids odd global options)
safe_print <- function(x, n = Inf) {
  op <- options(na.print = "NA"); on.exit(options(op), add = TRUE)
  if (inherits(x, "tbl_df")) print(x, n = n) else print(as.data.frame(x))
}

# -------------------------------
# Species LS-means (percent & 95% CI)
# -------------------------------
species_lsmeans <- emm_sp_tbl %>%
  mutate(estimate_pct = round(estimate_pct, 2),
         lower_pct    = round(lower_pct,    2),
         upper_pct    = round(upper_pct,    2)) %>%
  arrange(time_period, category)

cat("\n--- Species LS-means (percent & 95% CI) ---\n")
safe_print(as_tibble(species_lsmeans), n = Inf)

# Species contrasts (Post vs Pre; OR & p)
species_contrasts <- ctr_sp_tbl %>%
  transmute(category,
            OR = signif(odds.ratio, 3),
            p  = signif(p.value,   3)) %>%
  arrange(category)

cat("\n--- Species Post vs Pre contrasts (OR & p) ---\n")
safe_print(as_tibble(species_contrasts), n = Inf)

# -------------------------------
# LifeForm LS-means (percent & 95% CI)
# -------------------------------
lifeform_lsmeans <- emm_lf_tbl %>%
  mutate(estimate_pct = round(estimate_pct, 2),
         lower_pct    = round(lower_pct,    2),
         upper_pct    = round(upper_pct,    2)) %>%
  arrange(time_period, category)

cat("\n--- LifeForm LS-means (percent & 95% CI) ---\n")
safe_print(as_tibble(lifeform_lsmeans), n = Inf)

# LifeForm contrasts (Post vs Pre; OR & p)
lifeform_contrasts <- ctr_lf_tbl %>%
  transmute(category,
            OR = signif(odds.ratio, 3),
            p  = signif(p.value,   3)) %>%
  arrange(category)

cat("\n--- LifeForm Post vs Pre contrasts (OR & p) ---\n")
safe_print(as_tibble(lifeform_contrasts), n = Inf)
                                                                                                                                                                               
            
                                                                                                                                                                                                              # Rank species by total global token share (all keywords combined)
species_global_totals <- sp_global %>%
  group_by(TaxonName) %>%
  summarise(total_global_prop = sum(prop_global, na.rm = TRUE)) %>%
  arrange(desc(total_global_prop))

print(head(species_global_totals, 20), n = Inf)
                    
                    
# ==== EXPORTS: Species GLOBAL proportions (Table S7_GLOBAL) ====
suppressPackageStartupMessages({
  library(dplyr); library(readr)
  library(flextable); library(officer)
})

OUT_DIR_EST <- OUT_DIR_EST
if (!dir.exists(OUT_DIR_EST)) dir.create(OUT_DIR_EST, recursive = TRUE)

# If species_global_totals isn't in memory, compute it now from kdat
if (!exists("species_global_totals")) {
  stopifnot(exists("kdat"))
  species_global_totals <- kdat %>%
    count(TaxonName, name = "n_tokens") %>%
    mutate(total_global_prop = 100 * n_tokens / sum(n_tokens)) %>%
    arrange(desc(total_global_prop))
}

# --- CSV ---
csv_path <- file.path(OUT_DIR_EST, "species_global_totals_NO_COMMENTS.csv")
write_csv(species_global_totals, csv_path)

# --- Markdown (top 50 to keep it readable; change n as you wish) ---
to_md_table <- function(df, file) {
  stopifnot(is.data.frame(df))
  hdr <- paste(names(df), collapse = " | ")
  sep <- paste(rep("---", ncol(df)), collapse = " | ")
  rows <- apply(df, 1, function(r) paste(r, collapse = " | "))
  out  <- c(paste0("| ", hdr, " |"),
            paste0("| ", sep, " |"),
            paste0("| ", rows, " |"))
  writeLines(out, file); invisible(out)
}

md_top <- species_global_totals %>%
  mutate(total_global_prop = round(total_global_prop, 2)) %>%
  slice_head(n = 50)

md_path <- file.path(OUT_DIR_EST, "Table_S7_GLOBAL_species_global_totals_MARKDOWN.md")
to_md_table(md_top, md_path)

# --- Word (DOCX) ---
docx_path <- file.path(OUT_DIR_EST, "Table_S7_GLOBAL_species_global_totals.docx")
ft <- flextable(md_top) |>
  autofit() |>
  theme_booktabs()

doc <- read_docx() |>
  body_add_par("Table S7_GLOBAL. Species global share of keyword tokens (all periods combined).",
               style = "heading 1") |>
  body_add_par("Values are each species percentage of all tokens across the entire dataset (Pre + Post combined).",
               style = "Normal") |>
  body_add_flextable(ft)

print(doc, target = docx_path)

cat("\nSaved global totals:\n",
    "- CSV: ", csv_path, "\n",
    "- Markdown: ", md_path, "\n",
    "- Word: ", docx_path, "\n")
   
                                                                                                                                                                                                              # ==== Species RELATIVE share within each period (Pre vs Post) ====
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(readr)
  library(flextable); library(officer)
})

OUT_DIR_EST <- OUT_DIR_EST
if (!dir.exists(OUT_DIR_EST)) dir.create(OUT_DIR_EST, recursive = TRUE)

# kdat should be your NO_COMMENTS tokens after harmonization
# (same object you used for S6-S8; columns: TaxonName, category, time_period, etc.)
stopifnot(exists("kdat"))

# 1) Token totals per species x period, then species share of the period total
species_period_totals <- kdat %>%
  count(TaxonName, time_period, name = "n_tokens")

period_totals <- species_period_totals %>%
  group_by(time_period) %>%
  summarise(period_total = sum(n_tokens), .groups = "drop")

species_share_within_period <- species_period_totals %>%
  left_join(period_totals, by = "time_period") %>%
  mutate(share_pct = 100 * n_tokens / period_total) %>%
  arrange(time_period, desc(share_pct))

# 2) Quick look: top 15 per period
top15_by_period <- species_share_within_period %>%
  group_by(time_period) %>%
  slice_max(share_pct, n = 15, with_ties = FALSE) %>%
  ungroup()

cat("\n--- Top 15 species by relative share within each period ---\n")
print(top15_by_period, n = Inf)

# 3) Export full table (all species)
write_csv(species_share_within_period,
          file.path(OUT_DIR_EST, "species_relative_within_period_NO_COMMENTS.csv"))

# 4) Also export a compact Markdown table for Supplementary (top 20 per period)
to_md_table <- function(df, file) {
  hdr <- paste(names(df), collapse = " | ")
  sep <- paste(rep("---", ncol(df)), collapse = " | ")
  rows <- apply(df, 1, function(r) paste(r, collapse = " | "))
  out <- c(paste0("| ", hdr, " |"),
           paste0("| ", sep, " |"),
           paste0("| ", rows, " |"))
  writeLines(out, file); invisible(out)
}

md_top20 <- species_share_within_period %>%
  group_by(time_period) %>%
  slice_max(share_pct, n = 20, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(share_pct = round(share_pct, 2)) %>%
  arrange(time_period, desc(share_pct))

to_md_table(md_top20,
            file.path(OUT_DIR_EST, "Table_S7_species_relative_within_period_MARKDOWN.md"))

# 5) Optional: Word table for S7 (top 20 per period)
docx_path <- file.path(OUT_DIR_EST, "Table_S7_species_relative_within_period.docx")
ft <- flextable(md_top20) |> autofit() |> theme_booktabs()
doc <- read_docx() |>
  body_add_par("Table S7. Species relative share of keyword tokens within each period.", style = "heading 1") |>
  body_add_par("Values are each species percentage of all tokens in that period (Pre vs Post); shares sum to 100% within each period.", style = "Normal") |>
  body_add_flextable(ft)
print(doc, target = docx_path)

cat("\nSaved:\n",
    "- CSV: ", file.path(OUT_DIR_EST, "species_relative_within_period_NO_COMMENTS.csv"), "\n",
    "- Markdown: ", file.path(OUT_DIR_EST, "Table_S7_species_relative_within_period_MARKDOWN.md"), "\n",
    "- Word: ", docx_path, "\n")
                      
                                                                                                                                                                                                                                        
suppressPackageStartupMessages({
  library(dplyr); library(tidyr)
  library(flextable); library(officer)
})

# =========================
# Vectorized format helpers
# =========================
rnd2 <- function(x) ifelse(is.na(x), NA, round(x, 2))

fmt_ci_row_vec <- function(est, lo, hi) {
  miss <- is.na(est) | is.na(lo) | is.na(hi)
  out  <- paste0(rnd2(est), " [", rnd2(lo), "-", rnd2(hi), "]")
  out[miss] <- "-"
  out
}

fmt_or_vec <- function(x) {
  y <- ifelse(is.na(x), NA, signif(x, 3))
  # keep as character; show small numbers nicely
  out <- ifelse(is.na(y), "-", as.character(y))
  out
}

fmt_p_vec <- function(x) {
  out <- rep("-", length(x))
  nax <- is.na(x)
  if (any(!nax)) {
    xp <- x[!nax]
    tiny <- xp < 1e-4
    out[!nax] <- ifelse(tiny, formatC(xp, format = "e", digits = 2),
                        as.character(signif(xp, 3)))
  }
  out
}

safe_print <- function(x, n = Inf) {
  op <- options(na.print = "NA"); on.exit(options(op), add = TRUE)
  print(x, n = n)
}

# =======================================
# Builder: from emmeans + contrasts -> table
# =======================================
build_compact_summary <- function(emm_tbl, ctr_tbl,
                                  category_order = c("Detection","Invasion","Threat","eCommerce")) {
  pre  <- emm_tbl %>%
    filter(time_period == "Pre-Introduction") %>%
    transmute(category, pre_est = estimate_pct, pre_lo = lower_pct, pre_hi = upper_pct)

  post <- emm_tbl %>%
    filter(time_period == "Post-Introduction") %>%
    transmute(category, post_est = estimate_pct, post_lo = lower_pct, post_hi = upper_pct)

  orp <- ctr_tbl %>%
    dplyr::select(category, odds.ratio, p.value) %>%
    group_by(category) %>% slice(1) %>% ungroup()

  out <- full_join(pre, post, by = "category") %>%
    full_join(orp, by = "category") %>%
    mutate(category = factor(category, levels = category_order)) %>%
    arrange(category) %>%
    transmute(
      `Keyword category` = as.character(category),
      `Pre (%, 95% CI)`  = fmt_ci_row_vec(pre_est,  pre_lo,  pre_hi),
      `Post (%, 95% CI)` = fmt_ci_row_vec(post_est, post_lo, post_hi),
      `OR (Post vs Pre)` = fmt_or_vec(odds.ratio),
      `p (Holm)`         = fmt_p_vec(p.value)
    )
  out
}

# =======================================
# Build the two tables (uses your objects)
# =======================================
# You already have these in memory from your paste:
# emm_sp_tbl, ctr_sp_tbl
# (and for lifeform: emm_lf_tbl, ctr_lf_tbl)

species_compact  <- build_compact_summary(emm_sp_tbl, ctr_sp_tbl)
lifeform_compact <- build_compact_summary(emm_lf_tbl, ctr_lf_tbl)

cat("\n=== Species GLMM summary (compact) ===\n");  safe_print(species_compact)
cat("\n=== LifeForm GLMM summary (compact) ===\n"); safe_print(lifeform_compact)

# =======================================
# (Optional) write a Word doc with both
# =======================================
OUT_DIR_EST <- OUT_DIR_EST
if (!dir.exists(OUT_DIR_EST)) dir.create(OUT_DIR_EST, recursive = TRUE, showWarnings = FALSE)

ft_style <- function(df) {
  flextable(df) |>
    autofit() |>
    set_table_properties(width = 1, layout = "autofit") |>
    theme_booktabs() |>
    fontsize(size = 9, part = "all") |>
    align(align = "center", part = "all") |>
    bold(part = "header")
}

docx_path <- file.path(OUT_DIR_EST, "GLMM_compact_summaries.docx")
doc <- read_docx()
doc <- body_add_par(doc, "Compact GLMM summaries (period-normalised, titles+descriptions)", style = "heading 1")
doc <- body_add_par(doc, "Species - LS-means (%, 95% CI) and Post vs Pre contrasts (OR, Holm p)", style = "heading 2")
doc <- body_add_flextable(doc, ft_style(species_compact))
doc <- body_add_par(doc, "", style = "Normal")
doc <- body_add_par(doc, "LifeForm - LS-means (%, 95% CI) and Post vs Pre contrasts (OR, Holm p)", style = "heading 2")
doc <- body_add_flextable(doc, ft_style(lifeform_compact))
doc <- body_add_par(doc, "", style = "Normal")
print(doc, target = docx_path)
message("Wrote Word file: ", docx_path)
                           
                           
library(dplyr)
# uses emm_sp_tbl you already have
glmm_delta <- emm_sp_tbl %>%
  dplyr::select(time_period, category, estimate_pct) %>%
  tidyr::pivot_wider(names_from = time_period, values_from = estimate_pct) %>%
  transmute(
    `Keyword category` = category,
    `Pre (%, 95% CI)`  = NA_character_,   # you already have this in the compact table
    `Post (%, 95% CI)` = NA_character_,   # ditto; here we only compute ?
    `? (Post - Pre)`   = round(`Post-Introduction` - `Pre-Introduction`, 2)
  )
glmm_delta
