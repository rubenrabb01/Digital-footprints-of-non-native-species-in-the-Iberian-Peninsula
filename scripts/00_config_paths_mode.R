# 00_config_paths_mode.R
# Paths and run mode.


# Choose ONE mode before sourcing 14_run_all.R.
#   "NO_COMMENTS"          = titles + descriptions only
#   "COMMENTS_TIMESTAMPS"  = titles + descriptions + timestamped comments
#   "COMMENTS_ONLY"        = comments + replies only
if (!exists("ANALYSIS_MODE", inherits = FALSE)) {
  ANALYSIS_MODE <- "NO_COMMENTS"
}

VALID_ANALYSIS_MODES <- c("NO_COMMENTS", "COMMENTS_TIMESTAMPS", "COMMENTS_ONLY")
if (!ANALYSIS_MODE %in% VALID_ANALYSIS_MODES) {
  stop("ANALYSIS_MODE must be one of: ", paste(VALID_ANALYSIS_MODES, collapse = ", "))
}

# Project root: assume scripts are sourced from project root. If not, set PROJECT_ROOT manually.
if (!exists("PROJECT_ROOT", inherits = FALSE)) {
  PROJECT_ROOT <- getwd()
}

SCRIPTS_DIR <- file.path(PROJECT_ROOT, "scripts")
ORIGINAL_SCRIPTS_DIR <- file.path(PROJECT_ROOT, "original_submitted_scripts")
DATA_DIR <- file.path(PROJECT_ROOT, "data")
PAPER_INPUT_DIR <- file.path(DATA_DIR, "paper_input")
TEST_INPUT_DIR <- file.path(DATA_DIR, "preparation_input", "private_raw_api")
DATA_RAW_DIR <- PAPER_INPUT_DIR
FIG_ASSETS_DIR <- file.path(PROJECT_ROOT, "fig_assets")

TABLES_ROOT <- file.path(PROJECT_ROOT, file.path("outputs", "intermediate"))
OUTPUTS_ROOT <- file.path(PROJECT_ROOT, file.path("outputs", "intermediate"))
KW_TABLES_DIR <- file.path(TABLES_ROOT, "keywords")
KW_OUTPUTS_DIR <- file.path(OUTPUTS_ROOT, "keywords")

if (ANALYSIS_MODE == "NO_COMMENTS") {
  TOKEN_FILE_BASENAME <- "token_table_from_BASE_raw_NO_COMMENTS.csv"
  TOKEN_SOURCE_LABEL <- "NO_COMMENTS"
  OUTPUT_SUFFIX <- ""
  OBJECT_SUFFIX <- "NO_COMMENTS"
  MODEL_DIR_SUFFIX <- ""
  BUILD_COMMENTS_TOKENS <- FALSE
}

if (ANALYSIS_MODE == "COMMENTS_TIMESTAMPS") {
  TOKEN_FILE_BASENAME <- "token_table_from_BASE_raw.csv"
  TOKEN_SOURCE_LABEL <- "ALL"
  OUTPUT_SUFFIX <- "_COMMENTS_TIMESTAMPS"
  OBJECT_SUFFIX <- "COMMENTS_TIMESTAMPS"
  MODEL_DIR_SUFFIX <- "_COMMENTS_TIMESTAMPS"
  BUILD_COMMENTS_TOKENS <- TRUE
}

if (ANALYSIS_MODE == "COMMENTS_ONLY") {
  TOKEN_FILE_BASENAME <- "token_table_from_BASE_raw_COMMENTS.csv"
  TOKEN_SOURCE_LABEL <- "COMMENTS_ONLY"
  OUTPUT_SUFFIX <- "_COMMENTS_ONLY"
  OBJECT_SUFFIX <- "COMMENTS_ONLY"
  MODEL_DIR_SUFFIX <- "_COMMENTS_ONLY"
  BUILD_COMMENTS_TOKENS <- TRUE
}

TOKEN_FILE_TABLES <- file.path(KW_TABLES_DIR, TOKEN_FILE_BASENAME)
TOKEN_FILE_OUTPUTS <- file.path(KW_OUTPUTS_DIR, TOKEN_FILE_BASENAME)

# Original submitted script filenames. Keep these unchanged for traceability.
ORIG_FIG1 <- file.path(ORIGINAL_SCRIPTS_DIR, "Figure 1 (ICON_FIX)(2).R")
ORIG_FIG2 <- file.path(ORIGINAL_SCRIPTS_DIR, "Figure 2 (ICON_FIX)_comment_timestamps_extracted(1).R")
ORIG_FIG3_TABLE2_S9 <- file.path(ORIGINAL_SCRIPTS_DIR, "Figure 3 + Table 2 + Table S9  (ICON_FIX)(2).R")
ORIG_FIG4_NO_COMMENTS <- file.path(ORIGINAL_SCRIPTS_DIR, "Figures 4 + S3 + S6 + Tables 4 + S14-S15 (ICON_FIX)_NO_COMMENTS(2).R")
ORIG_FIG4_COMMENTS <- file.path(ORIGINAL_SCRIPTS_DIR, "Figures 4 + S3 + S6 + Tables 4 + S14-S15 (ICON_FIX)_comment_timestamps_extracted_FIX3_Tables S14+S16_merged(1).R")
ORIG_FIGS_S1_S2 <- file.path(ORIGINAL_SCRIPTS_DIR, "Figures S1 + S2 (ICON_FIX)(1).R")
ORIG_TABLES_S6_S8 <- file.path(ORIGINAL_SCRIPTS_DIR, "Tables S6–S8 - Results (Thematic content of YouTube videos)(2).R")
ORIG_TABLES_S10_S13 <- file.path(ORIGINAL_SCRIPTS_DIR, "Tables S10–S13(1).R")
ORIG_TABLES_S14_S16_COUNTS <- file.path(ORIGINAL_SCRIPTS_DIR, "Tables S14-S16 (FIX)_COUNTS(1).R")
ORIG_TABLES_S14_S16_PROPS <- file.path(ORIGINAL_SCRIPTS_DIR, "Tables S14-S16 (FIX)_PROPS(1).R")
ORIG_TOKENIZATION <- file.path(ORIGINAL_SCRIPTS_DIR, "Tokenization (Views+Likes+Comments)_comment_timestamps_extracted(1).R")

message("Analysis mode: ", ANALYSIS_MODE)
message("Token source: ", TOKEN_SOURCE_LABEL, " -> ", TOKEN_FILE_BASENAME)
message("Output suffix: '", OUTPUT_SUFFIX, "'")
