# ============================================================
# 19_test_video_availability_and_radial_engagement.R
# Supplementary figure and exploratory/testing plots.
#
# Purpose
#   Create one paper-ready supplementary coverage figure and additional exploratory figures summarising:
#   1) which species in the study search scope have / do not have videos in
#      the final validated corpus, and
#   2) alternative engagement summaries for species with videos.
#
# Notes
#   This version fixes the first test version by:
#   - using real species-level video, view, and like totals for radial plots;
#   - avoiding radial plots where all species appear to have the same value;
#   - adding clearer non-radial alternatives for checking species availability;
#   - exporting the coverage bar plot as outputs/figures/supplement/Figure_S1 and keeping other test plots in outputs/figures/exploratory/.
# ============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(forcats)
  library(ggplot2)
  library(scales)
})

if (!exists("PROJECT_ROOT", inherits = FALSE)) PROJECT_ROOT <- getwd()

FIG_EXPL_DIR <- file.path(PROJECT_ROOT, "outputs", "figures", "exploratory")
FIG_SUPP_DIR <- file.path(PROJECT_ROOT, "outputs", "figures", "supplement")
QA_DIR       <- file.path(PROJECT_ROOT, "outputs", "tables", "qa")
dir.create(FIG_EXPL_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(FIG_SUPP_DIR, recursive = TRUE, showWarnings = FALSE)

# Remove stale exploratory filenames from earlier test versions.
unlink(file.path(FIG_EXPL_DIR, c("Test_species_availability_radial_FIXED.png",
                                "Test_species_availability_radial_FIXED.tiff",
                                "Test_radial_engagement_top60_FIXED.png",
                                "Test_radial_engagement_top60_FIXED.tiff")),
       force = TRUE)
dir.create(QA_DIR, recursive = TRUE, showWarnings = FALSE)

videos_path  <- file.path(PROJECT_ROOT, "data", "paper_input", "videos_validated.csv")
species_path <- file.path(PROJECT_ROOT, "data", "species_input", "iberian_nns_first_records_filtered_for_search.csv")

if (!file.exists(videos_path)) stop("Missing video file: ", videos_path)
if (!file.exists(species_path)) stop("Missing species file: ", species_path)

videos_raw  <- readr::read_csv(videos_path, show_col_types = FALSE)
species_raw <- readr::read_csv(species_path, show_col_types = FALSE)

# -------------------------------------------------------------------------
# Palettes and common style
# -------------------------------------------------------------------------

# Print-friendly, colour-blind-friendly Tol muted palette.
tol_muted <- c(
  "#332288", "#88CCEE", "#44AA99", "#117733",
  "#999933", "#DDCC77", "#CC6677", "#882255"
)

# Use the same eight taxonomic groups as the manuscript figures and tables.
# Additional labels in the raw species-scope file (e.g. Mammals or other
# unmatched values) are excluded from these exploratory figures and exported
# to a QA file for transparency.
lifeform_levels <- c(
  "Birds",
  "Insects",
  "Herptiles",
  "Fishes",
  "Plants",
  "Crustaceans",
  "Non-arthropod invertebrates",
  "Bacteria, Viruses, Fungi"
)

# The species input file uses more detailed ASFRD life-form labels
# (e.g. Vascular plants, Reptiles, Molluscs, Viruses), whereas the
# manuscript figures use broader plotting groups. The recoding function
# below harmonises both sources before plotting. Labels outside the
# manuscript groups are treated as excluded/unmatched rather than plotted.
lifeform_cols <- setNames(tol_muted[seq_along(lifeform_levels)], lifeform_levels)
status_cols   <- c("Videos found" = tol_muted[3], "No videos found" = tol_muted[7])
metric_cols   <- c("Total uploads" = tol_muted[3], "Total views" = tol_muted[1], "Total likes" = tol_muted[6])

base_theme <- function(base_size = 12) {
  theme_light(base_size = base_size) +
    theme(
      legend.position = "top",
      legend.title = element_text(size = base_size),
      legend.text = element_text(size = base_size - 1),
      axis.text = element_text(size = base_size - 1),
      axis.title = element_text(size = base_size + 1),
      axis.title.x = element_text(margin = margin(t = 10)),
      axis.title.y = element_text(margin = margin(r = 10)),
      panel.grid.minor = element_blank(),
      plot.margin = margin(8, 10, 8, 8)
    )
}

clean_taxon <- function(x) {
  x %>%
    as.character() %>%
    stringr::str_replace_all("_", " ") %>%
    stringr::str_squish()
}

normalise_lifeform <- function(x) {
  x_chr <- as.character(x)
  x_low <- stringr::str_to_lower(stringr::str_squish(x_chr))

  dplyr::case_when(
    is.na(x_chr) | x_low == "" ~ NA_character_,

    # Main manuscript groups already used in the final video table
    x_low %in% c("birds", "bird") ~ "Birds",
    x_low %in% c("insects", "insect") ~ "Insects",
    x_low %in% c("fishes", "fish") ~ "Fishes",
    x_low %in% c("plants", "plant", "vascular plants", "vascular plant", "algae", "alga") ~ "Plants",
    x_low %in% c("herptiles", "reptiles", "reptile", "amphibians", "amphibian") ~ "Herptiles",
    x_low %in% c("crustaceans", "crustacean") ~ "Crustaceans",

    # Broader non-arthropod invertebrate group
    x_low %in% c(
      "non-arthropod invertebrates",
      "non-arthropod inv.",
      "non-arthropod inv",
      "invertebrates (excl. arthropods, molluscs)",
      "invertebrates (excl. arthropods, mollusks)",
      "molluscs",
      "mollusks",
      "bryozoa"
    ) ~ "Non-arthropod invertebrates",

    # Bacteria/virus/fungus group; written out for figure readability
    x_low %in% c(
      "bacteria, viruses, fungi",
      "bacteria, viruses, and fungi",
      "bacteria/viruses/fungi",
      "bacteria/fungi",
      "bvf",
      "bacteria",
      "viruses",
      "virus",
      "fungi",
      "fungus"
    ) ~ "Bacteria, Viruses, Fungi",

    # Not included in the manuscript life-form groups
    x_low %in% c("mammals", "mammal") ~ NA_character_,

    TRUE ~ NA_character_
  )
}

num_safe <- function(x) suppressWarnings(as.numeric(x))

first_available <- function(dat, candidates) {
  hit <- candidates[candidates %in% names(dat)]
  if (length(hit) == 0) return(rep(NA_character_, nrow(dat)))
  out <- dat[[hit[1]]]
  if (length(hit) > 1) {
    for (nm in hit[-1]) out <- dplyr::coalesce(out, dat[[nm]])
  }
  out
}

fmt_count <- function(x) {
  dplyr::case_when(
    is.na(x) ~ "",
    abs(x) >= 1e6 ~ paste0(round(x / 1e6, 1), "M"),
    abs(x) >= 1e3 ~ paste0(round(x / 1e3, 1), "k"),
    TRUE ~ as.character(round(x, 0))
  )
}

# -------------------------------------------------------------------------
# 1) Species availability table: complete study scope vs final video corpus
# -------------------------------------------------------------------------

species_scope_all <- species_raw %>%
  mutate(
    TaxonName_clean = clean_taxon(.data$TaxonName),
    LifeForm_raw = as.character(.data$LifeForm),
    LifeForm = normalise_lifeform(.data$LifeForm)
  ) %>%
  group_by(.data$TaxonName_clean) %>%
  summarise(
    TaxonName = dplyr::first(.data$TaxonName),
    CleanName = dplyr::first(.data$TaxonName_clean),
    LifeForm_raw = paste(sort(unique(na.omit(.data$LifeForm_raw))), collapse = "; "),
    LifeForm = dplyr::first(na.omit(.data$LifeForm)),
    PresentStatus = paste(sort(unique(na.omit(.data$PresentStatus))), collapse = "; "),
    FirstRecord = suppressWarnings(min(as.numeric(.data$FirstRecord), na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  mutate(
    FirstRecord = ifelse(is.infinite(.data$FirstRecord), NA_real_, .data$FirstRecord)
  )

# Export labels that are present in the raw species-scope file but are not part
# of the eight manuscript groups. They are not included in the exploratory plots.
excluded_lifeforms <- species_scope_all %>%
  filter(is.na(.data$LifeForm) | !.data$LifeForm %in% lifeform_levels) %>%
  dplyr::select(TaxonName, CleanName, LifeForm_raw)
if (nrow(excluded_lifeforms) > 0) {
  readr::write_csv(excluded_lifeforms, file.path(QA_DIR, "test_excluded_non_manuscript_lifeforms.csv"), na = "")
  message("Excluded non-manuscript life-form labels; see outputs/tables/qa/test_excluded_non_manuscript_lifeforms.csv")
}

species_scope <- species_scope_all %>%
  filter(!is.na(.data$LifeForm), .data$LifeForm %in% lifeform_levels) %>%
  mutate(LifeForm = factor(.data$LifeForm, levels = lifeform_levels))

videos_clean <- videos_raw %>%
  mutate(
    TaxonName_clean = clean_taxon(first_available(., c("CleanName", "species_normalized", "TaxonName"))),
    LifeForm_video = normalise_lifeform(first_available(., c("LifeForm"))),
    viewCount = num_safe(first_available(., c("viewCount", "views", "ViewCount"))),
    likeCount = num_safe(first_available(., c("likeCount", "likes", "LikeCount"))),
    video_id_use = first_available(., c("video_id", "id", "VideoID"))
  )

found_species <- videos_clean %>%
  filter(!is.na(.data$TaxonName_clean), .data$TaxonName_clean != "") %>%
  group_by(.data$TaxonName_clean) %>%
  summarise(
    # Use distinct videos to avoid duplicated rows inflating availability.
    n_videos = dplyr::n_distinct(.data$video_id_use),
    total_views = sum(.data$viewCount, na.rm = TRUE),
    total_likes = sum(.data$likeCount, na.rm = TRUE),
    .groups = "drop"
  )

availability <- species_scope %>%
  left_join(found_species, by = "TaxonName_clean") %>%
  mutate(
    n_videos = tidyr::replace_na(.data$n_videos, 0L),
    total_views = tidyr::replace_na(.data$total_views, 0),
    total_likes = tidyr::replace_na(.data$total_likes, 0),
    video_status = ifelse(.data$n_videos > 0, "Videos found", "No videos found"),
    video_status = factor(.data$video_status, levels = c("Videos found", "No videos found")),
    log_uploads = log1p(.data$n_videos)
  ) %>%
  arrange(.data$LifeForm, desc(.data$n_videos), .data$CleanName)

readr::write_csv(availability, file.path(QA_DIR, "test_species_video_availability.csv"), na = "")

# Basic check: after filtering to manuscript groups, no plotted species should
# have a missing life-form. If this file is created, inspect it before using
# the exploratory figures.
unmatched_lifeforms <- availability %>%
  filter(is.na(.data$LifeForm) | !as.character(.data$LifeForm) %in% lifeform_levels) %>%
  dplyr::select(TaxonName, CleanName, LifeForm)
if (nrow(unmatched_lifeforms) > 0) {
  readr::write_csv(unmatched_lifeforms, file.path(QA_DIR, "test_unmatched_lifeforms.csv"), na = "")
  message("Some plotted life-form labels were not recognised; see outputs/tables/qa/test_unmatched_lifeforms.csv")
}

availability_lifeform <- availability %>%
  count(.data$LifeForm, .data$video_status, name = "n_species") %>%
  tidyr::complete(
    LifeForm = factor(lifeform_levels, levels = lifeform_levels),
    video_status = factor(c("Videos found", "No videos found"),
                          levels = c("Videos found", "No videos found")),
    fill = list(n_species = 0L)
  ) %>%
  group_by(.data$LifeForm) %>%
  mutate(
    total_lifeform = sum(.data$n_species),
    pct = dplyr::if_else(.data$total_lifeform > 0, .data$n_species / .data$total_lifeform, 0),
    label = dplyr::if_else(.data$n_species > 0,
                           paste0(.data$n_species, " (", scales::percent(.data$pct, accuracy = 1), ")"),
                           "")
  ) %>%
  ungroup() %>%
  filter(.data$total_lifeform > 0) %>%
  mutate(LifeForm = droplevels(.data$LifeForm))

# -------------------------------------------------------------------------
# 2) Alternative availability plots
# -------------------------------------------------------------------------

# A. Paper-ready Supplementary Figure S1: clear stacked bar by taxonomic group.
p_avail_bar <- ggplot(availability_lifeform, aes(x = LifeForm, y = n_species, fill = video_status)) +
  geom_col(width = 0.72, colour = "grey25", linewidth = 0.20) +
  geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 3.2) +
  scale_fill_manual(values = status_cols, name = NULL) +
  labs(x = NULL, y = "Number of species") +
  base_theme(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 35, hjust = 1, vjust = 1),
    panel.grid.major.x = element_blank()
  )

ggsave(file.path(FIG_SUPP_DIR, "Figure_S1.png"),
       p_avail_bar, width = 8.5, height = 5.2, dpi = 300, bg = "white")
ggsave(file.path(FIG_SUPP_DIR, "Figure_S1.tiff"),
       p_avail_bar, width = 8.5, height = 5.2, dpi = 300, compression = "lzw", bg = "white")

# A copy with a descriptive testing name is not written to the exploratory folder;
# the paper-ready version is exported only as Supplementary Figure S1.

# B. Radial stacked bars by taxonomic group.
#    This is a clearer circular alternative than the first test version because
#    the radial length represents the actual number of species.
p_avail_radial_lifeform <- ggplot(availability_lifeform, aes(x = LifeForm, y = n_species, fill = video_status)) +
  geom_col(width = 0.72, colour = "white", linewidth = 0.35) +
  coord_polar(start = -0.20, clip = "off") +
  scale_fill_manual(values = status_cols, name = NULL) +
  labs(x = NULL, y = NULL) +
  theme_light(base_size = 12) +
  theme(
    legend.position = "top",
    legend.text = element_text(size = 11),
    axis.text.x = element_text(size = 10, face = "plain"),
    axis.text.y = element_text(size = 9),
    axis.title = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave(file.path(FIG_EXPL_DIR, "Test_video_availability_by_lifeform_radial_bars.png"),
       p_avail_radial_lifeform, width = 7.0, height = 6.7, dpi = 300, bg = "white")
ggsave(file.path(FIG_EXPL_DIR, "Test_video_availability_by_lifeform_radial_bars.tiff"),
       p_avail_radial_lifeform, width = 7.0, height = 6.7, dpi = 300, compression = "lzw", bg = "white")

# C. Species-level tile map: one tile = one species.
#    This is usually the clearest way to show represented and non-represented
#    species without unreadable radial labels.
tile_df <- availability %>%
  group_by(.data$LifeForm) %>%
  arrange(.data$video_status, desc(.data$n_videos), .data$CleanName, .by_group = TRUE) %>%
  mutate(species_rank = dplyr::row_number()) %>%
  ungroup()

p_avail_tiles <- ggplot(tile_df, aes(x = species_rank, y = LifeForm, fill = video_status)) +
  geom_tile(colour = "white", linewidth = 0.25, height = 0.78) +
  scale_fill_manual(values = status_cols, name = NULL) +
  scale_x_continuous(expand = expansion(mult = c(0.005, 0.02))) +
  labs(x = "Species ordered within each taxonomic group", y = NULL) +
  base_theme(base_size = 12) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_text(size = 11)
  )

ggsave(file.path(FIG_EXPL_DIR, "Test_species_availability_tilemap.png"),
       p_avail_tiles, width = 9.0, height = 4.8, dpi = 300, bg = "white")
ggsave(file.path(FIG_EXPL_DIR, "Test_species_availability_tilemap.tiff"),
       p_avail_tiles, width = 9.0, height = 4.8, dpi = 300, compression = "lzw", bg = "white")

# D. Species-level faceted bars. Species with no videos are shown with small
#    points at zero; species with videos have bars proportional to uploads.
faceted_df <- availability %>%
  group_by(.data$LifeForm) %>%
  arrange(.data$n_videos, .data$CleanName, .by_group = TRUE) %>%
  mutate(CleanName_plot = factor(.data$CleanName, levels = unique(.data$CleanName))) %>%
  ungroup()

p_species_bars <- ggplot(faceted_df, aes(x = n_videos, y = fct_reorder(CleanName, n_videos), fill = video_status)) +
  geom_col(width = 0.72, colour = "grey35", linewidth = 0.10) +
  geom_point(
    data = dplyr::filter(faceted_df, .data$n_videos == 0),
    aes(x = 0, y = CleanName),
    inherit.aes = FALSE,
    shape = 21,
    size = 1.6,
    stroke = 0.30,
    fill = status_cols[["No videos found"]],
    colour = "grey25"
  ) +
  facet_wrap(~ LifeForm, scales = "free_y", ncol = 2) +
  scale_x_continuous(trans = "pseudo_log", breaks = c(0, 1, 5, 10, 25, 50, 100, 300)) +
  scale_fill_manual(values = status_cols, name = NULL) +
  labs(x = "Number of validated videos per species", y = NULL) +
  base_theme(base_size = 10) +
  theme(
    legend.position = "top",
    axis.text.y = element_text(size = 5.7, face = "italic"),
    axis.text.x = element_text(size = 8),
    strip.background = element_rect(fill = "white", colour = "grey70"),
    strip.text = element_text(size = 10, face = "plain"),
    panel.grid.major.y = element_blank()
  )

ggsave(file.path(FIG_EXPL_DIR, "Test_species_availability_faceted_bars.png"),
       p_species_bars, width = 11.0, height = 15.5, dpi = 300, bg = "white")
ggsave(file.path(FIG_EXPL_DIR, "Test_species_availability_faceted_bars.tiff"),
       p_species_bars, width = 11.0, height = 15.5, dpi = 300, compression = "lzw", bg = "white")

# E. Fixed radial species-availability plot.
#    Each sector is one species. Radial height is proportional to log10(uploads + 1),
#    so species with more videos extend farther from the centre. Species without
#    videos are shown as a small inner mark rather than as a full-height sector.
radial_df <- availability %>%
  arrange(.data$LifeForm, desc(.data$n_videos), .data$CleanName) %>%
  mutate(
    species_id = dplyr::row_number(),
    upload_radius = log10(.data$n_videos + 1),
    upload_radius_plot = dplyr::if_else(.data$n_videos > 0, .data$upload_radius, 0.035)
  )

y_max_radial <- max(radial_df$upload_radius_plot, na.rm = TRUE)
if (!is.finite(y_max_radial) || y_max_radial <= 0) y_max_radial <- 1

lifeform_boundaries <- radial_df %>%
  group_by(.data$LifeForm) %>%
  summarise(
    x_min = min(.data$species_id) - 0.5,
    x_max = max(.data$species_id) + 0.5,
    x_mid = mean(range(.data$species_id)),
    .groups = "drop"
  )

p_avail_radial_species <- ggplot(radial_df, aes(x = species_id, y = upload_radius_plot)) +
  geom_col(
    data = dplyr::filter(radial_df, .data$n_videos > 0),
    aes(fill = LifeForm),
    width = 0.88,
    colour = NA,
    alpha = 0.92
  ) +
  geom_point(
    data = dplyr::filter(radial_df, .data$n_videos == 0),
    aes(x = species_id, y = 0.035),
    inherit.aes = FALSE,
    shape = 21,
    size = 1.25,
    stroke = 0.18,
    fill = status_cols[["No videos found"]],
    colour = "grey35",
    alpha = 0.90
  ) +
  geom_vline(
    data = lifeform_boundaries,
    aes(xintercept = x_min),
    inherit.aes = FALSE,
    colour = "grey70",
    linewidth = 0.20
  ) +
  geom_text(
    data = lifeform_boundaries,
    aes(x = x_mid, y = y_max_radial * 1.15, label = LifeForm),
    inherit.aes = FALSE,
    size = 2.7,
    lineheight = 0.92
  ) +
  coord_polar(clip = "off") +
  scale_y_continuous(
    limits = c(-y_max_radial * 0.30, y_max_radial * 1.22),
    breaks = log10(c(1, 2, 6, 11, 51, 101, 301)),
    labels = c("0", "1", "5", "10", "50", "100", "300")
  ) +
  scale_fill_manual(values = lifeform_cols, drop = FALSE, name = "Taxonomic group") +
  labs(x = NULL, y = "Validated videos per species") +
  theme_light(base_size = 12) +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_text(size = 8),
    axis.title.y = element_text(size = 11, margin = margin(r = 8)),
    panel.grid.minor = element_blank(),
    plot.margin = margin(18, 26, 18, 26)
  )

ggsave(file.path(FIG_EXPL_DIR, "Test_species_availability_radial.png"),
       p_avail_radial_species, width = 9.2, height = 8.4, dpi = 300, bg = "white")
ggsave(file.path(FIG_EXPL_DIR, "Test_species_availability_radial.tiff"),
       p_avail_radial_species, width = 9.2, height = 8.4, dpi = 300, compression = "lzw", bg = "white")

# Also overwrite the original radial output name with the fixed version.
ggsave(file.path(FIG_EXPL_DIR, "Test_species_availability_radial.png"),
       p_avail_radial_species, width = 9.2, height = 8.4, dpi = 300, bg = "white")
ggsave(file.path(FIG_EXPL_DIR, "Test_species_availability_radial.tiff"),
       p_avail_radial_species, width = 9.2, height = 8.4, dpi = 300, compression = "lzw", bg = "white")

# -------------------------------------------------------------------------
# 3) Alternative engagement summaries for species with videos
# -------------------------------------------------------------------------

engagement_summary <- availability %>%
  filter(.data$n_videos > 0) %>%
  transmute(
    CleanName,
    LifeForm,
    total_uploads = as.numeric(.data$n_videos),
    total_views = as.numeric(.data$total_views),
    total_likes = as.numeric(.data$total_likes)
  ) %>%
  mutate(
    uploads_scaled = ifelse(max(.data$total_uploads, na.rm = TRUE) > 0, .data$total_uploads / max(.data$total_uploads, na.rm = TRUE), 0),
    views_scaled   = ifelse(max(.data$total_views,   na.rm = TRUE) > 0, .data$total_views   / max(.data$total_views,   na.rm = TRUE), 0),
    likes_scaled   = ifelse(max(.data$total_likes,   na.rm = TRUE) > 0, .data$total_likes   / max(.data$total_likes,   na.rm = TRUE), 0),
    engagement_score = .data$uploads_scaled + .data$views_scaled + .data$likes_scaled
  ) %>%
  arrange(desc(.data$engagement_score), desc(.data$total_uploads), .data$CleanName)

readr::write_csv(engagement_summary, file.path(QA_DIR, "test_species_engagement_summary.csv"), na = "")

N_TOP <- min(60, nrow(engagement_summary))
engagement_long <- engagement_summary %>%
  slice_head(n = N_TOP) %>%
  mutate(CleanName = factor(.data$CleanName, levels = rev(.data$CleanName))) %>%
  pivot_longer(
    cols = c(total_uploads, total_views, total_likes),
    names_to = "metric",
    values_to = "value_raw"
  ) %>%
  group_by(.data$metric) %>%
  mutate(
    metric_max = max(.data$value_raw, na.rm = TRUE),
    value_scaled = ifelse(.data$metric_max > 0, .data$value_raw / .data$metric_max, 0),
    value_label = fmt_count(.data$value_raw)
  ) %>%
  ungroup() %>%
  mutate(
    metric = recode(.data$metric,
                    total_uploads = "Total uploads",
                    total_views = "Total views",
                    total_likes = "Total likes"),
    metric = factor(.data$metric, levels = c("Total uploads", "Total views", "Total likes"))
  )

readr::write_csv(engagement_long, file.path(QA_DIR, "test_species_engagement_long_top60.csv"), na = "")

# F. Heatmap alternative: compact and easier to compare than radial bars.
#    Use the top 40 species according to the composite engagement score.
top40_names <- engagement_summary %>%
  slice_head(n = min(40, nrow(.))) %>%
  pull(.data$CleanName)

heatmap_df <- engagement_long %>%
  filter(as.character(.data$CleanName) %in% top40_names) %>%
  mutate(CleanName = factor(as.character(.data$CleanName), levels = rev(top40_names)))

p_eng_heat <- ggplot(heatmap_df, aes(x = metric, y = CleanName, fill = value_scaled)) +
  geom_tile(colour = "white", linewidth = 0.35) +
  geom_text(aes(label = value_label), size = 2.6, colour = "black") +
  scale_fill_gradient(low = "#F7F7F7", high = tol_muted[1], labels = scales::percent_format(accuracy = 1), name = "Relative\nwithin metric") +
  labs(x = NULL, y = NULL) +
  base_theme(base_size = 11) +
  theme(
    legend.position = "right",
    axis.text.y = element_text(size = 7.5, face = "italic"),
    axis.text.x = element_text(size = 10),
    panel.grid = element_blank()
  )

ggsave(file.path(FIG_EXPL_DIR, "Test_engagement_top40_heatmap.png"),
       p_eng_heat, width = 7.2, height = 9.0, dpi = 300, bg = "white")
ggsave(file.path(FIG_EXPL_DIR, "Test_engagement_top40_heatmap.tiff"),
       p_eng_heat, width = 7.2, height = 9.0, dpi = 300, compression = "lzw", bg = "white")

# G. Faceted horizontal bars: one scale-free panel per metric.
p_eng_bars <- engagement_long %>%
  filter(as.character(.data$CleanName) %in% top40_names) %>%
  mutate(CleanName = factor(as.character(.data$CleanName), levels = rev(top40_names))) %>%
  ggplot(aes(x = value_scaled, y = CleanName, fill = metric)) +
  geom_col(width = 0.72, colour = "grey35", linewidth = 0.10) +
  geom_text(aes(label = value_label), hjust = -0.08, size = 2.4) +
  facet_grid(. ~ metric, labeller = ggplot2::label_value) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0, 1.13)) +
  scale_fill_manual(values = metric_cols, guide = "none") +
  labs(x = "Relative value within each metric", y = NULL) +
  base_theme(base_size = 10) +
  theme(
    axis.text.y = element_text(size = 6.5, face = "italic"),
    axis.text.x = element_text(size = 8),
    strip.background = element_rect(fill = "grey92", colour = "grey65"),
    strip.text.x = element_text(size = 11, face = "bold", margin = margin(4, 4, 4, 4)),
    panel.grid.major.y = element_blank()
  )

ggsave(file.path(FIG_EXPL_DIR, "Test_engagement_top40_faceted_bars.png"),
       p_eng_bars, width = 11.5, height = 9.0, dpi = 300, bg = "white")
ggsave(file.path(FIG_EXPL_DIR, "Test_engagement_top40_faceted_bars.tiff"),
       p_eng_bars, width = 11.5, height = 9.0, dpi = 300, compression = "lzw", bg = "white")

# H. Fixed radial engagement plot.
#    The bar length is the within-metric scaled value. This prevents the visual
#    issue where all species appeared to have the same height in the first test.
p_eng_radial <- ggplot(engagement_long, aes(x = CleanName, y = value_scaled, fill = metric)) +
  geom_col(position = position_dodge2(width = 0.82, preserve = "single"), width = 0.70, colour = NA) +
  scale_fill_manual(values = metric_cols, name = "Metric") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(-0.20, 1.05)) +
  coord_polar(clip = "off") +
  labs(x = NULL, y = "Relative value within each metric") +
  theme_light(base_size = 12) +
  theme(
    legend.position = "top",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 11),
    axis.text.x = element_text(size = 6.7, face = "italic"),
    axis.text.y = element_text(size = 9),
    axis.title.y = element_text(size = 12, margin = margin(r = 9)),
    panel.grid.minor = element_blank(),
    plot.margin = margin(14, 18, 14, 18)
  )

ggsave(file.path(FIG_EXPL_DIR, "Test_radial_engagement_top60.png"),
       p_eng_radial, width = 10.0, height = 9.2, dpi = 300, bg = "white")
ggsave(file.path(FIG_EXPL_DIR, "Test_radial_engagement_top60.tiff"),
       p_eng_radial, width = 10.0, height = 9.2, dpi = 300, compression = "lzw", bg = "white")

# Also overwrite the original output name.
ggsave(file.path(FIG_EXPL_DIR, "Test_radial_engagement_top60.png"),
       p_eng_radial, width = 10.0, height = 9.2, dpi = 300, bg = "white")
ggsave(file.path(FIG_EXPL_DIR, "Test_radial_engagement_top60.tiff"),
       p_eng_radial, width = 10.0, height = 9.2, dpi = 300, compression = "lzw", bg = "white")

# -------------------------------------------------------------------------
# 4) Optional icon-enhanced life-form summary
# -------------------------------------------------------------------------
# This block is skipped automatically if cowplot is unavailable. The main plots
# above do not depend on icons or extra packages.

if (requireNamespace("cowplot", quietly = TRUE)) {
  icon_dir <- file.path(PROJECT_ROOT, "fig_assets", "icons")
  icon_map <- c(
    "Birds" = file.path(icon_dir, "bird.png"),
    "Insects" = file.path(icon_dir, "insect.png"),
    "Fishes" = file.path(icon_dir, "fish.png"),
    "Plants" = file.path(icon_dir, "plant.png"),
    "Herptiles" = file.path(icon_dir, "herp.png"),
    "Crustaceans" = file.path(icon_dir, "crustacean.png"),
    "Non-arthropod invertebrates" = file.path(icon_dir, "invert_nonarth.png"),
    "Bacteria, Viruses, Fungi" = file.path(icon_dir, "bacteria.png")
  )
  icon_map <- icon_map[file.exists(icon_map)]
  
  p_icon_base <- p_avail_bar +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
  
  icon_canvas <- cowplot::ggdraw(p_icon_base)
  
  if (length(icon_map) > 0) {
    message("Icon files found; icon-enhanced plot is not drawn by default because exact placement depends on final figure size.")
  }
}

message("Exploratory video-availability and engagement figures written to: ", FIG_EXPL_DIR)
message("Exploratory source tables written to: ", QA_DIR)
message("Recommended first figures to inspect:")
message("  - Figure_S1.png (supplement)")
message("  - Test_species_availability_tilemap.png")
message("  - Test_species_availability_faceted_bars.png")
message("  - Test_engagement_top40_heatmap.png")
message("  - Test_engagement_top40_faceted_bars.png")
