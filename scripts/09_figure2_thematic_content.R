if (file.exists("scripts/00_direct_output_config.R")) source("scripts/00_direct_output_config.R", encoding = "UTF-8")
# ============================================================
# 09_figure2_thematic_content.R
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

# ===========================================================
# FIGURE 2 - UPDATED to use TOKENS INCLUDING COMMENTS (ALL)
#   - Reads token_table_from_BASE_raw.csv (meta + comments+replies)
#   - Produces: trend (A), species bars (B), lifeform inset (C), panels
# ===========================================================

source(file.path(SCRIPTS_DIR, "03_keyword_lists.R"), encoding = "UTF-8")

# --------------------------- Lifeform order (match Fig 1) --------------------
desired_lf_order <- c(
  "Birds","Herptiles","Fishes","Insects",
  "Crustaceans","Non-arthropod invertebrates","Plants","Bacteria, Viruses, Fungi"
)

# Display labels (only for plotting text; underlying LifeForm values unchanged)
lifeform_display_labels <- c(
  "Non-arthropod invertebrates" = "N.A. invertebrates",
  "Bacteria, Viruses, Fungi"    = "Bacteria/Viruses/Fungi"
)

BASE_FSIZE <- 14

KW_SPECIES_MODE       <- c("ALL", "TOPN", "TOPP")[2]
TOPN_KEYWORD_SPECIES  <- 35
TOPP_KEYWORD_SPECIES  <- 0.03
VARIANTS_TO_RUN <- c("all")

LEGEND_SHOW_TITLE  <- TRUE
LEGEND_POSITION    <- "right"

# ----------------------- Text sizes (your request) -----------------------
AX_TEXT_SIZE   <- 12
AX_TITLE_SIZE  <- 14

LEG_TEXT_SIZE  <- 18
LEG_TITLE_SIZE <- 18

TAG_SIZE       <- 18

# Plot B inside-plot text ~ 11 pt
PT_TO_GG <- function(pt) pt / 2.845276
B_INPLOT_GG_SIZE <- PT_TO_GG(14)

# species names in B (y-axis text) = 11 pt
B_SPECIES_Y_TEXT_PT <- 11

# Inset % label size (increase here)
INSET_PCT_GG_SIZE <- PT_TO_GG(34)   # was ~10; set 12-14 if you prefer bigger

# -------------------------------------------------------------------------
# Alias variables to prevent silent failures due to name mismatch
# (NO VALUE CHANGES; just ensures all references exist)
# -------------------------------------------------------------------------
LEGEND_TEXT_SIZE <- LEG_TEXT_SIZE
LEGEND_TITLE_SIZE <- LEG_TITLE_SIZE
AXIS_TEXT_SIZE  <- AX_TEXT_SIZE
AXIS_TITLE_SIZE <- AX_TITLE_SIZE

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(ggplot2); library(forcats); library(stringr)
  library(readr); library(SnowballC); library(lubridate); library(purrr); library(grid)
  library(png); library(stringi)
})

# ----------------------- Theme -----------------------
theme_inat <- function(base_size = 14) {
  theme_light(base_size = base_size) +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      legend.title       = element_text(size = LEG_TITLE_SIZE),
      legend.text        = element_text(size = LEG_TEXT_SIZE),
      axis.text.x        = element_text(size = AX_TEXT_SIZE, face = "plain", angle = 45, hjust = 1,
                                        margin = margin(t = 6)),
      axis.text.y        = element_text(size = AX_TEXT_SIZE, face = "plain", margin = margin(r = 6)),
      axis.title.x       = element_text(size = AX_TITLE_SIZE, margin = margin(t = 18)),
      axis.title.y       = element_text(size = AX_TITLE_SIZE, margin = margin(r = 18)),
      plot.title         = element_text(face = "plain", margin = margin(b = 8))
    )
}

FORCE_PLAIN_X <- theme(
  axis.text.x = element_text(face = "plain", angle = 0),
  text = element_text(face = "plain")
)

# ----------------------- Utilities --------------------------
.strip_titles_legends <- function(p) {
  if (!inherits(p, "gg")) return(p)
  p + labs(title = NULL) + theme(legend.title = element_blank())
}

ensure_dir <- function(path) if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)

# Figure 2 requires intermediate PNG files for panel assembly. To keep the
# project outputs clean, these dependencies are written to a temporary session
# folder instead of outputs/intermediate/figure2. Only the approved final figure
# files are exported to outputs/figures/main and outputs/figures/supplement.
if (!exists("FIG2_TMP_DIR", inherits = FALSE)) {
  FIG2_TMP_DIR <- file.path(tempdir(), paste0("figure2_build_", Sys.getpid()))
}
ensure_dir(FIG2_TMP_DIR)
# Remove stale outputs from older workflow versions that wrote many Figure 2
# variants under outputs/intermediate/figure2. The current workflow keeps these
# intermediate dependencies in FIG2_TMP_DIR and exports only the approved figures.
.old_fig2_variant_dir <- file.path("outputs", "intermediate", "figure2")
if (dir.exists(.old_fig2_variant_dir)) unlink(.old_fig2_variant_dir, recursive = TRUE, force = TRUE)

save_plot_safely <- function(plot, filename, width=185, height=175,
                             units="mm", dpi=300, bg="white") {
  # Figure 2 needs several intermediate PNGs to assemble the final panel.
  # Save these only in the temporary build folder, not in outputs/intermediate.
  internal_dir <- FIG2_TMP_DIR
  ensure_dir(internal_dir)

  base_name <- tools::file_path_sans_ext(basename(filename))
  internal_stem <- file.path(internal_dir, base_name)

  if (inherits(plot, "gg")) plot <- .strip_titles_legends(plot)

  # Save internal dependency files without printing "Saved:" messages.
  ggsave(paste0(internal_stem, ".png"), plot = plot,
         width = width, height = height, units = units, dpi = dpi, bg = bg)
  ggsave(paste0(internal_stem, ".tiff"), plot = plot,
         width = width, height = height, units = units, dpi = dpi, bg = bg,
         device = "tiff", compression = "lzw")

  # Export only the approved final Figure 2 / comments-only Fig. S7 with clean names.
  if (exists("ANALYSIS_MODE") && ANALYSIS_MODE == "COMMENTS_ONLY") {
    keep_name <- "Figure2_PANEL_TOPtrend__GAM_overall_with_CI_large_VERT__COMMENTS_ONLY"
    # Export only the paper-ready comments-only sensitivity figure: Supplementary Fig. S7.
    final_stems <- file.path(FIG_SUPP_DIR, "Figure_S7")
  } else {
    keep_name <- "Figure2_PANEL_TOPtrend__GAM_overall_with_CI_large_VERT__NO_COMMENTS"
    final_stems <- file.path(FIG_MAIN_DIR, "Figure_2")
  }

  if (identical(base_name, keep_name)) {
    for (final_stem in final_stems) {
      ensure_dir(dirname(final_stem))
      file.copy(paste0(internal_stem, ".png"),  paste0(final_stem, ".png"),  overwrite = TRUE)
      file.copy(paste0(internal_stem, ".tiff"), paste0(final_stem, ".tiff"), overwrite = TRUE)
      message("Saved final figure: ", final_stem, ".png and .tiff")
    }
  }

  invisible(TRUE)
}

save_table_safely <- function(df, filename) {
  ensure_dir(dirname(filename))
  readr::write_csv(df, filename)
  message("Saved table: ", filename)
}

save_variant_noLegend_noXtitle <- function(plot, filename_base,
                                           width = 285, height = 185, units = "mm") {
  if (!inherits(plot, "gg")) return(invisible(NULL))
  p_variant <- plot + theme(legend.position = "none") + labs(x = NULL)
  save_plot_safely(p_variant, paste0(filename_base, "_noLegend_noXtitle.png"),
                   width = width, height = height, units = units)
}

normalize_time_period_vec <- function(x) dplyr::case_when(
  is.na(x) ~ NA_character_,
  x %in% c("Before","Pre-Intro","Pre-Introduction") ~ "Pre-Introduction",
  x %in% c("After","Post-Intro","Post-Introduction") ~ "Post-Introduction",
  TRUE ~ as.character(x)
)

# ----------------------- Colors -------------------------
base_cols <- c(
  Detection = "#6871ff",
  eCommerce = "#6F4685",
  Invasion  = "#A6FF4D",
  Threat    = "#ff7f1b"
)

make_cat_period_cols <- function(base_cols, pre_alpha = 0.35, post_alpha = 1.0) {
  c(
    setNames(scales::alpha(base_cols["Threat"],    c(pre_alpha, post_alpha)),
             c("Threat_Pre-Introduction","Threat_Post-Introduction")),
    setNames(scales::alpha(base_cols["Detection"], c(pre_alpha, post_alpha)),
             c("Detection_Pre-Introduction","Detection_Post-Introduction")),
    setNames(scales::alpha(base_cols["eCommerce"], c(pre_alpha, post_alpha)),
             c("eCommerce_Pre-Introduction","eCommerce_Post-Introduction")),
    setNames(scales::alpha(base_cols["Invasion"],  c(pre_alpha, post_alpha)),
             c("Invasion_Pre-Introduction","Invasion_Post-Introduction"))
  )
}
category_colors <- make_cat_period_cols(base_cols, pre_alpha = 0.35, post_alpha = 1.0)

legend_name <- function(x) x
label_category_time <- function(x) {
  cat <- sub("_.*", "", x)
  per <- sub(".*_", "", x)
  per <- dplyr::recode(per,
                       "Pre-Introduction"  = "Pre-Intro",
                       "Post-Introduction" = "Post-Intro",
                       .default = per)
  sprintf("%s (%s)", cat, per)
}

# ======================= ICON HELPERS =======================

as_rgba <- function(img, light = 0.65,
                    tint = c(0.55, 0.50, 0.60)) {
  d <- dim(img)

  apply_tint <- function(g) {
    g <- light + (1 - light) * g
    list(
      r = g * tint[1],
      g = g * tint[2],
      b = g * tint[3]
    )
  }

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

  if (!is.null(d) && length(d) == 3 && d[3] == 3) {
    col <- apply_tint(img)
    out <- array(1, dim = c(d[1], d[2], 4))
    out[,,1] <- col$r
    out[,,2] <- col$g
    out[,,3] <- col$b
    return(out)
  }

  if (!is.null(d) && length(d) == 3 && d[3] == 4) {
    col <- apply_tint(img[,,1])
    img[,,1] <- col$r
    img[,,2] <- col$g
    img[,,3] <- col$b
    return(img)
  }

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

ICON_LIGHT <- 0.65
ICON_TINT  <- c(0.55, 0.50, 0.60)

add_y_icons_compact <- function(
  p_horiz, y_levels, icon_paths,
  icon_width_frac = 0.22,
  icon_half_height = 0.62,
  gap_frac        = -0.005,
  border_overlap  = 0.00,
  left_margin     = 10,
  frame_colour    = "grey70",
  frame_size      = 0.28
){
  gb   <- ggplot_build(p_horiz)
  xmax <- max(unlist(lapply(gb$data, function(d) if ("x" %in% names(d)) d$x else NA)), na.rm = TRUE)
  if (!is.finite(xmax) || xmax <= 0) xmax <- 100

  icon_w   <- xmax * icon_width_frac
  gap      <- xmax * gap_frac
  x_center <- -(gap + icon_w/2)

  x_min   <- x_center - icon_w/2 + icon_w * border_overlap
  x_right <- xmax * 1.12

  layers <- lapply(seq_along(y_levels), function(i){
    lf <- y_levels[i]
    path <- icon_paths[lf]
    if (is.na(path) || !file.exists(path)) return(NULL)

    img <- png::readPNG(path)
    img <- as_rgba(img, light = ICON_LIGHT, tint = ICON_TINT)
    gr  <- grid::rasterGrob(img, interpolate = TRUE)

    y0 <- i - icon_half_height
    y1 <- i + icon_half_height
    x0 <- x_center - icon_w/2
    x1 <- x_center + icon_w/2

    annotation_custom(gr, xmin = x0, xmax = x1, ymin = y0, ymax = y1)
  })
  layers <- layers[!vapply(layers, is.null, logical(1))]

  p_horiz +
    layers +
    scale_x_continuous(expand = expansion(mult = c(0, 0))) +
    coord_cartesian(xlim = c(x_min, x_right), clip = "off") +
    theme(
      panel.grid   = element_blank(),
      panel.border = element_blank(),
      plot.margin  = margin(t = 3, r = 3, b = 3, l = 3)
    ) +
    geom_segment(aes(x=x_min, xend=x_right, y=0.5, yend=0.5),
                 inherit.aes=FALSE, linewidth=frame_size, colour=frame_colour) +
    geom_segment(aes(x=x_min, xend=x_right, y=length(y_levels)+0.5, yend=length(y_levels)+0.5),
                 inherit.aes=FALSE, linewidth=frame_size, colour=frame_colour) +
    geom_segment(aes(x=x_min, xend=x_min,  y=0.5, yend=length(y_levels)+0.5),
                 inherit.aes=FALSE, linewidth=frame_size, colour=frame_colour) +
    geom_segment(aes(x=x_right, xend=x_right, y=0.5, yend=length(y_levels)+0.5),
                 inherit.aes=FALSE, linewidth=frame_size, colour=frame_colour)
}

add_x_icons_compact <- function(
  p_vert, x_levels, icon_paths,
  icon_height_frac = 0.12,
  gap_frac         = -0.005,
  icon_width_frac  = 0.98,
  border_overlap   = 0.00,
  frame_colour     = "grey70",
  frame_size       = 0.28
){
  gb <- ggplot_build(p_vert)

  ymax <- max(unlist(lapply(gb$data, function(d) if ("y" %in% names(d)) d$y else NA)), na.rm = TRUE)
  if (!is.finite(ymax) || ymax <= 0) ymax <- 100

  icon_h <- ymax * icon_height_frac
  gap    <- ymax * gap_frac

  y_top    <- -gap
  y_bottom <- -gap - icon_h

  x_pos <- seq_along(x_levels)

  layers <- lapply(seq_along(x_levels), function(i){
    lf <- x_levels[i]
    path <- icon_paths[lf]
    if (is.na(path) || !file.exists(path)) return(NULL)

    img <- png::readPNG(path)
    img <- as_rgba(img, light = ICON_LIGHT, tint = ICON_TINT)
    gr  <- grid::rasterGrob(img, interpolate = TRUE)

    half_w <- 0.5 * icon_width_frac
    x0 <- x_pos[i] - half_w + border_overlap
    x1 <- x_pos[i] + half_w - border_overlap

    annotation_custom(gr, xmin = x0, xmax = x1, ymin = y_bottom, ymax = y_top)
  })
  layers <- layers[!vapply(layers, is.null, logical(1))]

  p_vert +
    layers +
    scale_y_continuous(expand = expansion(mult = c(0, 0))) +
    coord_cartesian(ylim = c(y_bottom, ymax * 1.13), clip = "off") +
    theme(
      plot.margin = margin(t = 2, r = 2, b = 0, l = 2)
    )
}

# -------- Lifeform icon setup --------
icon_filemap <- c(
  "Birds"  = "bird.png",
  "Insects"= "insect.png",
  "Herptiles"="herp.png",
  "Fishes" = "fish.png",
  "Non-arthropod invertebrates"="invert_nonarth.png",
  "Bacteria, Viruses, Fungi"   ="bacteria.png",
  "Crustaceans"="crustacean.png",
  "Plants"     ="plant.png"
)
icon_dir_candidates <- c("fig_assets/icons", "fig_assets")
pick_icon_dir <- function(cands, probe = "bird.png") {
  for (d in cands) if (dir.exists(d) && file.exists(file.path(d, probe))) return(d)
  NA_character_
}
ICON_DIR <- pick_icon_dir(icon_dir_candidates)
if (is.na(ICON_DIR)) {
  message("WARNING: icon directory not found; inset will render without icons. Tried: ",
          paste(icon_dir_candidates, collapse = ", "))
}
icon_paths <- if (!is.na(ICON_DIR)) {
  p <- file.path(ICON_DIR, unname(icon_filemap)); names(p) <- names(icon_filemap); p
} else setNames(rep(NA_character_, length(icon_filemap)), names(icon_filemap))

# ---------------- Keyword smart matching ----------------
if (exists("keyword_lists") && is.list(keyword_lists)) {
  get_vec <- function(x) { v <- keyword_lists[[x]]; if (is.null(v)) character() else unique(as.character(v)) }
  Threat <- get_vec("Threat"); Detection <- get_vec("Detection"); eCommerce <- get_vec("eCommerce"); Invasion <- get_vec("Invasion")
}
.normalize_ascii_lower <- function(x) {
  x <- as.character(x)
  x <- stringi::stri_trans_general(x, "Latin-ASCII")
  x <- tolower(trimws(x))
  x <- gsub("[^a-z0-9]+", "", x)
  x[nchar(x) > 0]
}
.multi_stems <- function(w) {
  langs <- c("spanish","portuguese","english","catalan")
  unique(unlist(lapply(langs, \(lg) tryCatch(SnowballC::wordStem(w, language=lg), error=\(e) w))))
}
.build_match_set <- function(v) {
  if (!length(v)) return(character(0))
  base <- .normalize_ascii_lower(v)
  morph <- unique(c(base, ifelse(grepl("[sxz]$", base), paste0(base,"es"), paste0(base,"s")), sub("(es|s)$","",base)))
  stems <- unique(unlist(lapply(morph, .multi_stems)))
  unique(c(base, morph, stems))
}
Threat_set     <- .build_match_set(Threat)
Detection_set  <- .build_match_set(Detection)
Invasion_set   <- .build_match_set(Invasion)
eCommerce_set  <- .build_match_set(eCommerce)

# ----------------------- Output dirs -----------------------
ensure_dir(paper_keyword_fig_dir())
root_tables <- file.path("outputs", "intermediate")
ensure_dir(root_tables)
ensure_dir(file.path(root_tables, "keywords"))
ensure_dir(file.path(root_tables, "word_proportions"))

# ----------------------- Load base video table -----------------------
videos_src <- if (exists("combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN")) {
  combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN
} else if (exists("RAW_FLAGGED_IS_IBERIAN")) {
  RAW_FLAGGED_IS_IBERIAN
} else stop("No video-level table found.")

has_col <- function(df, nm) nm %in% names(df)

videos_tbl <- videos_src %>%
  mutate(
    TaxonName = dplyr::coalesce(if (has_col(., "TaxonName")) .data$TaxonName else NA_character_,
                               if (has_col(., "species_normalized")) gsub(" +", "_", .data$species_normalized) else NA_character_),
    species_normalized = dplyr::coalesce(if (has_col(., "species_normalized")) .data$species_normalized else NA_character_,
                                        if (has_col(., "TaxonName")) gsub("_", " ", .data$TaxonName) else NA_character_),
    LifeForm      = if (has_col(., "LifeForm")) as.character(.data$LifeForm) else NA_character_,
    PresentStatus = if (has_col(., "PresentStatus")) as.character(.data$PresentStatus) else NA_character_,
    FirstRecord   = if (has_col(., "FirstRecord")) as.integer(.data$FirstRecord) else NA_integer_,
    created_at    = if (has_col(., "created_at")) as.POSIXct(.data$created_at) else as.POSIXct(NA),
    publishedAt   = if (has_col(., "publishedAt")) as.POSIXct(.data$publishedAt) else as.POSIXct(NA),
    event_date    = suppressWarnings(as.POSIXct(dplyr::coalesce(.data$created_at, .data$publishedAt)))
  ) %>%
  dplyr::select(video_id, TaxonName, species_normalized, LifeForm, PresentStatus, FirstRecord,
                created_at, publishedAt, event_date) %>%
  distinct(video_id, .keep_all = TRUE) %>%
  mutate(
    TaxonName = gsub("_", " ", TaxonName),
    species_normalized = gsub("_", " ", species_normalized),
    FirstRecordDate = ifelse(!is.na(FirstRecord), paste0(pmax(FirstRecord, 1L), "-06-01"), NA_character_),
    FirstRecordDate = suppressWarnings(as.Date(FirstRecordDate))
  )

# =========================================================
# ===================== TOKEN TABLE INPUTS =================
# =========================================================
# Choose which token CSV to use for Figure 2
#   - "ALL"          => token_table_from_BASE_raw.csv (META + COMMENTS)
#   - "COMMENTS_ONLY"=> token_table_from_BASE_raw_COMMENTS.csv
#   - "NO_COMMENTS"  => token_table_from_BASE_raw_NO_COMMENTS.csv

tokens_path_no_comments <- file.path(root_tables, "keywords", "token_table_from_BASE_raw_NO_COMMENTS.csv")
tokens_path_all         <- file.path(root_tables, "keywords", "token_table_from_BASE_raw.csv")
tokens_path_comments     <- file.path(root_tables, "keywords", "token_table_from_BASE_raw_COMMENTS.csv")

# ---- load all three token tables (same paths as your Fig2 snippet) ----
tokens_no_comments <- readr::read_csv(tokens_path_no_comments, show_col_types = FALSE)
tokens_all         <- readr::read_csv(tokens_path_all,         show_col_types = FALSE)
tokens_comments    <- readr::read_csv(tokens_path_comments,    show_col_types = FALSE)

# ---- column names (quick check) ----
cat("\nNO_COMMENTS columns:\n"); print(names(tokens_no_comments))
cat("\nALL columns:\n");         print(names(tokens_all))
cat("\nCOMMENTS_ONLY columns:\n"); print(names(tokens_comments))

quick_counts <- function(df){
  nms <- names(df)
  vid <- intersect(c("video_id","videoId","videoID","yt_video_id","id"), nms)
  sp  <- intersect(c("TaxonName","species","species_name","CleanName","SciName","scientific_name"), nms)

  out <- list(
    n_rows = nrow(df),
    n_cols = ncol(df)
  )
  if (length(vid) > 0) out$n_unique_videos <- dplyr::n_distinct(df[[vid[1]]])
  if (length(sp)  > 0) out$n_unique_species <- dplyr::n_distinct(df[[sp[1]]])
  out
}

cat("\nCounts NO_COMMENTS:\n"); print(quick_counts(tokens_no_comments))
cat("\nCounts ALL:\n");         print(quick_counts(tokens_all))
cat("\nCounts COMMENTS_ONLY:\n"); print(quick_counts(tokens_comments))


FIG2_TOKEN_SOURCE <- switch(
  ANALYSIS_MODE,
  "NO_COMMENTS" = "NO_COMMENTS",
  "COMMENTS_TIMESTAMPS" = "ALL",
  "COMMENTS_ONLY" = "COMMENTS_ONLY",
  "NO_COMMENTS"
)


tokens_path_no_comments <- file.path(root_tables, "keywords", "token_table_from_BASE_raw_NO_COMMENTS.csv")
tokens_path_all         <- file.path(root_tables, "keywords", "token_table_from_BASE_raw.csv")
tokens_path_comments     <- file.path(root_tables, "keywords", "token_table_from_BASE_raw_COMMENTS.csv")

# pick the chosen one (and keep compatibility objects kw_df_AB and kw_df_C)
tokens_path_fig2 <- dplyr::case_when(
  FIG2_TOKEN_SOURCE == "NO_COMMENTS"   ~ tokens_path_no_comments,
  FIG2_TOKEN_SOURCE == "COMMENTS_ONLY" ~ tokens_path_comments,
  TRUE                                 ~ tokens_path_all
)

if (!file.exists(tokens_path_fig2)) stop("Missing token file for FIG2_TOKEN_SOURCE='", FIG2_TOKEN_SOURCE, "': ", tokens_path_fig2)

# We keep the old naming so the rest of your script stays unchanged:
#   kw_df_AB = the dataset used for B + inset C
#   kw_df_C  = the dataset used for overall trend A
kw_df_AB <- readr::read_csv(tokens_path_fig2, show_col_types = FALSE)
kw_df_C  <- readr::read_csv(tokens_path_fig2, show_col_types = FALSE)

harmonize_tokens <- function(df) {
  if ("KeywordCategory" %in% names(df) && !("category" %in% names(df))) df <- dplyr::rename(df, category = KeywordCategory)
  need_cols <- c("video_id","TaxonName","LifeForm","PresentStatus","word","category","time_period","created_at")
  for (cc in need_cols) if (!cc %in% names(df)) df[[cc]] <- NA

  df %>%
    mutate(
      TaxonName     = gsub("_"," ", as.character(TaxonName)),
      time_period   = normalize_time_period_vec(time_period),
      category      = as.character(category),
      LifeForm      = as.character(LifeForm),
      PresentStatus = as.character(PresentStatus),
      word          = as.character(word),
      created_at    = suppressWarnings(as.POSIXct(created_at, tz = "UTC"))
    ) %>%
    filter(!is.na(word), word != "",
           !is.na(category), category != "",
           !is.na(time_period)) %>%
    distinct()
}

kw_df_AB <- harmonize_tokens(kw_df_AB)
kw_df_C  <- harmonize_tokens(kw_df_C)

# Save the long token table used by Fig2 (now includes comments depending on FIG2_TOKEN_SOURCE)
save_table_safely(
  kw_df_AB %>% dplyr::select(video_id, TaxonName, LifeForm, PresentStatus, word, category, time_period, created_at),
  file.path(root_tables, "keywords", paste0("keywords_long_before_after_FOR_FIG2__", FIG2_TOKEN_SOURCE, ".csv"))
)

# ======================================================================
# LIFEFORM proportions builder (used by BOTH vertical + horizontal insets)
# ======================================================================
build_lifeform_props_from_tokens <- function(kdf, vtbl) {

  # join LifeForm from video table if needed
  if (!"LifeForm" %in% names(kdf) || all(is.na(kdf$LifeForm))) {
    kdf <- kdf %>%
      left_join(vtbl %>% dplyr::select(video_id, LifeForm) %>% distinct(), by = "video_id")
  }

  df <- kdf %>%
    filter(!is.na(LifeForm), LifeForm != "",
           !is.na(category), category != "",
           !is.na(time_period)) %>%
    mutate(time_period = normalize_time_period_vec(time_period)) %>%
    count(LifeForm, category, time_period, name = "n") %>%
    group_by(time_period) %>%
    mutate(total_in_period = sum(n),
           prop = 100 * n / ifelse(total_in_period > 0, total_in_period, 1)) %>%
    ungroup() %>%
    mutate(category_time = paste0(category, "_", time_period)) %>%
    mutate(LifeForm = factor(LifeForm, levels = desired_lf_order)) %>%
    filter(!is.na(LifeForm))

  df
}

# ---------- Inset % labels: ONE per LifeForm (bar total) ----------
make_lifeform_total_labels <- function(df, orientation = c("horizontal","vertical")) {
  orientation <- match.arg(orientation)
  out <- df %>%
    group_by(LifeForm) %>%
    summarise(prop_total = sum(prop, na.rm = TRUE), .groups = "drop") %>%
    mutate(lab = ifelse(is.na(prop_total) | prop_total <= 0, "", sprintf("%.0f%%", prop_total)))
  out
}

# ======================================================================
# Export LIFEFORM inset PNGs (VERTICAL and HORIZONTAL) with icons-only
# ======================================================================
export_lifeform_vertical_png_for_inset <- function(kdf, vtbl, out_dir, suffix = "") {
  ensure_dir(out_dir)

  df_lf_prop <- build_lifeform_props_from_tokens(kdf, vtbl)
  df_lf_tot  <- make_lifeform_total_labels(df_lf_prop, orientation = "vertical")

  legend_breaks <- c(
    "Detection_Pre-Introduction","Detection_Post-Introduction",
    "eCommerce_Pre-Introduction","eCommerce_Post-Introduction",
    "Invasion_Pre-Introduction","Invasion_Post-Introduction",
    "Threat_Pre-Introduction","Threat_Post-Introduction"
  )

  p_lf_vert <- ggplot(df_lf_prop, aes(x = LifeForm, y = prop, fill = category_time)) +
    geom_col(position = "stack", width = 0.82) +
    geom_text(
      data = df_lf_tot,
      aes(x = LifeForm, y = prop_total, label = lab),
      inherit.aes = FALSE,
      vjust = -0.30, hjust = 0.5,
      size  = INSET_PCT_GG_SIZE
    ) +
    scale_fill_manual(values = category_colors, breaks = legend_breaks,
                      labels = label_category_time, drop = FALSE,
                      name = legend_name("Thematic category (period)")) +
    scale_x_discrete(drop = FALSE, labels = function(x) dplyr::recode(x, !!!lifeform_display_labels, .default = x)) +
    labs(x = NULL, y = NULL, title = NULL) +
    theme_inat(BASE_FSIZE) +
    theme(
      legend.position = "none",
      panel.grid      = element_blank(),
      legend.title       = element_text(size = LEG_TITLE_SIZE),
      legend.text        = element_text(size = LEG_TEXT_SIZE),
      axis.text.x     = element_blank(),
      axis.ticks.x    = element_blank(),
      axis.title.x    = element_blank(),
      axis.text.y     = element_blank(),
      axis.ticks.y    = element_blank(),
      axis.title.y    = element_blank(),
      plot.margin     = margin(t = 3, r = 3, b = 3, l = 3)
    ) + FORCE_PLAIN_X +
    coord_cartesian(ylim = c(0, max(df_lf_tot$prop_total, na.rm = TRUE) * 1.10), clip = "off")

  p_lf_vert <- p_lf_vert + theme(plot.margin = margin(0, 0, 0, 0))

  p_lf_vert_icons <- add_x_icons_compact(
    p_vert          = p_lf_vert,
    x_levels        = levels(df_lf_prop$LifeForm),
    icon_paths      = icon_paths,
    icon_height_frac = 0.25,
    icon_width_frac  = 0.98,
    gap_frac         = -0.005
  ) +
    scale_x_discrete(labels = function(x) rep("", length(x))) +
    theme(
      axis.title.x = element_blank(),
      axis.text.x  = element_blank(),
      axis.ticks.x = element_blank()
    ) + FORCE_PLAIN_X

  outfile_base <- file.path(out_dir, paste0("kw_lifeform_raw_periodnorm_with_icons_VERTICAL_TOP50__", FIG2_TOKEN_SOURCE, suffix))
  save_plot_safely(p_lf_vert_icons, paste0(outfile_base, ".png"),
                   width = 285, height = 185, units = "mm")
  save_variant_noLegend_noXtitle(p_lf_vert_icons, outfile_base, width = 285, height = 185, units = "mm")

  invisible(TRUE)
}

export_lifeform_horizontal_png_for_inset <- function(kdf, vtbl, out_dir, suffix = "") {
  ensure_dir(out_dir)

  df_lf_prop <- build_lifeform_props_from_tokens(kdf, vtbl)
  df_lf_prop <- df_lf_prop %>%
    mutate(LifeForm = factor(LifeForm, levels = rev(desired_lf_order))) %>%
    filter(!is.na(LifeForm))

  df_lf_tot <- make_lifeform_total_labels(df_lf_prop, orientation = "horizontal")

  legend_breaks <- c(
    "Detection_Pre-Introduction","Detection_Post-Introduction",
    "eCommerce_Pre-Introduction","eCommerce_Post-Introduction",
    "Invasion_Pre-Introduction","Invasion_Post-Introduction",
    "Threat_Pre-Introduction","Threat_Post-Introduction"
  )

  p_lf_h <- ggplot(df_lf_prop, aes(x = prop, y = LifeForm, fill = category_time)) +
    geom_col(position = "stack", width = 0.82) +
    geom_text(
      data = df_lf_tot,
      aes(x = prop_total, y = LifeForm, label = lab),
      inherit.aes = FALSE,
      hjust = -0.10, vjust = 0.5,
      size  = INSET_PCT_GG_SIZE
    ) +
    scale_fill_manual(values = category_colors, breaks = legend_breaks,
                      labels = label_category_time, drop = FALSE,
                      name = legend_name("Category (period)")) +
    labs(x = "Proportion by time period (%)", y = NULL, title = NULL) +
    theme_inat(BASE_FSIZE) +
    theme(
      legend.position = "none",
      panel.grid      = element_blank(),
      axis.title.x = element_blank(),
      axis.text.x  = element_blank(),
      axis.ticks.x = element_blank(),
      axis.title.y    = element_blank(),
      axis.text.y     = element_blank(),
      axis.ticks.y    = element_blank()
    ) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.10))) +
    FORCE_PLAIN_X

  p_lf_h_icons <- add_y_icons_compact(
    p_horiz     = p_lf_h,
    y_levels    = levels(df_lf_prop$LifeForm),
    icon_paths  = icon_paths,
    icon_width_frac = 0.18,
    icon_half_height = 0.52
  ) +
    theme(
      axis.text.y  = element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.x  = element_blank(),
      axis.ticks.x = element_blank(),
      axis.title.x = element_blank()
    ) + FORCE_PLAIN_X

  outfile_base <- file.path(out_dir, paste0("kw_lifeform_raw_periodnorm_with_icons_HORIZONTAL_TOP50__", FIG2_TOKEN_SOURCE, suffix))
  save_plot_safely(p_lf_h_icons, paste0(outfile_base, ".png"),
                   width = 285, height = 185, units = "mm")
  save_variant_noLegend_noXtitle(p_lf_h_icons, outfile_base, width = 285, height = 185, units = "mm")

  invisible(TRUE)
}

# ===================== Builders (SPECIES) =====================
make_kw_species_plots <- function(kdf, vtbl, out_dir, suffix="") {
  ensure_dir(out_dir)

  first_year_tbl <- vtbl %>%
    filter(!is.na(TaxonName)) %>%
    group_by(TaxonName) %>%
    summarise(FirstRecord = suppressWarnings(as.integer(min(FirstRecord, na.rm = TRUE))), .groups = "drop") %>%
    mutate(FirstRecord = ifelse(is.infinite(FirstRecord), NA_integer_, FirstRecord))

  status_map <- c(established = "E", alien = "P", casual = "C", uncertain = "U")
  species_status <- vtbl %>%
    filter(!is.na(TaxonName), !is.na(PresentStatus)) %>%
    count(TaxonName, PresentStatus, name = "n") %>%
    arrange(TaxonName, desc(n)) %>%
    group_by(TaxonName) %>% slice(1) %>% ungroup() %>%
    mutate(status_letter = dplyr::recode(PresentStatus, !!!status_map, .default = "")) %>%
    dplyr::select(TaxonName, status_letter)

  order_species_by_year <- function(species_vec, first_year_tbl) {
    first_year_tbl %>%
      filter(TaxonName %in% species_vec) %>%
      mutate(yr = ifelse(is.na(FirstRecord), Inf, FirstRecord)) %>%
      arrange(yr, TaxonName) %>% pull(TaxonName) %>% unique()
  }

  year_labels_for <- function(sp_alpha) {
    yrs <- first_year_tbl %>% filter(TaxonName %in% sp_alpha)
    if (nrow(yrs) == 0) return(tibble(FirstRecord = integer(0), y = numeric(0)))
    yrs$y_index <- match(yrs$TaxonName, sp_alpha)
    yrs %>% group_by(FirstRecord) %>% summarise(y = mean(y_index), .groups = "drop") %>% arrange(y)
  }

  legend_breaks <- c(
    "Detection_Pre-Introduction","Detection_Post-Introduction",
    "eCommerce_Pre-Introduction","eCommerce_Post-Introduction",
    "Invasion_Pre-Introduction","Invasion_Post-Introduction",
    "Threat_Pre-Introduction","Threat_Post-Introduction"
  )

  scale_ct <- scale_fill_manual(
    values = category_colors,
    breaks = legend_breaks,
    labels = label_category_time,
    drop   = FALSE,
    name   = legend_name("Thematic category (period)")
  )

  raw_base <- kdf %>%
    filter(!is.na(TaxonName), !is.na(category), category != "", !is.na(time_period)) %>%
    mutate(time_period = normalize_time_period_vec(time_period)) %>%
    count(TaxonName, category, time_period, name = "n")

  raw_period <- raw_base %>%
    group_by(time_period) %>%
    mutate(total_in_period = sum(n),
           prop = 100 * n / ifelse(total_in_period > 0, total_in_period, 1)) %>%
    ungroup() %>%
    mutate(category_time = paste0(category, "_", time_period))

  sp_totals_period <- raw_period %>% group_by(TaxonName) %>% summarise(total_prop = sum(prop), .groups = "drop")
  sp_sel_period <- sp_totals_period %>% arrange(desc(total_prop)) %>%
    slice_head(n = if (is.infinite(TOPN_KEYWORD_SPECIES)) nrow(.) else TOPN_KEYWORD_SPECIES) %>%
    pull(TaxonName)
  sp_alpha_period <- order_species_by_year(sp_sel_period, first_year_tbl)
  year_groups_period <- year_labels_for(sp_alpha_period)

  x_max_period <- (raw_period %>%
                     filter(TaxonName %in% sp_alpha_period) %>%
                     group_by(TaxonName) %>%
                     summarise(s = sum(prop), .groups="drop") %>%
                     pull(s) %>% max(0)) * 1.15
  x_status_period <- x_max_period * 0.90
  x_div_period    <- x_max_period * 0.92
  x_year_period   <- x_max_period * 0.95

  p_raw_period <- raw_period %>%
    filter(TaxonName %in% sp_alpha_period) %>%
    ggplot(aes(x = prop, y = forcats::fct_relevel(TaxonName, sp_alpha_period), fill = category_time)) +
    geom_col(width = 0.8, position = "stack") +
    scale_ct +
    labs(x = "Proportion by time period (%)", y = "Non-native species (NNS)") +
    theme_inat(BASE_FSIZE) +
    theme(
      legend.position = "top",
      legend.title    = if (LEGEND_SHOW_TITLE) element_text(size = LEG_TITLE_SIZE) else element_blank(),
      legend.text     = element_text(size = LEG_TEXT_SIZE - 1),

      axis.text.x  = element_text(size = 17, face = "plain", margin = margin(t = 8)),
      axis.title.x = element_text(size = 19, face = "plain", margin = margin(t = 18)),
      axis.title.y = element_text(size = 19, face = "plain", angle = 90, margin = margin(r = 20)),

      axis.text.y  = element_text(size = 14, face = "italic", margin = margin(r = 6)),

      plot.margin  = margin(t = 3, r = 3, b = 3, l = 15)
    ) +
    FORCE_PLAIN_X +
    coord_cartesian(xlim = c(0, x_max_period), clip = "off") +
    annotate("segment", x = x_div_period, xend = x_div_period,
             y = 0.5, yend = length(sp_alpha_period) + 0.5, linewidth = 0.4,
             linetype = "dashed") +
    geom_text(data = year_groups_period,
              aes(x = x_year_period, y = y, label = ifelse(is.na(FirstRecord), "", FirstRecord)),
              inherit.aes = FALSE, hjust = 0, size = B_INPLOT_GG_SIZE)

  end_period <- raw_period %>%
    filter(TaxonName %in% sp_alpha_period) %>%
    group_by(TaxonName) %>%
    summarise(x_end = sum(prop), .groups = "drop") %>%
    left_join(species_status, by = "TaxonName") %>%
    mutate(x_lab = x_status_period, y_fac = factor(TaxonName, levels = sp_alpha_period))

  p_raw_period <- p_raw_period +
    geom_text(data = end_period,
              aes(x = x_lab, y = y_fac, label = status_letter),
              inherit.aes = FALSE, size = B_INPLOT_GG_SIZE, vjust = 0.5, hjust = 1)

  h_raw_period <- max(220, 5.5 * length(sp_alpha_period))
  save_plot_safely(p_raw_period, file.path(out_dir, paste0("kw_species_raw_periodnorm__", FIG2_TOKEN_SOURCE, suffix, "_TOP50.png")),
                   width = 305, height = h_raw_period, units = "mm")

  assign("fig2_species_plot",  p_raw_period, envir = .GlobalEnv)
  invisible(TRUE)
}

save_species_nolegend_png <- function(out_dir) {
  pA_noleg <- get("fig2_species_plot", envir = .GlobalEnv) + theme(legend.position = "none")
  save_plot_safely(
    pA_noleg,
    file.path(out_dir, paste0("kw_species_raw_periodnorm_NOLEGEND_TOP50__", FIG2_TOKEN_SOURCE, ".png")),
    width = 305, height = 185, units = "mm"
  )
}

render_variant_fig2 <- function() {
  vf <- videos_tbl
  kf <- kw_df_AB

  nspp <- vf %>% filter(!is.na(TaxonName)) %>% pull(TaxonName) %>% n_distinct()
  if (KW_SPECIES_MODE == "ALL") TOPN_KEYWORD_SPECIES <<- Inf
  if (KW_SPECIES_MODE == "TOPP") TOPN_KEYWORD_SPECIES <<- max(1, round(nspp * TOPP_KEYWORD_SPECIES))

  make_kw_species_plots(kdf = kf, vtbl = vf,
                        out_dir = paper_keyword_fig_dir(),
                        suffix  = "")

  export_lifeform_horizontal_png_for_inset(kdf = kf, vtbl = vf,
                                          out_dir = paper_keyword_fig_dir(),
                                          suffix = "")
  export_lifeform_vertical_png_for_inset(kdf = kf, vtbl = vf,
                                        out_dir = paper_keyword_fig_dir(),
                                        suffix = "")
}

render_variant_fig2()
save_species_nolegend_png(out_dir = paper_keyword_fig_dir())

# =====================================================================
# PANEL COMPOSITION (TOP trend + B species with inset + legend)
# =====================================================================
suppressPackageStartupMessages({ library(cowplot); library(mgcv); library(scales); library(png) })
out_dir <- FIG2_TMP_DIR

png_size_mm <- function(path, default_dpi = 300) {
  img  <- png::readPNG(path, native = FALSE, info = TRUE)
  info <- attributes(img)$info
  xdpi <- if (!is.null(info$xres)) as.numeric(info$xres) else default_dpi
  ydpi <- if (!is.null(info$yres)) as.numeric(info$yres) else default_dpi
  dims <- dim(img)
  wpx  <- as.numeric(dims[2]); hpx <- as.numeric(dims[1])
  c(width_mm = (wpx / xdpi) * 25.4, height_mm = (hpx / ydpi) * 25.4)
}
read_png_grob <- function(path, interpolate = TRUE) {
  img <- png::readPNG(path, native = TRUE)
  grid::rasterGrob(img, interpolate = interpolate)
}

build_overall_ts <- function() {
  kw_df_C %>%
    filter(!is.na(created_at), !is.na(category), category != "") %>%
    mutate(month = lubridate::floor_date(created_at, unit = "month")) %>%
    count(month, category, name = "n") %>%
    group_by(month) %>%
    mutate(prop = 100 * n / sum(n)) %>%
    ungroup()
}

TREND_LWD <- 1.8

make_trend_GAM <- function(ci = TRUE) {
  ts_overall <- build_overall_ts()
  cat_cols <- base_cols[c("Detection","Threat","eCommerce","Invasion")]
  n_months <- length(unique(ts_overall$month))
  k_val    <- min(20, max(6, n_months - 1))
  gam_form <- as.formula(paste0("y ~ s(x, bs = 'tp', k = ", k_val, ")"))

  ggplot(ts_overall, aes(x = month, y = prop, color = category, group = category)) +
    geom_point(size = 1.2, alpha = 0.55, show.legend = TRUE) +
    geom_smooth(method = mgcv::gam, formula = gam_form, se = ci,
                linewidth = TREND_LWD, aes(fill = category),
                alpha = 0.18, show.legend = FALSE) +
    geom_smooth(method = mgcv::gam, formula = gam_form, se = FALSE,
                linewidth = TREND_LWD, alpha = 0, show.legend = TRUE) +
    scale_color_manual(values = cat_cols, name = "Thematic category") +
    scale_fill_manual(values = cat_cols, guide = "none") +
    guides(color = guide_legend(override.aes = list(
      linetype = 1, linewidth = 1.5, shape = 16, size = 2.6, alpha = 1
    ))) +
    scale_x_date(labels = scales::label_date("%Y"), breaks = scales::pretty_breaks(n = 8)) +
    labs(x = "Video upload date", y = "Monthly keyword proportion (%)") +
    theme_light(base_size = BASE_FSIZE) +
    theme(
      axis.text.x  = element_text(size = 12, angle = 0, hjust = 1, margin = margin(t = 8)),
      axis.text.y  = element_text(size = 12),
      axis.title.x = element_text(size = 14, margin = margin(t = 18)),
      axis.title.y = element_text(size = 14, margin = margin(r = 10)),
      legend.text  = element_text(size = 13),
      legend.title = element_text(size = 13)
    )
}

LEG_W <- 0.22
LEG_H <- 0.98
PAD_R <- 0.000

LEG_X_NUDGE_A <- 0.006
LEG_X_NUDGE_B <- 0.010

TOP_TREND_HEIGHT_MM <- 125
TOP_TREND_WIDTH_MM  <- 290

save_trend_GAM_CI_A_only <- function(out_dir) {
  p_trend <- make_trend_GAM(ci = TRUE) + theme(legend.position = "right")
  leg_tr <- cowplot::get_legend(p_trend)
  p_trend_noleg <- p_trend + theme(legend.position = "none")

  LEG_X_CANVAS <- 1 - LEG_W - PAD_R - LEG_X_NUDGE_A

  gA <- cowplot::ggdraw() +
    cowplot::draw_plot(p_trend_noleg, x = 0.03, y = 0, width = 1 - LEG_W, height = 1) +
    cowplot::draw_grob(
      leg_tr,
      x = LEG_X_CANVAS, y = 0.6,
      width = LEG_W, height = LEG_H,
      hjust = 0, vjust = 0.5
    ) +
    cowplot::draw_label("A)",
                        x = 0.0150, y = 0.985,
                        hjust = 0, vjust = 1,
                        fontface = "plain", size = TAG_SIZE)

  out_file <- file.path(out_dir, paste0("Fig2A_trend_GAM_with_CI__", FIG2_TOKEN_SOURCE, ".png"))
  save_plot_safely(gA, out_file, width = TOP_TREND_WIDTH_MM, height = TOP_TREND_HEIGHT_MM, units = "mm")
  out_file
}

INSET_KNOBS_HORIZ <- list(
  OFFSET_L = -0.065,
  INSET_X  = 0.415,
  INSET_Y  = 0.142,
  INSET_H  = 0.35,
  INSET_W  = 0.28,
  DX       = 0.035,
  DY       = -0.01
)

INSET_KNOBS_VERT <- list(
  OFFSET_L = -0.065,
  INSET_X  = 0.40,
  INSET_Y  = 0.13689,
  INSET_H  = 0.37,
  INSET_W  = 0.30,
  DX       = 0.035,
  DY       = -0.01
)

compose_AB_only_panel <- function(out_dir, outfile_suffix = "ABonly", INSET_ORIENTATION = c("horizontal","vertical")[1]) {

  sp_png <- file.path(out_dir, paste0("kw_species_raw_periodnorm_NOLEGEND_TOP50__", FIG2_TOKEN_SOURCE, ".png"))

  lf_h_png1 <- file.path(out_dir, paste0("kw_lifeform_raw_periodnorm_with_icons_HORIZONTAL_TOP50__", FIG2_TOKEN_SOURCE, "_noLegend_noXtitle.png"))
  lf_h_png2 <- file.path(out_dir, paste0("kw_lifeform_raw_periodnorm_with_icons_HORIZONTAL_TOP50__", FIG2_TOKEN_SOURCE, ".png"))
  lf_v_png1 <- file.path(out_dir, paste0("kw_lifeform_raw_periodnorm_with_icons_VERTICAL_TOP50__", FIG2_TOKEN_SOURCE, "_noLegend_noXtitle.png"))
  lf_v_png2 <- file.path(out_dir, paste0("kw_lifeform_raw_periodnorm_with_icons_VERTICAL_TOP50__", FIG2_TOKEN_SOURCE, ".png"))

  lf_png_horizontal <- if (file.exists(lf_h_png1)) lf_h_png1 else lf_h_png2
  lf_png_vertical   <- if (file.exists(lf_v_png1)) lf_v_png1 else lf_v_png2

  lf_png <- if (INSET_ORIENTATION == "vertical") lf_png_vertical else lf_png_horizontal
  if (!file.exists(lf_png)) stop("Inset file not found: ", lf_png)
  if (!file.exists(sp_png)) stop("Species NOLEGEND file not found: ", sp_png)

  g_species <- read_png_grob(sp_png)
  mm_sp     <- png_size_mm(sp_png)

  sp_legend <- cowplot::get_legend(
    get("fig2_species_plot", envir = .GlobalEnv) +
      guides(
        fill = guide_legend(
          byrow = TRUE,
          keyheight = unit(9, "mm")
        )
      ) +
      theme(
        legend.position = "right",
        legend.text     = element_text(size = LEG_TEXT_SIZE - 1),
        legend.title    = element_text(size = LEG_TITLE_SIZE)
      )
  )

  kn <- if (INSET_ORIENTATION == "vertical") INSET_KNOBS_VERT else INSET_KNOBS_HORIZ

  OFFSET_L <- kn$OFFSET_L
  INSET_X  <- kn$INSET_X
  INSET_Y  <- kn$INSET_Y
  INSET_H  <- kn$INSET_H
  INSET_W  <- kn$INSET_W
  STACKED_INSET_DX <- kn$DX
  STACKED_INSET_DY <- kn$DY

  PAD_R_B <- 0.03
  SPEC_W  <- 1 - LEG_W - PAD_R_B
  LEG_X_CANVAS <- 1 - LEG_W - PAD_R_B - LEG_X_NUDGE_B

  LEG_Y <- 0.55

  INSET_X_CANVAS <- OFFSET_L + INSET_X + STACKED_INSET_DX
  INSET_Y_CANVAS <- INSET_Y + STACKED_INSET_DY

  TAG_X_B <- 0.001

  X_STATUS_HDR <- SPEC_W * 0.902
  X_YEAR_HDR   <- SPEC_W * 0.923
  Y_HDR        <- 1.02

  p <- cowplot::ggdraw() +
    theme(plot.margin = margin(t = 6, r = 3, b = 3, l = 3, unit = "mm")) +
    cowplot::draw_grob(g_species, x = 0, y = 0, width = SPEC_W, height = 1,
                       hjust = 0, vjust = 0) +
    cowplot::draw_label("B)", x = TAG_X_B, y = 0.985,
                        hjust = 0, vjust = 1,
                        fontface = "plain", size = 24) +
    cowplot::draw_image(lf_png,
                        x = INSET_X_CANVAS, y = INSET_Y_CANVAS,
                        width = INSET_W, height = INSET_H,
                        hjust = 0, vjust = 0) +
    cowplot::draw_label("C)",
                        x = INSET_X_CANVAS + 0.24,
                        y = INSET_Y_CANVAS + INSET_H - 0.020,
                        hjust = 0, vjust = 1,
                        fontface = "plain", size = 24) +
    cowplot::draw_grob(sp_legend,
                       x = LEG_X_CANVAS, y = LEG_Y,
                       width = LEG_W, height = LEG_H,
                       hjust = 0, vjust = 0.5) +
    cowplot::draw_label("STATUS",
                        x = X_STATUS_HDR, y = Y_HDR,
                        hjust = 1, vjust = 1,
                        fontface = "plain", size = 12) +
    cowplot::draw_label("YFIR",
                        x = X_YEAR_HDR, y = Y_HDR,
                        hjust = 0, vjust = 1,
                        fontface = "plain", size = 12)

  outfile_base <- file.path(out_dir, paste0("Figure2_PANEL__", outfile_suffix, "__", FIG2_TOKEN_SOURCE))

  W_species_mm <- as.numeric(mm_sp["width_mm"])
  H_canvas_mm  <- as.numeric(mm_sp["height_mm"])
  W_canvas_mm  <- W_species_mm / SPEC_W

  save_plot_safely(
    p, paste0(outfile_base, ".png"),
    width  = W_canvas_mm,
    height = H_canvas_mm,
    units  = "mm"
  )

  paste0(outfile_base, ".png")
}

VERT_PANEL_GAP_REL      <- 0.008
VERT_TOP_REL_HEIGHT     <- 0.7
VERT_BOTTOM_REL_HEIGHT  <- 0.7
VERT_TOP_REL_WIDTH      <- 1.00
VERT_BOTTOM_REL_WIDTH   <- 1.00

compose_TREND_top_AB_bottom <- function(trend_png, ab_png, outfile_suffix,
                                        scale_factor = 1.2, dpi = 300) {

  mm_top_orig <- png_size_mm(trend_png)
  mm_bot_orig <- png_size_mm(ab_png)

  W_canvas_mm <- max(as.numeric(mm_top_orig["width_mm"]), as.numeric(mm_bot_orig["width_mm"]))
  H_canvas_mm <- (as.numeric(mm_top_orig["height_mm"]) + as.numeric(mm_bot_orig["height_mm"])) * scale_factor

  ht_rel <- VERT_TOP_REL_HEIGHT; hb_rel <- VERT_BOTTOM_REL_HEIGHT
  s_h <- ht_rel + hb_rel
  ht0 <- ht_rel / s_h; hb0 <- hb_rel / s_h

  g <- VERT_PANEL_GAP_REL
  scale_h <- (1 - g)
  ht <- ht0 * scale_h
  hb <- hb0 * scale_h

  yb <- 0
  yt <- hb + g

  g_top <- read_png_grob(trend_png)
  g_bot <- read_png_grob(ab_png)

  TOP_SHRINK <- 0.918
  A_X_SHIFT  <- -0.005

  TOP_W <- VERT_TOP_REL_WIDTH * TOP_SHRINK
  TOP_H <- ht * TOP_SHRINK

  TOP_X <- 0 + A_X_SHIFT
  TOP_Y <- yt + (ht - TOP_H) / 2

  p <- cowplot::ggdraw() +
    cowplot::draw_grob(
      g_top,
      x = TOP_X, y = TOP_Y,
      width = TOP_W, height = TOP_H,
      hjust = 0, vjust = 0
    ) +
    cowplot::draw_grob(
      g_bot,
      x = 0, y = yb,
      width = VERT_BOTTOM_REL_WIDTH, height = hb,
      hjust = 0, vjust = 0
    )

  outfile_base <- file.path(out_dir, paste0("Figure2_PANEL_TOPtrend__", outfile_suffix, "__", FIG2_TOKEN_SOURCE))
  save_plot_safely(p, paste0(outfile_base, ".png"),
                   width = W_canvas_mm, height = H_canvas_mm, units = "mm")

  paste0(outfile_base, ".png")
}

# ---- RUN FINAL EXPORT (BOTH inset variants) ----
trend_gam_CI_A <- save_trend_GAM_CI_A_only(out_dir = out_dir)

ab_only_path_H <- compose_AB_only_panel(out_dir = out_dir, outfile_suffix = "ABonly_HORIZ", INSET_ORIENTATION = "horizontal")
compose_TREND_top_AB_bottom(
  trend_png      = trend_gam_CI_A,
  ab_png         = ab_only_path_H,
  outfile_suffix = "GAM_overall_with_CI_large_HORIZ",
  scale_factor   = 1.2,
  dpi            = 300
)

ab_only_path_V <- compose_AB_only_panel(out_dir = out_dir, outfile_suffix = "ABonly_VERT", INSET_ORIENTATION = "vertical")
compose_TREND_top_AB_bottom(
  trend_png      = trend_gam_CI_A,
  ab_png         = ab_only_path_V,
  outfile_suffix = "GAM_overall_with_CI_large_VERT",
  scale_factor   = 1.2,
  dpi            = 300
)


# Final Figure 2 export is handled directly inside save_plot_safely().
