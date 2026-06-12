if (file.exists("scripts/00_direct_output_config.R")) source("scripts/00_direct_output_config.R", encoding = "UTF-8")
# ============================================================
# 11_figures_S1_S2_engagement.R
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
# Figure 4 (age-controlled): split into TWO 2-panel figures
#   - Figure S1: (A) top uploads + dashed EC_adj rulers, (B) bubble
#   - Figure S2: (A) life-form uploads (icons), (B) life-form EC_adj (icons)
#   - Keeps ONLY palette variants: Spectral, Accent, Set2, Set3 (bubble panels)
#   - Applies Fig 1-3 icon order
#   - Larger tag letters (22) + larger fonts (titles/text/legends)
#   - Extra right outer margin so legends are not cut
#   - Bubble species labels in italics
#
# MINIMAL UPDATE (as requested now):
#   Panel S2:
#     - Keep SAME S2 format
#     - ONLY increase spacing between x-axis title and x-axis text for S2 plot A (icons/uploads)
#     - DO NOT change S2 plot B spacing
#   Also: fix palette builder S2 plot A margin (was incorrectly set to l=20 causing clipping)
#
# UPDATE (NOW REQUESTED):
#   - Replace icon path setup with robust ICON_DIR picker (from other figures)
#   - Keep icon recolor via as_rgba() BUT DO NOT write tinted files to disk
#   - Remove any "_tinted_icons" path usage
#   - Apply recolor on-the-fly inside add_y_icons_compact()
# ===========================================================

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(ggplot2); library(forcats); library(stringr)
  library(ggrepel); library(scales); library(readr); library(lubridate); library(mgcv)
  library(png); library(grid); library(cowplot)
  library(viridisLite); library(RColorBrewer)
})

# ----------------------- Globals & helpers -----------------------
TOPN_SPECIES <- 30

# Font sizes (requested)
AXIS_TITLE_SIZE <- 19
AXIS_TEXT_SIZE  <- 17
LEG_TITLE_SIZE  <- 19
LEG_TEXT_SIZE   <- 17
TAG_SIZE        <- 22

# Spacing knobs (explicit + used)
AX_TITLE_TEXT_GAP_S1 <- 20  # S1: make A match B by being explicit
AX_TITLE_TEXT_GAP_S2 <- 24  # (kept, but will be applied ONLY to S2 plot A)
AX_TEXT_TOP_GAP       <- 6  # explicit space between tick labels and axis line (readability)

# ### FIX: S2 plot A only - title-to-ticks gap
AX_TITLE_TEXT_GAP_S2_A <- 24  # only applied to S2 plot A (icons/uploads)

# Extra outer right margin so legend never gets cut (requested)
OUTER_RIGHT_PAD <- 30

ensure_dir <- function(path) if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)

save_plot_safely <- function(plot, filename, width=185, height=175, units="mm", dpi=300, bg="white") {
  ensure_dir(dirname(filename))
  ggsave(filename, plot = plot, width = width, height = height, units = units, dpi = dpi, bg = bg)
  message("Saved plot: ", filename)
}
save_table_safely <- function(df, filename) {
  ensure_dir(dirname(filename)); readr::write_csv(df, filename, na = ""); message("Saved table: ", filename)
}

# ----------------------- Life-form order & palettes -----------------------
lifeform_levels <- c(
  "Birds","Insects","Herptiles","Fishes","Non-arthropod invertebrates",
  "Crustaceans","Bacteria, Viruses, Fungi","Plants","Unknown"
)

desired_lf_order <- c(
  "Birds","Herptiles","Fishes","Insects",
  "Crustaceans","Non-arthropod invertebrates","Plants","Bacteria, Viruses, Fungi"
)
KEEP_LF <- desired_lf_order
LF_TOP_FIRST <- rev(KEEP_LF)

lifeform_palette <- c(
  "Birds"="#FDDC5C","Insects"="#40E0D0","Herptiles"="#3357FF",
  "Fishes"="#A50026","Non-arthropod invertebrates"="#313695","Crustaceans"="#33FF57",
  "Bacteria, Viruses, Fungi"="#F85820","Plants"="#90D0F8","Unknown"="#B0B0B0"
)

`%||%` <- function(a, b) if (!is.null(a)) a else b

# Directories
out_root   <- file.path("outputs", "intermediate", "engagement")
out_tables <- file.path(out_root, "tables")
out_figs   <- file.path(out_root, "figs")
ensure_dir(out_tables); ensure_dir(out_figs)

theme_sizes_patch <- theme(
  axis.title.x = element_text(size = AXIS_TITLE_SIZE),
  axis.title.y = element_text(size = AXIS_TITLE_SIZE),
  axis.text.x  = element_text(size = AXIS_TEXT_SIZE),
  axis.text.y  = element_text(size = AXIS_TEXT_SIZE),
  legend.title = element_text(size = LEG_TITLE_SIZE),
  legend.text  = element_text(size = LEG_TEXT_SIZE)
)

theme_sizes_icons_patch <- theme(
  axis.title.x = element_text(size = AXIS_TITLE_SIZE),
  axis.text.x  = element_text(size = AXIS_TEXT_SIZE),
  legend.title = element_text(size = LEG_TITLE_SIZE),
  legend.text  = element_text(size = LEG_TEXT_SIZE),

  axis.text.y  = element_blank(),
  axis.title.y = element_blank(),
  axis.ticks.y = element_blank(),
  axis.line.y  = element_blank()
)

# ----------------------- Load data -----------------------
videos_src <- if (exists("combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN")) {
  combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN
} else if (exists("RAW_FLAGGED_IS_IBERIAN")) {
  RAW_FLAGGED_IS_IBERIAN
} else stop("No video-level table found in environment.")

videos_tbl <- videos_src %>%
  mutate(
    TaxonName = coalesce(.data$TaxonName, gsub(" +"," ", species_normalized)),
    species_normalized = coalesce(.data$species_normalized, gsub("_"," ", .data$TaxonName)),
    TaxonName = gsub("_"," ", TaxonName),
    species_normalized = gsub("_"," ", species_normalized),

    LifeForm      = as.character(LifeForm),
    LifeForm      = ifelse(is.na(LifeForm), "Unknown", LifeForm),
    PresentStatus = as.character(PresentStatus),

    FirstRecord   = suppressWarnings(as.integer(FirstRecord)),
    viewCount     = suppressWarnings(as.numeric(viewCount)),
    likeCount     = suppressWarnings(as.numeric(likeCount)),
    commentCount  = suppressWarnings(as.numeric(commentCount)),
    channelTitle  = as.character(channelTitle),

    created_at    = suppressWarnings(as.POSIXct(created_at)),
    publishedAt   = suppressWarnings(as.POSIXct(publishedAt)),
    event_date    = suppressWarnings(as.POSIXct(coalesce(created_at, publishedAt)))
  ) %>%
  dplyr::select(video_id, TaxonName, species_normalized, LifeForm, PresentStatus, FirstRecord,
                channelTitle, viewCount, likeCount, commentCount, created_at, publishedAt, event_date) %>%
  distinct(video_id, .keep_all = TRUE)


# ----------------------- Age control (GAM residuals) -----------------------
anchor_date <- suppressWarnings(max(videos_tbl$event_date, na.rm = TRUE))
if (!is.finite(anchor_date)) anchor_date <- Sys.time()

videos_tbl <- videos_tbl %>%
  mutate(
    video_age_years = as.numeric(difftime(anchor_date, event_date, units = "days"))/365.25,
    video_age_years = ifelse(is.na(video_age_years)|!is.finite(video_age_years), NA_real_, pmax(video_age_years, 0)),
    v_views_log    = log1p(viewCount),
    v_likes_log    = log1p(likeCount),
    v_comments_log = log1p(commentCount)
  )

age_resid <- function(y, age) {
  ok <- is.finite(y) & is.finite(age)
  r  <- rep(NA_real_, length(y))
  if (sum(ok) >= 10 && length(unique(age[ok])) >= 5) {
    fit <- mgcv::gam(y ~ s(age, k = 6), method = "REML")
    r[ok] <- residuals(fit, type = "response")
  } else {
    m <- mean(y[ok], na.rm = TRUE); r[ok] <- y[ok] - m
  }
  r
}

videos_tbl <- videos_tbl %>%
  mutate(
    r_views_log    = age_resid(v_views_log,    video_age_years),
    r_likes_log    = age_resid(v_likes_log,    video_age_years),
    r_comments_log = age_resid(v_comments_log, video_age_years)
  )

# ----------------------- Species metrics (RAW + AGE-ADJ) -----------------------
species_metrics_raw <- videos_tbl %>%
  filter(!is.na(TaxonName)) %>%
  group_by(TaxonName, species_normalized, LifeForm, PresentStatus) %>%
  summarise(
    n_videos = n_distinct(video_id),
    views    = sum(viewCount, na.rm = TRUE),
    likes    = sum(likeCount, na.rm = TRUE),
    comments = sum(commentCount, na.rm = TRUE),
    .groups  = "drop"
  ) %>%
  mutate(
    views_log    = log1p(views),
    likes_log    = log1p(likes),
    comments_log = log1p(comments),
    views_log_z    = as.numeric(scale(views_log)),
    likes_log_z    = as.numeric(scale(likes_log)),
    comments_log_z = as.numeric(scale(comments_log)),
    composite      = (views_log_z + likes_log_z + comments_log_z)/3,
    composite_logmean = (views_log + likes_log + comments_log)/3,
    composite_rawsum  =  views_log + likes_log + comments_log
  ) %>%
  arrange(desc(composite))

species_metrics_ageadj <- videos_tbl %>%
  filter(!is.na(TaxonName)) %>%
  group_by(TaxonName, species_normalized, LifeForm, PresentStatus) %>%
  summarise(
    n_videos = n_distinct(video_id),
    views_log_adj    = sum(r_views_log,    na.rm = TRUE),
    likes_log_adj    = sum(r_likes_log,    na.rm = TRUE),
    comments_log_adj = sum(r_comments_log, na.rm = TRUE),
    .groups  = "drop"
  ) %>%
  mutate(
    views_log_adj_z    = as.numeric(scale(views_log_adj)),
    likes_log_adj_z    = as.numeric(scale(likes_log_adj)),
    comments_log_adj_z = as.numeric(scale(comments_log_adj)),
    composite_adj      = (views_log_adj_z + likes_log_adj_z + comments_log_adj_z)/3
  ) %>%
  arrange(desc(composite_adj))


# ----------------------- Life-form metrics (RAW + AGE-ADJ) -----------------------
taxa_metrics_raw <- videos_tbl %>%
  group_by(LifeForm) %>%
  summarise(
    n_videos = n_distinct(video_id),
    views    = sum(viewCount, na.rm = TRUE),
    likes    = sum(likeCount, na.rm = TRUE),
    comments = sum(commentCount, na.rm = TRUE),
    .groups  = "drop"
  ) %>%
  mutate(
    views_log = log1p(views), likes_log = log1p(likes), comments_log = log1p(comments),
    views_log_z = as.numeric(scale(views_log)),
    likes_log_z = as.numeric(scale(likes_log)),
    comments_log_z = as.numeric(scale(comments_log)),
    composite = (views_log_z + likes_log_z + comments_log_z)/3,
    LifeForm = factor(LifeForm, levels = lifeform_levels)
  ) %>% arrange(desc(n_videos))

taxa_metrics_ageadj <- videos_tbl %>%
  group_by(LifeForm) %>%
  summarise(
    n_videos = n_distinct(video_id),
    views_log_adj_sum    = sum(r_views_log,    na.rm = TRUE),
    likes_log_adj_sum    = sum(r_likes_log,    na.rm = TRUE),
    comments_log_adj_sum = sum(r_comments_log, na.rm = TRUE),
    .groups  = "drop"
  ) %>%
  mutate(
    views_log_adj_z    = as.numeric(scale(views_log_adj_sum)),
    likes_log_adj_z    = as.numeric(scale(likes_log_adj_sum)),
    comments_log_adj_z = as.numeric(scale(comments_log_adj_sum)),
    composite_adj      = (views_log_adj_z + likes_log_adj_z + comments_log_adj_z)/3,
    LifeForm           = factor(LifeForm, levels = desired_lf_order)
  ) %>%
  arrange(LifeForm)

# Save tables
save_table_safely(species_metrics_raw,    file.path(out_tables, "species_metrics_raw.csv"))
save_table_safely(species_metrics_ageadj, file.path(out_tables, "species_metrics_ageadjusted.csv"))
save_table_safely(taxa_metrics_raw,       file.path(out_tables, "lifeform_metrics_raw.csv"))

# ============================================================
# 9) ICON SETUP (single source) - ROBUST PATHS + ON-THE-FLY RECOLOR
#    (NO tinted files written to disk)
# ============================================================

# --------------------------- ICONS (robust paths) ----------------------------
icon_filemap <- c(
  "Birds"  = "bird_counts.png",
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

pick_icon_dir <- function(cands, probe = "bird_counts.png") {
  for (d in cands) {
    if (dir.exists(d) && file.exists(file.path(d, probe))) return(d)
  }
  return(NA_character_)
}
ICON_DIR <- pick_icon_dir(icon_dir_candidates)
if (is.na(ICON_DIR)) {
  stop("Couldn't find icons. Tried: ", paste(icon_dir_candidates, collapse = ", "),
       "\nWorking directory: ", getwd(),
       "\nMake sure at least one icon (e.g., bird_counts.png) is in fig_assets/ or fig_assets/icons/")
}

# IMPORTANT: keep names aligned with desired_lf_order
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

add_y_icons_compact <- function(
  p_horiz, y_levels, icon_paths,
  icon_width_frac = 0.14, icon_half_height = 0.50,
  gap_frac = 0.022, border_overlap = 1.12,
  left_margin = 155, clamp_nonnegative = FALSE
){
  gb <- ggplot_build(p_horiz)
  x_vals <- unlist(lapply(gb$data, function(d) {
    as.numeric(c(d$x %||% numeric(), d$xmin %||% numeric(), d$xmax %||% numeric()))
  }))
  xmin_data <- suppressWarnings(min(x_vals, na.rm = TRUE))
  xmax_data <- suppressWarnings(max(x_vals, na.rm = TRUE))
  if (!is.finite(xmin_data)) xmin_data <- 0
  if (!is.finite(xmax_data) || xmax_data <= 0) xmax_data <- 100

  icon_w   <- xmax_data * icon_width_frac
  gap      <- xmax_data * gap_frac
  x_center <- -(gap + icon_w/2)

  left_lim_icons <- x_center - icon_w/2 + icon_w * border_overlap
  x_left <- if (is.finite(xmin_data) && xmin_data < 0) {
    xmin_data * 1.05
  } else {
    if (isTRUE(clamp_nonnegative)) 0 else left_lim_icons
  }
  x_right <- xmax_data * 1.12

  layers <- lapply(seq_along(y_levels), function(i){
    lf   <- y_levels[i]
    path <- icon_paths[lf]
    if (is.na(path) || !file.exists(path)) return(NULL)

    # ---- ON-THE-FLY recolor (NO files written) ----
    img <- png::readPNG(path)
    img <- as_rgba(img, light = ICON_LIGHT, tint = ICON_TINT)

    gr <- grid::rasterGrob(img, interpolate = TRUE)
    ggplot2::annotation_custom(
      grob = gr,
      xmin = x_center - icon_w/2, xmax = x_center + icon_w/2,
      ymin = i - icon_half_height, ymax = i + icon_half_height
    )
  })
  layers <- layers[!vapply(layers, is.null, logical(1))]

  p_horiz +
    layers +
    ggplot2::coord_cartesian(xlim = c(x_left, x_right), clip = "off") +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 12, r = 14, b = 6, l = 90))
}

# ----------------------- Panel A (S1): uploads + dashed EC_adj rulers -----------------------
df_top <- species_metrics_raw %>%
  distinct(TaxonName, .keep_all = TRUE) %>%
  transmute(TaxonName, LifeForm, n_videos) %>%
  arrange(desc(n_videos))

df_top_plot <- df_top %>% slice_head(n = min(TOPN_SPECIES, nrow(df_top)))
  
n_final <- min(TOPN_SPECIES, nrow(df_top_plot))

df_top_plot <- df_top_plot %>% slice_head(n = n_final)

print(df_top_plot %>% slice_head(n = 10))

df_top_plot %>% filter(TaxonName %in% c("Vespa velutina","Xylella fastidiosa","Rugulopteryx okamurae"))

p_top_nvideos_A_age <- ggplot(
  df_top_plot,
  aes(x = forcats::fct_reorder(TaxonName, n_videos), y = n_videos, fill = LifeForm)) +
  geom_col(width = 0.85) +
  coord_flip() +
  scale_fill_manual(values = lifeform_palette, limits = lifeform_levels, drop = FALSE, name = NULL) +
  labs(x = NULL, y = "Number of videos") +
  theme_light(base_size = 11) +
  theme(
    axis.text.y = element_text(face = "italic", size = 10)
  )

df_top_plot_z_adj <- df_top_plot %>%
  left_join(species_metrics_ageadj %>% dplyr::select(TaxonName, composite_adj), by = "TaxonName")
z_range_adj <- range(species_metrics_ageadj$composite_adj, na.rm = TRUE)
xmax_A      <- max(df_top_plot$n_videos, na.rm = TRUE)

df_top_plot_z_adj <- df_top_plot_z_adj %>%
  mutate(z_to_videos = scales::rescale(composite_adj, to = c(0, xmax_A), from = z_range_adj))

p_top_nvideos_with_z_age <- p_top_nvideos_A_age +
  geom_segment(
    data = df_top_plot_z_adj,
    aes(x = TaxonName, xend = TaxonName, y = 0, yend = z_to_videos),
    inherit.aes = FALSE,
    linewidth = 0.4, linetype = "22", colour = "grey20"
  ) +
  theme(legend.position = "none")

# ----------------------- Panel B (S1): bubble - uploads vs EC_adj -----------------------
dfC_bubble_age <- species_metrics_ageadj %>%
  group_by(TaxonName) %>%
  summarise(
    composite_adj = mean(composite_adj, na.rm = TRUE),
    n_videos      = mean(n_videos, na.rm = TRUE),
    LifeForm      = dplyr::first(na.omit(LifeForm)),
    .groups       = "drop"
  ) %>%
  left_join(
    species_metrics_raw %>%
      group_by(TaxonName) %>%
      summarise(
        views_raw = sum(views, na.rm = TRUE),
        LifeForm_raw = dplyr::first(na.omit(LifeForm)),
        .groups = "drop"
      ),
    by = "TaxonName"
  ) %>%
  mutate(
    uploads   = dplyr::coalesce(n_videos, 0L),
    views_log = log1p(dplyr::coalesce(views_raw, 0)),
    LifeForm  = dplyr::coalesce(LifeForm, LifeForm_raw)
  ) %>%
  semi_join(df_top_plot %>% dplyr::select(TaxonName), by = "TaxonName") %>%
  mutate(ec_per_vid_a = composite_adj / pmax(uploads, 1)) %>%
  distinct(TaxonName, .keep_all = TRUE)

top10_lab_age <- dfC_bubble_age %>%
  arrange(desc(ec_per_vid_a)) %>%
  slice_head(n = 10) %>%
  pull(TaxonName)

pB_bubble_age <- ggplot(
  dfC_bubble_age,
  aes(x = uploads, y = composite_adj, fill = LifeForm, size = views_log)) +
  geom_point(alpha = 0.85, shape = 21, stroke = 0.3) +
  #geom_smooth(aes(group = 1), method = "lm", se = FALSE, linewidth = 0.6, inherit.aes = TRUE) +
  ggrepel::geom_text_repel(
    data = subset(dfC_bubble_age, TaxonName %in% top10_lab_age),
    aes(label = TaxonName),
    size = 4.5, min.segment.length = 0.15, seed = 42,
    point.padding = 0.2, box.padding = 0.25,
    max.overlaps = Inf, show.legend = FALSE,
    fontface = "italic"
  ) +
  scale_fill_manual(values = lifeform_palette, limits = lifeform_levels, drop = FALSE, name = NULL) +
  scale_size_continuous(range = c(2.5, 9), name = "log1p(views)") +
  labs(x = "Number of videos", y = "Engagement (EC, age-adjusted)") +
  theme_light(base_size = 11) +
  theme_sizes_patch +
  theme(
    legend.position = "none",
    axis.title.y = element_text(margin = margin(r = 10)),
    axis.text.y  = element_text(margin = margin(r = 5)),
    plot.margin  = margin(t = 32, r = 50, b = 6, l = 0)
  )

# ----------------------- Panel A (S2): uploads by life-form (raw) + icons -----------------------
taxa_metrics_lf_raw <- taxa_metrics_raw %>%
  mutate(LifeForm = factor(as.character(LifeForm), levels = desired_lf_order)) %>%
  arrange(LifeForm)

pB_base_h <- ggplot(taxa_metrics_lf_raw, aes(x = n_videos, y = LifeForm, fill = LifeForm)) +
  geom_col(width = 0.82) +
  scale_fill_manual(values = lifeform_palette,
                    limits = desired_lf_order, drop = FALSE, name = NULL) +
  scale_y_discrete(limits = rev(desired_lf_order), drop = FALSE) +
  labs(x = "Number of videos", y = NULL) +
  theme_light(base_size = 11) +
  theme_sizes_icons_patch +
  theme(legend.position = "none")

pB_icons_only <- add_y_icons_compact(
  p_horiz           = pB_base_h,
  y_levels          = rev(levels(taxa_metrics_lf_raw$LifeForm)),
  icon_paths        = icon_paths,
  icon_width_frac   = 0.15,
  gap_frac          = 0.070,
  border_overlap    = 1.12,
  left_margin       = 185,
  clamp_nonnegative = TRUE
)

# ----------------------- Panel B (S2): life-form EC_adj + icons -----------------------
taxa_metrics_lf_adj <- taxa_metrics_ageadj %>%
  mutate(LifeForm = factor(as.character(LifeForm), levels = desired_lf_order)) %>%
  arrange(LifeForm)

pD_base_h_age <- ggplot(taxa_metrics_lf_adj, aes(x = composite_adj, y = LifeForm, fill = LifeForm)) +
  geom_col(width = 0.82) +
  scale_fill_manual(values = lifeform_palette,
                    limits = desired_lf_order, drop = FALSE, name = NULL) +
  scale_y_discrete(limits = rev(desired_lf_order), drop = FALSE) +
  labs(x = "Engagement (EC, age-adjusted)", y = NULL) +
  theme_light(base_size = 11) +
  theme_sizes_icons_patch +
  theme(legend.position = "right")

pD_icons_only_age <- add_y_icons_compact(
  p_horiz         = pD_base_h_age + theme(legend.position = "none"),
  y_levels        = rev(levels(taxa_metrics_lf_adj$LifeForm)),
  icon_paths      = icon_paths,
  icon_width_frac = 0.25,
  gap_frac        = 0.68,
  border_overlap  = 1.12,
  left_margin     = 185
)
pD_plain_age <- pD_base_h_age

# ----------------------- Common helpers (tags, wrapping, legends) -----------------------
tag_plot <- function(p, lab, x = 0.01, y = 0.99) {
  p + labs(tag = lab) +
    theme(
      plot.tag = element_text(face = "plain", size = TAG_SIZE),
      plot.tag.position = c(x, y)
    )
}

wrap_g <- function(g) cowplot::ggdraw() + cowplot::draw_grob(g)

equalize_named_rows <- function(g1, g2, row_names = c("panel","axis-b","xlab-b")) {
  for (nm in row_names) {
    i1 <- which(g1$layout$name == nm)
    i2 <- which(g2$layout$name == nm)
    if (length(i1) && length(i2)) {
      r1 <- g1$layout[i1[1], ]; r2 <- g2$layout[i2[1], ]
      rng1 <- r1$t:r1$b; rng2 <- r2$t:r2$b
      h <- grid::unit.pmax(g1$heights[rng1], g2$heights[rng2])
      g1$heights[rng1] <- h; g2$heights[rng2] <- h
    }
  }
  h_full <- grid::unit.pmax(g1$heights, g2$heights)
  g1$heights <- h_full; g2$heights <- h_full
  list(g1 = g1, g2 = g2)
}

# ----------------------- BASE plots used in panels -----------------------
ROW_GAP <- 5

pA_age <- p_top_nvideos_with_z_age +
  theme(
    legend.position = "none",
    axis.title.x = element_text(margin = margin(t = AX_TITLE_TEXT_GAP_S1)),
    axis.text.x  = element_text(margin = margin(t = AX_TEXT_TOP_GAP)),
    axis.text.y  = element_text(face = "italic", size = 10),
    plot.margin  = margin(t = 8,  r = 10, b = ROW_GAP, l = 40)
  )

pB_age <- pB_bubble_age +
  theme(
    axis.title.x = element_text(margin = margin(t = AX_TITLE_TEXT_GAP_S1)),
    axis.text.x  = element_text(margin = margin(t = AX_TEXT_TOP_GAP))
  )

# ### FIX (ONLY REQUEST): S2 plot A (icons/uploads) - increase title?tick spacing
pC_age <- pB_icons_only +
  theme(
    legend.position = "none",
    axis.title.x = element_text(margin = margin(t = AX_TITLE_TEXT_GAP_S2_A)),
    axis.text.x  = element_text(margin = margin(t = AX_TEXT_TOP_GAP)),
    plot.margin  = margin(t = 2, r = 65, b = ROW_GAP, l = 90)
  )

# S2 plot B - unchanged spacing (do NOT apply AX_TITLE_TEXT_GAP_S2_A here)
pD_age <- pD_icons_only_age +
  theme(
    legend.position = "none",
    axis.title.x = element_text(margin = margin(t = AX_TITLE_TEXT_GAP_S2_A)),
    axis.text.x  = element_text(margin = margin(t = AX_TEXT_TOP_GAP)),
    plot.margin  = margin(t = ROW_GAP, r = 3, b = 3, l = 1)
  )

# ----------------------- Build & save TWO separate final panels -----------------------

legend_fill_S1 <- cowplot::get_legend(
  pD_plain_age +
    guides(fill = guide_legend(title = NULL)) +
    theme(legend.position = "right",
          legend.title = element_text(size = LEG_TITLE_SIZE),
          legend.text  = element_text(size = LEG_TEXT_SIZE))
)
legend_size_S1 <- cowplot::get_legend(
  pB_age +
    guides(fill = "none", size = guide_legend(title = "log1p(views)")) +
    theme(legend.position = "right",
          legend.title = element_text(size = LEG_TITLE_SIZE),
          legend.text  = element_text(size = LEG_TEXT_SIZE))
)

y_fill <- 0.28; y_size <- 0.68
legend_col_S1 <- cowplot::ggdraw() +
  cowplot::draw_plot(legend_fill_S1, x = 0.26, y = y_fill, width = 0.96, height = 0.36,
                     hjust = 0, vjust = 1.0) +
  cowplot::draw_plot(legend_size_S1, x = 0.26, y = y_size, width = 0.96, height = 0.26,
                     hjust = 0, vjust = 1.0)

legend_fill_S2 <- cowplot::get_legend(
  pD_plain_age +
    guides(fill = guide_legend(title = NULL)) +
    theme(legend.position = "right",
          legend.title = element_text(size = LEG_TITLE_SIZE),
          legend.text  = element_text(size = LEG_TEXT_SIZE))
)
legend_col_S2 <- cowplot::ggdraw() +
  cowplot::draw_plot(legend_fill_S2, x = 0.42, y = 0.80, width = 0.96, height = 0.60,
                     hjust = 0.35, vjust = 1.0)

pA_tag_S1 <- tag_plot(pA_age, "A)", x = 0.012, y = 1.20)
pB_tag_S1 <- tag_plot(pB_age, "B)", x = -0.05, y = 1.20)

# Keep S2 tags inside (your current main already does for A)
pA_tag_S2 <- tag_plot(pC_age, "A)", x = 0.003, y = 1.39)
pB_tag_S2 <- tag_plot(pD_age, "B)", x = -0.05, y = 1.17)

gA_S1 <- ggplotGrob(pA_tag_S1)
gB_S1 <- ggplotGrob(pB_tag_S1)
eq_S1 <- equalize_named_rows(gA_S1, gB_S1, row_names = c("panel","axis-b","xlab-b"))
gA_S1 <- eq_S1$g1; gB_S1 <- eq_S1$g2

panel_main_S1 <- cowplot::plot_grid(
  wrap_g(gA_S1), wrap_g(gB_S1),
  ncol = 2, align = "h", rel_widths = c(1.1, 1)
)

panel_S1_with_legend <- cowplot::plot_grid(
  panel_main_S1, legend_col_S1,
  ncol = 2, rel_widths = c(1, 0.38), align = "h"
)

TOP_PAD <- 46
panel_S1_with_legend_padded <- cowplot::ggdraw(panel_S1_with_legend) +
  theme(plot.margin = margin(t = TOP_PAD, r = OUTER_RIGHT_PAD, b = 6, l = 12))

save_plot_safely(
  panel_S1_with_legend_padded,
  file.path(out_figs, "Figure4_engagement_A_to_B_ageadjusted_bubble.png"),
  width = 420, height = 140, units = "mm"
)

gA_S2 <- ggplotGrob(pA_tag_S2)
gB_S2 <- ggplotGrob(pB_tag_S2)
eq_S2 <- equalize_named_rows(gA_S2, gB_S2, row_names = c("panel","axis-b","xlab-b"))
gA_S2 <- eq_S2$g1; gB_S2 <- eq_S2$g2

panel_main_S2 <- cowplot::plot_grid(
  wrap_g(gA_S2), wrap_g(gB_S2),
  ncol = 2, align = "h", rel_widths = c(1.2, 1)
)

panel_S2_with_legend <- cowplot::plot_grid(
  panel_main_S2, legend_col_S2,
  ncol = 2, rel_widths = c(1, 0.38), align = "h"
)

# keep as-is (no extra bottom bump needed for your single requested change)
panel_S2_with_legend_padded <- cowplot::ggdraw(panel_S2_with_legend) +
  theme(plot.margin = margin(t = TOP_PAD, r = OUTER_RIGHT_PAD, b = 6, l = 12))

save_plot_safely(
  panel_S2_with_legend_padded,
  file.path(out_figs, "Figure4_engagement_C_to_D_ageadjusted_bubble.png"),
  width = 460, height = 155, units = "mm"
)

message("Saved split final Figure 4 panels (S1 and S2) to: ", out_figs)

# ===========================================================
# Palette variants - BUBBLE PANEL ONLY (age-adjusted) - SPLIT
#   - Keeps ONLY: Spectral, Accent, Set2, Set3
#   - Inherits the SAME S2 plot A spacing fix
#   - ### FIX: restore S2 plot A left margin (was incorrectly set to l=20)
# ===========================================================

suppressPackageStartupMessages({
  library(ggplot2); library(cowplot); library(grid)
  library(RColorBrewer); library(viridisLite)
})

out_figs_pal <- file.path(out_figs, "palettes")
ensure_dir(out_figs_pal)

normalize_scheme <- function(x) tolower(gsub("[^A-Za-z0-9]+", "_", x))

.gen_colors <- function(scheme, n) {
  if (scheme %in% c("viridis","plasma","magma","inferno","cividis","turbo","mako","rocket")) {
    fun <- switch(scheme,
      viridis = viridisLite::viridis, plasma = viridisLite::plasma,
      magma   = viridisLite::magma,   inferno = viridisLite::inferno,
      cividis = viridisLite::cividis, turbo   = viridisLite::turbo,
      mako    = viridisLite::mako,    rocket  = viridisLite::rocket
    )
    return(fun(n))
  }
  if (scheme %in% rownames(RColorBrewer::brewer.pal.info)) {
    maxn <- RColorBrewer::brewer.pal.info[scheme, "maxcolors"]
    k    <- min(maxn, max(n, 3))
    cols <- RColorBrewer::brewer.pal(k, scheme)
    if (k != n) cols <- grDevices::colorRampPalette(cols)(n)
    return(cols)
  }
  if (scheme %in% c("rainbow","heat")) {
    fun <- switch(scheme, rainbow = grDevices::rainbow, heat = grDevices::heat.colors)
    return(fun(n))
  }
  if (scheme %in% c("protanopia","deuteranopia","tritanopia")) {
    base_cols <- viridisLite::viridis(n)
    if (requireNamespace("dichromat", quietly = TRUE)) {
      mode <- switch(scheme, protanopia="protan", deuteranopia="deutan", tritanopia="tritan")
      return(dichromat::dichromat(base_cols, type = mode))
    } else return(base_cols)
  }
  if (scheme == "goldrose") {
    base <- c("#4B3F72","#B95F89","#E56B6F","#EAAC8B","#FFD29D","#FFEBC1","#F7F7F7")
    return(grDevices::colorRampPalette(base)(n))
  }
  if (scheme == "tealgrey") {
    base <- c("#003F5C","#2F4B7C","#665191","#A5A5A5","#CCCCCC","#E0E0E0","#F7F7F7")
    return(grDevices::colorRampPalette(base)(n))
  }
  viridisLite::viridis(n)
}

lf_palette_for_levels <- function(levels_vec, scheme) {
  n <- length(levels_vec)
  cols <- .gen_colors(scheme, n)
  if (length(cols) != n) cols <- grDevices::colorRampPalette(cols)(n)
  stats::setNames(cols, levels_vec)
}

wrap_g <- function(g) cowplot::ggdraw() + cowplot::draw_grob(g)

build_split_panels_with_palette_age <- function(palA, palB, palC, palD, base_name) {

  pA_var <- p_top_nvideos_with_z_age +
    scale_fill_manual(values = palA, limits = lifeform_levels, drop = FALSE, name = NULL) +
    theme_light(base_size = 11) +
    theme_sizes_patch +
    theme(
      legend.position = "none",
      axis.text.y = element_text(face = "italic", size = 10),
      axis.title.x = element_text(margin = margin(t = AX_TITLE_TEXT_GAP_S1)),
      axis.text.x  = element_text(margin = margin(t = AX_TEXT_TOP_GAP)),
      plot.margin  = margin(t = 8, r = 25, b = ROW_GAP, l = 25)
    )

  pBubble_var <- pB_bubble_age +
    scale_fill_manual(values = palC, limits = lifeform_levels, drop = FALSE, name = NULL) +
    theme_sizes_patch +
    theme(
      axis.title.x = element_text(margin = margin(t = AX_TITLE_TEXT_GAP_S1)),
      axis.text.x  = element_text(margin = margin(t = AX_TEXT_TOP_GAP))
    )

  # ### FIX: keep S2 plot A icon gutter (l must NOT be 20)
  # ### FIX: apply title?tick spacing ONLY to S2 plot A
  pLife_uploads_var <- pB_icons_only +
    scale_fill_manual(values = palB, limits = desired_lf_order, drop = FALSE, name = NULL) +
    theme_sizes_icons_patch +
    theme(
      legend.position = "none",
      axis.title.x = element_text(margin = margin(t = AX_TITLE_TEXT_GAP_S2_A)),
      axis.text.x  = element_text(margin = margin(t = AX_TEXT_TOP_GAP))#,
      #plot.margin  = margin(t = 2, r = 65, b = ROW_GAP, l = 90)
    )

  # S2 plot B: DO NOT change its title?tick spacing (keep format)
  pLife_ec_var <- pD_icons_only_age +
    scale_fill_manual(values = palD, limits = desired_lf_order, drop = FALSE, name = NULL) +
    theme_sizes_icons_patch +
    theme(
      legend.position = "none",
      axis.title.x = element_text(margin = margin(t = AX_TITLE_TEXT_GAP_S2_A)),
      axis.text.x  = element_text(margin = margin(t = AX_TEXT_TOP_GAP))
    )

  pLife_plain_var <- pD_base_h_age +
    scale_fill_manual(values = palD, limits = desired_lf_order, drop = FALSE, name = NULL) +
    theme_sizes_patch

  pA_tag_S1 <- tag_plot(pA_var,      "A)", x = -0.01, y = 1.14)
  pB_tag_S1 <- tag_plot(pBubble_var, "B)", x = -0.01, y = 1.14)

  # Keep S2 tags INSIDE to avoid clipping in palette exports
  pA_tag_S2 <- tag_plot(pLife_uploads_var, "A)", x = -0.15, y = 1.10)
  pB_tag_S2 <- tag_plot(pLife_ec_var,      "B)", x = -0.15, y = 1.10)

  gA_S1 <- ggplotGrob(pA_tag_S1); gB_S1 <- ggplotGrob(pB_tag_S1)
  eq_S1 <- equalize_named_rows(gA_S1, gB_S1, row_names = c("panel","axis-b","xlab-b"))
  gA_S1 <- eq_S1$g1; gB_S1 <- eq_S1$g2

  gA_S2 <- ggplotGrob(pA_tag_S2); gB_S2 <- ggplotGrob(pB_tag_S2)
  eq_S2 <- equalize_named_rows(gA_S2, gB_S2, row_names = c("panel","axis-b","xlab-b"))
  gA_S2 <- eq_S2$g1; gB_S2 <- eq_S2$g2

  legend_fill_S1 <- cowplot::get_legend(
    pLife_plain_var + guides(fill = guide_legend(title = NULL)) +
      theme(legend.position = "right",
            legend.title = element_text(size = LEG_TITLE_SIZE),
            legend.text  = element_text(size = LEG_TEXT_SIZE))
  )
  legend_size_S1 <- cowplot::get_legend(
    pBubble_var + guides(fill = "none", size = guide_legend(title = "log1p(views)")) +
      theme(legend.position = "right",
            legend.title = element_text(size = LEG_TITLE_SIZE),
            legend.text  = element_text(size = LEG_TEXT_SIZE))
  )

  legend_col_S1 <- cowplot::ggdraw() +
    cowplot::draw_plot(legend_fill_S1, x = 0.204, y = 0.87, width = 0.96, height = 0.36,
                       hjust = 0.35, vjust = 1.01) +
    cowplot::draw_plot(legend_size_S1, x = 0.38, y = -0.08, width = 0.96, height = 0.26,
                       hjust = 0.8, vjust = -1.15)

  legend_fill_S2 <- cowplot::get_legend(
    pLife_plain_var + guides(fill = guide_legend(title = NULL)) +
      theme(legend.position = "right",
            legend.title = element_text(size = LEG_TITLE_SIZE),
            legend.text  = element_text(size = LEG_TEXT_SIZE))
  )
  legend_col_S2 <- cowplot::ggdraw() +
    cowplot::draw_plot(legend_fill_S2, x = -0.65, y = 0.85, width = 0.96, height = 0.60,
                       hjust = -0.65, vjust = 1.0)

  panel_main_S1 <- cowplot::plot_grid(
    wrap_g(gA_S1), wrap_g(gB_S1),
    ncol = 2, align = "h", rel_widths = c(1, 0.9)
  )
  panel_S1_with_legend <- cowplot::plot_grid(
    panel_main_S1, legend_col_S1,
    ncol = 2, rel_widths = c(1, 0.28), align = "h"
  )
  panel_S1_padded <- cowplot::ggdraw(panel_S1_with_legend) +
    theme(plot.margin = margin(t = TOP_PAD, r = 0, b = 6, l = 0))

  save_plot_safely(
    panel_S1_padded,
    file.path(out_figs_pal, paste0(base_name, "_S1.png")),
    width = 450, height = 165, units = "mm"
  )

  panel_main_S2 <- cowplot::plot_grid(
    wrap_g(gA_S2), wrap_g(gB_S2),
    ncol = 2, align = "h", rel_widths = c(1, 1)
  )
  panel_S2_with_legend <- cowplot::plot_grid(
    panel_main_S2, legend_col_S2,
    ncol = 2, rel_widths = c(1, 0.30), align = "h"
  )
  panel_S2_padded <- cowplot::ggdraw(panel_S2_with_legend) +
    theme(plot.margin = margin(t = TOP_PAD, r = 0, b = 6, l = 0))

  save_plot_safely(
    panel_S2_padded,
    file.path(out_figs_pal, paste0(base_name, "_S2.png")),
    width = 450, height = 165, units = "mm"
  )
}

schemes_keep <- c("Spectral","Accent","Set2","Set3")

for (sch in schemes_keep) {
  palA <- lf_palette_for_levels(lifeform_levels,  sch)
  palB <- lf_palette_for_levels(desired_lf_order, sch)
  palC <- lf_palette_for_levels(lifeform_levels,  sch)
  palD <- lf_palette_for_levels(desired_lf_order, sch)

  base_name <- paste0("Figure4_palette_uniform_bubble_", normalize_scheme(sch))

  build_split_panels_with_palette_age(
    palA, palB, palC, palD,
    base_name = base_name
  )
}

message("Palette variants (ONLY Spectral/Accent/Set2/Set3) saved in: ", out_figs_pal)


# ---- FINAL DIRECT EXPORT NAME ----------------------------------------------
for (ext in c(".png", ".tiff")) {
  src1 <- file.path("outputs", "intermediate", "engagement", "figs", "palettes",
                    paste0("Figure4_palette_uniform_bubble_set3_S1", ext))
  dst1 <- file.path(FIG_SUPP_DIR, paste0("Figure_S1", ext))
  if (file.exists(src1)) file.copy(src1, dst1, overwrite = TRUE)
  src2 <- file.path("outputs", "intermediate", "engagement", "figs", "palettes",
                    paste0("Figure4_palette_uniform_bubble_set3_S2", ext))
  dst2 <- file.path(FIG_SUPP_DIR, paste0("Figure_S2", ext))
  if (file.exists(src2)) file.copy(src2, dst2, overwrite = TRUE)
}
# engagement intermediate tables are kept until Tables S10-S13 are created.
