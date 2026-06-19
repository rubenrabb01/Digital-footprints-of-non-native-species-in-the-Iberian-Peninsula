# ============================================================
# 12b_figures_S4_S5_weighted_sensitivity_calibration.R
#
# Adapted from the submitted Figure S6 + S5 script.
# Produces the missing Supplementary Figures S4 and S5 directly
# in outputs/figures/supplement, using the model objects fitted
# in 12_figures4_S3_S6_model_predictions.R.
#
# IMPORTANT: This script intentionally preserves the submitted
# styling constants, category colours, icon tinting, panel layout,
# and export dimensions used in the old Figure S6/S5 script.
# ============================================================

if (!exists("ANALYSIS_MODE", inherits = FALSE)) ANALYSIS_MODE <- "NO_COMMENTS"
if (ANALYSIS_MODE != "NO_COMMENTS") {
  message("Skipping Figures S4/S5 because ANALYSIS_MODE != NO_COMMENTS.")
} else {

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(tibble)
  library(purrr)
  library(ggplot2)
  library(scales)
  library(readr)
  library(ggimage)
  library(cowplot)
  library(ggnewscale)
  library(grid)
  library(png)
})

if (file.exists("scripts/00_direct_output_config.R")) {
  source("scripts/00_direct_output_config.R", encoding = "UTF-8")
}
if (!exists("FIG_SUPP_DIR", inherits = TRUE)) FIG_SUPP_DIR <- file.path("outputs", "figures", "supplement")
if (!exists("TAB_SUPP_DIR", inherits = TRUE)) TAB_SUPP_DIR <- file.path("outputs", "tables", "supplement")
dir.create(FIG_SUPP_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TAB_SUPP_DIR, recursive = TRUE, showWarnings = FALSE)

# ---------------------------
# MODEL OBJECTS FROM SCRIPT 12
# ---------------------------
# The submitted S4/S5 script expected m_step, m_w_step, df, dat_mlr and nd.
# In the cleaned workflow, these are created in script 12 with explicit names.
if (!exists("m_step", inherits = FALSE)) {
  if (exists("m_step_NO_COMMENTS", inherits = TRUE)) m_step <- get("m_step_NO_COMMENTS", inherits = TRUE)
}
if (!exists("m_w_step", inherits = FALSE)) {
  if (exists("m_w_step_ci", inherits = TRUE)) m_w_step <- get("m_w_step_ci", inherits = TRUE)
}
if (!exists("df", inherits = FALSE)) {
  if (exists("df_NO_COMMENTS", inherits = TRUE)) df <- get("df_NO_COMMENTS", inherits = TRUE)
}
if (!exists("dat_mlr", inherits = FALSE)) dat_mlr <- df

stopifnot(exists("m_step"), exists("m_w_step"), exists("df"))
stopifnot(all(c("LifeForm","time_period","PresentStatus","KeywordCategory") %in% names(df)))

# --------------------------- FONT SIZES (UNIFIED; submitted values) ----------
AXIS_TITLE_SIZE <- 19
AXIS_TEXT_SIZE  <- 17
LEG_TITLE_SIZE  <- 19
LEG_TEXT_SIZE   <- 17
TAG_SIZE        <- 22

# --------------------------- Lifeform order (match Fig 1-4) ------------------
desired_lf_order <- c(
  "Birds","Herptiles","Fishes","Insects",
  "Crustaceans","Non-arthropod invertebrates","Plants","Bacteria, Viruses, Fungi"
)

# --------------------------- COLOR SCHEME (EXACT submitted values) -----------
base_cols <- c(
  Detection = "#959BFF",
  eCommerce = "#6F4685",
  Invasion  = "#A6FF4D",
  Threat    = "#ff7f1b"
)
kw_cols   <- base_cols
kw_levels <- c("Invasion","Detection","eCommerce","Threat")

# Heatmap tint helper used in the submitted figure style.
if (!exists("tint_to_white", inherits = TRUE)) {
  tint_to_white <- function(hex, t, min_int = 0.10, max_int = 1.0){
    s <- min_int + (max_int - min_int) * pmin(pmax(t, 0), 1)
    b <- grDevices::col2rgb(hex) / 255
    out <- 1 - (1 - b) * s
    grDevices::rgb(out[1], out[2], out[3])
  }
}

# --------------------------- ICONS (robust paths; submitted tint values) -----
icon_filemap <- c(
  "Birds"  = "bird_multinom.png",
  "Herptiles"="herp.png",
  "Fishes" = "fish.png",
  "Insects"= "insect.png",
  "Crustaceans"="crustacean.png",
  "Non-arthropod invertebrates"="invert_nonarth_diversity.png",
  "Plants"     ="plant.png",
  "Bacteria, Viruses, Fungi"   ="bacteria.png"
)

icon_dir_candidates <- c("fig_assets/icons", "fig_assets")
pick_icon_dir <- function(cands, probe = "bird_multinom.png") {
  for (d in cands) {
    if (dir.exists(d) && file.exists(file.path(d, probe))) return(d)
  }
  return(NA_character_)
}
ICON_DIR <- pick_icon_dir(icon_dir_candidates)
if (is.na(ICON_DIR)) {
  stop("Couldn't find icons. Tried: ", paste(icon_dir_candidates, collapse = ", "),
       "\nWorking directory: ", getwd(),
       "\nMake sure at least one icon (e.g., bird_multinom.png) is in fig_assets/ or fig_assets/icons/")
}
icon_paths <- file.path(ICON_DIR, icon_filemap[desired_lf_order])
names(icon_paths) <- desired_lf_order

as_rgba <- function(img, light = 0.65,
                    tint = c(0.75, 0.80, 0.90)) {
  d <- dim(img)
  apply_tint <- function(g) {
    g <- light + (1 - light) * g
    list(r = g * tint[1], g = g * tint[2], b = g * tint[3])
  }
  if (!is.null(d) && length(d) == 3 && d[3] == 2) {
    g <- img[,,1]; a <- img[,,2]; col <- apply_tint(g)
    out <- array(0, dim = c(d[1], d[2], 4))
    out[,,1] <- col$r; out[,,2] <- col$g; out[,,3] <- col$b; out[,,4] <- a
    return(out)
  }
  if (!is.null(d) && length(d) == 3 && d[3] == 3) {
    col <- apply_tint(img)
    out <- array(1, dim = c(d[1], d[2], 4))
    out[,,1] <- col$r; out[,,2] <- col$g; out[,,3] <- col$b
    return(out)
  }
  if (!is.null(d) && length(d) == 3 && d[3] == 4) {
    col <- apply_tint(img[,,1])
    img[,,1] <- col$r; img[,,2] <- col$g; img[,,3] <- col$b
    return(img)
  }
  if (!is.null(d) && length(d) == 2) {
    col <- apply_tint(img)
    out <- array(0, dim = c(d[1], d[2], 4))
    out[,,1] <- col$r; out[,,2] <- col$g; out[,,3] <- col$b; out[,,4] <- 1
    return(out)
  }
  stop("Unsupported PNG format: dim = ", paste(d, collapse = " x "))
}

ICON_LIGHT <- 0.65
ICON_TINT  <- c(0.55, 0.50, 0.60)

tinted_dir <- file.path(ICON_DIR, "_tinted_icons")
if (!dir.exists(tinted_dir)) dir.create(tinted_dir, recursive = TRUE)
tinted_icon_paths <- icon_paths

for (lf in names(icon_paths)) {
  fp <- icon_paths[[lf]]
  if (is.null(fp) || !file.exists(fp)) next
  out_fp <- file.path(
    tinted_dir,
    sprintf("%s__L%s__T%s-%s-%s.png",
            tools::file_path_sans_ext(basename(fp)),
            format(ICON_LIGHT, nsmall = 2),
            format(ICON_TINT[1], nsmall = 2),
            format(ICON_TINT[2], nsmall = 2),
            format(ICON_TINT[3], nsmall = 2))
  )
  if (!file.exists(out_fp)) {
    img <- png::readPNG(fp)
    img <- as_rgba(img, light = ICON_LIGHT, tint = ICON_TINT)
    png::writePNG(img, target = out_fp)
  }
  tinted_icon_paths[[lf]] <- out_fp
}
icon_paths <- tinted_icon_paths

add_x_icons_bars_bottom <- function(p, pred_df, icon_paths,
                                    icon_width_x    = 1.15,
                                    icon_height_rel = 0.40,
                                    gap_rel         = 0.085,
                                    bottom_margin_pts = 70) {
  x_levels <- levels(pred_df$LifeForm)
  bottom_level <- tail(levels(pred_df$time_period_plot), 1)
  df_icons <- data.frame(
    time_period_plot = factor(bottom_level, levels = levels(pred_df$time_period_plot)),
    LifeForm    = factor(x_levels, levels = x_levels),
    x           = seq_along(x_levels),
    y           = -gap_rel - icon_height_rel/2,
    image       = unname(icon_paths[x_levels]),
    stringsAsFactors = FALSE
  )
  size_x <- icon_width_x / length(x_levels)
  size_y <- icon_height_rel
  size   <- max(size_x, size_y)
  p +
    ggimage::geom_image(
      data = df_icons,
      aes(x = x, y = y, image = image),
      inherit.aes = FALSE,
      size = size
    ) +
    coord_cartesian(ylim = c(0, 1), clip = "off") +
    theme(plot.margin = margin(t = 6, r = 8, b = bottom_margin_pts, l = 10))
}

# ============================================================
# DATA CHECKS + FACTOR LEVELS
# ============================================================
df <- df %>%
  mutate(
    time_period = factor(as.character(time_period), levels = c("Pre-Introduction","Post-Introduction")),
    LifeForm = factor(as.character(LifeForm)),
    PresentStatus = factor(as.character(PresentStatus)),
    KeywordCategory = factor(as.character(KeywordCategory), levels = kw_levels)
  ) %>%
  filter(!is.na(time_period), !is.na(LifeForm), !is.na(PresentStatus), !is.na(KeywordCategory)) %>%
  droplevels()

lf_levels_present <- desired_lf_order[desired_lf_order %in% levels(df$LifeForm)]
df <- df %>% mutate(LifeForm = factor(LifeForm, levels = lf_levels_present))
dat_mlr <- df

# ============================================================
# BUILD NEWDATA GRID FOR WEIGHTED MODEL
# ============================================================
Terms_w <- terms(m_w_step)
mf_w    <- model.frame(m_w_step)
xlev_w  <- lapply(mf_w, levels)

nd <- expand.grid(
  LifeForm      = levels(df$LifeForm),
  time_period   = levels(df$time_period),
  PresentStatus = levels(df$PresentStatus),
  KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
)

for (v in intersect(names(nd), names(xlev_w))) {
  nd[[v]] <- factor(nd[[v]], levels = xlev_w[[v]])
}

# ============================================================
# PREDICT PROBABILITIES (WEIGHTED MODEL) AND MARGINALISE STATUS
# ============================================================
pred_mat_w <- as.data.frame(predict(m_w_step, newdata = nd, type = "probs"))
resp_levels <- levels(model.frame(m_w_step)[[1]])
keep_cols   <- intersect(resp_levels, colnames(pred_mat_w))
stopifnot(length(keep_cols) >= 2)

pred_long <- bind_cols(nd, pred_mat_w[, keep_cols, drop = FALSE]) %>%
  pivot_longer(cols = all_of(keep_cols),
               names_to = "KeywordCategory",
               values_to = "prob") %>%
  mutate(
    KeywordCategory = factor(KeywordCategory, levels = kw_levels),
    LifeForm = factor(LifeForm, levels = lf_levels_present),
    time_period = factor(time_period, levels = c("Pre-Introduction","Post-Introduction"))
  )

w_status <- df %>%
  count(LifeForm, time_period, PresentStatus, name = "n") %>%
  group_by(LifeForm, time_period) %>%
  mutate(w = n / sum(n)) %>%
  ungroup()

pred_marg <- pred_long %>%
  left_join(w_status, by = c("LifeForm","time_period","PresentStatus")) %>%
  mutate(w = coalesce(w, 0)) %>%
  group_by(LifeForm, time_period, KeywordCategory) %>%
  summarise(prob = sum(prob * w), .groups = "drop") %>%
  mutate(
    time_period_plot = factor(as.character(time_period),
                              levels = c("Pre-Introduction","Post-Introduction"))
  )

# ============================================================
# FIG S4A — HEATMAP
# ============================================================
pred_heat <- pred_marg %>%
  mutate(
    fill_col = vapply(seq_len(n()), function(i){
      base <- kw_cols[[as.character(pred_marg$KeywordCategory[i])]]
      tint_to_white(base, pred_marg$prob[i])
    }, character(1))
  )

anchor_x <- levels(pred_heat$LifeForm)[1]
anchor_y <- levels(pred_heat$KeywordCategory)[1]

p_S4A <- ggplot(pred_heat, aes(x = LifeForm, y = KeywordCategory)) +
  geom_tile(aes(fill = fill_col), width = 1, height = 1) +
  scale_fill_identity(guide = "none") +
  geom_text(aes(label = sprintf("%.2f", prob)), size = 4.2, colour = "black") +
  facet_wrap(~ time_period_plot, ncol = 1, strip.position = "right") +
  ggnewscale::new_scale_fill() +
  geom_point(
    data = data.frame(
      prob = seq(0, 1, length.out = 100),
      LifeForm = factor(anchor_x, levels = levels(pred_heat$LifeForm)),
      KeywordCategory = factor(anchor_y, levels = levels(pred_heat$KeywordCategory))
    ),
    aes(x = LifeForm, y = KeywordCategory, fill = prob),
    alpha = 0, inherit.aes = FALSE
  ) +
  scale_fill_gradient(
    name = "Pred. prob.",
    limits = c(0, 1),
    breaks = c(0, .25, .5, .75, 1),
    labels = c("0.00","0.25","0.50","0.75","1.00"),
    low = "white", high = "grey20",
    guide = guide_colourbar(
      barheight = unit(80, "pt"),
      title.position = "top",
      title.hjust = 0.5,
      title.theme = element_text(size = LEG_TITLE_SIZE),
      label.theme = element_text(size = LEG_TEXT_SIZE)
    )
  ) +
  labs(x = NULL, y = NULL) +
  theme_light(base_size = 16) +
  theme(
    strip.background   = element_rect(fill = NA, colour = NA),
    strip.text.y.right = element_text(face = "plain", colour = "black", margin = margin(l = 3), size = AXIS_TEXT_SIZE),
    strip.placement    = "inside",
    axis.text.x        = element_blank(),
    axis.ticks.x       = element_blank(),
    axis.title.y       = element_blank(),
    axis.text.y        = element_text(size = AXIS_TEXT_SIZE, colour = NA),
    axis.ticks.y       = element_blank(),
    panel.grid         = element_blank(),
    plot.margin        = margin(t = 6, r = 8, b = 2, l = 10)
  ) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0))

# ============================================================
# FIG S4B — DELTA (Post - Pre) STEMS
# ============================================================
pred_delta <- pred_marg %>%
  dplyr::select(LifeForm, time_period, KeywordCategory, prob) %>%
  tidyr::pivot_wider(
    names_from  = time_period,
    values_from = prob,
    values_fn   = mean
  ) %>%
  dplyr::mutate(
    delta = `Post-Introduction` - `Pre-Introduction`,
    KeywordCategory = factor(KeywordCategory, levels = kw_levels),
    LifeForm        = factor(LifeForm, levels = lf_levels_present),
    period_strip    = factor("Δ (Post - Pre)", levels = "Δ (Post - Pre)")
  )

offset_map <- c(Invasion = -0.33, Detection = -0.11, eCommerce = 0.11, Threat = 0.33)
pred_delta <- pred_delta %>%
  dplyr::mutate(
    x_idx = as.numeric(LifeForm),
    x_pos = x_idx + unname(offset_map[as.character(KeywordCategory)])
  )

n_lf <- nlevels(pred_delta$LifeForm)

p_S4B <- ggplot(pred_delta, aes(colour = KeywordCategory)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_segment(aes(x = x_pos, xend = x_pos, y = 0, yend = delta), linewidth = 0.9) +
  geom_point(aes(x = x_pos, y = delta), size = 2.8) +
  scale_colour_manual(values = kw_cols, name = "Keyword category") +
  labs(x = NULL, y = expression(Delta~" probability (Post - Pre)")) +
  facet_wrap(~ period_strip, ncol = 1, strip.position = "right") +
  scale_x_continuous(
    limits = c(0.5, n_lf + 0.5),
    breaks = 1:n_lf, labels = levels(pred_delta$LifeForm),
    expand = expansion(mult = c(0, 0))
  ) +
  theme_light(base_size = 16) +
  theme(
    strip.background   = element_rect(fill = NA, colour = NA),
    strip.text.y.right = element_text(face = "plain", colour = "black", margin = margin(l = 3), size = AXIS_TEXT_SIZE),
    strip.placement    = "inside",
    axis.text.x        = element_blank(),
    axis.ticks.x       = element_blank(),
    axis.title.y       = element_text(size = AXIS_TITLE_SIZE, margin = margin(r = 18)),
    axis.text.y        = element_text(size = AXIS_TEXT_SIZE, margin = margin(r = 6)),
    legend.position    = "right",
    legend.text        = element_text(size = LEG_TEXT_SIZE),
    plot.margin        = margin(t = 6, r = 8, b = 2, l = 10)
  )

# ============================================================
# FIG S4C — BARS + approx 95% CI (weighted model)
# ============================================================
n_eff <- df %>% count(LifeForm, time_period, name = "n_eff")

pred_bar <- pred_marg %>%
  left_join(n_eff, by = c("LifeForm","time_period")) %>%
  mutate(
    n_eff = pmax(n_eff, 1),
    se    = sqrt(prob * (1 - prob) / n_eff),
    lower = pmax(prob - 1.96 * se, 0),
    upper = pmin(prob + 1.96 * se, 1),
    KeywordCategory = factor(KeywordCategory, levels = kw_levels),
    LifeForm = factor(LifeForm, levels = lf_levels_present),
    time_period_plot = factor(as.character(time_period), levels = c("Pre-Introduction","Post-Introduction"))
  )

dodge <- position_dodge(width = 0.8)

p_S4C_base <- ggplot(pred_bar, aes(x = LifeForm, y = prob)) +
  geom_col(aes(fill = KeywordCategory, group = KeywordCategory),
           position = dodge, width = 0.8) +
  geom_errorbar(aes(ymin = lower, ymax = upper, group = KeywordCategory),
                position = dodge, width = 0.25, colour = "grey20") +
  scale_fill_manual(values = kw_cols, name = "Keyword category") +
  labs(x = NULL, y = "Predicted probability") +
  facet_wrap(~ time_period_plot, ncol = 1, strip.position = "right") +
  theme_light(base_size = 16) +
  theme(
    strip.background   = element_rect(fill = NA, colour = NA),
    strip.text.y.right = element_text(face = "plain", colour = "black", margin = margin(l = 3), size = AXIS_TEXT_SIZE),
    strip.placement    = "inside",
    axis.text.x        = element_blank(),
    axis.ticks.x       = element_blank(),
    axis.title.y       = element_text(size = AXIS_TITLE_SIZE, margin = margin(r = 18)),
    axis.text.y        = element_text(size = AXIS_TEXT_SIZE, margin = margin(r = 6)),
    legend.position    = "right",
    legend.text        = element_text(size = LEG_TEXT_SIZE),
    plot.margin        = margin(t = 6, r = 8, b = 6, l = 10)
  ) +
  scale_x_discrete(expand = c(0, 0))

p_S4C <- add_x_icons_bars_bottom(p_S4C_base, pred_bar, icon_paths)

# ============================================================
# COMPOSE FIGURE S4 (A+B+C stacked)
# ============================================================
tag_style <- theme(
  plot.tag.position = c(0.00, 1.00),
  plot.tag = element_text(size = TAG_SIZE, face = "plain")
)
COMMON_MARGIN <- margin(t = 6, r = 8, b = 2, l = 26)

p_S4A_m <- p_S4A + theme(plot.margin = COMMON_MARGIN)
p_S4B_m <- p_S4B + theme(plot.margin = COMMON_MARGIN)
p_S4C_m <- p_S4C + theme(plot.margin = margin(t = 6, r = 8, b = 70, l = 26))

A_TAG_X <- 0.030
A_TAG_Y <- 0.995

pA <- p_S4A_m + labs(tag = "A)") + tag_style + theme(plot.tag.position = c(A_TAG_X, A_TAG_Y))
pB <- p_S4B_m + labs(tag = "B)") + tag_style
pC <- p_S4C_m + labs(tag = "C)") + tag_style

Fig_S4_panel_core <- cowplot::plot_grid(
  pA, pB, pC,
  ncol = 1,
  rel_heights = c(1.05, 0.85, 1.25),
  align = "v",
  axis  = "lr"
)

LEFT_PAD  <- 0.00
RIGHT_PAD <- 0.06
TOP_PAD   <- 0.00
BOT_PAD   <- 0.00

Fig_S4_panel_core <- cowplot::ggdraw() +
  cowplot::draw_plot(
    Fig_S4_panel_core,
    x = LEFT_PAD,
    y = BOT_PAD,
    width  = 1 - LEFT_PAD - RIGHT_PAD,
    height = 1 - TOP_PAD  - BOT_PAD
  )

# ============================================================
# FIGURE S5 — Calibration (Observed vs Predicted)
# ============================================================
theme_inat_S5 <- function(base_size = 16) {
  theme_light(base_size = base_size) +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      legend.position    = "right",
      legend.title       = element_blank(),
      legend.text        = element_text(size = LEG_TEXT_SIZE),
      axis.text.x        = element_text(size = AXIS_TEXT_SIZE, margin = margin(t = 4)),
      axis.text.y        = element_text(size = AXIS_TEXT_SIZE, margin = margin(r = 6)),
      axis.title.x       = element_text(size = AXIS_TITLE_SIZE, margin = margin(t = 10)),
      axis.title.y       = element_text(size = AXIS_TITLE_SIZE, margin = margin(r = 10)),
      strip.background = element_rect(fill = "white", colour = NA),
      strip.text       = element_text(size = AXIS_TEXT_SIZE, face = "italic", colour = "black"),
      plot.margin        = margin(t = 6, r = 10, b = 6, l = 10)
    )
}

if ("KeywordCategory" %in% names(dat_mlr)) {
  dat_mlr <- dat_mlr %>% mutate(KeywordCategory = factor(KeywordCategory, levels = kw_levels))
}

obs <- dat_mlr %>%
  count(LifeForm, time_period, PresentStatus, KeywordCategory, name = "n") %>%
  group_by(LifeForm, time_period, PresentStatus) %>%
  mutate(obs_prop = n / sum(n)) %>%
  ungroup()

pred_mat <- as.data.frame(predict(m_step, newdata = nd, type = "probs"))
resp_levels2 <- levels(model.frame(m_step)[[1]])
keep_cols2   <- intersect(resp_levels2, colnames(pred_mat))
if (length(keep_cols2) == 0) stop("No matching probability columns found in predict(..., type='probs').")

pred_unw <- bind_cols(nd, pred_mat[, keep_cols2, drop = FALSE]) %>%
  pivot_longer(cols = all_of(keep_cols2),
               names_to = "KeywordCategory",
               values_to = "pred_prop") %>%
  mutate(KeywordCategory = factor(KeywordCategory, levels = kw_levels))

cal <- left_join(
  obs, pred_unw,
  by = c("LifeForm","time_period","PresentStatus","KeywordCategory")
) %>%
  filter(!is.na(pred_prop), !is.na(obs_prop))

p_S5 <- ggplot(
  cal,
  aes(x = pred_prop, y = obs_prop, colour = KeywordCategory)
) +
  geom_abline(slope = 1, intercept = 0, linetype = 2, linewidth = 0.6, colour = "black") +
  geom_point(aes(size = n), alpha = 0.7) +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
  scale_x_continuous(
    limits = c(0, 1),
    breaks = c(0, 0.25, 0.5, 0.75, 1),
    labels = c("0", "0.25", "0.5", "0.75", "1")
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = c(0, 0.25, 0.5, 0.75, 1),
    labels = c("0", "0.25", "0.5", "0.75", "1")
  ) +
  facet_wrap(~ KeywordCategory, ncol = 2) +
  scale_colour_manual(values = base_cols, guide = "none") +
  scale_size_continuous(range = c(1.8, 6), guide = "none") +
  labs(x = "Model-predicted proportion", y = "Observed proportion") +
  theme_inat_S5(16) +
  theme(
    panel.spacing.x   = unit(14, "pt"),
    strip.background  = element_rect(fill = "white", colour = NA),
    strip.text        = element_text(face = "italic", colour = "black", size = 17)
  )

# ============================================================
# EXPORT FIGURES DIRECTLY TO SUPPLEMENTARY FOLDER
# ============================================================
ggsave(file.path(FIG_SUPP_DIR, "Figure_S5.png"),
       Fig_S4_panel_core, width = 375, height = 375, units = "mm", dpi = 300, bg = "white")
ggsave(file.path(FIG_SUPP_DIR, "Figure_S5.tiff"),
       Fig_S4_panel_core, width = 375, height = 375, units = "mm", dpi = 300, bg = "white")

ggsave(file.path(FIG_SUPP_DIR, "Figure_S6.png"),
       p_S5, width = 260, height = 170, units = "mm", dpi = 300, bg = "white")
ggsave(file.path(FIG_SUPP_DIR, "Figure_S6.tiff"),
       p_S5, width = 260, height = 170, units = "mm", dpi = 300, bg = "white")

# Export compact figure-source data/diagnostics for reproducibility.
readr::write_csv(pred_marg,  file.path(TAB_SUPP_DIR, "Figure_S5_weighted_predicted_probabilities.csv"))
readr::write_csv(pred_delta, file.path(TAB_SUPP_DIR, "Figure_S5_weighted_post_pre_deltas.csv"))
readr::write_csv(pred_bar,   file.path(TAB_SUPP_DIR, "Figure_S5_weighted_barplot_ci_data.csv"))
readr::write_csv(cal,        file.path(TAB_SUPP_DIR, "Figure_S6_calibration_observed_vs_predicted.csv"))

aic_summary <- tibble::tibble(
  model = c("unweighted_step_model", "view_weighted_step_model"),
  AIC = c(AIC(m_step), AIC(m_w_step))
)
readr::write_csv(aic_summary, file.path(TAB_SUPP_DIR, "Figure_S5_S6_model_AIC_summary.csv"))

cat("\nUNWEIGHTED AIC:", AIC(m_step), "\n")
cat("WEIGHTED   AIC:", AIC(m_w_step), "\n")
message("Figures S4 and S5 exported to: ", FIG_SUPP_DIR)
message("Figure S6/S5 source data exported to: ", TAB_SUPP_DIR)

}
