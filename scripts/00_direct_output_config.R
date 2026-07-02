# ============================================================
# 00_direct_output_config.R
# Direct clean output configuration.
#
# IMPORTANT:
# The workflow writes only paper-ready figures/tables plus required
# intermediate CSVs. Obsolete folders such as outputs/audit and
# outputs/figures/sensitivity_comments are not created.
# ============================================================

OUT_ROOT <- "outputs"

FIG_MAIN_DIR <- file.path(OUT_ROOT, "figures", "main")
FIG_SUPP_DIR <- file.path(OUT_ROOT, "figures", "supplement")

TAB_MAIN_DIR <- file.path(OUT_ROOT, "tables", "main")
TAB_SUPP_DIR <- file.path(OUT_ROOT, "tables", "supplement")
TAB_QA_DIR   <- file.path(OUT_ROOT, "tables", "qa")

INTERMEDIATE_DIR <- file.path(OUT_ROOT, "intermediate")

# Backward-compatible aliases. These point to paper-ready folders so scripts
# that still refer to sensitivity directories do not create old folders.
FIG_SENS_DIR <- FIG_SUPP_DIR
TAB_SENS_DIR <- TAB_SUPP_DIR

invisible(lapply(c(
  FIG_MAIN_DIR, FIG_SUPP_DIR,
  TAB_MAIN_DIR, TAB_SUPP_DIR, TAB_QA_DIR,
  INTERMEDIATE_DIR
), dir.create, recursive = TRUE, showWarnings = FALSE))

# Remove stale folders from older workflow versions, if present.
stale_dirs <- c(
  file.path(OUT_ROOT, "figures", "sensitivity_comments"),
  file.path(OUT_ROOT, "audit")
)
for (d in stale_dirs) if (dir.exists(d)) unlink(d, recursive = TRUE, force = TRUE)

# Analysis modes remain:
#   NO_COMMENTS          = main title/description workflow
#   COMMENTS_ONLY        = comments/replies-only sensitivity
#   COMMENTS_TIMESTAMPS  = mixed all-token diagnostic, retained only if manually run

paper_suffix <- function() {
  if (!exists("ANALYSIS_MODE", envir = .GlobalEnv)) return("")
  if (ANALYSIS_MODE == "NO_COMMENTS") return("")
  if (ANALYSIS_MODE == "COMMENTS_ONLY") return("_COMMENTS_ONLY")
  if (ANALYSIS_MODE == "COMMENTS_TIMESTAMPS") return("_COMMENTS_TIMESTAMPS")
  ""
}

paper_estimates_dir <- function() {
  if (exists("ANALYSIS_MODE", envir = .GlobalEnv) && ANALYSIS_MODE == "COMMENTS_ONLY") return(TAB_SUPP_DIR)
  TAB_SUPP_DIR
}

paper_models_dir <- function() {
  if (exists("ANALYSIS_MODE", envir = .GlobalEnv) && ANALYSIS_MODE == "COMMENTS_ONLY") return(TAB_SUPP_DIR)
  TAB_MAIN_DIR
}

paper_keyword_fig_dir <- function() {
  if (exists("ANALYSIS_MODE", envir = .GlobalEnv) && ANALYSIS_MODE == "COMMENTS_ONLY") return(FIG_SUPP_DIR)
  FIG_MAIN_DIR
}
