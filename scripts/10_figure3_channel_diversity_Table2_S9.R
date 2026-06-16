if (file.exists("scripts/00_direct_output_config.R")) source("scripts/00_direct_output_config.R", encoding = "UTF-8")
# ============================================================
# 10_figure3_channel_diversity_Table2_S9.R
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

# Figure 3 - channel diversity panels (Figure 2C renamed)
# =============================================================================
# Libraries -------------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(readr)
library(flextable)
library(viridisLite)
library(patchwork)
library(grid)
library(png)
library(RColorBrewer)

# Methods say vegan was used; we import it and QA-check equivalence ------------
# (We keep your manual calculations to avoid altering any downstream results/plots.)
library(vegan)

# Output dirs -----------------------------------------------------------------
# Figures are written to outputs/figures/main.
# Tables and QA files are written to outputs/tables/* so the figure folder stays clean.
OUT_DIR <- FIG_MAIN_DIR
if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive = TRUE)

TAB_MAIN_OUT_DIR <- TAB_MAIN_DIR
TAB_SUPP_OUT_DIR <- TAB_SUPP_DIR
TAB_QA_OUT_DIR   <- file.path(OUT_ROOT, "tables", "qa")
invisible(lapply(c(TAB_MAIN_OUT_DIR, TAB_SUPP_OUT_DIR, TAB_QA_OUT_DIR),
                 dir.create, recursive = TRUE, showWarnings = FALSE))

# Helper to save PNG + TIFF ---------------------------------------------------
save_plot_both <- function(plot, filename_base,
                           width, height, units = "mm",
                           dpi = 300, bg = "white") {
  base_name <- basename(filename_base)
  keep_name <- "Figure3_panel_icons-abs-rel-top_YlGnBu_NOTAGS"
  if (!identical(base_name, keep_name)) return(invisible(FALSE))
  out_base <- file.path(FIG_MAIN_DIR, "Figure_3")
  ggplot2::ggsave(paste0(out_base, ".png"), plot,
                  width = width, height = height, units = units, dpi = dpi, bg = bg)
  ggplot2::ggsave(paste0(out_base, ".tiff"), plot,
                  width = width, height = height, units = units, dpi = dpi, bg = bg,
                  device = "tiff", compression = "lzw")
  message("Saved final figure: ", out_base, ".png and .tiff")
  invisible(TRUE)
}

save_plot_png_tiff <- function(plot, file_base,
                               width = 160, height = 110,
                               units = "mm", dpi = 300) {
  base_name <- basename(file_base)
  keep_name <- "Figure3_panel_icons-abs-rel-top_YlGnBu_NOTAGS"
  if (!identical(base_name, keep_name)) return(invisible(FALSE))
  out_base <- file.path(FIG_MAIN_DIR, "Figure_3")
  ggplot2::ggsave(paste0(out_base, ".png"),  plot,
                  width = width, height = height, units = units, dpi = dpi)
  ggplot2::ggsave(paste0(out_base, ".tiff"), plot,
                  width = width, height = height, units = units, dpi = dpi,
                  device = "tiff", compression = "lzw", bg = "white")
  message("Saved final figure: ", out_base, ".png and .tiff")
  invisible(TRUE)
}

# --- SETTINGS ---------------------------------------------------------------
desired_lf_order <- c(
  "Birds","Herptiles","Fishes","Insects",
  "Crustaceans","Non-arthropod invertebrates","Plants","Bacteria, Viruses, Fungi"
)
KEEP_LF <- desired_lf_order
LF_TOP_FIRST <- rev(KEEP_LF)   # Birds at TOP


# ---- helpers ---------------------------------------------------------------
fmt_mean_sd <- function(m, s) {
  ok <- is.finite(m) & is.finite(s)
  out <- rep("-", length(m))
  out[ok] <- sprintf("%.1f +/- %.1f", m[ok], s[ok])
  out
}
norm_taxon <- function(x) {
  x |>
    as.character() |>
    gsub("\\s+", "_", x = _) |>
    gsub("__+", "_", x = _) |>
    trimws()
}
fmt_neff <- function(x) ifelse(is.finite(x), scales::number(x, big.mark = " "), "-")

# Unified theme for all plots (base 16, no angled x text) --------------------
theme_inat <- function(base_size = 17) {
  theme_light(base_size = base_size) +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      legend.title       = element_text(size = base_size),
      legend.text        = element_text(size = 17),
      axis.text.x        = element_text(
        size = base_size, face = "plain", angle = 0, hjust = 0.5,
        margin = margin(t = 6)
      ),
      axis.text.y        = element_text(
        size = base_size, face = "plain", margin = margin(r = 6)
      ),
      axis.title.x       = element_text(size = base_size, margin = margin(t = 10)),
      axis.title.y       = element_text(size = base_size, margin = margin(r = 10)),
      plot.title         = element_text(face = "plain", size = base_size,
                                        margin = margin(b = 8))
    )
}

# ---- ensure denominators ---------------------------------------------------
if (!exists("denom_by_lifeform")) {
  denom_by_lifeform <- zenodo_grouped |>
    dplyr::mutate(TaxonName = norm_taxon(.data$TaxonName)) |>
    dplyr::group_by(.data$TaxonName) |>
    dplyr::slice_min(.data$FirstRecord, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::count(.data$LifeForm, name = "Searched")
}
denom_by_lifeform <- denom_by_lifeform |>
  dplyr::mutate(LifeForm = factor(LifeForm, levels = KEEP_LF))

# ---- strict Iberian filter (LABELLED) --------------------------------------
LABELLED_USE_STRICT_IBERIAN <- TRUE
lab_df <- combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN |>
  dplyr::mutate(TaxonName = norm_taxon(.data$TaxonName))

if (LABELLED_USE_STRICT_IBERIAN && "is_iberian" %in% names(lab_df)) {
  lab_df <- lab_df |>
    dplyr::filter(.data$is_iberian %in% c(TRUE, 1, "TRUE", "true"))
}

# Enforce desired LifeForm order globally (drop unknowns if desired)
lab_df <- lab_df |>
  dplyr::mutate(
    LifeForm = as.character(.data$LifeForm),
    LifeForm = ifelse(LifeForm %in% KEEP_LF, LifeForm, NA_character_),
    LifeForm = factor(LifeForm, levels = KEEP_LF)
  ) |>
  dplyr::filter(!is.na(LifeForm))

# ---- per-species stats -----------------------------------------------------
labelled_stats_species <- lab_df |>
  dplyr::group_by(.data$TaxonName, .data$LifeForm) |>
  dplyr::summarise(
    n_videos   = dplyr::n(),
    n_channels = dplyr::n_distinct(.data$channelTitle, na.rm = TRUE),
    .groups = "drop"
  )

lifeform_totals <- lab_df |>
  dplyr::group_by(.data$LifeForm) |>
  dplyr::summarise(
    total_videos          = dplyr::n(),
    total_unique_channels = dplyr::n_distinct(.data$channelTitle, na.rm = TRUE),
    .groups = "drop"
  )

# ---- channel concentration per LifeForm ------------------------------------
lifeform_channel_counts <- lab_df |>
  dplyr::group_by(.data$LifeForm, .data$channelTitle) |>
  dplyr::summarise(n_vids = dplyr::n(), .groups = "drop")

channel_diversity <- lifeform_channel_counts |>
  dplyr::group_by(.data$LifeForm) |>
  dplyr::summarise(
    total_videos = sum(n_vids),
    m_channels   = dplyr::n_distinct(.data$channelTitle),
    HHI          = { p <- n_vids / sum(n_vids); sum(p^2) },
    invHHI_norm  = dplyr::if_else(m_channels > 1, (1 - HHI) / (1 - 1/m_channels), 0),
    Neff_HHI     = dplyr::if_else(HHI > 0, 1/HHI, NA_real_),

    # Shannon entropy (manual)
    H            = { p <- n_vids / sum(n_vids); -sum(p * log(p)) },
    H_norm       = dplyr::if_else(m_channels > 1, H / log(m_channels), 0),
    Neff_H       = exp(H),

    # Shannon entropy (vegan, for QA vs Methods statement)
    H_vegan      = { p <- n_vids / sum(n_vids); vegan::diversity(p, index = "shannon") },
    Hnorm_vegan  = dplyr::if_else(m_channels > 1, H_vegan / log(m_channels), 0),
    NeffH_vegan  = exp(H_vegan),

    .groups = "drop"
  ) |>
  dplyr::mutate(LifeForm = factor(LifeForm, levels = KEEP_LF))

# ---- LifeForm summary core (means per species + denominators) --------------
labelled_summary_lifeform <- labelled_stats_species |>
  dplyr::group_by(.data$LifeForm) |>
  dplyr::summarise(
    Found_species = dplyr::n_distinct(.data$TaxonName),
    mean_videos   = mean(.data$n_videos,   na.rm = TRUE),
    sd_videos     = sd(.data$n_videos,     na.rm = TRUE),
    mean_channels = mean(.data$n_channels, na.rm = TRUE),
    sd_channels   = sd(.data$n_channels,   na.rm = TRUE),
    .groups = "drop"
  ) |>
  dplyr::left_join(lifeform_totals,   by = "LifeForm") |>
  dplyr::left_join(denom_by_lifeform, by = "LifeForm") |>
  dplyr::left_join(channel_diversity,  by = "LifeForm") |>
  dplyr::mutate(
    `Found of Searched (%)` = dplyr::if_else(.data$Searched > 0,
      round(100 * .data$Found_species / .data$Searched, 1), NA_real_)
  )

# Canonicalize column names for table build (handles .x/.y cases)
tv_candidates  <- c("total_videos", "total_videos.x", "total_videos.y")
tuc_candidates <- c("total_unique_channels", "total_unique_channels.x", "total_unique_channels.y")
tv_col  <- intersect(tv_candidates,  names(labelled_summary_lifeform))[1]
tuc_col <- intersect(tuc_candidates, names(labelled_summary_lifeform))[1]
if (is.na(tv_col))  stop("Could not find any total_videos column.")
if (is.na(tuc_col)) stop("Could not find any total_unique_channels column.")

labelled_summary_lifeform <- labelled_summary_lifeform %>%
  dplyr::mutate(
    total_videos          = .data[[tv_col]],
    total_unique_channels = .data[[tuc_col]]
  ) %>%
  dplyr::select(
    -dplyr::any_of(setdiff(tv_candidates,  "total_videos")),
    -dplyr::any_of(setdiff(tuc_candidates, "total_unique_channels"))
  )

# ---- MAIN TABLE (clean order, totals once, single write) -------------------
Searched_total        <- sum(denom_by_lifeform$Searched, na.rm = TRUE)
Found_species_total   <- dplyr::n_distinct(labelled_stats_species$TaxonName)
Found_pct_total       <- round(100 * Found_species_total / Searched_total, 1)
overall_mean_videos   <- mean(labelled_stats_species$n_videos,   na.rm = TRUE)
overall_sd_videos     <- sd(labelled_stats_species$n_videos,     na.rm = TRUE)
overall_mean_channels <- mean(labelled_stats_species$n_channels, na.rm = TRUE)
overall_sd_channels   <- sd(labelled_stats_species$n_channels,   na.rm = TRUE)
Total_videos_all      <- nrow(lab_df)
Total_unique_channels_all <- dplyr::n_distinct(lab_df$channelTitle, na.rm = TRUE)

totals_row <- dplyr::tibble(
  `Taxonomic group`                    = "Total",
  `Found of Searched (%)`              = Found_pct_total,
  `Videos / species (mean+/-SD)`         = fmt_mean_sd(overall_mean_videos, overall_sd_videos),
  `Channels / species (mean+/-SD)`       = fmt_mean_sd(overall_mean_channels, overall_sd_channels),
  `Total videos`                       = Total_videos_all,
  `Total unique channels`              = Total_unique_channels_all,
  `Channel concentration (invHHI, 0-1)`= NA_real_,
  `Effective channels (1/HHI)`         = NA_real_
)

table2_main_body <- labelled_summary_lifeform |>
  dplyr::transmute(
    `Taxonomic group`              = as.character(.data$LifeForm),
    `Found of Searched (%)`        = .data$`Found of Searched (%)`,
    `Videos / species (mean+/-SD)`   = fmt_mean_sd(.data$mean_videos,   .data$sd_videos),
    `Channels / species (mean+/-SD)` = fmt_mean_sd(.data$mean_channels, .data$sd_channels),
    `Total videos`                 = .data$total_videos,
    `Total unique channels`        = .data$total_unique_channels,
    invHHI_raw                     = .data$invHHI_norm,
    invHHI_disp                    = round(.data$invHHI_norm, 2),
    eff_channels                   = round(.data$Neff_HHI, 1)
  ) |>
  dplyr::arrange(dplyr::desc(invHHI_raw)) |>
  dplyr::transmute(
    `Taxonomic group`,
    `Found of Searched (%)`,
    `Videos / species (mean+/-SD)`,
    `Channels / species (mean+/-SD)`,
    `Total videos`,
    `Total unique channels`,
    `Channel concentration (invHHI, 0-1)` = invHHI_disp,
    `Effective channels (1/HHI)`           = eff_channels
  )

table2_main <- dplyr::bind_rows(table2_main_body, totals_row)

readr::write_csv(table2_main, file.path(TAB_MAIN_OUT_DIR, "Table2_LABELLED_main.csv"))
ft_main <- flextable::flextable(table2_main)
flextable::save_as_docx(ft_main, path = file.path(TAB_MAIN_OUT_DIR, "Table2_LABELLED_main.docx"))

# ---- SUPPLEMENT: full diagnostics -----------------------------------------
supp_diversity <- channel_diversity |>
  dplyr::select(
    LifeForm, total_videos, m_channels, HHI, invHHI_norm,
    H, H_norm, Neff_HHI, Neff_H
  ) |>
  dplyr::arrange(dplyr::desc(invHHI_norm))

readr::write_csv(supp_diversity, file.path(TAB_SUPP_OUT_DIR, "TableS9_channel_diversity_full.csv"))
ft_supp0 <- flextable::flextable(supp_diversity)
flextable::save_as_docx(ft_supp0, path = file.path(TAB_SUPP_OUT_DIR, "TableS9_channel_diversity_full.docx"))

# Rounded export -------------------------------------------------------------
DIGITS_HHI     <- 3
DIGITS_INVHHI  <- 3
DIGITS_H       <- 3
DIGITS_HNORM   <- 3
DIGITS_NEFFHHI <- 1
DIGITS_NEFFH   <- 1

supp_diversity_round <- supp_diversity |>
  dplyr::mutate(
    total_videos = as.integer(total_videos),
    m_channels   = as.integer(m_channels),
    HHI          = round(HHI,          DIGITS_HHI),
    invHHI_norm  = round(invHHI_norm,  DIGITS_INVHHI),
    H            = round(H,            DIGITS_H),
    H_norm       = round(H_norm,       DIGITS_HNORM),
    Neff_HHI     = round(Neff_HHI,     DIGITS_NEFFHHI),
    Neff_H       = round(Neff_H,       DIGITS_NEFFH)
  )

readr::write_csv(supp_diversity_round, file.path(TAB_SUPP_OUT_DIR, "TableSx_channel_diversity_full.csv"))
ft_supp <- flextable::flextable(supp_diversity_round) |>
  flextable::colformat_num(j = c("HHI"),         digits = DIGITS_HHI) |>
  flextable::colformat_num(j = c("invHHI_norm"), digits = DIGITS_INVHHI) |>
  flextable::colformat_num(j = c("H"),           digits = DIGITS_H) |>
  flextable::colformat_num(j = c("H_norm"),      digits = DIGITS_HNORM) |>
  flextable::colformat_num(j = c("Neff_HHI"),    digits = DIGITS_NEFFHHI) |>
  flextable::colformat_num(j = c("Neff_H"),      digits = DIGITS_NEFFH)

flextable::save_as_docx(ft_supp, path = file.path(TAB_SUPP_OUT_DIR, "TableSx_channel_diversity_full.docx"))

# =============================================================================
# FIGURE 3 PANELS
# =============================================================================

# ------------------ C1: invHHI (0-1) bar plot -------------------------------
p_C1_invHHI <- ggplot2::ggplot(channel_diversity,
  ggplot2::aes(x = invHHI_norm, y = LifeForm)) +
  ggplot2::geom_col(width = 0.7) +
  ggplot2::geom_text(
    ggplot2::aes(label = scales::number(invHHI_norm, accuracy = 0.001)),
    hjust = -0.1, size = 4
  ) +
  ggplot2::scale_x_continuous(
    limits = c(0, 1.05), breaks = seq(0, 1, by = 0.2),
    expand = ggplot2::expansion(mult = c(0, 0.02))
  ) +
  ggplot2::scale_y_discrete(limits = LF_TOP_FIRST) +
  ggplot2::labs(
    x = "Normalised inverse HHI (0-1)\n(higher = more decentralised)",
    y = NULL,
    title = "Decentralisation of video production by life-form"
  ) +
  theme_inat(17) +
  ggplot2::theme(
    legend.position    = "none",
    panel.grid.major.y = ggplot2::element_blank(),
    axis.title.x       = ggplot2::element_text(margin = ggplot2::margin(t = 12)),
    plot.title         = ggplot2::element_text(face = "plain", hjust = 0)
  )

# --------------- C2: Effective channels (1/HHI), log10 ----------------------
p_C2_neff <- ggplot2::ggplot(channel_diversity,
  ggplot2::aes(x = Neff_HHI, y = LifeForm)) +
  ggplot2::geom_col(width = 0.7) +
  ggplot2::geom_text(
    ggplot2::aes(label = fmt_neff(Neff_HHI)),
    hjust = -0.1, size = 4
  ) +
  ggplot2::scale_x_continuous(
    trans = "log10",
    breaks = c(5, 10, 20, 50, 100, 200, 400),
    labels = scales::number_format(accuracy = 1, big.mark = " "),
    expand = ggplot2::expansion(mult = c(0, 0.02))
  ) +
  ggplot2::scale_y_discrete(limits = LF_TOP_FIRST) +
  ggplot2::labs(
    x = "Effective channels (1/HHI, log scale)\n( equally productive channels)",
    y = NULL,
    title = "Effective number of contributing channels by life-form"
  ) +
  theme_inat(17) +
  ggplot2::theme(
    legend.position    = "none",
    panel.grid.major.y = ggplot2::element_blank(),
    axis.title.x       = ggplot2::element_text(margin = ggplot2::margin(t = 12)),
    plot.title         = ggplot2::element_text(face = "plain", hjust = 0)
  )

# --- Save C1 / C2 singles (PNG + TIFF) --------------------------------------
save_plot_both(
  p_C1_invHHI,
  file.path(OUT_DIR, "Figure3_C1_invHHI_norm"),
  width = 160, height = 125, units = "mm"
)

save_plot_both(
  p_C2_neff,
  file.path(OUT_DIR, "Figure3_C2_effective_channels_log"),
  width = 160, height = 125, units = "mm"
)

# ================== CLEAN LOLLIPOP (A) ======================================
df_neff <- channel_diversity %>%
  dplyr::mutate(LifeForm = factor(LifeForm, levels = KEEP_LF)) %>%
  dplyr::arrange(Neff_HHI)

x_max <- max(df_neff$Neff_HHI, na.rm = TRUE)

p_abs_clean <- ggplot(df_neff, aes(x = Neff_HHI, y = LifeForm)) +
  geom_segment(aes(x = 1, xend = Neff_HHI, yend = LifeForm),
               linewidth = 0.6, colour = "grey55", lineend = "round") +
  geom_point(size = 3.6) +
  scale_x_continuous(
    trans  = "log10",
    breaks = c(5, 10, 20, 50, 100, 200, 300),
    labels = scales::number_format(accuracy = 1)
  ) +
  labs(
    title = "How many equally productive channels?",
    x = "1/HHI (log)", y = NULL
  ) +
  coord_cartesian(xlim = c(1, x_max * 1.08), clip = "on") +
  theme_inat(17) +
  theme(
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    plot.title   = element_text(face = "plain", size = 17, lineheight = 1.05),
    axis.title.x = element_text(size = 17),
    plot.margin  = margin(8, 12, 10, 6)
  ) +
  scale_y_discrete(limits = LF_TOP_FIRST)

# Single export for A (no icons, no letter) ----------------------------------
save_plot_both(
  p_abs_clean,
  file.path(OUT_DIR, "Figure3_A_abs_lollipop"),
  width = 150, height = 130, units = "mm"
)

# ================== Build stacked shares (Top1 / Top10p / Rest) =============
stack_df <- lifeform_channel_counts |>
  dplyr::group_by(LifeForm, channelTitle) |>
  dplyr::summarise(n_vids = sum(n_vids), .groups = "drop_last") |>
  dplyr::mutate(LifeForm = factor(LifeForm, levels = KEEP_LF)) |>
  dplyr::arrange(LifeForm, dplyr::desc(n_vids)) |>
  dplyr::group_modify(~{
    df <- .x
    tot <- sum(df$n_vids)
    nC  <- nrow(df)
    if (tot == 0 || nC == 0) {
      return(tibble::tibble(Slice = factor(c("Top1","Top10p","Rest"),
                                           levels = c("Top1","Top10p","Rest")),
                            share = c(0,0,0)))
    }
    top1_share <- df$n_vids[1] / tot
    k <- max(1, ceiling(0.10 * nC))
    top10_share <- sum(df$n_vids[seq_len(k)]) / tot
    top10_only  <- max(0, top10_share - top1_share)
    rest_share  <- max(0, 1 - top10_share)
    tibble::tibble(
      Slice = factor(c("Top1","Top10p","Rest"),
                     levels = c("Top1","Top10p","Rest")),
      share = c(top1_share, top10_only, rest_share)
    )
  }) |>
  dplyr::ungroup()

# ================== Minimal WAFFLE (B, if missing) ==========================
if (!exists("p_C3_waffle")) {
  df_waffle <- channel_diversity |>
    mutate(neff_ratio = ifelse(m_channels > 0, Neff_HHI / m_channels, NA_real_),
           LifeForm = factor(LifeForm, levels = KEEP_LF))
  p_C3_waffle <- ggplot(df_waffle, aes(x = neff_ratio, y = LifeForm)) +
    geom_col(width = 0.70) +
    scale_x_continuous(limits = c(0,1),
                       breaks = c(0.25, 0.5, 0.75, 1.0),
                       labels = scales::percent_format(accuracy = 1)) +
    scale_y_discrete(limits = LF_TOP_FIRST) +
    labs(x = "Neff / channels", y = NULL, title = NULL) +
    theme_inat(17) +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor   = element_blank(),
      axis.title.x       = element_text(size = 17),
      axis.text.y        = element_blank(),
      axis.ticks.y       = element_blank()
    )
}

# ================== REFRESH WAFFLE (B) ======================================
# Change #4: force B x-axis baseline to match the grey-ish style of A/C
AXISLINE_COL <- "grey70"

p_rel <- p_C3_waffle +
  labs(title = "How evenly is it shared?",
       x = "Neff / channels", y = NULL) +
  theme(
    plot.title    = element_text(face = "plain", size = 17),
    axis.title.x  = element_text(size = 17, margin = margin(t = 10)),
    axis.text.y   = element_blank(),
    axis.text.x   = element_text(size = 17, margin = margin(t = 6)),

    axis.ticks.y = element_line(colour = AXISLINE_COL),
    axis.ticks.x  = element_line(colour = AXISLINE_COL),

    axis.line.x   = element_line(colour = AXISLINE_COL),
    axis.line.y   = element_line(colour = AXISLINE_COL),  # <-- your requested fix

    plot.margin   = margin(8, 6, 10, 6)
  ) +
  scale_y_discrete(limits = LF_TOP_FIRST)

# Single export for B (no icons, no letter) ----------------------------------
save_plot_both(
  p_rel,
  file.path(OUT_DIR, "Figure3_B_rel_neff_ratio"),
  width = 150, height = 130, units = "mm"
)

# ================== Plot C base (default colors) ============================
vir_cols_default <- setNames(viridisLite::viridis(3, option = "C", direction = -1),
                             c("Top1", "Top10p", "Rest"))

p_top <- ggplot(stack_df, aes(x = share, y = LifeForm, fill = Slice)) +
  geom_col(width = 0.70, color = NA) +
  scale_x_continuous(
    limits = c(0, 1),
    breaks  = c(0.25, 0.50, 0.75, 1.00),
    labels  = scales::percent_format(accuracy = 1),
    expand  = expansion(mult = c(0, 0.02))
  ) +
  scale_fill_manual(values = vir_cols_default) +
  labs(title = "Who uploads the videos?", x = "Share", y = NULL) +
  theme_inat(17) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank(),
    legend.position    = "right",
    legend.title       = element_blank(),
    plot.title         = element_text(face = "plain", size = 17),
    axis.title.x       = element_text(size = 17, margin = margin(t = 10)),
    axis.text.y        = element_blank(),
    axis.text.x        = element_text(size = 17, margin = margin(t = 6)),
    axis.ticks.y       = element_blank(),
    axis.ticks.x       = element_line(),
    # smaller right margin so legend is closer to border
    plot.margin        = margin(8, 2, 10, 6)
  ) +
  scale_y_discrete(limits = LF_TOP_FIRST)

# --------------------------- ICONS (robust paths) ----------------------------
icon_filemap <- c(
  "Birds"  = "bird.png",
  "Herptiles"="herp.png",
  "Fishes" = "fish.png",
  "Insects"= "insect.png",
  "Crustaceans"="crustacean.png",
  "Non-arthropod invertebrates"="invert_nonarth_diversity.png",
  "Plants"     ="plant.png",
  "Bacteria, Viruses, Fungi"   ="bacteria.png"
)

icon_dir_candidates <- c(
  "fig_assets/icons",
  "fig_assets"
)

pick_icon_dir <- function(cands, probe = "bird.png") {
  for (d in cands) {
    if (dir.exists(d) && file.exists(file.path(d, probe))) return(d)
  }
  return(NA_character_)
}
ICON_DIR <- pick_icon_dir(icon_dir_candidates)
if (is.na(ICON_DIR)) {
  stop("Couldn't find icons. Tried: ", paste(icon_dir_candidates, collapse = ", "),
       "\nWorking directory: ", getwd(),
       "\nMake sure at least one icon (e.g., bird.png) is in fig_assets/ or fig_assets/icons/")
}
icon_paths <- file.path(ICON_DIR, icon_filemap[desired_lf_order])
names(icon_paths) <- desired_lf_order


# ======================= ICON RECOLOR HELPER (same as Fig 1-2) ======================
as_rgba <- function(img, light = 0.65,
                    tint = c(0.75, 0.80, 0.90)) {
  d <- dim(img)

  apply_tint <- function(g) {
    g <- light + (1 - light) * g
    list(
      r = g * tint[1],
      g = g * tint[2],
      b = g * tint[3]
    )
  }

  # Grayscale + alpha (H x W x 2)
  if (!is.null(d) && length(d) == 3 && d[3] == 2) {
    g <- img[,,1]
    a <- img[,,2]
    col <- apply_tint(g)

    out <- array(0, dim = c(d[1], d[2], 4))
    out[,,1] <- col$r
    out[,,2] <- col$g
    out[,,3] <- col$b
    out[,,4] <- a
    return(out)
  }

  # RGB (H x W x 3)
  if (!is.null(d) && length(d) == 3 && d[3] == 3) {
    col <- apply_tint(img)
    out <- array(1, dim = c(d[1], d[2], 4))
    out[,,1] <- col$r
    out[,,2] <- col$g
    out[,,3] <- col$b
    return(out)
  }

  # RGBA (H x W x 4)
  if (!is.null(d) && length(d) == 3 && d[3] == 4) {
    col <- apply_tint(img[,,1])
    img[,,1] <- col$r
    img[,,2] <- col$g
    img[,,3] <- col$b
    return(img)
  }

  # Grayscale matrix (H x W)
  if (!is.null(d) && length(d) == 2) {
    col <- apply_tint(img)
    out <- array(0, dim = c(d[1], d[2], 4))
    out[,,1] <- col$r
    out[,,2] <- col$g
    out[,,3] <- col$b
    out[,,4] <- 1
    return(out)
  }

  stop("Unsupported PNG format: dim = ", paste(d, collapse = " x "))
}

# ---- EDIT THESE to try different bluish-greys (same knobs as Fig 2) ----
ICON_LIGHT <- 0.65
ICON_TINT  <- c(0.55, 0.50, 0.60)   # R, G, B multipliers


# ================== ICON STRIPS (single vs panel) ===========================
# NOTE: assumes `icon_paths` is a named list: names = LifeForm, values = file paths.

# Single-plot icons (larger)
ICON_XMIN_SINGLE <- 0.30
ICON_XMAX_SINGLE <- 1.00
ICON_PAD_SINGLE  <- 0.80   # single plots - larger icons

icon_df_single <- tibble::tibble(LifeForm = factor(LF_TOP_FIRST, levels = LF_TOP_FIRST))

p_icons_single <- ggplot2::ggplot(icon_df_single) +
  ggplot2::geom_blank(ggplot2::aes(x = 0, y = LifeForm)) +
  ggplot2::theme_void(base_size = 17) +
  ggplot2::coord_cartesian(xlim = c(0, 1), clip = "off") +
  ggplot2::theme(plot.margin = ggplot2::margin(8, 2, 10, 10)) +
  ggplot2::scale_y_discrete(limits = LF_TOP_FIRST)

icon_ann_single <- lapply(seq_along(LF_TOP_FIRST), function(i){
  lf <- LF_TOP_FIRST[i]; fp <- icon_paths[[lf]]
  if (is.null(fp) || !file.exists(fp)) return(NULL)
  img <- png::readPNG(fp)
  img <- as_rgba(img, light = ICON_LIGHT, tint = ICON_TINT)
  g   <- grid::rasterGrob(img, interpolate = TRUE)
  ggplot2::annotation_custom(
    g,
    xmin = ICON_XMIN_SINGLE, xmax = ICON_XMAX_SINGLE,
    ymin = i - ICON_PAD_SINGLE, ymax = i + ICON_PAD_SINGLE
  )
})
icon_ann_single <- icon_ann_single[!vapply(icon_ann_single, is.null, logical(1))]
for (a in icon_ann_single) p_icons_single <- p_icons_single + a

# Panel icons (slightly smaller than singles, but larger than old version)
ICON_XMIN_PANEL <- 0.35
ICON_XMAX_PANEL <- 1.17
ICON_PAD_PANEL  <- 0.95   # panel - medium icon size

icon_df_panel <- tibble::tibble(LifeForm = factor(LF_TOP_FIRST, levels = LF_TOP_FIRST))

p_icons_panel <- ggplot2::ggplot(icon_df_panel) +
  ggplot2::geom_blank(ggplot2::aes(x = 0, y = LifeForm)) +
  ggplot2::theme_void(base_size = 17) +
  ggplot2::coord_cartesian(xlim = c(0, 1), clip = "off") +
  ggplot2::theme(plot.margin = ggplot2::margin(8, 2, 10, 10)) +
  ggplot2::scale_y_discrete(limits = LF_TOP_FIRST)

icon_ann_panel <- lapply(seq_along(LF_TOP_FIRST), function(i){
  lf <- LF_TOP_FIRST[i]; fp <- icon_paths[[lf]]
  if (is.null(fp) || !file.exists(fp)) return(NULL)
  img <- png::readPNG(fp)
  img <- as_rgba(img, light = ICON_LIGHT, tint = ICON_TINT)
  g   <- grid::rasterGrob(img, interpolate = TRUE)
  ggplot2::annotation_custom(
    g,
    xmin = ICON_XMIN_PANEL, xmax = ICON_XMAX_PANEL,
    ymin = i - ICON_PAD_PANEL, ymax = i + ICON_PAD_PANEL
  )
})
icon_ann_panel <- icon_ann_panel[!vapply(icon_ann_panel, is.null, logical(1))]
for (a in icon_ann_panel) p_icons_panel <- p_icons_panel + a

# Helper: combine icon strip (left) + one plot (right) for single exports
make_single_with_icons <- function(p, widths = c(0.18, 1)) {
  (p_icons_single | p) + patchwork::plot_layout(widths = widths)
}

# ================== PANEL without letters (default colors) ==================
panel_C_final <- p_icons_panel | p_abs_clean | p_rel | p_top
panel_C_final <- panel_C_final +
  patchwork::plot_layout(widths = c(0.18, 1, 1, 1)) &
  ggplot2::theme(plot.margin = grid::unit(c(6, 6, 6, 0), "pt"))

save_plot_both(
  panel_C_final,
  file.path(OUT_DIR, "Figure3_panel_icons-abs-rel-top_DEFAULT"),
  width = 435, height = 160, units = "mm"
)

# ================== LETTER TAG SETTINGS (Change #3) =========================
TAG_SIZE <- 22

# Move tags slightly UP and give extra top margin so they don't clip
TAG_POS  <- c(-0.02, 1.07)  # was ~1.03; push upward
TAG_MARG <- ggplot2::margin(22, 12, 12, 22)  # bigger top margin per-plot

# ================== TAGGED A / B (for panel) ================================
p_abs_tag <- p_abs_clean +
  ggplot2::labs(tag = "A)") +
  ggplot2::theme(
    plot.tag          = ggplot2::element_text(face = "plain", size = TAG_SIZE, hjust = 0),
    plot.tag.position = TAG_POS,
    plot.margin       = TAG_MARG
  )

p_rel_tag <- p_rel +
  ggplot2::labs(tag = "B)") +
  ggplot2::theme(
    plot.tag          = ggplot2::element_text(face = "plain", size = TAG_SIZE, hjust = 0),
    plot.tag.position = TAG_POS,
    plot.margin       = TAG_MARG
  )

        
# ================== PALETTE VARIANTS for C (and panel) ======================
suppressPackageStartupMessages({
  library(viridisLite)
  library(RColorBrewer)
})

.has_dichromat <- requireNamespace("dichromat", quietly = TRUE)

.alias_map <- c(
  "breweryellow-green-blue" = "YlGnBu",
  "yellow-green-blue"       = "YlGnBu",
  "yelloworangebrown"       = "YlOrBr",
  "yelloworangered"         = "YlOrRd",
  "publisher"               = "PuBu",
  "spectral"                = "Spectral",
  "redblue"                 = "RdBu",
  "redyellowgreen"          = "RdYlGn",
  "purplegreen"             = "PRGn",
  "pinkgreen"               = "PiYG",
  "purpleorange"            = "PuOr"
)

normalize_scheme <- function(x) {
  y <- tolower(x)
  if (y %in% names(.alias_map)) return(.alias_map[[y]])
  switch(y,
    viridis = "viridis", plasma = "plasma", magma = "magma", inferno = "inferno",
    cividis = "cividis", turbo  = "turbo",  mako   = "mako",   rocket  = "rocket",
    rainbow = "rainbow", heat   = "heat",
    x
  )
}

# Change #2: keep ONLY these schemes
schemes <- c("viridis", "goldrose", "tritanopia", "GnBu", "mako", "YlGnBu")

custom_schemes <- list(
  goldrose = c("#FFD166","#EF476F","#26547C"),
  tealgrey = c("#003f5c","#7a5195","#bc5090")
)

.pick3 <- function(cols) cols[round(seq(1, length(cols), length.out = 3))]

.long_gradient <- function(name, n = 256) {
  nm <- normalize_scheme(name)
  if (nm %in% c("viridis","plasma","magma","inferno","cividis","turbo","mako","rocket")) {
    return(viridisLite::viridis(n, option = nm))
  }
  if (nm == "rainbow") return(grDevices::rainbow(n))
  if (nm == "heat")    return(grDevices::heat.colors(n))
  if (nm %in% rownames(RColorBrewer::brewer.pal.info)) {
    maxn <- RColorBrewer::brewer.pal.info[nm, "maxcolors"]
    pal  <- RColorBrewer::brewer.pal(max(3, min(maxn, 9)), nm)
    return(grDevices::colorRampPalette(pal)(n))
  }
  viridisLite::viridis(n)
}

.cvd_transform <- function(cols, mode = c("protan","deutan","tritan")) {
  mode <- match.arg(mode)
  if (!.has_dichromat) return(cols)
  dichromat::dichromat(cols, type = switch(mode,
    protan = "protan", deutan = "deutan", tritan = "tritan"))
}

get_cols_named <- function(scheme) {
  sch <- normalize_scheme(scheme)
  if (sch %in% names(custom_schemes)) {
    return(setNames(custom_schemes[[sch]], c("Top1","Top10p","Rest")))
  }
  if (sch %in% c("protanopia","deuteranopia","tritanopia")) {
    src <- .long_gradient("viridis", 256)
    mode <- switch(sch,
      protanopia   = "protan",
      deuteranopia = "deutan",
      tritanopia   = "tritan"
    )
    adj  <- .cvd_transform(src, mode = mode)
    return(setNames(.pick3(adj), c("Top1","Top10p","Rest")))
  }
  cols_long <- .long_gradient(sch, 256)
  cols3     <- .pick3(cols_long)
  if (sch %in% rownames(RColorBrewer::brewer.pal.info)) {
    cols3 <- rev(cols3)
  }
  setNames(cols3, c("Top1","Top10p","Rest"))
}

build_p_top_with_palette <- function(cols_named) {
  ggplot(stack_df, aes(x = share, y = LifeForm, fill = Slice)) +
    geom_col(width = 0.70, color = NA) +
    scale_x_continuous(
      limits = c(0, 1),
      breaks = c(0.25, 0.50, 0.75, 1.00),
      labels = scales::percent_format(accuracy = 1),
      expand  = expansion(mult = c(0, 0.02))
    ) +
    scale_fill_manual(values = cols_named) +
    labs(title = "Who uploads the videos?", x = "Share", y = NULL) +
    theme_inat(17) +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor   = element_blank(),
      legend.position    = "right",
      legend.title       = element_blank(),
      legend.box.margin  = margin(0, 0, 0, 0),
      plot.title         = element_text(face = "plain", size = 17),
      axis.title.x       = element_text(size = 17, margin = margin(t = 10)),
      axis.text.y        = element_blank(),
      axis.text.x        = element_text(face = "plain", size = 17, margin = margin(t = 6)),
      axis.ticks.y       = element_blank(),
      axis.ticks.x       = element_line(),
      plot.margin        = margin(8, 2, 10, 6)
    ) +
    scale_y_discrete(limits = LF_TOP_FIRST)
}



# ---------------------------------------------------------------
# TAG-LESS COLOUR VARIANTS FOR THE FULL PANEL (A+B+C)
#   -> same layout as Figure3_panel_icons-abs-rel-top_DEFAULT
# ---------------------------------------------------------------

for (sch in schemes) {
  # 1) Get colours for this scheme
  cols_named    <- get_cols_named(sch)

  # 2) Build C-plot with this palette (no tag)
  p_top_variant <- build_p_top_with_palette(cols_named)

  # 3) Assemble tag-less panel: icons + A + B + C
  panel_nolett <- p_icons_panel | p_abs_clean | p_rel | p_top_variant
  panel_nolett <- panel_nolett +
    patchwork::plot_layout(widths = c(0.18, 1, 1, 1)) &
    ggplot2::theme(plot.margin = grid::unit(c(6, 6, 6, 0), "pt"))

  # 4) Save PNG + TIFF for this colour scheme
  save_plot_both(
    panel_nolett,
    file.path(
      OUT_DIR,
      sprintf("Figure3_panel_icons-abs-rel-top_%s_NOTAGS", sch)
    ),
    width  = 460,
    height = 160,
    units  = "mm"
  )
}
      
# -----------------------------------------------------------------
# SINGLE A, B, C DEFAULT WITH ICONS (PNG + TIFF, NO LETTER TAGS)
# -----------------------------------------------------------------
SINGLE_W_MM <- 160
SINGLE_H_MM <- 130
SINGLE_DPI  <- 300

# A) single with icons
p_A_single_core <- p_abs_clean +
  ggplot2::labs(tag = NULL) +
  ggplot2::theme(plot.tag = ggplot2::element_blank())

p_A_single_icons <- make_single_with_icons(p_A_single_core)

save_plot_png_tiff(
  p_A_single_icons,
  file.path(OUT_DIR, "Figure3_A_single_with_icons"),
  width  = SINGLE_W_MM,
  height = SINGLE_H_MM,
  dpi    = SINGLE_DPI
)

# B) single with icons
p_B_single_core <- p_rel +
  ggplot2::labs(tag = NULL) +
  ggplot2::theme(plot.tag = ggplot2::element_blank())

p_B_single_icons <- make_single_with_icons(p_B_single_core)

save_plot_png_tiff(
  p_B_single_icons,
  file.path(OUT_DIR, "Figure3_B_single_with_icons"),
  width  = SINGLE_W_MM,
  height = SINGLE_H_MM,
  dpi    = SINGLE_DPI
)

# C) default Who uploads the videos? single with icons
p_C_default_single_core <- p_top +
  ggplot2::labs(tag = NULL) +
  ggplot2::theme(plot.tag = ggplot2::element_blank())

p_C_default_single_icons <- make_single_with_icons(p_C_default_single_core)

save_plot_png_tiff(
  p_C_default_single_icons,
  file.path(OUT_DIR, "Figure3_C_single_with_icons_DEFAULT"),
  width  = SINGLE_W_MM,
  height = SINGLE_H_MM,
  dpi    = SINGLE_DPI
)

# ---------------------------------------------------------------------------
# ONLY EXPORT: FULL PANEL (icons + A + B + C) WITH LETTERS, for kept schemes
# ---------------------------------------------------------------------------
PANEL_W_MM <- 460
PANEL_H_MM <- 170

# Add extra top padding to the whole panel so big tags never clip (Change #3)
PANEL_MARGIN_PT <- grid::unit(c(26, 6, 6, 6), "pt")  # top, right, bottom, left

variant_plots <- list()

for (sch in schemes) {
  cols_named    <- get_cols_named(sch)
  p_top_variant <- build_p_top_with_palette(cols_named)

  # C) tagged
  p_top_tag <- p_top_variant +
    ggplot2::labs(tag = "C)") +
    ggplot2::theme(
      plot.tag          = ggplot2::element_text(face = "plain", size = TAG_SIZE, hjust = 0),
      plot.tag.position = TAG_POS,
      plot.margin       = TAG_MARG
    )

  panel_with_letters <- p_icons_panel | p_abs_tag | p_rel_tag | p_top_tag
  panel_with_letters <- panel_with_letters +
    patchwork::plot_layout(widths = c(0.18, 1, 1, 1)) &
    ggplot2::theme(plot.margin = PANEL_MARGIN_PT)

  # Change #1: export ONLY the WITH_LETTERS full panels
  save_plot_both(
    panel_with_letters,
    file.path(OUT_DIR, sprintf("Figure3_panel_icons-abs-rel-top_WITH_LETTERS_%s", sch)),
    width  = PANEL_W_MM,
    height = PANEL_H_MM,
    units  = "mm"
  )

  variant_plots[[sch]] <- list(
    p_top_tag = p_top_tag,
    panel     = panel_with_letters
  )
}

# ================= QA SUMMARY (for manuscript numbers) ======================
qa_summary <- channel_diversity %>%
  dplyr::mutate(
    neff_ratio = dplyr::if_else(m_channels > 0, Neff_HHI / m_channels, NA_real_)
  ) %>%
  dplyr::select(LifeForm, total_videos, m_channels, HHI, invHHI_norm,
                Neff_HHI, H, H_norm, Neff_H, H_vegan, Hnorm_vegan, NeffH_vegan, neff_ratio)

# ---- QA: identity checks used in Supplement (Table S9 statement) ------------
qa_id <- qa_summary %>%
  dplyr::mutate(
    Neff_check     = 1/HHI,
    invHHI_check   = dplyr::if_else(m_channels > 1, (1 - HHI) / (1 - 1/m_channels), 0),
    Hnorm_check    = dplyr::if_else(m_channels > 1, H / log(m_channels), 0),
    ok_Neff        = abs(Neff_HHI - Neff_check) < 1e-10,
    ok_invHHI      = abs(invHHI_norm - invHHI_check) < 1e-10,
    ok_Hnorm       = abs(H_norm - Hnorm_check) < 1e-10,
    ok_H_vegan     = abs(H - H_vegan) < 1e-10,
    ok_Hnorm_vegan = abs(H_norm - Hnorm_vegan) < 1e-10,
    ok_NeffH_vegan = abs(Neff_H - NeffH_vegan) < 1e-10
  ) %>%
  dplyr::select(LifeForm, ok_Neff, ok_invHHI, ok_Hnorm, ok_H_vegan, ok_Hnorm_vegan, ok_NeffH_vegan)

message("- QA: identity checks (must all be TRUE) -")
print(qa_id, n = Inf)

# ---- DIAGNOSTIC: full precision (for coauthor rounding concern) -------------
channel_diversity %>%
  dplyr::mutate(
    invHHI_6 = sprintf("%.6f", invHHI_norm),
    Neff_3   = sprintf("%.3f", Neff_HHI),
    HHI_6    = sprintf("%.6f", HHI),
    m        = m_channels
  ) %>%
  dplyr::arrange(invHHI_norm) %>%
  dplyr::select(LifeForm, m, HHI_6, invHHI_6, Neff_3) %>%
  print(n = Inf)

# ---- explicitly check which invHHInorm values collide after rounding --------
channel_diversity %>%
  dplyr::mutate(invHHI_round3 = round(invHHI_norm, 3)) %>%
  dplyr::count(invHHI_round3, sort = TRUE) %>%
  dplyr::filter(n > 1) %>%
  print(n = Inf)

channel_diversity %>%
  dplyr::mutate(invHHI_round3 = round(invHHI_norm, 3)) %>%
  dplyr::group_by(invHHI_round3) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  dplyr::ungroup() %>%
  dplyr::select(LifeForm, m_channels, HHI, invHHI_norm, Neff_HHI, invHHI_round3) %>%
  dplyr::arrange(invHHI_round3, LifeForm) %>%
  print(n = Inf)

# ---- show which Neff values collapse to the same " integer" ----------------
channel_diversity %>%
  dplyr::mutate(Neff_round0 = round(Neff_HHI, 0)) %>%
  dplyr::count(Neff_round0, sort = TRUE) %>%
  dplyr::filter(n > 1) %>%
  print(n = Inf)

channel_diversity %>%
  dplyr::mutate(Neff_round0 = round(Neff_HHI, 0)) %>%
  dplyr::group_by(Neff_round0) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  dplyr::ungroup() %>%
  dplyr::select(LifeForm, Neff_HHI, Neff_round0) %>%
  dplyr::arrange(Neff_round0, LifeForm) %>%
  print(n = Inf)

# ---- additional compact tie-report (optional) -------------------------------
channel_diversity %>%
  dplyr::mutate(
    invHHI_round3 = round(invHHI_norm, 3),
    invHHI_6      = round(invHHI_norm, 6),
    Neff_1        = round(Neff_HHI, 1)
  ) %>%
  dplyr::arrange(invHHI_round3, invHHI_6) %>%
  dplyr::select(LifeForm, m_channels, HHI, invHHI_round3, invHHI_6, Neff_1) %>%
  print(n = Inf)

# ---- persist QA outputs (useful for supplement / responses) -----------------
readr::write_csv(qa_summary, file.path(TAB_QA_OUT_DIR, "QA_channel_diversity_full_precision.csv"))
readr::write_csv(qa_id,      file.path(TAB_QA_OUT_DIR, "QA_identity_checks.csv"))

# ---- Existing QA from your script (kept) -----------------------------------
ext_invHHI <- qa_summary %>%
  dplyr::arrange(dplyr::desc(invHHI_norm)) %>%
  dplyr::slice_head(n = 1)

ext_Neff <- qa_summary %>%
  dplyr::arrange(dplyr::desc(Neff_HHI)) %>%
  dplyr::slice_head(n = 1)

ext_ratio <- qa_summary %>%
  dplyr::arrange(dplyr::desc(neff_ratio)) %>%
  dplyr::slice_head(n = 1)

top_shares <- stack_df %>%
  tidyr::pivot_wider(names_from = Slice, values_from = share) %>%
  dplyr::mutate(
    Top1   = round(Top1,   3),
    Top10p = round(Top10p, 3),
    Rest   = round(Rest,   3)
  )

range_top1  <- range(top_shares$Top1,   na.rm = TRUE)
range_top10 <- range(top_shares$Top10p, na.rm = TRUE)

message("- QA: HHI identity checks -")
qa <- lifeform_channel_counts %>%
  dplyr::group_by(LifeForm) %>%
  dplyr::summarise(HHI_check = {
    p <- n_vids / sum(n_vids); sum(p^2)
  }, .groups = "drop") %>%
  dplyr::left_join(channel_diversity %>% dplyr::select(LifeForm, HHI), by = "LifeForm") %>%
  dplyr::mutate(ok = abs(HHI_check - HHI) < 1e-10)
print(qa)

message("\n- QA: extremes -")
print(ext_invHHI)
print(ext_Neff)
print(ext_ratio)

message("\n- QA: ranges -")
message(sprintf("Top1 share range: %.2f-%.2f", range_top1[1], range_top1[2]))
message(sprintf("Top10p share range: %.2f-%.2f", range_top10[1], range_top10[2]))


# =============================================================================
# MERGED TABLE: new Supplementary Table S9 (replaces Table 2 + old S9)
#   - invHHI_norm rounded to 5 decimals (to avoid apparent "ties")
#   - other rounding kept as in your current exports
# =============================================================================

# ---- formatting helpers (reuse yours, but ensure present) -------------------
if (!exists("fmt_mean_sd")) {
  fmt_mean_sd <- function(m, s) {
    ok <- is.finite(m) & is.finite(s)
    out <- rep("-", length(m))
    out[ok] <- sprintf("%.1f +/- %.1f", m[ok], s[ok])
    out
  }
}

# ---- build "Table 2-like" fields at lifeform level --------------------------
t2_like <- labelled_summary_lifeform %>%
  dplyr::transmute(
    LifeForm = as.character(.data$LifeForm),
    `Species found (%)` = round(.data$`Found of Searched (%)`, 1),
    `Videos/species (mean+/-SD)`   = fmt_mean_sd(.data$mean_videos,   .data$sd_videos),
    `Channels/species (mean+/-SD)` = fmt_mean_sd(.data$mean_channels, .data$sd_channels),
    `Total videos`   = as.integer(.data$total_videos),
    `Channels (m)`   = as.integer(.data$m_channels)   # from channel_diversity joined in labelled_summary_lifeform
  )

# ---- build "S9-like" diversity diagnostics (with requested precision) -------
s9_like <- channel_diversity %>%
  dplyr::transmute(
    LifeForm = as.character(.data$LifeForm),
    HHI         = round(.data$HHI, 3),
    invHHI_norm = round(.data$invHHI_norm, 5),   # <-- requested: 5 decimals
    H           = round(.data$H, 3),
    H_norm      = round(.data$H_norm, 3),
    `Neff (1/HHI)`   = round(.data$Neff_HHI, 1),
    `Neff (exp(H))`  = round(.data$Neff_H,   1)
  )

# ---- merge and order as in paper (your desired_lf_order) --------------------
merged_S9 <- t2_like %>%
  dplyr::left_join(s9_like, by = "LifeForm") %>%
  dplyr::mutate(LifeForm = factor(LifeForm, levels = desired_lf_order)) %>%
  dplyr::arrange(LifeForm) %>%
  dplyr::rename(`Taxonomic group` = LifeForm) %>%
  dplyr::select(
    `Taxonomic group`,
    `Species found (%)`,
    `Videos/species (mean+/-SD)`,
    `Channels/species (mean+/-SD)`,
    `Total videos`,
    `Channels (m)`,
    HHI,
    invHHI_norm,
    H,
    H_norm,
    `Neff (1/HHI)`,
    `Neff (exp(H))`
  )


######### ORDER BY THREE DIFFERENT INDICES ############  choose one!!!!!!!

# ---- merge and order (recommended) -----------------------------------------
merged_S9 <- t2_like %>%
  dplyr::left_join(s9_like, by = "LifeForm") %>%
  dplyr::mutate(
    LifeForm = as.character(LifeForm),
    invHHI_norm_num = as.numeric(invHHI_norm)   # ensure sortable
  ) %>%
  dplyr::arrange(dplyr::desc(invHHI_norm_num), LifeForm) %>%  # <-- ORDER HERE   
  dplyr::select(-invHHI_norm_num) %>%
  dplyr::rename(`Taxonomic group` = LifeForm)


merged_S9 <- t2_like %>%
  dplyr::left_join(s9_like, by = "LifeForm") %>%
  dplyr::mutate(
    LifeForm = as.character(LifeForm),
    H_norm_num = as.numeric(H_norm)
  ) %>%
  dplyr::arrange(dplyr::desc(H_norm_num), LifeForm) %>%
  dplyr::select(-H_norm_num) %>%
  dplyr::rename(`Taxonomic group` = LifeForm)


merged_S9 <- t2_like %>%
  dplyr::left_join(s9_like, by = "LifeForm") %>%
  dplyr::mutate(
    LifeForm = as.character(LifeForm),
    invHHI_num = as.numeric(invHHI_norm),
    Hnorm_num  = as.numeric(H_norm)
  ) %>%
  dplyr::arrange(dplyr::desc(invHHI_num), dplyr::desc(Hnorm_num), LifeForm) %>%
  dplyr::select(-invHHI_num, -Hnorm_num) %>%
  dplyr::rename(`Taxonomic group` = LifeForm)



# ---- (optional) add Total row (kept from Table 2 logic; diagnostics omitted) -
Searched_total        <- sum(denom_by_lifeform$Searched, na.rm = TRUE)
Found_species_total   <- dplyr::n_distinct(labelled_stats_species$TaxonName)
Found_pct_total       <- round(100 * Found_species_total / Searched_total, 1)

overall_mean_videos   <- mean(labelled_stats_species$n_videos,   na.rm = TRUE)
overall_sd_videos     <- sd(labelled_stats_species$n_videos,     na.rm = TRUE)
overall_mean_channels <- mean(labelled_stats_species$n_channels, na.rm = TRUE)
overall_sd_channels   <- sd(labelled_stats_species$n_channels,   na.rm = TRUE)

Total_videos_all          <- nrow(lab_df)
Total_unique_channels_all <- dplyr::n_distinct(lab_df$channelTitle, na.rm = TRUE)

total_row_S9 <- dplyr::tibble(
  `Taxonomic group`              = "Total",
  `Species found (%)`            = Found_pct_total,
  `Videos/species (mean+/-SD)`     = fmt_mean_sd(overall_mean_videos,   overall_sd_videos),
  `Channels/species (mean+/-SD)`   = fmt_mean_sd(overall_mean_channels, overall_sd_channels),
  `Total videos`                 = as.integer(Total_videos_all),
  `Channels (m)`                 = as.integer(Total_unique_channels_all),
  HHI         = NA_real_,
  invHHI_norm = NA_real_,
  H           = NA_real_,
  H_norm      = NA_real_,
  `Neff (1/HHI)`  = NA_real_,
  `Neff (exp(H))` = NA_real_
)

merged_S9_with_total <- dplyr::bind_rows(merged_S9, total_row_S9)

# ---- write outputs (CSV + DOCX + MD) ---------------------------------------
OUT_S9_CSV <- file.path(TAB_SUPP_OUT_DIR, "TableS9_MERGED_channel_diversity.csv")
OUT_S9_DOCX <- file.path(TAB_SUPP_OUT_DIR, "TableS9_MERGED_channel_diversity.docx")
OUT_S9_MD <- file.path(TAB_SUPP_OUT_DIR, "TableS9_MERGED_channel_diversity.md")

readr::write_csv(merged_S9_with_total, OUT_S9_CSV)

ft_S9 <- flextable::flextable(merged_S9_with_total)
flextable::save_as_docx(ft_S9, path = OUT_S9_DOCX)

# Minimal markdown writer (no extra deps)
md_lines <- c(
  paste0("| ", paste(names(merged_S9_with_total), collapse = " | "), " |"),
  paste0("|", paste(rep("---", ncol(merged_S9_with_total)), collapse = "|"), "|")
)
for (i in seq_len(nrow(merged_S9_with_total))) {
  row <- merged_S9_with_total[i, , drop = FALSE]
  vals <- vapply(row, function(x) {
    if (is.numeric(x)) {
      if (is.na(x)) return("")
      # keep as printed by R default for our rounded numeric columns
      return(as.character(x))
    }
    if (is.na(x)) return("")
    as.character(x)
  }, character(1))
  md_lines <- c(md_lines, paste0("| ", paste(vals, collapse = " | "), " |"))
}
writeLines(md_lines, con = OUT_S9_MD)

message("Saved merged S9 as: ", OUT_S9_CSV)
message("Saved merged S9 as: ", OUT_S9_DOCX)
message("Saved merged S9 as: ", OUT_S9_MD)


# ============================================================
# FINAL TABLES: Table 2 (descriptive) + Table S9 (metrics)
#   - Recomputed from underlying data (lab_df)
#   - Saved to:
#     all_dataset_RAW_FLAGGED_IS_IBERIAN_outputs_NEW_channel_diversity
# ============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tibble)
})

# ------------------------------------------------------------
# OUTPUT DIRECTORY (requested)
# ------------------------------------------------------------
OUT_DIR <- FIG_MAIN_DIR
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# ------------------------------------------------------------
# REQUIRED OBJECTS (must already exist upstream)
# ------------------------------------------------------------
# lab_df              : filtered Iberian dataset
# denom_by_lifeform   : LifeForm + Searched
# KEEP_LF             : vector of life-form levels
#
# REQUIRED COLUMNS in lab_df:
#   TaxonName, LifeForm, channelTitle

stopifnot(exists("lab_df"))
stopifnot(all(c("TaxonName","LifeForm","channelTitle") %in% names(lab_df)))
stopifnot(exists("denom_by_lifeform"))
stopifnot(all(c("LifeForm","Searched") %in% names(denom_by_lifeform)))
stopifnot(exists("KEEP_LF"))

# Enforce LifeForm levels
lab_df <- lab_df %>%
  mutate(
    LifeForm = as.character(LifeForm),
    LifeForm = ifelse(LifeForm %in% KEEP_LF, LifeForm, NA_character_),
    LifeForm = factor(LifeForm, levels = KEEP_LF)
  ) %>%
  filter(!is.na(LifeForm))

denom_by_lifeform <- denom_by_lifeform %>%
  mutate(
    LifeForm = as.character(LifeForm),
    LifeForm = ifelse(LifeForm %in% KEEP_LF, LifeForm, NA_character_),
    LifeForm = factor(LifeForm, levels = KEEP_LF)
  ) %>%
  filter(!is.na(LifeForm))

# ============================================================
# 1) TABLE 2 - DESCRIPTIVE ONLY
# ============================================================

stats_species <- lab_df %>%
  group_by(TaxonName, LifeForm) %>%
  summarise(
    n_videos   = n(),
    n_channels = n_distinct(channelTitle, na.rm = TRUE),
    .groups = "drop"
  )

totals_lifeform <- lab_df %>%
  group_by(LifeForm) %>%
  summarise(
    total_videos   = n(),
    total_channels = n_distinct(channelTitle, na.rm = TRUE),
    .groups = "drop"
  )

fmt_mean_sd <- function(m, s) {
  ifelse(is.finite(m) & is.finite(s),
         sprintf("%.1f +/- %.1f", m, s),
         "-")
}

Table2_final <- stats_species %>%
  group_by(LifeForm) %>%
  summarise(
    Found_species = n_distinct(TaxonName),
    mean_videos   = mean(n_videos),
    sd_videos     = sd(n_videos),
    mean_channels = mean(n_channels),
    sd_channels   = sd(n_channels),
    .groups = "drop"
  ) %>%
  left_join(denom_by_lifeform, by = "LifeForm") %>%
  left_join(totals_lifeform,   by = "LifeForm") %>%
  mutate(
    `Species found (%)`            = round(100 * Found_species / Searched, 1),
    `Videos / species (mean+/-SD)`   = fmt_mean_sd(mean_videos,   sd_videos),
    `Channels / species (mean+/-SD)` = fmt_mean_sd(mean_channels, sd_channels)
  ) %>%
  transmute(
    `Taxonomic group`              = as.character(LifeForm),
    `Species found (%)`,
    `Videos / species (mean+/-SD)`,
    `Channels / species (mean+/-SD)`,
    `Total videos`                 = total_videos,
    `Channels`                     = total_channels
  )

Table2_total <- tibble(
  `Taxonomic group`              = "Total",
  `Species found (%)`            = round(
                                    100 * n_distinct(stats_species$TaxonName) /
                                    sum(denom_by_lifeform$Searched), 1),
  `Videos / species (mean+/-SD)`   = fmt_mean_sd(mean(stats_species$n_videos),
                                               sd(stats_species$n_videos)),
  `Channels / species (mean+/-SD)` = fmt_mean_sd(mean(stats_species$n_channels),
                                               sd(stats_species$n_channels)),
  `Total videos`                 = nrow(lab_df),
  `Channels`                     = n_distinct(lab_df$channelTitle)
)

Table2_final <- bind_rows(Table2_final, Table2_total)

# SAVE TABLE 2
write_csv(
  Table2_final,
  file.path(TAB_MAIN_OUT_DIR, "Table2_FINAL_descriptive_only.csv")
)

# ============================================================
# 2) TABLE S9 - CHANNEL DIVERSITY METRICS
# ============================================================

lifeform_channel_counts <- lab_df %>%
  group_by(LifeForm, channelTitle) %>%
  summarise(n_vids = n(), .groups = "drop")

channel_metrics <- lifeform_channel_counts %>%
  group_by(LifeForm) %>%
  summarise(
    m_channels = n_distinct(channelTitle),
    HHI        = { p <- n_vids / sum(n_vids); sum(p^2) },
    invHHI_norm= if_else(m_channels > 1,
                         (1 - HHI) / (1 - 1/m_channels), 0),
    Neff_HHI   = 1 / HHI,
    H          = { p <- n_vids / sum(n_vids); -sum(p * log(p)) },
    H_norm     = if_else(m_channels > 1, H / log(m_channels), 0),
    Neff_H     = exp(H),
    .groups = "drop"
  )

TableS9_final <- channel_metrics %>%
  mutate(
    HHI         = round(HHI, 3),
    invHHI_norm = round(invHHI_norm, 5),
    H           = round(H, 3),
    H_norm      = round(H_norm, 3),
    Neff_HHI    = round(Neff_HHI, 1),
    Neff_H      = round(Neff_H, 1)
  ) %>%
  arrange(desc(invHHI_norm), as.character(LifeForm)) %>%   # Option A ordering
  transmute(
    `Taxonomic group`   = as.character(LifeForm),
    `HHI`,
    `invHHInorm (0-1)`  = invHHI_norm,
    `H`,
    `Hnorm (0-1)`       = H_norm,
    `Neff (1/HHI)`      = Neff_HHI,
    `Neff (exp(H))`     = Neff_H
  )

TableS9_final <- bind_rows(
  TableS9_final,
  tibble(
    `Taxonomic group`   = "Total",
    `HHI`               = NA_real_,
    `invHHInorm (0-1)`  = NA_real_,
    `H`                 = NA_real_,
    `Hnorm (0-1)`       = NA_real_,
    `Neff (1/HHI)`      = NA_real_,
    `Neff (exp(H))`     = NA_real_
  )
)

# SAVE TABLE S9
write_csv(
  TableS9_final,
  file.path(TAB_SUPP_OUT_DIR, "TableS9_FINAL_channel_diversity_metrics.csv")
)

# ------------------------------------------------------------
# DONE
# ------------------------------------------------------------

# ============================================================
# Figure 3 - SINGLE plot C ONLY (vertical) with ICONS ON X-AXIS
#   - Extracts ONLY plot C (Who uploads the videos?)
#   - Rotates to vertical: LifeForm on x-axis, Share on y-axis
#   - Icons moved here (from plot A): icons appear on the x-axis
#   - Assumes these already exist upstream in your workflow:
#       stack_df, KEEP_LF, desired_lf_order, LF_TOP_FIRST (optional),
#       theme_inat(), save_plot_png_tiff() or save_plot_both(),
#       as_rgba(), ICON_LIGHT, ICON_TINT, icon_filemap, icon_dir_candidates
# ============================================================

# --------------------------- ICONS (robust paths) ----------------------------
icon_filemap <- c(
  "Birds"  = "bird.png",
  "Herptiles"="herp.png",
  "Fishes" = "fish.png",
  "Insects"= "insect.png",
  "Crustaceans"="crustacean.png",
  "Non-arthropod invertebrates"="invert_nonarth_diversity.png",
  "Plants"     ="plant.png",
  "Bacteria, Viruses, Fungi"   ="bacteria.png"
)

icon_dir_candidates <- c(
  "fig_assets/icons",
  "fig_assets"
)

pick_icon_dir <- function(cands, probe = "bird.png") {
  for (d in cands) {
    if (dir.exists(d) && file.exists(file.path(d, probe))) return(d)
  }
  return(NA_character_)
}
ICON_DIR <- pick_icon_dir(icon_dir_candidates)
if (is.na(ICON_DIR)) {
  stop("Couldn't find icons. Tried: ", paste(icon_dir_candidates, collapse = ", "),
       "\nWorking directory: ", getwd(),
       "\nMake sure at least one icon (e.g., bird.png) is in fig_assets/ or fig_assets/icons/")
}

icon_paths <- file.path(ICON_DIR, icon_filemap[desired_lf_order])
names(icon_paths) <- desired_lf_order


# ============================================================
# 1) Plot C (VERTICAL): stacked shares by LifeForm
# ============================================================
vir_cols_default <- setNames(
  viridisLite::viridis(3, option = "C", direction = -1),
  c("Top1", "Top10p", "Rest")
)

# Keep the same lifeform ordering you use everywhere:
#   - x axis uses KEEP_LF (Birds..Bacteria) so icons align logically left->right
# ============================================================
# Figure 3 - SINGLE plot C ONLY (vertical)
#   - No y-axis title
#   - No y-axis tick labels
#   - No legend
#   - Icons on x-axis
#   - Colour variants identical to full Figure 3
# ============================================================

# Base data (same ordering as main figure)
stack_df_C <- stack_df |>
  dplyr::mutate(
    LifeForm = factor(as.character(LifeForm), levels = KEEP_LF),
    Slice    = factor(Slice, levels = c("Top1","Top10p","Rest"))
  )

# ------------------------------------------------------------
# Function to build SINGLE C plot for a given palette
# ------------------------------------------------------------
build_p_C_vertical <- function(cols_named) {

  p <- ggplot2::ggplot(
    stack_df_C,
    ggplot2::aes(x = LifeForm, y = share, fill = Slice)
  ) +
    ggplot2::geom_col(width = 0.72, colour = NA) +
    ggplot2::scale_y_continuous(
      limits = c(0, 1),
      expand = ggplot2::expansion(mult = c(0, 0.02))
    ) +
    ggplot2::scale_fill_manual(values = cols_named) +
    ggplot2::labs(
      title = NULL,
      x = NULL,
      y = NULL
    ) +
    theme_inat(17) +
    ggplot2::theme(
      # remove legend
      legend.position    = "none",

      # remove y axis completely
      axis.title.y       = ggplot2::element_blank(),
      axis.text.y        = ggplot2::element_blank(),
      axis.ticks.y       = ggplot2::element_blank(),

      # x-axis text removed (icons replace labels)
      axis.text.x        = ggplot2::element_blank(),
      axis.ticks.x       = ggplot2::element_blank(),

      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor   = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),

      plot.title         = ggplot2::element_text(face = "plain", size = 17),
      plot.margin        = ggplot2::margin(10, 8, 28, 8) # space for icons
    )

  # ----------------------------------------------------------
  # Add ICONS ON X-AXIS
  # ----------------------------------------------------------
  ICON_YMIN <- -0.12
  ICON_YMAX <- -0.02

  for (i in seq_along(KEEP_LF)) {
    lf <- KEEP_LF[i]
    fp <- icon_paths[[lf]]
    if (is.null(fp) || !file.exists(fp)) next

    img <- png::readPNG(fp)
    img <- as_rgba(img, light = ICON_LIGHT, tint = ICON_TINT)
    g   <- grid::rasterGrob(img, interpolate = TRUE)

    p <- p +
      ggplot2::annotation_custom(
        g,
        xmin = i - 0.38, xmax = i + 0.38,
        ymin = ICON_YMIN, ymax = ICON_YMAX
      )
  }

  p + ggplot2::coord_cartesian(clip = "off")
}

# ============================================================
# EXPORT: SAME COLOUR VARIANTS AS FULL FIGURE
# ============================================================

SINGLE_W_MM <- 160
SINGLE_H_MM <- 130

for (sch in schemes) {

  cols_named <- get_cols_named(sch)
  p_C_var    <- build_p_C_vertical(cols_named)

  save_plot_png_tiff(
    p_C_var,
    file.path(
      OUT_DIR,
      sprintf("Figure3_C_single_VERTICAL_icons_%s", sch)
    ),
    width  = SINGLE_W_MM,
    height = SINGLE_H_MM,
    dpi    = 300
  )
}






# ---- FINAL DIRECT EXPORT NAME ----------------------------------------------
for (ext in c(".png", ".tiff")) {
  src <- file.path(FIG_MAIN_DIR, paste0("Figure3_panel_icons-abs-rel-top_YlGnBu_NOTAGS", ext))
  dst <- file.path(FIG_MAIN_DIR, paste0("Figure_3", ext))
  if (file.exists(src)) file.rename(src, dst)
}
# remove other Figure3 variants in main folder
keep <- file.path(FIG_MAIN_DIR, c("Figure_1.png","Figure_1.tiff","Figure_2.png","Figure_2.tiff",
                                  "Figure_3.png","Figure_3.tiff"))
unlink(setdiff(list.files(FIG_MAIN_DIR, pattern = "^Figure3|^Figure_3_", full.names = TRUE), keep), force = TRUE)
