if (file.exists("scripts/00_direct_output_config.R")) source("scripts/00_direct_output_config.R", encoding = "UTF-8")
# ============================================================
# 13_tables_S10_S13_engagement.R
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
# Definitive Supplementary Tables Workflow (S10-S13)
#   - Robust to duplicated TaxonName rows in species_* CSVs
#   - Exports: CSV + Markdown + Word (docx)
# ============================================================

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
  library(tidyr)
  library(knitr)
  library(officer)
  library(flextable)
})

# ----------------------------
# 0) Paths
# ----------------------------
out_root    <- file.path("outputs", "intermediate", "engagement")
out_tables  <- file.path(out_root, "tables")
out_derived <- file.path(out_tables, "derived")

if (!dir.exists(out_derived)) dir.create(out_derived, recursive = TRUE)

# ----------------------------
# 1) Load CSVs
# ----------------------------
species_raw  <- readr::read_csv(file.path(out_tables, "species_metrics_raw.csv"), show_col_types = FALSE)
species_adj  <- readr::read_csv(file.path(out_tables, "species_metrics_ageadjusted.csv"), show_col_types = FALSE)
lifeform_raw <- readr::read_csv(file.path(out_tables, "lifeform_metrics_raw.csv"), show_col_types = FALSE)

# ----------------------------
# 2) Small helpers
# ----------------------------
assert_has_cols <- function(df, cols, df_name = "df") {
  missing <- setdiff(cols, colnames(df))
  if (length(missing) > 0) {
    stop(df_name, " is missing required columns: ", paste(missing, collapse = ", "))
  }
  invisible(TRUE)
}

write_md_table <- function(df, outfile_md, caption) {
  md <- suppressWarnings(
    knitr::kable(df, format = "pipe", caption = caption, digits = 3)
  )
  writeLines(md, con = outfile_md)
}

# Collapse duplicated species rows WITHOUT inflating totals:
# - numeric totals: max()
# - categorical: if >1 unique non-NA value exists, keep first and warn
collapse_species <- function(df, df_name) {
  needed <- c("TaxonName","LifeForm","PresentStatus","n_videos","views","likes","comments","composite")
  assert_has_cols(df, needed, df_name)

  df1 <- df %>%
    filter(!is.na(TaxonName), TaxonName != "") %>%
    mutate(
      TaxonName = as.character(TaxonName),
      LifeForm = as.character(LifeForm),
      PresentStatus = as.character(PresentStatus)
    )

  # diagnose duplication
  dup <- df1 %>% count(TaxonName) %>% filter(n > 1)
  if (nrow(dup) > 0) {
    message("NOTE: ", df_name, " has duplicated TaxonName rows (n duplicated species = ", nrow(dup), "). Collapsing with max() to prevent inflation.")
  }

  # check for inconsistent categorical values across duplicates (optional but useful)
  cat_incons <- df1 %>%
    group_by(TaxonName) %>%
    summarise(
      n_lifeform = n_distinct(na.omit(LifeForm)),
      n_status   = n_distinct(na.omit(PresentStatus)),
      .groups = "drop"
    ) %>%
    filter(n_lifeform > 1 | n_status > 1)

  if (nrow(cat_incons) > 0) {
    message("WARNING: Some species have >1 LifeForm and/or PresentStatus across duplicated rows in ", df_name, ". Keeping first non-NA value. (Check upstream joins.)")
    print(cat_incons, n = min(25, nrow(cat_incons)))
  }

  # collapse
  df_collapsed <- df1 %>%
    group_by(TaxonName) %>%
    summarise(
      LifeForm      = dplyr::first(na.omit(LifeForm)),
      PresentStatus = dplyr::first(na.omit(PresentStatus)),
      n_videos      = max(n_videos, na.rm = TRUE),
      views         = max(views, na.rm = TRUE),
      likes         = max(likes, na.rm = TRUE),
      comments      = max(comments, na.rm = TRUE),
      composite     = max(composite, na.rm = TRUE),
      .groups = "drop"
    )

  df_collapsed
}

collapse_species_adj <- function(df_adj) {
  # We expect at least TaxonName + composite_adj. Some files may also carry n_videos/LifeForm/etc.
  assert_has_cols(df_adj, c("TaxonName","composite_adj"), "species_adj")

  df1 <- df_adj %>%
    filter(!is.na(TaxonName), TaxonName != "") %>%
    mutate(TaxonName = as.character(TaxonName))

  dup <- df1 %>% count(TaxonName) %>% filter(n > 1)
  if (nrow(dup) > 0) {
    message("NOTE: species_adj has duplicated TaxonName rows (n duplicated species = ", nrow(dup), "). Collapsing composite_adj safely.")
  }

  # If duplicated rows disagree strongly on composite_adj, flag it.
  adj_incons <- df1 %>%
    group_by(TaxonName) %>%
    summarise(
      n_vals = sum(!is.na(composite_adj)),
      sd_adj = sd(composite_adj, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    filter(n_vals > 1, is.finite(sd_adj), sd_adj > 0.25) %>%  # threshold: tweak if you want
    arrange(desc(sd_adj))

  if (nrow(adj_incons) > 0) {
    message("WARNING: Some species have substantially different composite_adj values across duplicated rows. Using mean(composite_adj). Please check upstream if this is unexpected.")
    print(adj_incons, n = min(25, nrow(adj_incons)))
  }

  df1 %>%
    group_by(TaxonName) %>%
    summarise(
      composite_adj = mean(composite_adj, na.rm = TRUE),
      .groups = "drop"
    )
}

# Collapse lifeform table to one row per LifeForm (prevent accidental duplication)
collapse_lifeform <- function(df_lf) {
  assert_has_cols(df_lf, c("LifeForm","n_videos","views","likes","comments","composite"), "lifeform_raw")

  df_lf %>%
    filter(!is.na(LifeForm), LifeForm != "") %>%
    group_by(LifeForm) %>%
    summarise(
      Videos   = max(n_videos, na.rm = TRUE),
      Views    = round(max(views, na.rm = TRUE)),
      Likes    = round(max(likes, na.rm = TRUE)),
      Comments = round(max(comments, na.rm = TRUE)),
      EC       = max(composite, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(Videos))
}

# ----------------------------
# 3) Build ONE-row-per-species master table
# ----------------------------
species_raw_1 <- collapse_species(species_raw, "species_raw")
species_adj_1 <- collapse_species_adj(species_adj)

species_merged <- species_raw_1 %>%
  left_join(species_adj_1, by = "TaxonName") %>%
  mutate(
    EC_per_video = composite / pmax(n_videos, 1)
  )

# Save the merged, de-duplicated species table for traceability
readr::write_csv(species_merged, file.path(out_derived, "species_metrics_merged_dedup_for_SI.csv"))

# ----------------------------
# 4) Correlations (species-level; deduped)
# ----------------------------
cor_raw <- cor.test(
  species_merged$n_videos,
  species_merged$composite,
  method = "spearman",
  exact  = FALSE
)

cor_adj <- cor.test(
  species_merged$n_videos,
  species_merged$composite_adj,
  method = "spearman",
  exact  = FALSE
)

cor_out <- tibble::tibble(
  test    = c("uploads_vs_EC_raw", "uploads_vs_EC_adj"),
  rho     = c(unname(cor_raw$estimate), unname(cor_adj$estimate)),
  p_value = c(cor_raw$p.value, cor_adj$p.value),
  n       = c(sum(complete.cases(species_merged$n_videos, species_merged$composite)),
              sum(complete.cases(species_merged$n_videos, species_merged$composite_adj)))
)

readr::write_csv(cor_out, file.path(out_derived, "ST-Engage_correlations_specieslevel.csv"))

cat("\nSpearman uploads vs EC (raw): rho =", unname(cor_raw$estimate), " p =", cor_raw$p.value, "\n")
cat("Spearman uploads vs EC_adj: rho =", unname(cor_adj$estimate), " p =", cor_adj$p.value, "\n")

# ----------------------------
# 5) Build S10-S13 tables (ONLY)
# ----------------------------

# ---- S11: Top 15 species by raw EC ----
ST_Engage_S11 <- species_merged %>%
  arrange(desc(composite)) %>%
  mutate(Rank = row_number()) %>%
  slice_head(n = 15) %>%
  transmute(
    Rank,
    Species  = TaxonName,
    LifeForm,
    Status   = PresentStatus,
    Videos   = n_videos,
    Views    = round(views),
    Likes    = round(likes),
    Comments = round(comments),
    EC       = composite,
    EC_adj   = composite_adj
  )

# ---- S10: Top 15 species by uploads ----
ST_Engage_S10 <- species_merged %>%
  arrange(desc(n_videos)) %>%
  mutate(Rank = row_number()) %>%
  slice_head(n = 15) %>%
  transmute(
    Rank,
    Species  = TaxonName,
    LifeForm,
    Status   = PresentStatus,
    Videos   = n_videos,
    Views    = round(views),
    Likes    = round(likes),
    Comments = round(comments),
    EC       = composite
  )

# ---- S12: Top 10 species by EC per video ----
ST_Engage_S12 <- species_merged %>%
  arrange(desc(EC_per_video)) %>%
  mutate(Rank = row_number()) %>%
  slice_head(n = 10) %>%
  transmute(
    Rank,
    Species  = TaxonName,
    LifeForm,
    Videos   = n_videos,
    EC       = composite,
    EC_per_video,
    Views    = round(views),
    Likes    = round(likes),
    Comments = round(comments)
  )

# ---- S13: Life-form summary (raw EC) ----
ST_Engage_S13 <- collapse_lifeform(lifeform_raw)

# ----------------------------
# 6) Export (CSV + MD)
# ----------------------------
readr::write_csv(ST_Engage_S11, file.path(out_derived, "ST-Engage-S11_top15_by_EC_raw.csv"))
readr::write_csv(ST_Engage_S10, file.path(out_derived, "ST-Engage-S10_top15_by_uploads.csv"))
readr::write_csv(ST_Engage_S12,  file.path(out_derived, "ST-Engage-S12_top10_by_EC_per_video.csv"))
readr::write_csv(ST_Engage_S13,  file.path(out_derived, "ST-Engage-S13_lifeform_summary.csv"))

write_md_table(ST_Engage_S11, file.path(out_derived, "ST-Engage-S11_top15_by_EC_raw.md"),
               "ST-Engage-S11. Top 15 species by composite engagement (raw EC).")
write_md_table(ST_Engage_S10, file.path(out_derived, "ST-Engage-S10_top15_by_uploads.md"),
               "ST-Engage-S10. Top 15 species by uploads (number of videos).")
write_md_table(ST_Engage_S12,  file.path(out_derived, "ST-Engage-S12_top10_by_EC_per_video.md"),
               "ST-Engage-S12. Top 10 species by engagement per video (EC per video).")
write_md_table(ST_Engage_S13,  file.path(out_derived, "ST-Engage-S13_lifeform_summary.md"),
               "ST-Engage-S13. Life-form summary of uploads and engagement (raw EC).")

# ----------------------------
# 7) Export to Word (.docx)
# ----------------------------
make_ft <- function(df) {
  flextable(df) %>%
    autofit() %>%
    theme_vanilla() %>%
    fontsize(size = 10, part = "all")
}

doc <- officer::read_docx()

doc <- doc %>%
  body_add_par("Supplementary Tables: Engagement (S10-S13)", style = "heading 1") %>%
  body_add_par("These tables were generated from de-duplicated species-level metrics (duplicates collapsed using max() to prevent inflation).", style = "Normal") %>%
  body_add_par("", style = "Normal")

# Add correlation summary (handy to keep next to the tables)
doc <- doc %>%
  body_add_par("Species-level correlations", style = "heading 2") %>%
  body_add_flextable(make_ft(cor_out)) %>%
  body_add_par("", style = "Normal")

doc <- doc %>%
  body_add_par("ST-Engage-S11. Top 15 species by composite engagement (raw EC).", style = "heading 2") %>%
  body_add_flextable(make_ft(ST_Engage_S11)) %>%
  body_add_par("", style = "Normal")

doc <- doc %>%
  body_add_par("ST-Engage-S10. Top 15 species by uploads (number of videos).", style = "heading 2") %>%
  body_add_flextable(make_ft(ST_Engage_S10)) %>%
  body_add_par("", style = "Normal")

doc <- doc %>%
  body_add_par("ST-Engage-S12. Top 10 species by engagement per video (EC per video).", style = "heading 2") %>%
  body_add_flextable(make_ft(ST_Engage_S12)) %>%
  body_add_par("", style = "Normal")

doc <- doc %>%
  body_add_par("ST-Engage-S13. Life-form summary of uploads and engagement (raw EC).", style = "heading 2") %>%
  body_add_flextable(make_ft(ST_Engage_S13)) %>%
  body_add_par("", style = "Normal")

docx_path <- file.path(out_derived, "ST-Engage_S10_to_S13_tables.docx")
print(doc, target = docx_path)

cat("\nDONE.\nOutputs written to:\n", normalizePath(out_derived), "\n", sep = "")
cat("Word document:\n", normalizePath(docx_path), "\n", sep = "")


# ---- FINAL DIRECT TABLE EXPORTS FOR ENGAGEMENT ------------------------------
# Copy/rename selected engagement tables to clean supplement table folder.
copy_table_if_exists <- function(from_stem, to_stem) {
  for (ext in c(".csv", ".docx", ".md")) {
    from <- paste0(from_stem, ext)
    to <- paste0(to_stem, ext)
    if (file.exists(from)) {
      dir.create(dirname(to), recursive = TRUE, showWarnings = FALSE)
      file.copy(from, to, overwrite = TRUE)
    }
  }
}
# Remove engagement intermediate folder after tables are copied.
if (dir.exists(file.path("outputs", "intermediate", "engagement"))) {
  unlink(file.path("outputs", "intermediate", "engagement"), recursive = TRUE, force = TRUE)
}
