# ============================================================
# 17_validation_summary_figures.R
# Note: uses explicit dplyr::select() to avoid conflicts with other packages.
# Validation figures for the YouTube/NNS Iberian workflow
#
# Purpose
#   Generate paper-ready figures from the validation outputs created by
#   scripts/15_validation_audits.R. The script works with either real returned
#   reviewer files processed by script 15, or with the placeholder/example
#   completed files included for testing.
#
# Outputs
#   outputs/figures/supplement/Figure_S9.png/.tiff
#   outputs/validation/tables/validation_figure_index.csv
#
# Important
#   Figures made from dummy/example files are for workflow testing only. Replace
#   the completed validation files with the real reviewer returns before using
#   the values in the manuscript or Supplementary Material.
# ============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(ggplot2)
  library(cowplot)
})

if (!exists("PROJECT_ROOT", inherits = FALSE)) PROJECT_ROOT <- getwd()
VALIDATION_DIR <- file.path(PROJECT_ROOT, "outputs", "validation")
TABLE_DIR <- file.path(VALIDATION_DIR, "tables")
COMPLETED_DIR <- file.path(VALIDATION_DIR, "completed")
FIG_VALIDATION_DIR <- file.path(PROJECT_ROOT, "outputs", "figures", "supplement")
if (!dir.exists(TABLE_DIR)) dir.create(TABLE_DIR, recursive = TRUE, showWarnings = FALSE)
if (!dir.exists(FIG_VALIDATION_DIR)) dir.create(FIG_VALIDATION_DIR, recursive = TRUE, showWarnings = FALSE)

# Note: older workflow versions wrote these figures to
# outputs/figures/validation/ with longer file names. This version writes them
# directly to outputs/figures/supplement/ using the final Supplementary Figure
# numbers only. It does not delete old files automatically.

read_csv_if_exists <- function(path) {
  if (!file.exists(path)) return(NULL)
  readr::read_csv(path, show_col_types = FALSE)
}

format_pct <- function(x, digits = 1) {
  ifelse(is.na(x), "", paste0(round(100 * x, digits), "%"))
}

format_num <- function(x, digits = 2) {
  ifelse(is.na(x), "", as.character(round(x, digits)))
}


# Print-friendly, colour-blind-friendly palette used for validation figures.
tol_muted <- c(
  "#332288", "#88CCEE", "#44AA99", "#117733",
  "#999933", "#DDCC77", "#CC6677", "#882255"
)

pick_tol_muted <- function(n) {
  if (n <= 1) return(tol_muted[1])
  if (n == 2) return(c(tol_muted[1], tol_muted[7]))
  if (n == 3) return(c(tol_muted[1], tol_muted[3], tol_muted[7]))
  if (n == 4) return(c(tol_muted[1], tol_muted[2], tol_muted[3], tol_muted[7]))
  tol_muted[seq_len(min(n, length(tol_muted)))]
}


save_validation_plot <- function(plot, file_base, width = 7, height = 5, dpi = 300) {
  png_path <- file.path(FIG_VALIDATION_DIR, paste0(file_base, ".png"))
  tiff_path <- file.path(FIG_VALIDATION_DIR, paste0(file_base, ".tiff"))
  ggplot2::ggsave(png_path, plot = plot, width = width, height = height, dpi = dpi)
  ggplot2::ggsave(tiff_path, plot = plot, width = width, height = height, dpi = dpi, compression = "lzw")
  tibble::tibble(figure = file_base, png = png_path, tiff = tiff_path)
}

# A small internal theme kept independent from manuscript figure themes so this
# script can run even if sourced outside the main plotting workflow.
theme_validation <- function(base_size = 12) {
  ggplot2::theme_light(base_size = base_size) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      plot.title = ggplot2::element_blank(),
      axis.title = ggplot2::element_text(face = "plain", size = base_size + 1),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 10)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 10)),
      axis.text = ggplot2::element_text(size = base_size),
      legend.title = ggplot2::element_text(size = base_size),
      legend.text = ggplot2::element_text(size = base_size - 1),
      legend.position = "right",
      plot.margin = ggplot2::margin(8, 12, 8, 8)
    )
}

figure_index <- list()

# ============================================================
# A) LABEL / Iberia-relevance validation figures
# ============================================================
label_confusion <- read_csv_if_exists(file.path(TABLE_DIR, "LABEL_iberian_relevance_validation_confusion.csv"))
label_metrics <- read_csv_if_exists(file.path(TABLE_DIR, "LABEL_iberian_relevance_validation_metrics.csv"))
label_agreement <- read_csv_if_exists(file.path(TABLE_DIR, "LABEL_iberian_relevance_validation_interrater_agreement.csv"))

# Fallback if script 15 has not yet written the summary table but the consensus
# file is present.
if (is.null(label_confusion)) {
  label_consensus_path <- file.path(COMPLETED_DIR, "LABEL_iberian_relevance_validation_completed_consensus.csv")
  label_consensus <- read_csv_if_exists(label_consensus_path)
  if (!is.null(label_consensus)) {
    decision_col <- dplyr::case_when(
      "validator2_is_iberian" %in% names(label_consensus) ~ "validator2_is_iberian",
      "reviewer2_is_iberian" %in% names(label_consensus) ~ "reviewer2_is_iberian",
      ".decision_consensus" %in% names(label_consensus) ~ ".decision_consensus",
      TRUE ~ NA_character_
    )
    if (!is.na(decision_col)) {
      label_confusion <- label_consensus %>%
        mutate(
          auto = "Retained in LABEL",
          decision_raw = tolower(trimws(as.character(.data[[decision_col]]))),
          validator = dplyr::case_when(
            stringr::str_detect(.data$decision_raw, "uncertain|unsure|unknown|doubt") ~ "Uncertain",
            .data$decision_raw %in% c("true", "t", "yes", "1", "iberian", "relevant", "retain") ~ "Retain/relevant",
            .data$decision_raw %in% c("false", "f", "no", "0", "non-iberian", "not relevant", "exclude") ~ "Exclude/not relevant",
            TRUE ~ "Uncertain"
          )
        ) %>%
        count(.data$auto, .data$validator, name = "n")
      readr::write_csv(label_confusion, file.path(TABLE_DIR, "LABEL_iberian_relevance_validation_confusion.csv"), na = "")
    }
  }
}

if (!is.null(label_confusion) && nrow(label_confusion) > 0) {
  label_outcomes <- label_confusion %>%
    group_by(.data$validator) %>%
    summarise(n = sum(.data$n, na.rm = TRUE), .groups = "drop") %>%
    mutate(
      validator = factor(.data$validator,
                         levels = c("Retain/relevant", "Uncertain", "Exclude/not relevant")),
      prop = .data$n / sum(.data$n, na.rm = TRUE),
      label = paste0(.data$n, "\n", format_pct(.data$prop))
    )

  p_label_outcomes <- ggplot(label_outcomes, aes(x = n, y = validator, fill = validator)) +
    geom_col(width = 0.70, show.legend = FALSE, colour = "grey25", linewidth = 0.20) +
    scale_fill_manual(values = setNames(pick_tol_muted(nlevels(label_outcomes$validator)), levels(label_outcomes$validator))) +
    geom_text(aes(label = label), hjust = -0.08, size = 3.2) +
    coord_cartesian(xlim = c(0, max(label_outcomes$n, na.rm = TRUE) * 1.18), clip = "off") +
    labs(
      title = NULL,
      x = "Number of validation records",
      y = NULL
    ) +
    theme_validation() +
    theme(plot.margin = margin(8, 18, 8, 8))

  p_panel_label_outcomes <- p_label_outcomes
}

if (!is.null(label_metrics) && nrow(label_metrics) > 0) {
  label_metrics_long <- label_metrics %>%
    transmute(
      `Auto-label agreement` = .data$agreement,
      `False-positive rate` = .data$false_positive_rate,
      `Uncertainty rate` = .data$uncertainty_rate,
      `Inter-reviewer agreement` = dplyr::coalesce(.data$intervalidator_pairwise_agreement, NA_real_),
      `Fleiss' kappa` = dplyr::coalesce(.data$intervalidator_fleiss_kappa, NA_real_)
    ) %>%
    pivot_longer(cols = everything(), names_to = "metric", values_to = "value") %>%
    filter(!is.na(.data$value)) %>%
    mutate(
      metric = factor(.data$metric, levels = rev(c(
        "Auto-label agreement", "False-positive rate", "Uncertainty rate",
        "Inter-reviewer agreement", "Fleiss' kappa"
      ))),
      label = ifelse(stringr::str_detect(as.character(.data$metric), "rate|agreement"),
                     format_pct(.data$value), format_num(.data$value))
    )

  if (nrow(label_metrics_long) > 0) {
    p_label_metrics <- ggplot(label_metrics_long, aes(x = metric, y = value, fill = metric)) +
      geom_col(width = 0.70, colour = "grey25", linewidth = 0.20, show.legend = FALSE) +
      scale_fill_manual(values = setNames(pick_tol_muted(nlevels(label_metrics_long$metric)), levels(label_metrics_long$metric))) +
      geom_text(aes(label = label), hjust = -0.08, size = 3.2) +
      coord_flip(ylim = c(min(0, min(label_metrics_long$value, na.rm = TRUE)), 1.05)) +
      labs(
        title = NULL,
        x = NULL,
        y = "Metric value"
      ) +
      theme_validation()

    p_panel_label_metrics <- p_label_metrics
  }
}

# ============================================================
# B) Keyword/thematic classifier validation figures
# ============================================================
keyword_metrics <- read_csv_if_exists(file.path(TABLE_DIR, "keyword_validation_category_metrics.csv"))
keyword_confusion <- read_csv_if_exists(file.path(TABLE_DIR, "keyword_validation_confusion_matrix_long.csv"))

if (!is.null(keyword_metrics) && nrow(keyword_metrics) > 0) {
  keyword_metrics_long <- keyword_metrics %>%
    dplyr::select(category, precision, recall, f1) %>%
    pivot_longer(cols = c(precision, recall, f1),
                 names_to = "metric", values_to = "value") %>%
    mutate(
      category = factor(.data$category, levels = c("Invasion", "Detection", "eCommerce", "Threat")),
      metric = recode(.data$metric, precision = "Precision", recall = "Recall", f1 = "F1"),
      metric = factor(.data$metric, levels = c("Precision", "Recall", "F1")),
      label = format_pct(.data$value)
    )

  p_keyword_metrics <- ggplot(keyword_metrics_long, aes(x = value, y = category, fill = metric)) +
    geom_col(position = position_dodge(width = 0.72), width = 0.65, colour = "grey25", linewidth = 0.20) +
    scale_fill_manual(values = setNames(pick_tol_muted(nlevels(keyword_metrics_long$metric)), levels(keyword_metrics_long$metric))) +
    geom_text(aes(label = label), position = position_dodge(width = 0.72),
              hjust = -0.12, size = 2.8) +
    coord_cartesian(xlim = c(0, 1.08), clip = "off") +
    labs(
      title = NULL,
      x = "Metric value",
      y = NULL,
      fill = "Metric"
    ) +
    theme_validation() +
    theme(plot.margin = margin(8, 18, 8, 8))

  p_panel_keyword_metrics <- p_keyword_metrics
}

if (!is.null(keyword_confusion) && nrow(keyword_confusion) > 0) {
  category_levels <- c("Invasion", "Detection", "eCommerce", "Threat", "None", "Ambiguous")
  keyword_confusion_plot <- keyword_confusion %>%
    mutate(
      manual_category = factor(.data$manual_category, levels = rev(category_levels)),
      auto_category = factor(.data$auto_category, levels = category_levels),
      label = ifelse(.data$n > 0, as.character(.data$n), "")
    )

  p_keyword_confusion <- ggplot(keyword_confusion_plot, aes(x = auto_category, y = manual_category, fill = n)) +
    geom_tile(color = "white") +
    scale_fill_gradientn(colours = pick_tol_muted(4)) +
    geom_text(aes(label = label), size = 3.1) +
    labs(
      title = NULL,
      x = "Dictionary-assigned category",
      y = "Manual validation category",
      fill = "Count"
    ) +
    theme_validation() +
    theme(axis.text.x = element_text(angle = 35, hjust = 1))

  p_panel_keyword_confusion <- p_keyword_confusion
}

# ============================================================
# Export combined validation panel figure
# ============================================================
blank_validation_panel <- ggplot() +
  theme_void() +
  annotate("text", x = 0, y = 0, label = "Validation data not available", size = 4)

panel_plots <- list(
  if (exists("p_panel_label_outcomes")) p_panel_label_outcomes else blank_validation_panel,
  if (exists("p_panel_label_metrics")) p_panel_label_metrics else blank_validation_panel,
  if (exists("p_panel_keyword_metrics")) p_panel_keyword_metrics else blank_validation_panel,
  if (exists("p_panel_keyword_confusion")) p_panel_keyword_confusion else blank_validation_panel
)

Figure_S9_panel <- cowplot::plot_grid(
  plotlist = panel_plots,
  ncol = 2,
  labels = c("A)", "B)", "C)", "D)"),
  label_size = 13,
  label_fontface = "plain",
  align = "hv"
)

figure_index <- list()
figure_index[[1]] <- save_validation_plot(Figure_S9_panel, "Figure_S9", width = 12.5, height = 7.5)

# ============================================================
# Export index
# ============================================================
if (length(figure_index) > 0) {
  validation_figure_index <- dplyr::bind_rows(figure_index)
  readr::write_csv(validation_figure_index, file.path(TABLE_DIR, "validation_figure_index.csv"), na = "")
  message("Combined validation panel written to: ", FIG_VALIDATION_DIR)
} else {
  message("No validation figures were written. Run scripts/15_validation_audits.R first or provide completed validation files.")
}
