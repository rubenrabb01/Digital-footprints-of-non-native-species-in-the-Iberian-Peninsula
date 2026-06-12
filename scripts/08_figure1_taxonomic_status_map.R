if (file.exists("scripts/00_direct_output_config.R")) source("scripts/00_direct_output_config.R", encoding = "UTF-8")
# ============================================================
# 08_figure1_taxonomic_status_map.R
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

# ============================ SETUP ==========================================
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(forcats)
library(sf)
library(rnaturalearth)
library(scatterpie)
library(patchwork)
library(cowplot)
library(png)   # for reading PNGs
library(grid)  # for rasterGrob

zoom_plot <- function(p, scale = 1.25) {
  cowplot::ggdraw() +
    cowplot::draw_plot(p, x = 0, y = 0, width = 1, height = 1, scale = scale)
}

# --------------------------- Lifeform order ----------------------------------
desired_lf_order <- c(
  "Birds","Herptiles","Fishes","Insects",
  "Crustaceans","Non-arthropod invertebrates","Plants","Bacteria, Viruses, Fungi"
)

# --------------------------- FIG 5 FONT SIZES / SPACING (APPLY HERE) ---------
AXIS_TITLE_SIZE <- 19
AXIS_TEXT_SIZE  <- 17
LEG_TITLE_SIZE  <- 19
LEG_TEXT_SIZE   <- 17
TAG_SIZE        <- 22

# --------------------------- Unified theme (match Fig 5) ---------------------
theme_inat <- function(base_size = 16) {
  theme_light(base_size = base_size) +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      legend.position    = "top",
      legend.direction   = "horizontal",
      legend.title       = element_text(size = LEG_TITLE_SIZE),
      legend.text        = element_text(size = LEG_TEXT_SIZE),
      axis.text.x        = element_text(
        size = AXIS_TEXT_SIZE, face = "plain", angle = 0, hjust = 0.5,
        margin = margin(t = 6)
      ),
      axis.text.y        = element_text(
        size = AXIS_TEXT_SIZE, face = "plain", margin = margin(r = 6)
      ),
      axis.title.x       = element_text(size = AXIS_TITLE_SIZE, margin = margin(t = 10)),
      axis.title.y       = element_text(size = AXIS_TITLE_SIZE, margin = margin(r = 10)),
      plot.title         = element_text(face = "plain", size = AXIS_TITLE_SIZE,
                                        margin = margin(b = 8))
    )
}

# --------------------------- ICONS (robust paths) ----------------------------
icon_filemap <- c(
  "Birds"  = "bird_counts.png",
  "Herptiles"="herp.png",
  "Fishes" = "fish_counts.png",
  "Insects"= "insect.png",
  "Crustaceans"="crustacean_counts.png",
  "Non-arthropod invertebrates"="invert_nonarth_counts.png",
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


# --------------------------- Helpers -----------------------------------------
norm_taxon <- function(x){
  x |> as.character() |> gsub("\\s+","_", x = _) |> gsub("__+","_", x = _) |> trimws()
}

status_levels <- c("Present","Established","Casual","Uncertain")
status_map <- c("alien"="Present","established"="Established","casual"="Casual","uncertain"="Uncertain")

base_cols <- c(
  "Present"     = "#FF5733",
  "Established" = "#33FF57",
  "Casual"      = "#3357FF",
  "Uncertain"   = "#FFC300"
)

# ============================ DATA (same as Fig 1) ============================
searched_status <- zenodo_grouped %>%
  mutate(
    TaxonName   = norm_taxon(TaxonName),
    StatusLabel = recode(tolower(PresentStatus), !!!status_map)
  ) %>%
  group_by(TaxonName) %>%
  slice_min(FirstRecord, with_ties = FALSE) %>%
  ungroup() %>%
  count(LifeForm, StatusLabel, name = "N") %>%
  mutate(Type = "Total species")

LABELLED_USE_STRICT_IBERIAN <- TRUE
lab_df <- combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN %>%
  mutate(
    TaxonName   = norm_taxon(TaxonName),
    StatusLabel = recode(tolower(PresentStatus), !!!status_map)
  )
if (LABELLED_USE_STRICT_IBERIAN && "is_iberian" %in% names(lab_df)) {
  lab_df <- lab_df %>% filter(is_iberian %in% c(TRUE, 1, "TRUE", "true"))
}

found_status <- lab_df %>%
  distinct(TaxonName, LifeForm, StatusLabel) %>%
  count(LifeForm, StatusLabel, name = "N") %>%
  mutate(Type = "Found species")

plot_df <- bind_rows(searched_status, found_status) %>%
  filter(!is.na(StatusLabel)) %>%
  mutate(
    StatusLabel = factor(StatusLabel, levels = status_levels),
    Type        = factor(Type, levels = c("Total species","Found species"))
  )

# Force LifeForm order globally (affects A bars + icons)
plot_df <- plot_df %>%
  mutate(LifeForm = factor(as.character(LifeForm), levels = desired_lf_order))

x_centers <- setNames(seq_along(levels(plot_df$LifeForm)), levels(plot_df$LifeForm))
plot_df <- plot_df %>%
  mutate(
    x_center = x_centers[as.character(LifeForm)],
    x = ifelse(Type == "Total species", x_center - 0.18, x_center + 0.18)
  )

bar_labels <- plot_df %>%
  group_by(LifeForm, Type, x) %>%
  summarise(Ntot = sum(N), .groups = "drop")

LINE_COL  <- "grey60"
LINE_SIZE <- 0.30
ymax_bars <- max(bar_labels$Ntot) * 1.15

BASE_FSIZE <- 14

# ============================ FIGURE 1A: BAR PLOT (builder) ===================
build_bars_A <- function(with_x_text = TRUE) {

  base_plot <- ggplot() +
    geom_col(
      data = plot_df %>% filter(Type == "Total species"),
      aes(x = x, y = N, fill = StatusLabel),
      width = 0.35, color = NA
    ) +
    geom_col(
      data = plot_df %>% filter(Type == "Found species"),
      aes(x = x, y = N, fill = StatusLabel),
      width = 0.35, color = NA, alpha = 0.5
    ) +
    geom_text(
      data = bar_labels,
      aes(x = x, y = Ntot, label = Ntot),
      vjust = -0.35, size = 6
    ) +
    scale_fill_manual(values = base_cols, limits = status_levels, name = "NNS status") +
    scale_x_continuous(
      breaks = x_centers, labels = names(x_centers),
      expand = expansion(mult = c(0.02, 0.08))
    ) +
    scale_y_continuous(
      breaks = function(lims) {
        br <- scales::pretty_breaks(n = 6)(c(0, ymax_bars))
        br[br < ymax_bars]
      }
    ) +
    labs(x = NULL, y = "Species count") +
    coord_cartesian(ylim = c(0, ymax_bars)) +

    annotate("segment", x = -Inf, xend = -Inf, y = 0,   yend =  Inf,
             linewidth = LINE_SIZE, colour = LINE_COL) +
    annotate("segment", x =  Inf, xend =  Inf, y = 0,   yend =  Inf,
             linewidth = LINE_SIZE, colour = LINE_COL) +
    annotate("segment", x = -Inf, xend =  Inf, y = Inf, yend = Inf,
             linewidth = LINE_SIZE, colour = LINE_COL) +

    theme_inat(16) +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),

      # legend INSIDE A), single column (restore the old format)
      legend.position      = c(0.90, 0.65),
      legend.justification = c(0.5, 0.5),
      legend.background    = element_rect(fill = "white", color = NA),
      legend.direction     = "vertical",   # <-- key
      legend.box           = "vertical",

      legend.title = element_text(size = LEG_TITLE_SIZE - 4, margin = margin(b = 12)),
      legend.text  = element_text(size = LEG_TEXT_SIZE - 4),
      legend.spacing.y  = unit(3, "lines"),
      legend.key.height = unit(10, "lines"),
      legend.key.size      = unit(1.25, "lines"),
      
      axis.title.y = element_text(size = AXIS_TITLE_SIZE, margin = margin(r = 18)),
      axis.text.y  = element_text(size = AXIS_TEXT_SIZE),

      panel.border = element_blank(),
      axis.line.x  = element_blank()
    ) +
    guides(
      fill = guide_legend(
        title.position = "top",
        title.hjust = 0,
        ncol = 1,                          # <-- key: single column
        byrow = TRUE,
            keyheight = unit(0.25, "lines"),        # <- **this** controls row spacing
            keywidth  = unit(1.2,  "lines"),
        label.theme = element_text(margin = margin(b = 6)),
        title.theme = element_text(margin = margin(b = 12))
      )
    )

  if (with_x_text) {
    base_plot
  } else {
    base_plot + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
  }
}

p_bars_with_x  <- build_bars_A(TRUE)
p_bars_no_x    <- build_bars_A(FALSE)


as_rgba <- function(img, light = 0.65,
                    tint = c(0.55, 0.50, 0.60)) {          # for light gray use: tint = c(0.75, 0.80, 0.90)) 
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

  # RGB
  if (!is.null(d) && length(d) == 3 && d[3] == 3) {
    col <- apply_tint(img)
    out <- array(1, dim = c(d[1], d[2], 4))
    out[,,1] <- col$r
    out[,,2] <- col$g
    out[,,3] <- col$b
    return(out)
  }

  # RGBA
  if (!is.null(d) && length(d) == 3 && d[3] == 4) {
    col <- apply_tint(img[,,1])
    img[,,1] <- col$r
    img[,,2] <- col$g
    img[,,3] <- col$b
    return(img)
  }

  # Grayscale matrix
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


# --------- Add icons below the x-axis (no baseline line) ----------------------
add_x_icons <- function(p_bars_no_x, x_centers, icon_paths,
                        icon_width_data = 0.56,
                        icon_height_frac = 0.24,
                        gap_frac = 0.016,
                        pad_frac = 0.00001,
                        bottom_margin = 8,
                        draw_baseline = TRUE) {

  maxN <- max(bar_labels$Ntot)
  ymax <- maxN * 1.15

  y_icon_h <- maxN * icon_height_frac
  gap      <- maxN * gap_frac
  pad      <- maxN * pad_frac

  y_center <- -(gap + y_icon_h/2)
  y_min    <- (y_center - y_icon_h/2 - pad)

  annos <- lapply(names(x_centers), function(lf) {
    path <- icon_paths[lf]
    if (is.na(path) || !file.exists(path)) return(NULL)
    img  <- png::readPNG(path)
    img  <- as_rgba(img)
    grob <- grid::rasterGrob(img, interpolate = TRUE)

    x0 <- as.numeric(x_centers[lf]) - icon_width_data
    x1 <- as.numeric(x_centers[lf]) + icon_width_data
    y0 <- y_center - y_icon_h/2
    y1 <- y_center + y_icon_h/2

    ggplot2::annotation_custom(grob, xmin = x0, xmax = x1, ymin = y0, ymax = y1)
  })
  annos <- annos[!vapply(annos, is.null, logical(1))]

  p_out <- p_bars_no_x +
    annos +
    coord_cartesian(ylim = c(y_min, ymax), clip = "off") +
    theme(plot.margin = margin(t = 5, r = 5, b = bottom_margin, l = 5))

  if (draw_baseline) {
    p_out <- p_out + ggplot2::geom_hline(yintercept = 0, linewidth = LINE_SIZE, colour = LINE_COL)
  }
  p_out
}

p_bars_no_x_icons <- add_x_icons(
  p_bars_no_x, x_centers, icon_paths,
  icon_width_data  = 0.45,
  icon_height_frac = 0.2,
  gap_frac         = 0.016,
  pad_frac         = 0.00001,
  bottom_margin    = 8,
  draw_baseline    = TRUE
)
       
# ============================ MAP DATA FOR PANEL B ============================
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
iberia_outline <- world %>% filter(admin %in% c("Spain","Portugal","Andorra"))
regions_sf <- iberia_outline

region_pts <- tibble::tribble(
  ~region,           ~lon,   ~lat,
  "Spain",           -3.5,   40.0,
  "Portugal",        -8.0,   39.5,
  "Andorra",          1.6,   42.5,
  "Azores",         -25.5,   37.7,
  "Madeira",        -16.9,   32.7,
  "Canary Islands", -15.5,   28.3
)

xlim <- c(-30, 6); ylim <- c(27.5, 45.5)

counts_found <- lab_df %>%
  distinct(TaxonName, LifeForm, Region, StatusLabel) %>%
  filter(Region %in% region_pts$region) %>%
  count(Region, LifeForm, StatusLabel, name = "n_species")

CRS_USE <- 3035

iberia_outline <- sf::st_transform(iberia_outline, CRS_USE)
regions_sf     <- sf::st_transform(regions_sf, CRS_USE)

region_pts_sf <- sf::st_as_sf(region_pts, coords = c("lon","lat"), crs = 4326) %>%
  sf::st_transform(CRS_USE)

region_xy <- cbind(region_pts_sf, sf::st_coordinates(region_pts_sf)) %>%
  sf::st_drop_geometry() %>%
  dplyr::rename(x = X, y = Y)

bb_iberia <- sf::st_bbox(iberia_outline)

bb_pts <- c(
  xmin = min(region_xy$x, na.rm = TRUE),
  xmax = max(region_xy$x, na.rm = TRUE),
  ymin = min(region_xy$y, na.rm = TRUE),
  ymax = max(region_xy$y, na.rm = TRUE)
)

bb_all <- c(
  xmin = min(bb_iberia["xmin"], bb_pts["xmin"]),
  xmax = max(bb_iberia["xmax"], bb_pts["xmax"]),
  ymin = min(bb_iberia["ymin"], bb_pts["ymin"]),
  ymax = max(bb_iberia["ymax"], bb_pts["ymax"])
)

buf_x <- as.numeric((bb_all["xmax"] - bb_all["xmin"]) * 0.025)
buf_y <- as.numeric((bb_all["ymax"] - bb_all["ymin"]) * 0.025)

xlim_proj <- c(bb_all["xmin"] - buf_x, bb_all["xmax"] + buf_x)
ylim_proj <- c(bb_all["ymin"] - buf_y, bb_all["ymax"] + buf_y)

status_cols <- status_levels

pies_by_lifeform <- counts_found %>%
  mutate(StatusLabel = factor(StatusLabel, levels = status_levels)) %>%
  pivot_wider(
    id_cols = c(Region, LifeForm),
    names_from = StatusLabel,
    values_from = n_species,
    values_fill = 0
  ) %>%
  left_join(region_xy, by = c("Region" = "region")) %>%
  group_by(LifeForm) %>%
  mutate(
    total_LF = rowSums(across(all_of(status_cols))),
    radius = {
      rng <- range(total_LF, na.rm = TRUE)
      if (is.finite(rng[1]) && diff(rng) > 0) {
        scales::rescale(total_LF, to = c(0.7, 1.9), from = rng)
      } else rep(1.2, dplyr::n())
    },
    radius_m = radius * 100000
  ) %>%
  ungroup() %>%
  mutate(LifeForm = factor(LifeForm, levels = desired_lf_order))

# ============================ FIGURE 1B (faceted map) =========================
p_map_faceted_inset <- ggplot() +
  geom_sf(data = iberia_outline, fill = "grey95", color = "grey70", linewidth = 0.25) +
  geom_sf(data = regions_sf,     fill = NA,       color = "grey40", linewidth = 0.4) +
  scatterpie::geom_scatterpie(
    data = pies_by_lifeform,
    aes(x = x, y = y, r = radius_m),
    cols = status_cols,
    color = "grey20", linewidth = 0.3, alpha = 0.95
  ) +
  scale_fill_manual(values = base_cols[status_cols], drop = FALSE, name = "NIS status") +
  coord_sf(crs = CRS_USE, xlim = xlim_proj, ylim = ylim_proj, expand = FALSE, datum = NA) +
  facet_wrap(
    ~ LifeForm,
    ncol = 4, nrow = 2,
    labeller = labeller(
      LifeForm = c(
        "Non-arthropod invertebrates" = "N.A. invertebrates",
        "Bacteria, Viruses, Fungi"   = "Bacteria/Viruses/Fungi"
      )
    )
  ) +
  theme_inat(16) +
  theme(
    legend.position  = "none",
    plot.title       = element_blank(),
    plot.subtitle    = element_blank(),
    axis.text.x      = element_blank(),
    axis.text.y      = element_blank(),
    axis.ticks.x     = element_blank(),
    axis.ticks.y     = element_blank(),
    axis.title       = element_blank(),
    panel.grid       = element_blank(),
    strip.background = element_rect(fill = "white", color = NA),
    strip.text = element_text(
      face = "plain",
      size = AXIS_TEXT_SIZE,
      color = "black",
      margin = margin(3, 3, 3, 3)
    ),
    panel.border     = element_rect(color = "grey70", fill = NA, linewidth = 0.3),
    plot.margin      = margin(t = 6, r = 0, b = 6, l = 0),
    plot.background  = element_rect(fill = "white", colour = NA),
    panel.background = element_rect(fill = "white", colour = NA)
  )

p_map_faceted_inset <- p_map_faceted_inset +
  theme(
    strip.text = element_text(size = 14)  # <-- lower this (e.g., 12-15)
  )


# ============================ COMBINE (STACKED) + SAVE ========================
out_dir <- FIG_MAIN_DIR
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

compose_and_save_stacked <- function(panelA, panelB, filename,
                                     width = 11.5, height = 8.6, dpi = 300,
                                     heights = c(1.22, 0.03, 1.23),
                                     label_size = TAG_SIZE,
                                     save_tiff = TRUE,
                                     tiff_filename = NULL,
                                     tiff_compression = "lzw") {

  L <- 6; R_A <- 6; R_B <- 0
  panelA2 <- panelA + theme(plot.margin = margin(t = 10, r = R_A, b = 14, l = L))
  panelB2 <- panelB + theme(plot.margin = margin(t =  1, r = R_B, b =  6, l = L))

  combo <- panelA2 /
    patchwork::plot_spacer() /
    panelB2 +
    patchwork::plot_layout(heights = heights)

  total_h <- sum(heights)
  y_A <- 0.99
  y_B <- (heights[3] / total_h) + 0.01

  p <- cowplot::ggdraw(combo) +
    cowplot::draw_plot_label(
      c("A)", "B)"),
      x = c(0.012, 0.012),
      y = c(y_A, y_B),
      hjust = c(0, 0),
      vjust = c(1, 1),
      size = label_size,
      fontface = "plain"
    ) +
    cowplot::draw_label(
      "Colors: solid = Total; translucent = Found",
      x = 0.625,
      y = 0.965,
      hjust = 0,
      vjust = 1,
      fontface = "italic",
      size = BASE_FSIZE * 0.90
    ) +
    theme(plot.background = element_rect(fill = "white", colour = NA))

  # ---- Save PNG (as before) ----
  ggplot2::ggsave(
    filename = file.path(out_dir, filename),
    plot = p,
    width = width, height = height, units = "in", dpi = dpi,
    bg = "white"
  )

  # ---- Save TIFF (new) ----
  if (isTRUE(save_tiff)) {
    if (is.null(tiff_filename)) {
      tiff_filename <- sub("\\.png$", ".tiff", filename, ignore.case = TRUE)
      if (identical(tiff_filename, filename)) {
        tiff_filename <- paste0(filename, ".tiff")
      }
    }

    ggplot2::ggsave(
      filename = file.path(out_dir, tiff_filename),
      plot = p,
      width = width, height = height, units = "in", dpi = dpi,
      device = "tiff",
      compression = tiff_compression,
      bg = "white"
    )
  }

  return(p)
}


Fig1_stacked_no_x_icons <- compose_and_save_stacked(
  p_bars_no_x_icons,
  p_map_faceted_inset,
  "Figure1_STACKED_faceted_map_no_xaxis_icons.png",
  width = 10.5, height = 8.6, dpi = 300
)

print(Fig1_stacked_no_x_icons)



# ---- FINAL DIRECT EXPORT NAME (main paper) ---------------------------------
# Keep only the approved Figure 1 names in clean output folder.
for (ext in c(".png", ".tiff")) {
  src <- file.path(FIG_MAIN_DIR, paste0("Figure1_STACKED_faceted_map_no_xaxis_icons", ext))
  dst <- file.path(FIG_MAIN_DIR, paste0("Figure_1", ext))
  if (file.exists(src)) file.rename(src, dst)
}
# remove other Figure1 variants in the same clean folder
unlink(setdiff(list.files(FIG_MAIN_DIR, pattern = "^Figure1|^Figure_1_", full.names = TRUE),
               file.path(FIG_MAIN_DIR, c("Figure_1.png", "Figure_1.tiff"))), force = TRUE)
