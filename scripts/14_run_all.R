# ============================================================
# 14_run_all.R
# Run one analysis mode.
# ============================================================

source("scripts/00_config_paths_mode.R", encoding = "UTF-8")
source("scripts/00_direct_output_config.R", encoding = "UTF-8")
source("scripts/00_helpers.R", encoding = "UTF-8")

# Prepare data and tokens
source("scripts/01_load_prepare_video_dataset.R", encoding = "UTF-8")
source("scripts/02_prepare_timestamped_comments.R", encoding = "UTF-8")
source("scripts/04_tokenization_strict.R", encoding = "UTF-8")
source("scripts/05_select_analysis_tokens.R", encoding = "UTF-8")

# Tables and figures
source("scripts/06_tables_S6_S8_thematic_content.R", encoding = "UTF-8")

# NOTE: 07_models_multinomial_and_S14_S16.R is a complete standalone copy of the
# Figures 4/S3/S6 + model/table workflow, but 12 runs that same full submitted code.
# We do not source 07 here to avoid duplicate model fitting and duplicate exports.

if (ANALYSIS_MODE != "COMMENTS_ONLY") {
  # Video-level outputs. These do not depend on comment text tokens, so they are
  # skipped in the comments-only audience-response branch.
  source("scripts/08_figure1_taxonomic_status_map.R", encoding = "UTF-8")
}

source("scripts/09_figure2_thematic_content.R", encoding = "UTF-8")

if (ANALYSIS_MODE != "COMMENTS_ONLY") {
  # Video-level channel-diversity and engagement outputs; identical to the
  # main corpus and therefore skipped for comments-only.
  source("scripts/10_figure3_channel_diversity_Table2_S9.R", encoding = "UTF-8")
  source("scripts/11_figures_S1_S2_engagement.R", encoding = "UTF-8")
}

if (ANALYSIS_MODE != "COMMENTS_ONLY") {
  source("scripts/12_figures4_S3_S6_model_predictions.R", encoding = "UTF-8")
  source("scripts/12b_figures_S4_S5_weighted_sensitivity_calibration.R", encoding = "UTF-8")
  source("scripts/13_tables_S10_S13_engagement.R", encoding = "UTF-8")
}

message("Unified workflow completed for mode: ", ANALYSIS_MODE)


# ---- final local cleanup: remove empty intermediate folders if possible ----
if (dir.exists(file.path("outputs", "intermediate"))) {
  # Keep intermediate data files but remove any accidental figure subfolders.
  fig_subdirs <- list.dirs(file.path("outputs", "intermediate"), recursive = TRUE, full.names = TRUE)
  fig_subdirs <- fig_subdirs[grepl("fig|plot|palette|outputs_NEW", fig_subdirs, ignore.case = TRUE)]
  for (d in rev(fig_subdirs)) if (dir.exists(d)) unlink(d, recursive = TRUE, force = TRUE)
}
message("Workflow completed with direct clean outputs.")
