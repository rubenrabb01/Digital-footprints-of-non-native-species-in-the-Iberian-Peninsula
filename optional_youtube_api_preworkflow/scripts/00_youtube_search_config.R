# ============================================================
# 00_youtube_search_config.R
# Configuration for the optional YouTube API search step.
# ============================================================

PROJECT_ROOT <- getwd()
DATA_RAW_DIR <- file.path(PROJECT_ROOT, "data_raw")
YT_OUTPUT_DIR <- file.path(PROJECT_ROOT, "yt_api_outputs")
YT_PER_LIST_DIR <- file.path(YT_OUTPUT_DIR, "per_list")
YT_LOG_DIR <- file.path(YT_OUTPUT_DIR, "logs")

for (d in c(DATA_RAW_DIR, YT_OUTPUT_DIR, YT_PER_LIST_DIR, YT_LOG_DIR)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# ------------------------------------------------------------
# RUN_MODE presets
# ------------------------------------------------------------
# Set RUN_MODE before sourcing this file, or edit the line below.
# Examples:
#   RUN_MODE <- "test_REG"
#   source("scripts/00_youtube_search_config.R", encoding = "UTF-8")
#
# Available modes:
#   custom                    = use CONFIG values as written below
#   test_REG                  = small REG-only test, no comments
#   test_GEO                  = small GEO-only test, no comments
#   test_REG_GEO              = small REG+GEO test, no comments
#   test_comments             = very small REG test with comments/replies
#   full_REG_GEO_no_comments  = full REG+GEO API retrieval, no comments
#   full_REG_GEO_with_comments= full REG+GEO retrieval plus comments/replies
# ------------------------------------------------------------
RUN_MODE <- if (exists("RUN_MODE", inherits = FALSE)) RUN_MODE else "custom"

CONFIG <- list(
  # ---- API key ----
  # Recommended: set once in R before running:
  #   Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
  # or define it in ~/.Renviron as:
  #   YOUTUBE_API_KEY=YOUR_KEY_HERE
  # Do not hard-code API keys in scripts that will be shared.
  api_key = Sys.getenv("YOUTUBE_API_KEY"),

  # ---- Search-term input ----
  # By default, uses scripts/00_species_search_terms_template.R.
  # Replace this with a file containing your full named species list if needed.
  species_terms_file = file.path("scripts", "00_species_search_terms_template.R"),  # small test list
  # For the full species list, use:
  # species_terms_file = file.path("scripts", "species_names_lists_full.R"),

  # Split species into smaller batches to avoid losing long searches if a session/API quota fails.
  # Set to Inf to put all species in one batch.
  max_species_per_batch = 20,

  # Search modes to run. Use c("REG", "GEO") for both, or one of them for testing.
  search_modes = c("REG", "GEO"),

  # If TRUE, remove previous generated API batch files and final raw outputs before running.
  # This prevents accidental mixing of old test files with new searches.
  # Set FALSE only when intentionally resuming/combining previous batch files.
  clear_previous_outputs = FALSE,

  # Date window used in the paper workflow.
  published_after  = "2005-03-01T00:00:00Z",
  published_before = paste0(format(Sys.Date(), "%Y-%m-%d"), "T00:00:00Z"),

  # YouTube API options.
  relevance_language = "es",
  postfilter_query_in_title_or_description = TRUE,
  max_videos_per_term = 100,
  sleep_seconds = 0.10,

  # Optional metadata extraction.
  extract_video_stats = TRUE,

  # Comments are quota-heavy. Set FALSE for a first test.
  extract_comments = FALSE,
  include_replies = TRUE,
  max_comments_per_video = 10,

  # REG settings.
  region_codes = c("ES", "PT"),

  # GEO settings used to cover mainland Iberia and adjacent archipelagos.
  # These are deliberately explicit to avoid relying on one broad radius.
  geo_locations = list(
    ES_MAIN     = list(coord = "40.0,-3.7",     radius = "1000km"),
    PT_MAIN     = list(coord = "39.7,-8.0",     radius = "700km"),
    ES_BALEARIC = list(coord = "39.6,3.0",      radius = "250km"),
    ES_CANARY   = list(coord = "28.3,-16.6",    radius = "350km"),
    PT_MADEIRA  = list(coord = "32.75,-16.97",  radius = "200km"),
    PT_AZORES_E = list(coord = "37.74,-25.67",  radius = "250km"),
    PT_AZORES_C = list(coord = "38.65,-28.00",  radius = "300km"),
    PT_AZORES_W = list(coord = "39.45,-31.13",  radius = "250km")
  ),

  # Final raw filenames expected by the downstream manuscript workflow / old scripts.
  reg_final_file = file.path(DATA_RAW_DIR, "yt_species_videos_ES_PT_regioncode_scientific_common_dedup.csv"),
  geo_final_file = file.path(DATA_RAW_DIR, "yt_species_videos_ES_PT_geotagged_dedup_1200km_new_locs_espanded.csv"),
  comments_final_file = file.path(DATA_RAW_DIR, "YT_comments_with_timestamps_long.csv"),

  # Backward-compatible aliases used by some older scripts.
  reg_alias_file = file.path(DATA_RAW_DIR, "final_region_scientific_common_dedup.csv"),
  geo_alias_file = file.path(DATA_RAW_DIR, "final_df_geotagged_dedup_1200km_new_locs_espanded.csv"),
  combined_alias_file = file.path(DATA_RAW_DIR, "YT_video_search_raw_REG_GEO_combined.csv"),

  # Set TRUE only when intentionally overwriting existing data_raw outputs.
  overwrite_final_outputs = TRUE
)

apply_run_mode <- function(config, run_mode) {
  run_mode <- as.character(run_mode)

  if (identical(run_mode, "custom")) return(config)

  if (identical(run_mode, "test_REG")) {
    config$search_modes <- c("REG")
    config$max_species_per_batch <- 2
    config$max_videos_per_term <- 10
    config$extract_video_stats <- TRUE
    config$extract_comments <- FALSE
    config$clear_previous_outputs <- TRUE
  } else if (identical(run_mode, "test_GEO")) {
    config$search_modes <- c("GEO")
    config$max_species_per_batch <- 2
    config$max_videos_per_term <- 10
    config$extract_video_stats <- TRUE
    config$extract_comments <- FALSE
    config$clear_previous_outputs <- TRUE
  } else if (identical(run_mode, "test_REG_GEO")) {
    config$search_modes <- c("REG", "GEO")
    config$max_species_per_batch <- 2
    config$max_videos_per_term <- 10
    config$extract_video_stats <- TRUE
    config$extract_comments <- FALSE
    config$clear_previous_outputs <- TRUE
  } else if (identical(run_mode, "test_comments")) {
    config$search_modes <- c("REG")
    config$max_species_per_batch <- 1
    config$max_videos_per_term <- 5
    config$extract_video_stats <- TRUE
    config$extract_comments <- TRUE
    config$include_replies <- TRUE
    config$max_comments_per_video <- 5
    config$clear_previous_outputs <- TRUE
  } else if (identical(run_mode, "full_REG_GEO_no_comments")) {
    config$search_modes <- c("REG", "GEO")
    config$max_species_per_batch <- 20
    config$max_videos_per_term <- 100
    config$extract_video_stats <- TRUE
    config$extract_comments <- FALSE
    config$clear_previous_outputs <- TRUE
  } else if (identical(run_mode, "full_REG_GEO_with_comments")) {
    config$search_modes <- c("REG", "GEO")
    config$max_species_per_batch <- 20
    config$max_videos_per_term <- 100
    config$extract_video_stats <- TRUE
    config$extract_comments <- TRUE
    config$include_replies <- TRUE
    config$max_comments_per_video <- 10
    config$clear_previous_outputs <- TRUE
  } else {
    stop("Unknown RUN_MODE: ", run_mode)
  }

  config
}

CONFIG <- apply_run_mode(CONFIG, RUN_MODE)

cat("YouTube API pre-workflow configuration loaded.\n")
cat("  RUN_MODE:", RUN_MODE, "\n")
cat("  Search modes:", paste(CONFIG$search_modes, collapse = ", "), "\n")
cat("  Max species per batch:", CONFIG$max_species_per_batch, "\n")
cat("  Max videos per term:", CONFIG$max_videos_per_term, "\n")
cat("  Extract comments:", CONFIG$extract_comments, "\n")
cat("  Clear previous outputs:", CONFIG$clear_previous_outputs, "\n")

if (!nzchar(CONFIG$api_key)) {
  warning(
    "YOUTUBE_API_KEY is not set. Set Sys.setenv(YOUTUBE_API_KEY = 'YOUR_KEY') before running API searches."
  )
}
