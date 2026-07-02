
# Force clean direct output directories
if (exists("ANALYSIS_MODE") && ANALYSIS_MODE == "COMMENTS_ONLY") {
  dir_tables <- TAB_SENS_DIR
  dir_plots  <- FIG_SENS_DIR
  dir_tables_NO_COMMENTS <- TAB_SENS_DIR
  dir_plots_NO_COMMENTS  <- FIG_SENS_DIR
  dir_tables_COMMENTS_ONLY <- TAB_SENS_DIR
  dir_plots_COMMENTS_ONLY  <- FIG_SENS_DIR
  dir_tables_ALL <- TAB_SENS_DIR
  dir_plots_ALL  <- FIG_SENS_DIR
} else {
  dir_tables <- TAB_MAIN_DIR
  dir_plots  <- FIG_MAIN_DIR
  dir_tables_NO_COMMENTS <- TAB_MAIN_DIR
  dir_plots_NO_COMMENTS  <- FIG_MAIN_DIR
  dir_tables_COMMENTS_ONLY <- TAB_SENS_DIR
  dir_plots_COMMENTS_ONLY  <- FIG_SENS_DIR
  dir_tables_ALL <- TAB_SENS_DIR
  dir_plots_ALL  <- FIG_SENS_DIR
}
dir.create(dir_tables, recursive = TRUE, showWarnings = FALSE)
dir.create(dir_plots, recursive = TRUE, showWarnings = FALSE)

if (file.exists("scripts/00_direct_output_config.R")) source("scripts/00_direct_output_config.R", encoding = "UTF-8")
# QA table directory for non-manuscript diagnostic tables.
TAB_QA_DIR <- if (exists("TAB_QA_DIR", inherits = TRUE)) TAB_QA_DIR else file.path("outputs", "tables", "qa")
dir.create(TAB_QA_DIR, recursive = TRUE, showWarnings = FALSE)


# Safety helper for weighted multinomial models:
# keeps weights inside the model data frame so AIC/logLik/export methods
# do not later fail with "object 'tmp' not found".

# Robust weighted multinomial helper:
# model calls use `weight_vec`, a numeric vector kept in the calling environment,
# avoiding later failures such as "object 'tmp' not found" or ".case_weight not found".
make_weight_vec <- function(dat) {
  if (".case_weight" %in% names(dat)) return(dat$.case_weight)
  if ("w" %in% names(dat)) return(dat$w)
  if ("weights" %in% names(dat)) return(dat$weights)
  if ("w_view" %in% names(dat)) return(dat$w_view)
  if ("w_view_ALL" %in% names(dat)) return(dat$w_view_ALL)
  rep(1, nrow(dat))
}

ensure_case_weight_column <- function(dat) {
  if (!".case_weight" %in% names(dat)) {
    if ("w" %in% names(dat)) dat$.case_weight <- dat$w
    else if ("weights" %in% names(dat)) dat$.case_weight <- dat$weights
  }
  dat
}

# ============================================================
# 12_figures4_S3_S6_model_predictions.R
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

if (ANALYSIS_MODE == "NO_COMMENTS") {
message("Running complete submitted Figures 4/S3/S6 + Tables 4/S14-S15 script: NO_COMMENTS")
                                                                                                    # ============================================================
  # COMPLETE WORKFLOW - Figures 4, S3-S6 + Tables 4, S14-S15
  # (Consolidated, NO_COMMENTS)
  # ============================================================
  
  # ---------------------------
  # 0) Packages (single load)
  # ---------------------------
  suppressPackageStartupMessages({
    library(dplyr)
    library(tidyr)
    library(stringr)
    library(purrr)
    library(tibble)
  
    library(ggplot2)
    library(scales)
    library(readr)
  
    library(nnet)
    library(MASS)
  
    library(cowplot)
    library(grid)
  
    library(ggimage)
    library(ggnewscale)
  
    library(mgcv)
  
    library(knitr)
    library(flextable)
    library(officer)
  })
  
  # ============================================================
  # 1) FIXED CONSTANTS (retain your tuned values)
  # ============================================================
  
  # --------------------------- Lifeform order (match Fig 1-4) ------------------
  desired_lf_order <- c(
    "Birds","Herptiles","Fishes","Insects",
    "Crustaceans","Non-arthropod invertebrates","Plants","Bacteria, Viruses, Fungi"
  )
  
  # Display labels (only for plotting text; underlying LifeForm values unchanged)
  lifeform_display_labels <- c(
    "Non-arthropod invertebrates" = "N.A. invertebrates",
    "Bacteria, Viruses, Fungi"    = "Bacteria/Viruses/Fungi"
  )
  
  # --------------------------- FONT SIZES (match Fig 4) ------------------------
  AXIS_TITLE_SIZE <- 19
  AXIS_TEXT_SIZE  <- 17
  LEG_TITLE_SIZE  <- 19
  LEG_TEXT_SIZE   <- 17
  TAG_SIZE        <- 22
  
  # ============================================================
  # 2) COLOR SCHEME - keep your FINAL base_cols assignment
  #    (Your pasted script overwrote base_cols multiple times; the
  #     LAST block wins. We keep that final block ONLY.)
  # ============================================================
  base_cols <- c(
    Detection = "#959BFF",
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
  
  # Practical palette mapping for THIS workflow
  kw_cols_NO_COMMENTS <- base_cols
  
  # --------------------------- Unified theme (uses Fig4 sizes) -----------------
  theme_inat <- function(base_size = 16) {
    theme_light(base_size = base_size) +
      theme(
        panel.grid.major.x = element_blank(),
        panel.grid.minor   = element_blank(),
        legend.title       = element_blank(),
        legend.position    = "top",
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
  
  # ============================================================
  # 3) PATHS (keep your structure/names)
  # ============================================================
  dir_tables_NO_COMMENTS <- TAB_MAIN_DIR
  dir_plots_NO_COMMENTS  <- FIG_MAIN_DIR
  dir.create(dir_tables_NO_COMMENTS, recursive = TRUE, showWarnings = FALSE)
  dir.create(dir_plots_NO_COMMENTS,  recursive = TRUE, showWarnings = FALSE)
  
  # Backward-compatible aliases
  dir_tables <- dir_tables_NO_COMMENTS
  dir_plots  <- dir_plots_NO_COMMENTS
  
  tok_csv_NO_COMMENTS <- file.path(
    file.path("outputs", "intermediate"),
    "keywords", "token_table_from_BASE_raw_NO_COMMENTS.csv"
  )
  if (!file.exists(tok_csv_NO_COMMENTS)) {
    alt <- file.path(
      file.path("outputs", "intermediate"),"keywords",
      "token_table_from_BASE_raw_NO_COMMENTS_NO_COMMENTS.csv"
    )
    if (file.exists(alt)) tok_csv_NO_COMMENTS <- alt else stop("Tokens CSV not found.")
  }
  
  # ============================================================
  # 4) TABLE EXPORT HELPERS (CSV + MD + DOCX)
  # ============================================================
  export_table_all <- function(tab, out_dir, stem, caption,
                               doc_heading_style = "heading 2",
                               doc_fontsize = 9) {
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
    csv_path  <- file.path(out_dir, paste0(stem, ".csv"))
    md_path   <- file.path(out_dir, paste0(stem, ".md"))
    docx_path <- file.path(out_dir, paste0(stem, ".docx"))
  
    readr::write_csv(tab, csv_path)
  
    writeLines(
      c(
        caption,
        "",
        knitr::kable(tab, format = "pipe", align = "l")
      ),
      md_path
    )
  
    ft <- flextable(tab) |>
      autofit() |>
      fontsize(size = doc_fontsize) |>
      align(align = "left", part = "all")
  
    docx <- read_docx()
    docx <- body_add_par(docx, caption, style = doc_heading_style)
    docx <- body_add_flextable(docx, ft)
    print(docx, target = docx_path)
  
    message("Saved: ", csv_path, " | ", md_path, " | ", docx_path)
    invisible(list(csv = csv_path, md = md_path, docx = docx_path))
  }
  
  # ============================================================
  # 5) READ + PREP TOKENS DATA
  # ============================================================
  kw_NO_COMMENTS <- readr::read_csv(tok_csv_NO_COMMENTS, show_col_types = FALSE)
  
  # Ensure robust date types (used later for trends)
  if (!inherits(kw_NO_COMMENTS$FirstRecordDate, "POSIXt")) {
    kw_NO_COMMENTS$FirstRecordDate <- as.POSIXct(kw_NO_COMMENTS$FirstRecordDate, tz = "UTC", origin = "1970-01-01")
  }
  if (!inherits(kw_NO_COMMENTS$created_at, "POSIXt")) {
    kw_NO_COMMENTS$created_at <- as.POSIXct(kw_NO_COMMENTS$created_at, tz = "UTC", origin = "1970-01-01")
  }
  
  kw_NO_COMMENTS <- kw_NO_COMMENTS %>% mutate(
    FR_year  = as.integer(FirstRecord),
    year_obs = as.integer(format(as.Date(created_at), "%Y")),
    rel_year = year_obs - FR_year
  )
  
  normalize_period_NO_COMMENTS <- function(x){
    dplyr::case_when(
      is.na(x) ~ NA_character_,
      x %in% c("Before","Pre-Intro","Pre-Introduction") ~ "Pre-Introduction",
      x %in% c("After","Post-Intro","Post-Introduction") ~ "Post-Introduction",
      TRUE ~ as.character(x)
    )
  }
  
  df_NO_COMMENTS <- kw_NO_COMMENTS %>%
    mutate(
      time_period = factor(normalize_period_NO_COMMENTS(time_period),
                           levels = c("Pre-Introduction","Post-Introduction")),
      LifeForm = factor(LifeForm),
      PresentStatus = factor(PresentStatus),
      KeywordCategory = factor(KeywordCategory,
                               levels = c("Invasion","Detection","eCommerce","Threat"))
    ) %>%
    filter(!is.na(time_period),
           !is.na(LifeForm), LifeForm != "Unknown",
           !is.na(PresentStatus),
           !is.na(KeywordCategory)) %>%
    droplevels()
  
  # --- Force PresentStatus to two-level and set refs (as you had) ---
  df_NO_COMMENTS <- df_NO_COMMENTS %>%
    mutate(
      PresentStatus = case_when(
        tolower(PresentStatus) %in% c("alien","present") ~ "present",
        tolower(PresentStatus) == "established"          ~ "established",
        TRUE ~ tolower(PresentStatus)
      ),
      PresentStatus = factor(PresentStatus, levels = c("present","established")),
      time_period     = stats::relevel(time_period,     ref = "Post-Introduction"),
      LifeForm        = stats::relevel(LifeForm,        ref = "Herptiles"),
      PresentStatus   = stats::relevel(PresentStatus,   ref = "present"),
      KeywordCategory = stats::relevel(KeywordCategory, ref = "Invasion")
    ) %>%
    filter(PresentStatus %in% c("present","established")) %>%
    droplevels()
  
  stopifnot(identical(levels(df_NO_COMMENTS$PresentStatus), c("present","established")))
  
  # ============================================================
  # 6) WEIGHTED / UNWEIGHTED STEP MODELS (ensures m_w_step exists)
  # ============================================================
  .choose_weight_vector <- function(df){
    if ("views_per_day" %in% names(df)) {
      w <- suppressWarnings(as.numeric(df$views_per_day))
    } else if ("view_age_norm" %in% names(df)) {
      w <- suppressWarnings(as.numeric(df$view_age_norm))
    } else if ("viewCount" %in% names(df)) {
      w <- suppressWarnings(as.numeric(df$viewCount))
      w <- log1p(w)
    } else {
      w <- rep(1, nrow(df))
    }
  
    w[!is.finite(w) | w < 0] <- NA_real_
    w <- tidyr::replace_na(w, 0)
  
    q <- stats::quantile(w[is.finite(w)], probs = .99, na.rm = TRUE, names = FALSE)
    if (is.finite(q)) w <- pmin(w, q)
  
    m <- mean(w[is.finite(w)], na.rm = TRUE)
    if (is.finite(m) && m > 0) w <- w / m
  
    pmax(w, 1e-6)
  }
  
  fit_step_multinom <- function(dat, weights = NULL, trace = FALSE){
    f_full <- KeywordCategory ~ time_period + LifeForm + PresentStatus
  
    args <- list(
      formula = f_full, data = dat,
      maxit = 1000, MaxNWts = 20000, trace = trace, Hess = TRUE
    )
    if (!is.null(weights)) args$weights <- weights
  
    m_full <- do.call(nnet::multinom, args)
  
    m_step <- try(MASS::stepAIC(m_full, direction = "backward", trace = FALSE), silent = TRUE)
    if (inherits(m_step, "try-error")) m_step <- m_full
  
    # Refit with Hess=TRUE so vcov() works reliably after stepAIC
    m_step_ci <- try(update(m_step, Hess = TRUE, trace = FALSE), silent = TRUE)
    if (inherits(m_step_ci, "try-error")) m_step_ci <- m_step
  
    list(full = m_full, step = m_step, step_ci = m_step_ci)
  }
  
  w_view <- .choose_weight_vector(df_NO_COMMENTS)
  
  fits_unw <- fit_step_multinom(df_NO_COMMENTS, weights = NULL)
  fits_w   <- fit_step_multinom(df_NO_COMMENTS, weights = w_view)
  
  m_step_NO_COMMENTS    <- fits_unw$step
  m_ci_NO_COMMENTS      <- fits_unw$step_ci
  m_w_step              <- fits_w$step
  m_w_step_ci           <- fits_w$step_ci
  
  # ============================================================
  # 7) TABLES S14 + S15 (AIC candidate set) - EXACT structure you want
  # ============================================================
  build_aic_table_multinom <- function(models_named, predictors_named) {
    stopifnot(length(models_named) == length(predictors_named))
  
    tab <- purrr::imap_dfr(models_named, function(mod, nm) {
      ll <- as.numeric(logLik(mod))
      k  <- attr(logLik(mod), "df")
      a  <- AIC(mod)
  
      tibble(
        Model = nm,
        Predictors = predictors_named[[nm]],
        K = as.integer(k),
        AIC = as.numeric(a),
        LL = ll
      )
    }) %>%
      arrange(AIC) %>%
      mutate(
        `?AIC` = AIC - min(AIC),
        AICWt  = exp(-0.5 * `?AIC`) / sum(exp(-0.5 * `?AIC`)),
        Cum.Wt = cumsum(AICWt)
      ) %>%
      mutate(
        AIC    = round(AIC, 2),
        `?AIC` = round(`?AIC`, 2),
        AICWt  = round(AICWt, 2),
        Cum.Wt = round(Cum.Wt, 2),
        LL     = round(LL, 2)
      )
  
    tab
  }
  
  # ---- S14 (UNWEIGHTED) ----
  m1_full_unw <- nnet::multinom(KeywordCategory ~ time_period + LifeForm + PresentStatus,
                                data = df_NO_COMMENTS, trace = FALSE, Hess = TRUE,
                                maxit = 1000, MaxNWts = 20000)
  m2_no_status_unw <- nnet::multinom(KeywordCategory ~ time_period + LifeForm,
                                     data = df_NO_COMMENTS, trace = FALSE, Hess = TRUE,
                                     maxit = 1000, MaxNWts = 20000)
  m3_no_lifeform_unw <- nnet::multinom(KeywordCategory ~ time_period + PresentStatus,
                                       data = df_NO_COMMENTS, trace = FALSE, Hess = TRUE,
                                       maxit = 1000, MaxNWts = 20000)
  m4_time_only_unw <- nnet::multinom(KeywordCategory ~ time_period,
                                     data = df_NO_COMMENTS, trace = FALSE, Hess = TRUE,
                                     maxit = 1000, MaxNWts = 20000)
  m5_null_unw <- nnet::multinom(KeywordCategory ~ 1,
                                data = df_NO_COMMENTS, trace = FALSE, Hess = TRUE,
                                maxit = 1000, MaxNWts = 20000)
  
  models_S14 <- list(
    "Model 1" = m1_full_unw,
    "Model 2" = m2_no_status_unw,
    "Model 3" = m3_no_lifeform_unw,
    "Model 4" = m4_time_only_unw,
    "Model 5" = m5_null_unw
  )
  pred_labels_S14 <- list(
    "Model 1" = "Time period + Taxonomic group + Invasion status",
    "Model 2" = "Time period + Taxonomic group",
    "Model 3" = "Time period + Invasion status",
    "Model 4" = "Time period",
    "Model 5" = "null"
  )
  
  tab_S14 <- build_aic_table_multinom(models_S14, pred_labels_S14)
  export_table_all(
    tab_S14,
    out_dir = TAB_SUPP_DIR,
    stem = "Table_S14_model_selection_unweighted",
    caption = "Table S14. Model selection for multinomial keyword-category models (unweighted)."
  )
  
  # ---- S15 (WEIGHTED) - use actual weights used in weighted fits ----
  w_w <- m_w_step$weights
  if (is.null(w_w)) w_w <- m_w_step_ci$weights
  if (is.null(w_w)) stop("Weighted model has NULL weights; cannot build S15.")
  
  # Use the same rows as in the fitted model
  mf_w <- model.frame(m_w_step)
  dat_w <- as.data.frame(mf_w)
  
  resp_name <- all.vars(formula(m_w_step))[1]
  dat_w[[resp_name]] <- as.factor(dat_w[[resp_name]])
  
  # Diagnostics (optional, but recommended)
  cat("\nS15 weight diagnostics:\n")
  print(summary(w_w))
  cat("sd(weights) =", sd(w_w), "\n")
  
  
  f_w1 <- as.formula(paste0(resp_name, " ~ time_period + LifeForm + PresentStatus"))
  f_w2 <- as.formula(paste0(resp_name, " ~ time_period + LifeForm"))
  f_w3 <- as.formula(paste0(resp_name, " ~ time_period + PresentStatus"))
  f_w4 <- as.formula(paste0(resp_name, " ~ time_period"))
  f_w5 <- as.formula(paste0(resp_name, " ~ 1"))
  
  m1_full_w <- nnet::multinom(f_w1, data = dat_w, weights = w_w,
                              trace = FALSE, Hess = TRUE, maxit = 1000, MaxNWts = 20000)
  m2_no_status_w <- nnet::multinom(f_w2, data = dat_w, weights = w_w,
                                   trace = FALSE, Hess = TRUE, maxit = 1000, MaxNWts = 20000)
  m3_no_lifeform_w <- nnet::multinom(f_w3, data = dat_w, weights = w_w,
                                     trace = FALSE, Hess = TRUE, maxit = 1000, MaxNWts = 20000)
  m4_time_only_w <- nnet::multinom(f_w4, data = dat_w, weights = w_w,
                                   trace = FALSE, Hess = TRUE, maxit = 1000, MaxNWts = 20000)
  m5_null_w <- nnet::multinom(f_w5, data = dat_w, weights = w_w,
                              trace = FALSE, Hess = TRUE, maxit = 1000, MaxNWts = 20000)
  
  models_S15 <- list(
    "Model 1" = m1_full_w,
    "Model 2" = m2_no_status_w,
    "Model 3" = m3_no_lifeform_w,
    "Model 4" = m4_time_only_w,
    "Model 5" = m5_null_w
  )
  
  tab_S15 <- build_aic_table_multinom(models_S15, pred_labels_S14)
  export_table_all(
    tab_S15,
    out_dir = TAB_SUPP_DIR,
    stem = "Table_S15_model_selection_weighted",
    caption = "Table S15. Model selection for multinomial keyword-category models (view-weighted sensitivity analysis)."
  )
  
  cat("\nBest S14 model:", tab_S14$Model[which.min(tab_S14$AIC)], " | AIC =", min(tab_S14$AIC), "\n")
  cat("Best S15 model:", tab_S15$Model[which.min(tab_S15$AIC)], " | AIC =", min(tab_S15$AIC), "\n")
  
  # ============================================================
  # 8) CI helper (unchanged, but kept as single function)
  # ============================================================
  simulate_probs_ci_safe <- function(mod, newdata, R = 400){
    Terms  <- stats::terms(mod)
    mf_fit <- model.frame(mod)
    X_fit  <- model.matrix(stats::delete.response(Terms), mf_fit)
    X_new <- model.matrix(
      stats::delete.response(Terms),
      model.frame(stats::delete.response(Terms), newdata,
                  xlev = lapply(mf_fit, levels))
    )
  
    miss_in_new <- setdiff(colnames(X_fit), colnames(X_new))
    if (length(miss_in_new)){
      X_new <- cbind(X_new, matrix(0, nrow = nrow(X_new), ncol = length(miss_in_new),
                                   dimnames = list(NULL, miss_in_new)))
    }
    X_new <- X_new[, colnames(X_fit), drop = FALSE]
  
    B <- coef(mod); if (is.list(B)) B <- do.call(rbind, B)
    if (!is.null(colnames(B))){
      miss_in_B <- setdiff(colnames(X_fit), colnames(B))
      if (length(miss_in_B)){
        B <- cbind(B, matrix(0, nrow = nrow(B), ncol = length(miss_in_B),
                             dimnames = list(NULL, miss_in_B)))
      }
      B <- B[, colnames(X_fit), drop = FALSE]
    } else {
      if (ncol(B) != ncol(X_fit)) stop("simulate_probs_ci_safe: coefficient dimension mismatch.")
    }
  
    softmax <- function(eta){
      ef <- cbind(0, eta)
      E  <- exp(ef - apply(ef, 1, max))
      E / rowSums(E)
    }
  
    Eta   <- X_new %*% t(B)
    P_hat <- softmax(Eta)
  
    vc <- try(vcov(mod), silent = TRUE)
    if (inherits(vc, "try-error") || anyNA(vc)){
      resp <- model.frame(mod)[[1]]
      classes <- levels(resp)
      n <- nrow(newdata)
      K1 <- nrow(B) + 1L
      out0 <- tibble::tibble(
        Class = rep(classes, each = n),
        fit   = as.vector(P_hat),
        lwr   = NA_real_, upr = NA_real_
      )
      new_rep <- newdata[rep(seq_len(nrow(newdata)), times = K1), , drop = FALSE]
      return(dplyr::bind_cols(out0, new_rep))
    }
  
    ok <- TRUE; tryCatch(chol(vc), error = function(e) ok <<- FALSE)
    if (!ok){
      if (requireNamespace("Matrix", quietly = TRUE)){
        vc <- as.matrix(Matrix::nearPD(vc, keepDiag = TRUE)$mat)
      } else vc <- vc + diag(1e-8, nrow(vc))
    }
  
    R <- max(200, min(R, 1200))
    mu <- as.vector(t(B))
  
    draws <- try(MASS::mvrnorm(n = R, mu = mu, Sigma = vc), silent = TRUE)
    if (inherits(draws, "try-error")){
      se <- sqrt(diag(vc))
      draws <- matrix(mu, nrow = R, byrow = TRUE) +
        matrix(rnorm(R * length(mu), 0, rep(se, each = R)), nrow = R)
    }
  
    n  <- nrow(newdata)
    K1 <- nrow(B) + 1L
    arr <- array(NA_real_, dim = c(n, K1, R))
  
    for (r in seq_len(R)){
      Br <- matrix(draws[r, ], nrow = nrow(B), byrow = TRUE)
      arr[,,r] <- softmax(X_new %*% t(Br))
    }
  
    resp    <- model.frame(mod)[[1]]
    classes <- levels(resp)
  
    prob_df <- purrr::map_dfr(seq_len(K1), function(j){
      tibble::tibble(
        Class = classes[j],
        fit   = rowMeans(arr[, j, , drop = FALSE], dims = 2),
        lwr   = apply(arr[, j, , drop = FALSE], 1, quantile, probs = .025),
        upr   = apply(arr[, j, , drop = FALSE], 1, quantile, probs = .975)
      )
    })
  
    new_rep <- newdata[rep(seq_len(nrow(newdata)), times = K1), , drop = FALSE]
    dplyr::bind_cols(prob_df, new_rep)
  }
  
  # ============================================================
  # 9) ICON SETUP (single source)
  # ============================================================
  # --------------------------- ICONS (robust paths) ----------------------------
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
  
  icon_dir_candidates <- c(
    "fig_assets/icons",
    "fig_assets"
  )
  
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
  
  
  # ======================= ICON RECOLOR (same as Fig 1-3) ======================
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
  
  # ---- tweak here (same knobs) ----
  ICON_LIGHT <- 0.65
  ICON_TINT  <- c(0.55, 0.50, 0.60)   # R, G, B multipliers
  
  # =================== WRITE TINTED ICON FILES + REPOINT PATHS ================
  # ggimage reads from disk at draw time, so we create tinted PNGs once and use them.
  tinted_dir <- file.path(ICON_DIR, "_tinted_icons")
  if (!dir.exists(tinted_dir)) dir.create(tinted_dir, recursive = TRUE)
  
  tinted_icon_paths <- icon_paths
  
  for (lf in names(icon_paths)) {
    fp <- icon_paths[[lf]]
    if (is.null(fp) || !file.exists(fp)) next
  
    # output file name includes the tint settings so caches don't collide
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
  
      # write tinted PNG
      png::writePNG(img, target = out_fp)
    }
  
    tinted_icon_paths[[lf]] <- out_fp
  }
  
  # IMPORTANT: from here on, EVERYTHING uses tinted icons automatically
  icon_paths <- tinted_icon_paths
  
  # ============================================================
  # 10) PREDICTIONS FOR PANELS A/B/C
  # ============================================================
  nd_A_NO_COMMENTS <- expand.grid(
    LifeForm      = levels(df_NO_COMMENTS$LifeForm),
    time_period   = levels(df_NO_COMMENTS$time_period),
    PresentStatus = levels(df_NO_COMMENTS$PresentStatus)[1],
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  for (v in names(nd_A_NO_COMMENTS)) {
    if (is.factor(df_NO_COMMENTS[[v]])) {
      nd_A_NO_COMMENTS[[v]] <- factor(nd_A_NO_COMMENTS[[v]], levels = levels(df_NO_COMMENTS[[v]]))
    }
  }
  
  probs_A_NO_COMMENTS <- as.data.frame(predict(m_step_NO_COMMENTS, newdata = nd_A_NO_COMMENTS, type = "probs"))
  resp_levels_NO_COMMENTS <- levels(model.frame(m_step_NO_COMMENTS)[[1]])
  keepK_NO_COMMENTS <- intersect(resp_levels_NO_COMMENTS, colnames(probs_A_NO_COMMENTS))
  
  pred_mean_A_NO_COMMENTS <- dplyr::bind_cols(nd_A_NO_COMMENTS, probs_A_NO_COMMENTS[, keepK_NO_COMMENTS, drop = FALSE]) |>
    tidyr::pivot_longer(all_of(keepK_NO_COMMENTS), names_to = "KeywordCategory", values_to = "fit") |>
    dplyr::mutate(KeywordCategory = factor(KeywordCategory,
                                           levels = c("Invasion","Detection","eCommerce","Threat")))
  
  pred_Aci_NO_COMMENTS <- try(
    simulate_probs_ci_safe(m_ci_NO_COMMENTS, nd_A_NO_COMMENTS, R = 800) |>
      dplyr::rename(KeywordCategory = Class) |>
      dplyr::mutate(KeywordCategory = factor(KeywordCategory,
                                             levels = c("Invasion","Detection","eCommerce","Threat"))),
    silent = TRUE
  )
  if (inherits(pred_Aci_NO_COMMENTS, "try-error")) pred_Aci_NO_COMMENTS <- NULL
  
  pred_A_NO_COMMENTS <- if (!is.null(pred_Aci_NO_COMMENTS)) {
    pred_mean_A_NO_COMMENTS |>
      dplyr::left_join(
        pred_Aci_NO_COMMENTS |>
          dplyr::select(LifeForm, time_period, PresentStatus, KeywordCategory, lwr, upr),
        by = c("LifeForm","time_period","PresentStatus","KeywordCategory")
      )
  } else {
    pred_mean_A_NO_COMMENTS |>
      dplyr::mutate(lwr = NA_real_, upr = NA_real_)
  }
  
  present_levels_A_NO_COMMENTS <- desired_lf_order[desired_lf_order %in% levels(pred_A_NO_COMMENTS$LifeForm)]
  pred_A_NO_COMMENTS <- pred_A_NO_COMMENTS %>%
    mutate(
      LifeForm = factor(LifeForm, levels = present_levels_A_NO_COMMENTS),
      time_period_plot = factor(as.character(time_period),
                                levels = c("Pre-Introduction","Post-Introduction"))
    )
  
  # ============================================================
  # 11) PLOT A - Probabilities (bars) + icons
  # ============================================================
  dodge <- position_dodge(width = 0.8)
  
  p_A_base_NO_COMMENTS <- ggplot(pred_A_NO_COMMENTS, aes(x = LifeForm, y = fit)) +
    geom_col(aes(fill = KeywordCategory, group = KeywordCategory),
             position = dodge, width = 0.8) +
    geom_errorbar(
      data = subset(pred_A_NO_COMMENTS, !is.na(lwr) & !is.na(upr)),
      aes(ymin = lwr, ymax = upr, group = KeywordCategory),
      position = dodge, width = 0.25, colour = "grey20"
    ) +
    scale_fill_manual(values = kw_cols_NO_COMMENTS, guide = "none") +
    labs(x = NULL, y = "Predicted probability") +
    theme_inat(16) +
    facet_wrap(~ time_period_plot, ncol = 1, strip.position = "right") +
    theme(
      strip.background   = element_rect(fill = NA, colour = NA),
      strip.text.y.right = element_text(face = "plain", colour = "black",
                                        margin = margin(l = 3), size = AXIS_TEXT_SIZE),
      strip.placement    = "inside",
      axis.text.x        = element_blank(),
      axis.ticks.x       = element_blank(),
      axis.title.y       = element_text(margin = margin(r = 18)),
      plot.margin        = margin(t = 6, r = 6, b = 6, l = 6)
    ) +
    scale_x_discrete(expand = c(0, 0))
  
  add_x_icons_bars_bottom <- function(p, pred_A, icon_paths,
                                      icon_width_x    = 1.15,
                                      icon_height_rel = 0.40,
                                      gap_rel         = 0.085,
                                      bottom_margin_pts = 70) {
  
    x_levels <- levels(pred_A$LifeForm)
    bottom_level <- tail(levels(pred_A$time_period_plot), 1)
  
    df_icons <- data.frame(
      time_period_plot = factor(bottom_level, levels = levels(pred_A$time_period_plot)),
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
      theme(plot.margin = margin(t = 6, r = 6, b = bottom_margin_pts, l = 6))
  }
  
  p_A_NO_COMMENTS <- add_x_icons_bars_bottom(p_A_base_NO_COMMENTS, pred_A_NO_COMMENTS, icon_paths)
  
  # Export single A with legend
  p_A_export_NO_COMMENTS <- p_A_NO_COMMENTS +
    scale_fill_manual(values = kw_cols_NO_COMMENTS, name = "Keyword category")
  
  ggsave(file.path(dir_plots,"Figure4_A_single_NO_COMMENTS.png"),
         p_A_export_NO_COMMENTS, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots,"Figure4_A_single_NO_COMMENTS.tiff"),
         p_A_export_NO_COMMENTS, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
  
  # ============================================================
  # 12) PLOT C - Delta (Post - Pre) - robust if CI missing
  # ============================================================
  pred_source_for_C <- if (!is.null(pred_Aci_NO_COMMENTS)) {
    pred_Aci_NO_COMMENTS %>% dplyr::select(LifeForm, time_period, KeywordCategory, fit)
  } else {
    pred_mean_A_NO_COMMENTS %>% dplyr::select(LifeForm, time_period, KeywordCategory, fit)
  }
  
  pred_C_NO_COMMENTS <- pred_source_for_C %>%
    tidyr::pivot_wider(names_from = time_period, values_from = fit) %>%
    mutate(
      delta = `Post-Introduction` - `Pre-Introduction`,
      period_strip = factor("\u0394 (Post - Pre)", levels = "\u0394 (Post - Pre)")
    )
  
  present_levels_C_NO_COMMENTS <- desired_lf_order[desired_lf_order %in% levels(pred_C_NO_COMMENTS$LifeForm)]
  pred_C_NO_COMMENTS <- pred_C_NO_COMMENTS %>% mutate(LifeForm = factor(LifeForm, levels = present_levels_C_NO_COMMENTS))
  
  offset_map_NO_COMMENTS <- c(Invasion = -0.33, Detection = -0.11, eCommerce = 0.11, Threat = 0.33)
  n_lf_NO_COMMENTS <- nlevels(pred_C_NO_COMMENTS$LifeForm)
  pred_C_NO_COMMENTS <- pred_C_NO_COMMENTS %>%
    mutate(
      x_idx = as.numeric(LifeForm),
      x_pos = x_idx + unname(offset_map_NO_COMMENTS[as.character(KeywordCategory)])
    ) %>%
    mutate(strip_pad = factor("Pre-Introduction", levels = "Pre-Introduction"))
  
  p_C_NO_COMMENTS <- ggplot(pred_C_NO_COMMENTS, aes(colour = KeywordCategory)) +
    geom_hline(yintercept = 0, linetype = 2) +
    geom_segment(aes(x = x_pos, xend = x_pos, y = 0, yend = delta), linewidth = 0.9) +
    geom_point(aes(x = x_pos, y = delta), size = 2.6) +
    scale_colour_manual(values = kw_cols_NO_COMMENTS, name = "Keyword category") +
    labs(x = NULL, y = expression(Delta~" probability (Post - Pre)")) +
    facet_wrap(~ strip_pad, ncol = 1, strip.position = "right") +
    scale_x_continuous(
      limits = c(0.5, n_lf_NO_COMMENTS + 0.5),
      breaks = 1:n_lf_NO_COMMENTS, labels = levels(pred_C_NO_COMMENTS$LifeForm),
      expand = expansion(mult = c(0, 0))
    ) +
    theme_light(base_size = 11) +
    theme(
      strip.background   = element_rect(fill = NA, colour = NA),
      strip.text.y.right = element_text(colour = "white", margin = margin(l = 28, r = 6), size = AXIS_TEXT_SIZE),
      axis.text.x        = element_blank(),
      axis.ticks.x       = element_blank(),
      axis.title.y       = element_text(size = AXIS_TITLE_SIZE, margin = margin(r = 18)),
      axis.text.y        = element_text(size = AXIS_TEXT_SIZE),
      legend.text        = element_text(size = LEG_TEXT_SIZE),
      plot.margin        = margin(t = 6, r = 6, b = 6, l = 6)
    )
  
  add_x_icons_delta_outside <- function(p, pred_C, icon_paths,
                                        icon_width_x     = 0.85,
                                        icon_height_frac = 0.20,
                                        gap_frac         = 0.085,
                                        bottom_margin_pts = 70) {
  
    x_levels <- levels(pred_C$LifeForm)
    x_idx    <- seq_along(x_levels)
    y_max <- max(pred_C$delta, 0, na.rm = TRUE)
    y_min <- min(pred_C$delta, 0, na.rm = TRUE)
    yrng  <- max(1e-6, y_max - y_min)
    y_icon <- y_min - gap_frac*yrng - (icon_height_frac*yrng)/2
  
    df_icons <- data.frame(
      LifeForm = factor(x_levels, levels = x_levels),
      x        = x_idx,
      y        = y_icon,
      image    = unname(icon_paths[x_levels]),
      stringsAsFactors = FALSE
    )
  
    size_x <- icon_width_x / length(x_levels)
    size_y <- icon_height_frac
    size   <- max(size_x, size_y)
  
    p +
      ggimage::geom_image(
        data = df_icons,
        aes(x = x, y = y, image = image),
        inherit.aes = FALSE,
        size = size
      ) +
      coord_cartesian(ylim = c(y_min, y_max), clip = "off") +
      theme(plot.margin = margin(t = 6, r = 6, b = bottom_margin_pts, l = 6))
  }
  
  p_C_NO_COMMENTS <- add_x_icons_delta_outside(p_C_NO_COMMENTS, pred_C_NO_COMMENTS, icon_paths)
  
  ggsave(file.path(dir_plots,"Figure4_C_single_NO_COMMENTS.png"),
         p_C_NO_COMMENTS, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots,"Figure4_C_single_NO_COMMENTS.tiff"),
         p_C_NO_COMMENTS, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
  
  # ============================================================
  # 13) PLOT B - Heatmap with tinted tiles + neutral gradient legend
  #     (Fix: avoid .$ inside vapply; compute rowwise safely)
  # ============================================================
  tint_to_white <- function(hex, t, min_int = 0.10, max_int = 1.0){
    s <- min_int + (max_int - min_int) * pmin(pmax(t, 0), 1)
    b <- grDevices::col2rgb(hex) / 255
    out <- 1 - (1 - b) * s
    grDevices::rgb(out[1], out[2], out[3])
  }
  
  probs_mat_NO_COMMENTS <- as.data.frame(predict(m_step_NO_COMMENTS, newdata = nd_A_NO_COMMENTS, type = "probs"))
  keep_cols_NO_COMMENTS <- intersect(resp_levels_NO_COMMENTS, colnames(probs_mat_NO_COMMENTS))
  stopifnot(length(keep_cols_NO_COMMENTS) > 0)
  
  pred_heat_NO_COMMENTS <- dplyr::bind_cols(nd_A_NO_COMMENTS, probs_mat_NO_COMMENTS[, keep_cols_NO_COMMENTS, drop = FALSE]) %>%
    tidyr::pivot_longer(all_of(keep_cols_NO_COMMENTS),
                        names_to="KeywordCategory", values_to="fit") %>%
    mutate(
      KeywordCategory = factor(KeywordCategory,
                               levels = c("Invasion","Detection","eCommerce","Threat")),
      LifeForm = factor(LifeForm, levels = levels(df_NO_COMMENTS$LifeForm))
    ) %>%
    mutate(
      base_hex = unname(kw_cols_NO_COMMENTS[as.character(KeywordCategory)]),
      fill_col = mapply(tint_to_white, base_hex, fit)  # safe vectorised mapping
    )
  
  present_levels_B_NO_COMMENTS <- desired_lf_order[desired_lf_order %in% levels(pred_heat_NO_COMMENTS$LifeForm)]
  pred_heat_NO_COMMENTS <- pred_heat_NO_COMMENTS %>%
    mutate(
      LifeForm = factor(LifeForm, levels = present_levels_B_NO_COMMENTS),
      time_period_plot = factor(as.character(time_period),
                                levels = c("Pre-Introduction","Post-Introduction"))
    )
  
  anchor_x_NO_COMMENTS <- levels(pred_heat_NO_COMMENTS$LifeForm)[1]
  anchor_y_NO_COMMENTS <- levels(pred_heat_NO_COMMENTS$KeywordCategory)[1]
  
  p_B_base_NO_COMMENTS <- ggplot(pred_heat_NO_COMMENTS, aes(x = LifeForm, y = KeywordCategory)) +
    geom_tile(aes(fill = fill_col), width = 1, height = 1) +
    scale_fill_identity(guide = "none") +
    geom_text(aes(label = sprintf("%.2f", fit)), size = 4.5, colour = "black") +
    facet_wrap(~ time_period_plot, ncol = 1, strip.position = "right") +
    ggnewscale::new_scale_fill() +
    geom_point(
      data = data.frame(
        fit = seq(0, 1, length.out = 100),
        LifeForm = factor(anchor_x_NO_COMMENTS, levels = levels(pred_heat_NO_COMMENTS$LifeForm)),
        KeywordCategory = factor(anchor_y_NO_COMMENTS, levels = levels(pred_heat_NO_COMMENTS$KeywordCategory))
      ),
      aes(x = LifeForm, y = KeywordCategory, fill = fit),
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
        title.theme = element_text(margin = margin(b = 20), size = LEG_TITLE_SIZE),
        label.theme = element_text(margin = margin(l = 6), size = LEG_TEXT_SIZE)
      )
    ) +
    labs(x = NULL, y = NULL) +
    theme_light(base_size = 11) +
    theme(
      strip.background   = element_rect(fill = NA, colour = NA),
      strip.text.y.right = element_text(face = "plain", colour = "black", margin = margin(l = 3), size = AXIS_TEXT_SIZE),
      strip.placement    = "inside",
      axis.text.x        = element_blank(),
      axis.ticks.x       = element_blank(),
      axis.text.y        = element_blank(),
      panel.grid         = element_blank(),
      axis.ticks         = element_blank(),
      panel.spacing.y    = unit(0, "pt"),
      legend.title       = element_text(size = LEG_TITLE_SIZE),
      legend.text        = element_text(size = LEG_TEXT_SIZE),
      legend.box.spacing = unit(10, "pt"),
      plot.margin        = margin(t = 2, r = 6, b = 2, l = 8)
    ) +
    scale_x_discrete(expand = c(0, 0)) +
    scale_y_discrete(expand = c(0, 0))
  
  # Ghost y-title to reserve left gutter
  p_B_base_NO_COMMENTS <- p_B_base_NO_COMMENTS +
    labs(y = "Keywords proportion") +
    theme(
      axis.title.y = element_text(colour = "white", size = AXIS_TITLE_SIZE, margin = margin(r = 12)),
      axis.text.y  = element_text(colour = "white"),
      axis.ticks.y = element_blank()
    )
  
  add_x_icons_heatmap_bottom <- function(p, pred_heat, icon_paths,
                                         icon_width_x   = 0.75,
                                         icon_height_y  = 0.35,
                                         gap_below      = 0.15,
                                         bottom_margin_pts = 60) {
  
    x_levels <- levels(pred_heat$LifeForm)
    n_rows   <- length(levels(pred_heat$KeywordCategory))
    bottom_level <- tail(levels(pred_heat$time_period_plot), 1)
  
    df_icons <- data.frame(
      time_period_plot = factor(bottom_level, levels = levels(pred_heat$time_period_plot)),
      LifeForm    = factor(x_levels, levels = x_levels),
      x           = seq_along(x_levels),
      y           = 0.5 - gap_below - icon_height_y/2,
      image       = unname(icon_paths[x_levels]),
      stringsAsFactors = FALSE
    )
  
    size_x <- icon_width_x / length(x_levels)
    size_y <- icon_height_y / n_rows
    size   <- max(size_x, size_y)
  
    p +
      ggimage::geom_image(
        data = df_icons,
        aes(x = x, y = y, image = image),
        inherit.aes = FALSE,
        size = size
      ) +
      coord_cartesian(ylim = c(0.5, n_rows + 0.5), clip = "off") +
      theme(plot.margin = margin(t = 2, r = 6, b = bottom_margin_pts, l = 6))
  }
  
  # Single export version WITH icons (as in your script)
  p_B_NO_COMMENTS <- add_x_icons_heatmap_bottom(
    p_B_base_NO_COMMENTS, pred_heat_NO_COMMENTS, icon_paths,
    icon_width_x      = 1.12,
    icon_height_y     = 0.95,
    gap_below         = 0.002,
    bottom_margin_pts = 60
  )
  
  ggsave(file.path(dir_plots,"Figure4_B_single_NO_COMMENTS.png"),
         p_B_NO_COMMENTS, width = 240, height = 160, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots,"Figure4_B_single_NO_COMMENTS.tiff"),
         p_B_NO_COMMENTS, width = 240, height = 160, units = "mm", dpi = 300, bg = "white")
  
  # ============================================================
  # 14) PLOT D - GAM trends (Pre + Post, -5..10) - as you had
  # ============================================================
  fmt_axis_NO_COMMENTS <- function(x) sub("([.]0+)$", "", format(x, trim = TRUE, nsmall = 1,
                                                                digits = 12, scientific = FALSE))
  
  kw_rel_NO_COMMENTS <- kw_NO_COMMENTS %>%
    mutate(
      rel_year_cont = as.numeric(difftime(created_at, FirstRecordDate, units = "days"))/365.25,
      year_bin      = floor(rel_year_cont),
      KeywordCategory = factor(KeywordCategory, levels = c("Invasion","Detection","eCommerce","Threat"))
    ) %>%
    filter(is.finite(year_bin))
  
  win_lo_NO_COMMENTS <- -5
  win_hi_NO_COMMENTS <- 10
  
  df_sum_NO_COMMENTS <- kw_rel_NO_COMMENTS %>%
    filter(year_bin >= win_lo_NO_COMMENTS, year_bin <= win_hi_NO_COMMENTS) %>%
    count(year_bin, KeywordCategory, name = "n_kw") %>%
    group_by(year_bin) %>%
    mutate(n_tot = sum(n_kw), prop = n_kw / pmax(n_tot, 1)) %>%
    ungroup() %>%
    mutate(strip_pad = factor("Pre-Introduction", levels = "Pre-Introduction"))
  
  ribbon_cols_NO_COMMENTS <- scales::alpha(kw_cols_NO_COMMENTS, 0.25)
  
  p_D_NO_COMMENTS <- ggplot(
    df_sum_NO_COMMENTS,
    aes(x = year_bin, y = prop, colour = KeywordCategory)
  ) +
    geom_point(aes(size = n_tot), alpha = 0.35, show.legend = FALSE) +
    stat_smooth(
      method = "gam", formula = y ~ s(x, k = 5),
      method.args = list(family = quasibinomial(link = "logit")),
      aes(weight = n_tot, fill = KeywordCategory),
      se = TRUE,
      linewidth = 2.2, alpha = 0.22
    ) +
    geom_vline(xintercept = 0, colour = "black", linetype = "dashed", linewidth = 0.3) +
    scale_x_continuous(
      limits = c(win_lo_NO_COMMENTS, win_hi_NO_COMMENTS),
      expand = c(0, 0),
      breaks = c(-3, 0, 3, 6, 9),
      labels = fmt_axis_NO_COMMENTS
    ) +
    scale_colour_manual(values = kw_cols_NO_COMMENTS, name = "Keyword category") +
    scale_fill_manual(values = ribbon_cols_NO_COMMENTS, guide = "none") +
    scale_size_continuous(range = c(1.5, 4), guide = "none") +
    labs(x = "Years from first Iberian record (Post-Intro, > 0)", y = "Keywords proportion") +
    facet_wrap(~ strip_pad, ncol = 1, strip.position = "right") +
    theme_light(base_size = 11) +
    ggtitle(NULL) +
    theme(
      strip.background   = element_rect(fill = NA, colour = NA),
      strip.text.y.right = element_text(colour = "white", margin = margin(l = 24, r = 6), size = AXIS_TEXT_SIZE),
      axis.text.y        = element_text(size = AXIS_TEXT_SIZE),
      axis.text.x        = element_text(size = AXIS_TEXT_SIZE),
      axis.title.x       = element_text(margin = margin(t = 14), size = AXIS_TITLE_SIZE),
      axis.title.y       = element_text(margin = margin(r = 18), size = AXIS_TITLE_SIZE),
      legend.text        = element_text(size = LEG_TEXT_SIZE),
      plot.margin        = margin(t = 18, r = 6, b = 6, l = 6),
      legend.position    = "top",
      legend.direction   = "horizontal"
    ) +
    guides(
      colour = guide_legend(nrow = 1, title = "Keyword category")
    )
  
  ggsave(
    file.path(dir_plots,"Figure4_D_single_variantA_pre_post_minus5_to_10_NO_COMMENTS.png"),
    p_D_NO_COMMENTS, width = 225, height = 150, units = "mm", dpi = 300, bg = "white"
  )
  ggsave(
    file.path(dir_plots,"Figure4_D_single_variantA_pre_post_minus5_to_10_NO_COMMENTS.tiff"),
    p_D_NO_COMMENTS, width = 225, height = 150, units = "mm", dpi = 300, bg = "white"
  )
                 
  # ============================================================
  # 16x) EXPLICIT ICON VARIANTS (so S4 matches original format)
  #   - A: bars (NO icons in S4)
  #   - B: heatmap (NO icons in S4)
  #   - C: delta (icons in S4 bottom only)
  # ============================================================
  
  # A (bars) - define a clean "no-icons" object
  p_A_noicons_NO_COMMENTS <- p_A_base_NO_COMMENTS +
    scale_fill_manual(values = kw_cols_NO_COMMENTS, name = "Keyword category")
  
  # A (bars) - icons version already exists (p_A_NO_COMMENTS); ensure it has legend mapping when needed
  p_A_icons_NO_COMMENTS <- p_A_NO_COMMENTS +
    scale_fill_manual(values = kw_cols_NO_COMMENTS, name = "Keyword category")
  
  # B (heatmap) - no-icons object (keeps pred prob colourbar)
  p_B_noicons_NO_COMMENTS <- p_B_base_NO_COMMENTS
  
  # B (heatmap) - icons version already exists (p_B_NO_COMMENTS)
  p_B_icons_NO_COMMENTS <- p_B_NO_COMMENTS
  
  # C (delta) - already has icons (you built them into p_C_NO_COMMENTS)
  p_C_icons_NO_COMMENTS <- p_C_NO_COMMENTS
  
  # C (delta) - if you ever need a no-icons version later, it would be the pre-icon object.
  # (Not required for your requested S4 format)
  
  # ============================================================
  # 16x) EXPLICIT ICON VARIANTS (so S4 matches original format)
  #   - A: bars (NO icons in S4)
  #   - B: heatmap (NO icons in S4)
  #   - C: delta (icons in S4 bottom only)
  # ============================================================
  
  # A (bars) - define a clean "no-icons" object
  p_A_noicons_NO_COMMENTS <- p_A_base_NO_COMMENTS +
    scale_fill_manual(values = kw_cols_NO_COMMENTS, name = "Keyword category")
  
  # A (bars) - icons version already exists (p_A_NO_COMMENTS); ensure it has legend mapping when needed
  p_A_icons_NO_COMMENTS <- p_A_NO_COMMENTS +
    scale_fill_manual(values = kw_cols_NO_COMMENTS, name = "Keyword category")
  
  # B (heatmap) - no-icons object (keeps pred prob colourbar)
  p_B_noicons_NO_COMMENTS <- p_B_base_NO_COMMENTS
  
  # B (heatmap) - icons version already exists (p_B_NO_COMMENTS)
  p_B_icons_NO_COMMENTS <- p_B_NO_COMMENTS
  
  # C (delta) - already has icons (you built them into p_C_NO_COMMENTS)
  p_C_icons_NO_COMMENTS <- p_C_NO_COMMENTS
  
  # C (delta) - if you ever need a no-icons version later, it would be the pre-icon object.
  # (Not required for your requested S4 format)
  
  
  # ============================================================
  # 15) PANEL COMPOSITION SETTINGS (your fixed knobs)
  # ============================================================
  tag_pos_NO_COMMENTS   <- c(0.00, 1.00)
  tag_style_NO_COMMENTS <- theme(
    plot.tag.position = tag_pos_NO_COMMENTS,
    plot.tag = element_text(size = TAG_SIZE, face = "plain")
  )
  
  get_legend_safe <- function(p) {
    leg <- cowplot::get_legend(p)
    if (is.null(leg)) grid::nullGrob() else leg
  }
  
  LEGEND_COL_RELWIDTH <- 0.25
  SPACER_RELHEIGHT    <- 0.08
  
  spacer_plot_NO_COMMENTS <- ggplot() + theme_void()
  
  # ============================================================
  # 16) FIGURE 4 PANEL (TOP=D, BOTTOM=A) with separate legends (right)
  # ============================================================
  p_D_panel_A_NO_COMMENTS <- (p_D_NO_COMMENTS + labs(tag = "A)") + tag_style_NO_COMMENTS)
  p_A_panel_B_NO_COMMENTS <- (p_A_NO_COMMENTS + labs(tag = "B)") + tag_style_NO_COMMENTS)
  
  `%||%` <- function(a, b) if (!is.null(a)) a else b
  
  draw_key_rectline <- function(data, params, size) {
    grid::grobTree(
      grid::rectGrob(
        x = 0.5, y = 0.5, width = 1, height = 0.65,
        gp = grid::gpar(col = NA, fill = data$fill %||% "grey90", alpha = 1)
      ),
      grid::segmentsGrob(
        x0 = 0.10, x1 = 0.90, y0 = 0.5, y1 = 0.5,
        gp = grid::gpar(
          col = data$colour %||% "black",
          lwd = (data$linewidth %||% 1) * size,
          lty = data$linetype %||% 1
        )
      )
    )
  }
  
  legend_cols_NO_COMMENTS <- base_cols[c("Invasion","Detection","eCommerce","Threat")]
  legend_fill_vals_NO_COMMENTS <- scales::alpha(unname(legend_cols_NO_COMMENTS), 0.22)
  
  legend_D_plot_NO_COMMENTS <- ggplot(
    data.frame(
      KeywordCategory = factor(names(legend_cols_NO_COMMENTS), levels = names(legend_cols_NO_COMMENTS)),
      x = 1
    ),
    aes(x = x, y = x, fill = KeywordCategory, colour = KeywordCategory)
  ) +
    geom_tile(show.legend = TRUE, key_glyph = draw_key_rectline) +
    scale_fill_manual(values = legend_cols_NO_COMMENTS, name = "Keyword category") +
    scale_colour_manual(values = legend_cols_NO_COMMENTS, guide = "none") +
    theme_void() +
    theme(
      legend.position   = "right",
      legend.direction  = "vertical",
      legend.key        = element_rect(fill = "white", colour = NA),
      legend.title      = element_text(size = LEG_TITLE_SIZE),
      legend.text       = element_text(size = LEG_TEXT_SIZE)
    ) +
    guides(
      fill = guide_legend(
        title = "Keyword category",
        title.position = "top",
        title.hjust = 0,
        override.aes = list(
          fill      = legend_fill_vals_NO_COMMENTS,
          colour    = unname(legend_cols_NO_COMMENTS),
          linewidth = 1.2,
          linetype  = 1,
          alpha     = 1
        ),
        keyheight   = unit(22, "pt"),
        label.theme = element_text(margin = margin(t = 0, b = 6)),
        title.theme = element_text(margin = margin(b = 12))
      )
    )
  
  leg_D_NO_COMMENTS <- get_legend_safe(legend_D_plot_NO_COMMENTS)
  
  # Actual plot D without legend
  p_D_plot_NO_COMMENTS <- p_D_panel_A_NO_COMMENTS + theme(legend.position = "none")
  
  # A legend
  p_A_for_leg_NO_COMMENTS <- p_A_panel_B_NO_COMMENTS +
    scale_fill_manual(values = kw_cols_NO_COMMENTS, name = "Keyword category") +
    theme(
      legend.position    = "right",
      legend.direction   = "vertical",
      legend.title       = element_text(size = LEG_TITLE_SIZE, margin = margin(b = 10)),
      legend.text        = element_text(size = LEG_TEXT_SIZE),
      legend.spacing.y   = unit(25, "pt"),
      legend.key.height  = unit(20, "pt"),
      legend.box.margin  = margin(t = 0, r = 0, b = 0, l = 0)
    ) +
    guides(
      fill = guide_legend(
        title = "Keyword category",
        title.position = "top",
        title.hjust = 0,
        keyheight = unit(22, "pt"),
        label.theme = element_text(margin = margin(b = 6)),
        title.theme = element_text(margin = margin(b = 12))
      )
    )
  
  leg_A_NO_COMMENTS <- get_legend_safe(p_A_for_leg_NO_COMMENTS)
  p_A_plot_NO_COMMENTS <- p_A_for_leg_NO_COMMENTS + theme(legend.position = "none")
  
  plots_Figure_4_left_NO_COMMENTS <- cowplot::plot_grid(
    p_D_plot_NO_COMMENTS,
    spacer_plot_NO_COMMENTS,
    p_A_plot_NO_COMMENTS,
    ncol = 1,
    rel_heights = c(1, SPACER_RELHEIGHT, 1),
    align = "v",
    axis  = "lr"
  )
  
  legs_Figure_4_right_NO_COMMENTS <- cowplot::plot_grid(
    leg_D_NO_COMMENTS,
    spacer_plot_NO_COMMENTS,
    leg_A_NO_COMMENTS,
    ncol = 1,
    rel_heights = c(1, SPACER_RELHEIGHT, 1),
    align = "v",
    axis  = "lr"
  )
  
  panel_Figure_4_core_NO_COMMENTS <- cowplot::plot_grid(
    plots_Figure_4_left_NO_COMMENTS,
    legs_Figure_4_right_NO_COMMENTS,
    ncol = 2,
    rel_widths = c(1, LEGEND_COL_RELWIDTH),
    align = "h",
    axis  = "tb"
  )
  
  LEFT_PAD  <- 0.025
  RIGHT_PAD <- 0.03
  
  panel_Figure_4_NO_COMMENTS <- cowplot::ggdraw() +
    cowplot::draw_plot(panel_Figure_4_core_NO_COMMENTS,
                       x = LEFT_PAD, y = 0,
                       width = 1 - LEFT_PAD - RIGHT_PAD, height = 1)
  
  ggsave(file.path(dir_plots,"Figure4_panel_Figure_4_ONECOL_TWOROWS_separate_legends_NO_COMMENTS.png"),
         panel_Figure_4_NO_COMMENTS, width = 350, height = 280, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots,"Figure4_panel_Figure_4_ONECOL_TWOROWS_separate_legends_NO_COMMENTS.tiff"),
         panel_Figure_4_NO_COMMENTS, width = 350, height = 280, units = "mm", dpi = 300, bg = "white")
  
  # ============================================================
  # 17) FIGURE S3 PANEL (TOP=B_base, BOTTOM=C) with separate legends
  # ============================================================
  p_B_panel_A_NO_COMMENTS <- (p_B_base_NO_COMMENTS + labs(tag = "A)") + tag_style_NO_COMMENTS)
  p_C_panel_B_NO_COMMENTS <- (p_C_NO_COMMENTS + labs(tag = "B)") + tag_style_NO_COMMENTS)
  
  p_B_for_leg_NO_COMMENTS <- p_B_panel_A_NO_COMMENTS +
    theme(
      legend.position  = "right",
      legend.direction = "vertical",
      legend.title = element_text(margin = margin(b = 8), size = LEG_TITLE_SIZE),
      legend.text  = element_text(size = LEG_TEXT_SIZE)
    )
  
  p_B_for_leg_NO_COMMENTS <- p_B_panel_A_NO_COMMENTS +
    theme(
      legend.position  = "right",
      legend.direction = "vertical",
      legend.title = element_text(margin = margin(b = 8), size = LEG_TITLE_SIZE),
      legend.box.margin = margin(t = 0, r = 0, b = 0, l = 0),
      legend.spacing.y = unit(25, "pt"),
      legend.key.height = unit(20, "pt"),
      legend.text  = element_text(size = LEG_TEXT_SIZE)
    ) +
    guides(fill = guide_legend(title = "Keyword category"))
    
  p_B_for_leg_NO_COMMENTS <- p_B_panel_A_NO_COMMENTS +
    theme(
      legend.position  = "right",
      legend.direction = "vertical",
      legend.title = element_text(margin = margin(b = 8), size = LEG_TITLE_SIZE),
      legend.box.margin = margin(t = 0, r = 0, b = 0, l = 0),
      legend.spacing.y = unit(25, "pt"),
      legend.key.height = unit(20, "pt"),
      legend.text  = element_text(size = LEG_TEXT_SIZE))
      
  leg_B_NO_COMMENTS <- get_legend_safe(p_B_for_leg_NO_COMMENTS)
  p_B_plot_NO_COMMENTS <- p_B_for_leg_NO_COMMENTS + theme(legend.position = "none")
  
  p_C_for_leg_NO_COMMENTS <- p_C_panel_B_NO_COMMENTS +
    theme(
      legend.position  = "right",
      legend.direction = "vertical",
      legend.title = element_text(margin = margin(b = 8), size = LEG_TITLE_SIZE),
      legend.box.margin = margin(t = 0, r = 0, b = 0, l = 0),
      legend.spacing.y = unit(25, "pt"),
      legend.key.height = unit(20, "pt"),
      legend.text  = element_text(size = LEG_TEXT_SIZE)
    ) +
    guides(
      colour = guide_legend(
        title = "Keyword category",
        title.position = "top",
        title.hjust = 0,
        keyheight = unit(22, "pt"),
        label.theme = element_text(margin = margin(b = 6)),
        title.theme = element_text(margin = margin(b = 12))
      )
    )
  
  leg_C_NO_COMMENTS <- get_legend_safe(p_C_for_leg_NO_COMMENTS)
  p_C_plot_NO_COMMENTS <- p_C_for_leg_NO_COMMENTS + theme(legend.position = "none")
  
  plots_Figure_S3_left_NO_COMMENTS <- cowplot::plot_grid(
    p_B_plot_NO_COMMENTS,
    spacer_plot_NO_COMMENTS,
    p_C_plot_NO_COMMENTS,
    ncol = 1,
    rel_heights = c(1, SPACER_RELHEIGHT, 1),
    align = "v",
    axis  = "lr"
  )
  
  legs_Figure_S3_right_NO_COMMENTS <- cowplot::plot_grid(
    leg_B_NO_COMMENTS,
    spacer_plot_NO_COMMENTS,
    leg_C_NO_COMMENTS,
    ncol = 1,
    rel_heights = c(1, SPACER_RELHEIGHT, 1),
    align = "v",
    axis  = "lr"
  )
  
  panel_Figure_S3_core_NO_COMMENTS <- cowplot::plot_grid(
    plots_Figure_S3_left_NO_COMMENTS,
    legs_Figure_S3_right_NO_COMMENTS,
    ncol = 2,
    rel_widths = c(1, LEGEND_COL_RELWIDTH),
    align = "h",
    axis  = "tb"
  )
  
  panel_Figure_S3_NO_COMMENTS <- cowplot::ggdraw() +
    cowplot::draw_plot(panel_Figure_S3_core_NO_COMMENTS,
                       x = LEFT_PAD, y = 0,
                       width = 1 - LEFT_PAD - RIGHT_PAD, height = 0.98)
  
  ggsave(file.path(dir_plots,"FigureS3_ONECOL_TWOROWS_shared_icons_separate_legends_NO_COMMENTS.png"),
         panel_Figure_S3_NO_COMMENTS, width = 350, height = 280, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots,"FigureS3_ONECOL_TWOROWS_shared_icons_separate_legends_NO_COMMENTS.tiff"),
         panel_Figure_S3_NO_COMMENTS, width = 350, height = 280, units = "mm", dpi = 300, bg = "white")
  
  # ============================================================
  # 17c) FIGURE S6 PANEL (A=DELTA, B=TRENDS) with separate legends
  # ============================================================
  
  p_S6_A <- (p_C_icons_NO_COMMENTS + labs(tag = "A)") + tag_style_NO_COMMENTS)
  p_S6_B <- (p_D_NO_COMMENTS       + labs(tag = "B)") + tag_style_NO_COMMENTS)
  
  leg_S6_A <- get_legend_safe(p_S6_A + theme(legend.position = "right", legend.direction = "vertical"))
  p_S6_A0  <- p_S6_A + theme(legend.position = "none")
  
  # For D, you already built a custom legend object (leg_D_NO_COMMENTS) earlier.
  # If that exists, prefer it; else extract from p_S6_B.
  leg_S6_B <- if (exists("leg_D_NO_COMMENTS")) leg_D_NO_COMMENTS else
    get_legend_safe(p_S6_B + theme(legend.position = "right", legend.direction = "vertical"))
  p_S6_B0  <- p_S6_B + theme(legend.position = "none")
  
  plots_S6_left <- cowplot::plot_grid(
    p_S6_A0, spacer_plot_NO_COMMENTS, p_S6_B0,
    ncol = 1,
    rel_heights = c(1, SPACER_RELHEIGHT, 1),
    align = "v",
    axis  = "lr"
  )
  
  legs_S6_right <- cowplot::plot_grid(
    leg_S6_A, spacer_plot_NO_COMMENTS, leg_S6_B,
    ncol = 1,
    rel_heights = c(1, SPACER_RELHEIGHT, 1),
    align = "v",
    axis  = "lr"
  )
  
  panel_S6_core <- cowplot::plot_grid(
    plots_S6_left,
    legs_S6_right,
    ncol = 2,
    rel_widths = c(1, LEGEND_COL_RELWIDTH),
    align = "h",
    axis  = "tb"
  )
  
  panel_Figure_S6_NO_COMMENTS <- cowplot::ggdraw() +
    cowplot::draw_plot(panel_S6_core,
                       x = LEFT_PAD, y = 0,
                       width = 1 - LEFT_PAD - RIGHT_PAD, height = 1)
  
  ggsave(file.path(dir_plots, "FigureS6_panel_AB_separate_legends_NO_COMMENTS.png"),
         panel_Figure_S6_NO_COMMENTS, width = 350, height = 280, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots, "FigureS6_panel_AB_separate_legends_NO_COMMENTS.tiff"),
         panel_Figure_S6_NO_COMMENTS, width = 350, height = 280, units = "mm", dpi = 300, bg = "white")
  
  # ============================================================
  # 16y) SINGLE EXPORTS - CANONICAL FILENAMES (FIXED)
  # ============================================================
  
  # ---- MAIN FIGURE 4 singles ----
  ggsave(file.path(dir_plots, "Figure4_A_single_NO_COMMENTS.png"),
         p_D_NO_COMMENTS, width = 225, height = 150, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots, "Figure4_A_single_NO_COMMENTS.tiff"),
         p_D_NO_COMMENTS, width = 225, height = 150, units = "mm", dpi = 300, bg = "white")
  
  ggsave(file.path(dir_plots, "Figure4_B_single_NO_COMMENTS.png"),
         p_A_icons_NO_COMMENTS, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots, "Figure4_B_single_NO_COMMENTS.tiff"),
         p_A_icons_NO_COMMENTS, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
  
  # ---- FIGURE S3 singles ----
  # IMPORTANT: S3-A must be the HEATMAP WITH PRED-PROB COLOURBAR, and NO icons (as in your original)
  ggsave(file.path(dir_plots, "FigureS3_A_single_NO_COMMENTS.png"),
         p_B_noicons_NO_COMMENTS, width = 240, height = 160, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots, "FigureS3_A_single_NO_COMMENTS.tiff"),
         p_B_noicons_NO_COMMENTS, width = 240, height = 160, units = "mm", dpi = 300, bg = "white")
  
  # S3-B is delta (icons OK)
  ggsave(file.path(dir_plots, "FigureS3_B_single_NO_COMMENTS.png"),
         p_C_icons_NO_COMMENTS, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
  ggsave(file.path(dir_plots, "FigureS3_B_single_NO_COMMENTS.tiff"),
         p_C_icons_NO_COMMENTS, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
     
  # ============================================================
  # 18) GAM trend stats export (CSV) - as you had
  # ============================================================
  gam_fits_NO_COMMENTS <- df_sum_NO_COMMENTS %>%
    group_split(KeywordCategory) %>%
    setNames(unique(df_sum_NO_COMMENTS$KeywordCategory)) %>%
    lapply(function(d) {
      gam(prop ~ s(year_bin, k = 5),
          family = quasibinomial(link = "logit"),
          weights = n_tot,
          method = "REML",
          data = d)
    })
  
  gam_summary_NO_COMMENTS <- lapply(names(gam_fits_NO_COMMENTS), function(cat) {
    s <- summary(gam_fits_NO_COMMENTS[[cat]])
    data.frame(
      KeywordCategory = cat,
      edf      = round(s$s.table[1, "edf"], 2),
      F_value  = round(s$s.table[1, "F"], 2),
      p_value  = signif(s$s.table[1, "p-value"], 3)
    )
  }) %>%
    bind_rows()
  
  print(gam_summary_NO_COMMENTS)
  
  write.csv(gam_summary_NO_COMMENTS,
            file.path(TAB_QA_DIR, "GAM_keyword_trends_summary_NO_COMMENTS.csv"),
            row.names = FALSE)
  
  # ============================================================
  # 19) MULTINOMIAL RESULTS TABLE (long) + Table 4 (wide)
  #     Export BOTH in CSV/MD/DOCX (your requirement #3)
  # ============================================================
  tidy_multinom_or <- function(mod, pretty_labels = TRUE) {
    B <- coef(mod)
    if (is.list(B)) B <- do.call(rbind, B)
    out_levels  <- rownames(B)
    terms_names <- colnames(B)
  
    V <- try(vcov(mod), silent = TRUE)
    if (inherits(V, "try-error")) stop("vcov() not available; refit with Hess = TRUE.")
  
    res_list <- lapply(seq_along(out_levels), function(i){
      outcome <- out_levels[i]
      p <- ncol(B)
      idx <- ((i - 1) * p + 1):(i * p)
  
      beta <- as.numeric(B[i, ])
      se   <- sqrt(diag(V)[idx])
      z    <- beta / se
      pval <- 2 * pnorm(abs(z), lower.tail = FALSE)
  
      tibble::tibble(
        Outcome = outcome,
        term    = terms_names,
        beta    = beta,
        se      = se,
        z       = z,
        p_value = pval,
        OR      = exp(beta),
        lwr     = exp(beta - 1.96 * se),
        upr     = exp(beta + 1.96 * se)
      )
    })
  
    tab <- bind_rows(res_list)
  
    tab <- tab %>%
      mutate(
        Predictor = case_when(
          str_starts(term, "time_period")   ~ "Time period",
          str_starts(term, "PresentStatus") ~ "Present Status",
          str_starts(term, "LifeForm")      ~ "LifeForm",
          TRUE                              ~ term
        ),
        Contrast = case_when(
          str_starts(term, "time_period")   ~ sub("^time_period", "", term),
          str_starts(term, "PresentStatus") ~ sub("^PresentStatus", "", term),
          str_starts(term, "LifeForm")      ~ sub("^LifeForm", "", term),
          TRUE                              ~ term
        ),
        Contrast = str_trim(Contrast)
      )
  
    if (pretty_labels) {
      tab <- tab %>%
        mutate(
          Contrast = case_when(
            Predictor == "Time period"    & Contrast == "Pre-Introduction" ~ "Pre-Introduction",
            Predictor == "Present Status" & Contrast == "established"       ~ "Established",
            Predictor == "LifeForm"       & Contrast == "Herptiles"         ~ "Herptiles",
            TRUE ~ Contrast
          )
        )
    }
  
    ref_levels <- list(
      "Time period"    = "Post-Introduction",
      "Present Status" = "present",
      "LifeForm"       = "Herptiles"
    )
  
    tab_nice <- tab %>%
      mutate(Predictor = factor(Predictor, levels = c("Time period","Present Status","LifeForm"))) %>%
      arrange(Outcome, Predictor, Contrast)
  
    tab_out <- tab_nice %>%
      group_by(Outcome) %>%
      group_modify(function(d, key){
        blocks <- list()
        for (pred in levels(tab_nice$Predictor)) {
          d_pred <- d %>% filter(Predictor == pred)
          if (nrow(d_pred) == 0) next
          ref_row  <- tibble(
            Outcome = unique(d$Outcome),
            Predictor = pred,
            Contrast  = paste0(ref_levels[[pred]], " (ref.)"),
            beta=NA_real_, se=NA_real_, z=NA_real_, p_value=NA_real_,
            OR=NA_real_, lwr=NA_real_, upr=NA_real_
          )
          blocks[[pred]] <- bind_rows(ref_row, d_pred)
        }
        bind_rows(blocks)
      }) %>%
      ungroup()
  
    tab_out %>%
      mutate(
        `Adj. OR (95% CI)` = ifelse(
          is.na(OR), "-",
          sprintf("%.2f (%.2f-%.2f)", OR, lwr, upr)
        ),
        P = ifelse(is.na(p_value), "-",
                   ifelse(p_value < .001, "<0.001", sprintf("%.3f", p_value)))
      ) %>%
      dplyr::select(Outcome, Predictor, Contrast, `Adj. OR (95% CI)`, P)
  }
  
  # Long multinomial results (for supplementary export)
  multi_tab_NO_COMMENTS <- tidy_multinom_or(m_ci_NO_COMMENTS)
  
  null_mod_NO_COMMENTS <- nnet::multinom(KeywordCategory ~ 1, data = df_NO_COMMENTS, trace = FALSE, Hess = TRUE)
  AIC_val_NO_COMMENTS  <- AIC(m_step_NO_COMMENTS)
  R2_mcF_NO_COMMENTS   <- 1 - as.numeric(logLik(m_step_NO_COMMENTS)) / as.numeric(logLik(null_mod_NO_COMMENTS))
  
  export_table_all(
    multi_tab_NO_COMMENTS,
    out_dir = TAB_QA_DIR,
    stem = "Multinomial_results_table_NO_COMMENTS",
    caption = sprintf(
      "Multinomial results (NO_COMMENTS). AIC: %.2f | McFadden R^2: %.3f",
      AIC_val_NO_COMMENTS, R2_mcF_NO_COMMENTS
    ),
    doc_heading_style = "heading 1",
    doc_fontsize = 9
  )
  
  # ---- Table 3 (wide) exactly as in the manuscript layout ----
  table4_wide <- multi_tab_NO_COMMENTS %>%
    mutate(
      cell = if_else(
        `Adj. OR (95% CI)` == "-", "-",
        paste0(`Adj. OR (95% CI)`, "\nP=", P)
      )
    ) %>%
    dplyr::select(Predictor, Contrast, Outcome, cell) %>%
    pivot_wider(names_from = Outcome, values_from = cell)
  
  # enforce column order if present
  want_cols <- c("Detection","eCommerce","Threat")
  have_cols <- intersect(want_cols, names(table4_wide))
  table4_wide <- table4_wide %>% dplyr::select(Predictor, Contrast, all_of(have_cols))
  
  export_table_all(
    table4_wide,
    out_dir = dir_tables_NO_COMMENTS,
    stem = "Table3_multinom_wide",
    caption = "Table 3. Multinomial model results (Invasion as reference outcome).",
    doc_heading_style = "heading 1",
    doc_fontsize = 9
  )
  
  # ============================================================
  # 20) OPTIONAL: COPY/ALIASES to your requested naming scheme
  #     (keeps original filenames but also provides FigureS4/S6
  #      placeholders so the build produces something deterministically.)
  # ============================================================
  # If you already have a fixed mapping for S4/S6, replace these copies accordingly.
  # The original reconstruction accidentally left two incomplete file.copy() calls
  # without destination paths. Keep the original Figure 4 A/B filenames as exported
  # above; no alias copy is needed for these two panels.
  file.copy(
    file.path(dir_plots,"Figure4_C_single_NO_COMMENTS.png"),
    file.path(dir_plots,"FigureS6_C_single_NO_COMMENTS.png"),
    overwrite = TRUE
  )
  file.copy(
    file.path(dir_plots,"Figure4_D_single_variantA_pre_post_minus5_to_10_NO_COMMENTS.png"),
    file.path(dir_plots,"FigureS6_D_single_NO_COMMENTS.png"),
    overwrite = TRUE
  )
  
  cat("\n=== DONE ===\n")
  cat("Figures saved under: ", dir_plots_NO_COMMENTS, "\n")
  cat("Tables  saved under: ", dir_tables_NO_COMMENTS, "\n")
                                                                    
} else {
message("Running complete submitted Figures 4/S3/S6 + Tables 4/S14-S16 script: ", ANALYSIS_MODE)
  # ============================================================
  # COMPLETE WORKFLOW - Figures 4, S3, S6 + Tables 4, S14-S16
  # (ALL TOKENS: titles + descriptions + comments + replies)
  #
  # KEY REQUIREMENTS IMPLEMENTED:
  #  1) Figures are produced using:
  #     - BEST_UNW_STEP  : best unweighted model from stepAIC (can drop time_period)
  #     - FORCED_UNW_STEP_TIME : best unweighted model from stepAIC with time_period forced in
  #     => For EACH figure/panel we save BOTH variants.
  #
  #  2) Supplementary figures use the UNWEIGHTED model as well
  #     (same BEST vs FORCED variants exported).
  #
  #  3) Tables S14-S15 are candidate-set AIC tables (unweighted + weighted).
  #  4) Table S16 is relative-time keyword trajectories using BINOMIAL COUNTS GAMs.
  #  5) Table 4 is exported PER VARIANT (so it matches the model used for the figures).
  # ============================================================
  
  # ---------------------------
  # 0) Packages (single load)
  # ---------------------------
  suppressPackageStartupMessages({
    library(dplyr)
    library(tidyr)
    library(stringr)
    library(purrr)
    library(tibble)
  
    library(ggplot2)
    library(scales)
    library(readr)
  
    library(nnet)
    library(MASS)
  
    library(cowplot)
    library(grid)
  
    library(ggimage)
    library(ggnewscale)
  
    library(mgcv)
  
    library(knitr)
    library(flextable)
    library(officer)
  
    library(png)
  })
  
  # ============================================================
  # 1) FIXED CONSTANTS (retain your tuned values)
  # ============================================================
  
  desired_lf_order <- c(
    "Birds","Herptiles","Fishes","Insects",
    "Crustaceans","Non-arthropod invertebrates","Plants","Bacteria, Viruses, Fungi"
  )
  
  lifeform_display_labels <- c(
    "Non-arthropod invertebrates" = "N.A. invertebrates",
    "Bacteria, Viruses, Fungi"    = "Bacteria/Viruses/Fungi"
  )
  
  AXIS_TITLE_SIZE <- 19
  AXIS_TEXT_SIZE  <- 17
  LEG_TITLE_SIZE  <- 19
  LEG_TEXT_SIZE   <- 17
  TAG_SIZE        <- 22
  
  # ============================================================
  # 2) COLOR SCHEME - keep your FINAL base_cols assignment
  # ============================================================
  base_cols <- c(
    Detection = "#959BFF",
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
  
  kw_cols_ALL <- base_cols
  kw_levels   <- c("Invasion","Detection","eCommerce","Threat")
  
  theme_inat <- function(base_size = 16) {
    theme_light(base_size = base_size) +
      theme(
        panel.grid.major.x = element_blank(),
        panel.grid.minor   = element_blank(),
        legend.title       = element_blank(),
        legend.position    = "top",
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
  
  # ============================================================
  # 3) PATHS (ALL)
  # ============================================================
  dir_tables_ALL <- file.path(file.path("outputs", "intermediate"),
                              paste0("models_multinom", MODE_OUTPUT_SUFFIX))
  dir_plots_ALL  <- file.path(file.path("outputs", "intermediate"),
                              paste0("models_multinom", MODE_OUTPUT_SUFFIX))
  dir.create(dir_tables_ALL, recursive = TRUE, showWarnings = FALSE)
  dir.create(dir_plots_ALL,  recursive = TRUE, showWarnings = FALSE)
  
  tok_csv_ALL <- file.path(
    file.path("outputs", "intermediate"),
    "keywords", TOKEN_FILE_BASENAME
  )
  if (!file.exists(tok_csv_ALL)) {
    alt <- file.path(
      file.path("outputs", "intermediate"), "keywords",
      TOKEN_FILE_BASENAME
    )
    if (file.exists(alt)) tok_csv_ALL <- alt else stop("Tokens CSV not found for ANALYSIS_MODE=", ANALYSIS_MODE,
                                                       " (expected: ", TOKEN_FILE_BASENAME, ").")
  }
  
  # ============================================================
  # 4) TABLE EXPORT HELPERS (CSV + MD + DOCX)  [FIXED]
  # ============================================================
  export_table_all <- function(tab, out_dir, stem, caption,
                               doc_heading_style = "heading 2",
                               doc_fontsize = 9) {
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
    tab <- tab %>% mutate(across(where(is.numeric), ~ round(.x, 4)))
  
    csv_path  <- file.path(out_dir, paste0(stem, ".csv"))
    md_path   <- file.path(out_dir, paste0(stem, ".md"))
    docx_path <- file.path(out_dir, paste0(stem, ".docx"))
  
    readr::write_csv(tab, csv_path)
  
    writeLines(
      c(
        caption,
        "",
        knitr::kable(tab, format = "pipe", align = "l")
      ),
      md_path
    )
  
    ft <- flextable(tab) |>
      autofit() |>
      fontsize(size = doc_fontsize) |>
      align(align = "left", part = "all")
  
    docx <- read_docx()
    docx <- body_add_par(docx, caption, style = doc_heading_style)
    docx <- body_add_flextable(docx, ft)
    print(docx, target = docx_path)
  
    message("Saved: ", csv_path, " | ", md_path, " | ", docx_path)
    invisible(list(csv = csv_path, md = md_path, docx = docx_path))
  }
  
  # ============================================================
  # 4b) REQUIRED HELPERS YOU REFERENCED
  # ============================================================
  
  .choose_weight_vector <- function(df, view_col = "viewCount",
                                    cap_prob = 0.99, eps = 1e-6) {
    stopifnot(view_col %in% names(df))
    w_raw <- log1p(df[[view_col]])
    w_raw[!is.finite(w_raw)] <- NA_real_
  
    cap <- stats::quantile(w_raw, probs = cap_prob, na.rm = TRUE, names = FALSE)
    w_cap <- pmin(w_raw, cap)
  
    w <- w_cap / mean(w_cap, na.rm = TRUE)
    w[is.na(w) | !is.finite(w) | w <= 0] <- eps
    w
  }
  
  build_aic_table_multinom <- function(models_named, predictors_named) {
    stopifnot(all(names(models_named) %in% names(predictors_named)))
  
    aic_vals <- sapply(models_named, AIC)
    ll_vals  <- sapply(models_named, function(m) as.numeric(logLik(m)))
    k_vals   <- sapply(models_named, function(m) attr(logLik(m), "df"))
  
    aic_min <- min(aic_vals, na.rm = TRUE)
    delta   <- aic_vals - aic_min
    relL    <- exp(-0.5 * delta)
    wts     <- relL / sum(relL)
  
    tibble::tibble(
      Model      = names(models_named),
      Predictors = unname(predictors_named[names(models_named)]),
      K          = as.integer(k_vals),
      AIC        = as.numeric(aic_vals),
      `?AIC`     = as.numeric(delta),
      AICWt      = as.numeric(wts),
      Cum.Wt     = as.numeric(cumsum(wts)),
      LL         = as.numeric(ll_vals)
    ) %>%
      arrange(`?AIC`) %>%
      mutate(
        AIC   = round(AIC, 2),
        `?AIC`= round(`?AIC`, 2),
        AICWt = round(AICWt, 2),
        Cum.Wt= round(Cum.Wt, 2),
        LL    = round(LL, 2)
      )
  }
  
  .make_model_data_and_weights <- function(df, w, form){
    mf <- model.frame(form, data = df, na.action = na.pass)
    keep <- complete.cases(mf)
    df2 <- df[keep, , drop = FALSE]
    w2  <- w[keep]
    w2[!is.finite(w2) | w2 < 0] <- 0
    list(data = ensure_case_weight_column(df2), w = w2, keep = keep)
  }
  
  build_stepwise_table <- function(step_model, label_prefix = "Step") {
    st <- step_model$anova
    if (is.null(st) || !nrow(st)) stop("No stepwise anova table found in step_model$anova.")
    out <- tibble::as_tibble(st)
    if (!"AIC" %in% names(out)) stop("AIC column not found in step_model$anova.")
    out %>%
      mutate(
        Model  = paste0(label_prefix, " ", row_number()),
        Action = if ("Step" %in% names(out)) as.character(.data$Step) else NA_character_,
        AIC    = as.numeric(.data$AIC)
      ) %>%
      dplyr::select(Model, Action, AIC) %>%
      mutate(dAIC = AIC - min(AIC, na.rm = TRUE)) %>%
      arrange(AIC)
  }
  
  # ============================================================
  # 5) READ + PREP TOKENS DATA (ALL) + rebuild created_at + time_period
  # ============================================================
  
  .pick_first_existing <- function(df, candidates) {
    nm <- intersect(candidates, names(df))
    if (!length(nm)) return(NULL)
    nm[1]
  }
  
  .to_posix_utc <- function(x) {
    if (inherits(x, "POSIXt")) return(as.POSIXct(x, tz = "UTC"))
    if (is.numeric(x)) {
      xx <- as.numeric(x)
      if (all(is.na(xx))) return(as.POSIXct(NA, tz = "UTC"))
      if (stats::median(xx, na.rm = TRUE) > 1e12) xx <- xx / 1000
      return(as.POSIXct(xx, tz = "UTC", origin = "1970-01-01"))
    }
    suppressWarnings(as.POSIXct(as.character(x), tz = "UTC"))
  }
  
  .ensure_firstrecorddate <- function(df) {
    if (!"FirstRecordDate" %in% names(df) || all(is.na(df$FirstRecordDate))) {
      if ("FirstRecord" %in% names(df)) {
        fr <- suppressWarnings(as.integer(df$FirstRecord))
        df$FirstRecordDate <- as.POSIXct(paste0(pmax(fr, 1L), "-06-01"), tz = "UTC")
      } else {
        df$FirstRecordDate <- as.POSIXct(NA, tz = "UTC")
      }
    } else {
      df$FirstRecordDate <- .to_posix_utc(df$FirstRecordDate)
    }
    df
  }
  
  .rebuild_created_at <- function(df) {
    cand <- c(
      "token_created_at","created_at",
      "comment_published_at","comment_publishedAt","comment_created_at","comment_date",
      "reply_published_at","reply_publishedAt","reply_created_at","reply_date",
      "publishedAt","published_at","publish_date","video_published_at"
    )
    best <- .pick_first_existing(df, cand)
    if (!is.null(best)) {
      df$created_at <- .to_posix_utc(df[[best]])
    } else {
      df$created_at <- as.POSIXct(NA, tz = "UTC")
    }
    df
  }
  
  .rebuild_time_period_from_time <- function(df) {
    df <- .ensure_firstrecorddate(df)
    df <- .rebuild_created_at(df)
  
    df$time_period <- ifelse(
      !is.na(df$created_at) & !is.na(df$FirstRecordDate) & df$created_at < df$FirstRecordDate,
      "Pre-Introduction",
      ifelse(!is.na(df$created_at) & !is.na(df$FirstRecordDate), "Post-Introduction", NA_character_)
    )
    df
  }
  
  kw_ALL <- readr::read_csv(tok_csv_ALL, show_col_types = FALSE) %>%
    .rebuild_time_period_from_time()
  
  cat("\nALL token file:", tok_csv_ALL, "\n")
  cat(MODE_OBJECT_SUFFIX, " rows:", nrow(kw_ALL), "\n")
  cat(MODE_OBJECT_SUFFIX, " time_period counts:\n"); print(table(kw_ALL$time_period, useNA = "ifany"))
  
  kw_ALL <- kw_ALL %>% mutate(
    FR_year  = suppressWarnings(as.integer(FirstRecord)),
    year_obs = suppressWarnings(as.integer(format(as.Date(created_at), "%Y"))),
    rel_year = year_obs - FR_year
  )
  
  # Build analysis frame (one row per TOKEN)
  df_ALL <- kw_ALL %>%
    mutate(
      time_period = factor(time_period, levels = c("Pre-Introduction","Post-Introduction")),
      LifeForm = factor(LifeForm),
      PresentStatus = factor(PresentStatus),
      KeywordCategory = factor(KeywordCategory, levels = kw_levels)
    ) %>%
    filter(
      !is.na(time_period),
      !is.na(LifeForm), LifeForm != "Unknown",
      !is.na(PresentStatus),
      !is.na(KeywordCategory)
    ) %>%
    mutate(
      PresentStatus = case_when(
        tolower(PresentStatus) %in% c("alien","present") ~ "present",
        tolower(PresentStatus) == "established"          ~ "established",
        TRUE ~ tolower(PresentStatus)
      ),
      PresentStatus = factor(PresentStatus, levels = c("present","established")),
      time_period     = stats::relevel(time_period,     ref = "Post-Introduction"),
      LifeForm        = stats::relevel(LifeForm,        ref = "Herptiles"),
      PresentStatus   = stats::relevel(PresentStatus,   ref = "present"),
      KeywordCategory = stats::relevel(KeywordCategory, ref = "Invasion")
    ) %>%
    filter(PresentStatus %in% c("present","established")) %>%
    droplevels()
  
  stopifnot(identical(levels(df_ALL$PresentStatus), c("present","established")))
  
  # ============================================================
  # 6) MODEL FITTING
  #   - Unweighted BEST (stepAIC can drop time_period)
  #   - Unweighted FORCED time_period (stepAIC keeps time_period)
  #   - Weighted step (for tables / sensitivity)
  # ============================================================
  
  fit_step_multinom <- function(dat, weights = NULL, force_time_period = FALSE, trace = FALSE){
    f_full <- KeywordCategory ~ time_period + LifeForm + PresentStatus
  
    args <- list(
      formula = f_full, data = dat,
      maxit = 1000, MaxNWts = 20000, trace = trace, Hess = TRUE
    )
    if (!is.null(weights)) args$weights <- weights
  
    m_full <- do.call(nnet::multinom, args)
  
    scope_list <- if (force_time_period) {
      list(lower = ~ time_period,
           upper = ~ time_period + LifeForm + PresentStatus)
    } else {
      list(lower = ~ 1,
           upper = ~ time_period + LifeForm + PresentStatus)
    }
  
    m_step <- try(
      MASS::stepAIC(
        m_full,
        scope = scope_list,
        direction = "backward",
        trace = FALSE
      ),
      silent = TRUE
    )
    if (inherits(m_step, "try-error")) m_step <- m_full
  
    m_step_ci <- try(update(m_step, Hess = TRUE, trace = FALSE), silent = TRUE)
    if (inherits(m_step_ci, "try-error")) m_step_ci <- m_step
  
    list(full = m_full, step = m_step, step_ci = m_step_ci)
  }
  
  # weights for weighted sensitivity
  w_view_ALL <- .choose_weight_vector(df_ALL)
  
  # Unweighted BEST + FORCED
  fits_unw_best_ALL   <- fit_step_multinom(df_ALL, weights = NULL, force_time_period = FALSE)
  fits_unw_forced_ALL <- fit_step_multinom(df_ALL, weights = NULL, force_time_period = TRUE)
  
  m_best_unw_ALL    <- fits_unw_best_ALL$step
  m_best_unw_ci_ALL <- fits_unw_best_ALL$step_ci
  
  m_forced_unw_ALL    <- fits_unw_forced_ALL$step
  m_forced_unw_ci_ALL <- fits_unw_forced_ALL$step_ci
  
  # Weighted step (used for stepwise path table, if you want it)
  fits_w_step_ALL <- fit_step_multinom(df_ALL, weights = w_view_ALL, force_time_period = TRUE)
  m_w_step_ALL    <- fits_w_step_ALL$step
  
  cat("\n=== FORMULAS (ALL) ===\n")
  cat("UNW BEST:   ", deparse(formula(m_best_unw_ALL)), "\n")
  cat("UNW FORCED: ", deparse(formula(m_forced_unw_ALL)), "\n")
  cat("W  STEP:    ", deparse(formula(m_w_step_ALL)), "\n")
  
  # ============================================================
  # 7) TABLES S14 + S15 (ALL) - candidate set model selection
  # ============================================================
  
  cand_forms <- list(
    "Model 1" = KeywordCategory ~ time_period + LifeForm + PresentStatus,
    "Model 2" = KeywordCategory ~ time_period + LifeForm,
    "Model 3" = KeywordCategory ~ time_period + PresentStatus,
    "Model 4" = KeywordCategory ~ time_period,
    "Model 5" = KeywordCategory ~ 1
  )
  
  pred_labels <- list(
    "Model 1" = "Time period + Taxonomic group + Invasion status",
    "Model 2" = "Time period + Taxonomic group",
    "Model 3" = "Time period + Invasion status",
    "Model 4" = "Time period",
    "Model 5" = "null"
  )
  
  # --- S14 (UNWEIGHTED candidates)
  models_S14_ALL <- lapply(cand_forms, function(fm){
    nnet::multinom(fm, data = df_ALL, trace = FALSE, Hess = TRUE,
                   maxit = 1000, MaxNWts = 20000)
  })
  tab_S14_ALL <- build_aic_table_multinom(models_S14_ALL, pred_labels)
  export_table_all(
    tab_S14_ALL,
    out_dir = TAB_QA_DIR,
    stem = "Table_S14_model_selection_unweighted_ALL",
    caption = "Table S14. Model selection for multinomial keyword-category models (unweighted; ALL tokens)."
  )
  
  # --- S15 (WEIGHTED candidates) with aligned complete-cases per formula
  models_S15_ALL <- lapply(cand_forms, function(fm){
    tmp <- .make_model_data_and_weights(df_ALL, w_view_ALL, fm)
    nnet::multinom(fm, data = tmp$data, weights = weight_vec,
                   trace = FALSE, Hess = TRUE, maxit = 1000, MaxNWts = 20000)
  })
  tab_S15_ALL <- build_aic_table_multinom(models_S15_ALL, pred_labels)
  export_table_all(
    tab_S15_ALL,
    out_dir = TAB_QA_DIR,
    stem = "Table_S15_model_selection_weighted_ALL",
    caption = "Table S15. Model selection for multinomial keyword-category models (view-weighted; ALL tokens)."
  )
  
  # (Optional) Stepwise path tables (kept since you already used them)
  tab_S14_step_path <- build_stepwise_table(fits_unw_forced_ALL$step, label_prefix = "Unw step")
  export_table_all(
    tab_S14_step_path,
    out_dir = TAB_QA_DIR,
    stem = "Table_S14_stepwise_path_unweighted_ALL",
    caption = "Table S14 (supplement). Stepwise AIC path for multinomial keyword-category models (unweighted; ALL tokens)."
  )
  tab_S15_step_path <- build_stepwise_table(m_w_step_ALL, label_prefix = "W step")
  export_table_all(
    tab_S15_step_path,
    out_dir = TAB_QA_DIR,
    stem = "Table_S15_stepwise_path_weighted_ALL",
    caption = "Table S15 (supplement). Stepwise AIC path for multinomial keyword-category models (view-weighted; ALL tokens)."
  )
  
  # ============================================================
  # 8) CI helper (unchanged from your paste)
  # ============================================================
  simulate_probs_ci_safe <- function(mod, newdata, R = 400){
    Terms  <- stats::terms(mod)
    mf_fit <- model.frame(mod)
    X_fit  <- model.matrix(stats::delete.response(Terms), mf_fit)
    X_new <- model.matrix(
      stats::delete.response(Terms),
      model.frame(stats::delete.response(Terms), newdata,
                  xlev = lapply(mf_fit, levels))
    )
  
    miss_in_new <- setdiff(colnames(X_fit), colnames(X_new))
    if (length(miss_in_new)){
      X_new <- cbind(X_new, matrix(0, nrow = nrow(X_new), ncol = length(miss_in_new),
                                   dimnames = list(NULL, miss_in_new)))
    }
    X_new <- X_new[, colnames(X_fit), drop = FALSE]
  
    B <- coef(mod); if (is.list(B)) B <- do.call(rbind, B)
    if (!is.null(colnames(B))){
      miss_in_B <- setdiff(colnames(X_fit), colnames(B))
      if (length(miss_in_B)){
        B <- cbind(B, matrix(0, nrow = nrow(B), ncol = length(miss_in_B),
                             dimnames = list(NULL, miss_in_B)))
      }
      B <- B[, colnames(X_fit), drop = FALSE]
    } else {
      if (ncol(B) != ncol(X_fit)) stop("simulate_probs_ci_safe: coefficient dimension mismatch.")
    }
  
    softmax <- function(eta){
      ef <- cbind(0, eta)
      E  <- exp(ef - apply(ef, 1, max))
      E / rowSums(E)
    }
  
    Eta   <- X_new %*% t(B)
    P_hat <- softmax(Eta)
  
    vc <- try(vcov(mod), silent = TRUE)
    if (inherits(vc, "try-error") || anyNA(vc)){
      resp <- model.frame(mod)[[1]]
      classes <- levels(resp)
      n <- nrow(newdata)
      K1 <- nrow(B) + 1L
      out0 <- tibble::tibble(
        Class = rep(classes, each = n),
        fit   = as.vector(P_hat),
        lwr   = NA_real_, upr = NA_real_
      )
      new_rep <- newdata[rep(seq_len(nrow(newdata)), times = K1), , drop = FALSE]
      return(dplyr::bind_cols(out0, new_rep))
    }
  
    ok <- TRUE; tryCatch(chol(vc), error = function(e) ok <<- FALSE)
    if (!ok){
      if (requireNamespace("Matrix", quietly = TRUE)){
        vc <- as.matrix(Matrix::nearPD(vc, keepDiag = TRUE)$mat)
      } else vc <- vc + diag(1e-8, nrow(vc))
    }
  
    R <- max(200, min(R, 1200))
    mu <- as.vector(t(B))
  
    draws <- try(MASS::mvrnorm(n = R, mu = mu, Sigma = vc), silent = TRUE)
    if (inherits(draws, "try-error")){
      se <- sqrt(diag(vc))
      draws <- matrix(mu, nrow = R, byrow = TRUE) +
        matrix(rnorm(R * length(mu), 0, rep(se, each = R)), nrow = R)
    }
  
    n  <- nrow(newdata)
    K1 <- nrow(B) + 1L
    arr <- array(NA_real_, dim = c(n, K1, R))
  
    for (r in seq_len(R)){
      Br <- matrix(draws[r, ], nrow = nrow(B), byrow = TRUE)
      arr[,,r] <- softmax(X_new %*% t(Br))
    }
  
    resp    <- model.frame(mod)[[1]]
    classes <- levels(resp)
  
    prob_df <- purrr::map_dfr(seq_len(K1), function(j){
      tibble::tibble(
        Class = classes[j],
        fit   = rowMeans(arr[, j, , drop = FALSE], dims = 2),
        lwr   = apply(arr[, j, , drop = FALSE], 1, quantile, probs = .025),
        upr   = apply(arr[, j, , drop = FALSE], 1, quantile, probs = .975)
      )
    })
  
    new_rep <- newdata[rep(seq_len(nrow(newdata)), times = K1), , drop = FALSE]
    dplyr::bind_cols(prob_df, new_rep)
  }
  
  # ============================================================
  # 9) ICON SETUP (single source) + TINTED ICONS
  # ============================================================
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
  
  icon_dir_candidates <- c("fig_assets/icons","fig_assets")
  
  pick_icon_dir <- function(cands, probe = "bird_multinom.png") {
    for (d in cands) {
      if (dir.exists(d) && file.exists(file.path(d, probe))) return(d)
    }
    return(NA_character_)
  }
  ICON_DIR <- pick_icon_dir(icon_dir_candidates)
  if (is.na(ICON_DIR)) {
    stop("Couldn't find icons. Tried: ", paste(icon_dir_candidates, collapse = ", "),
         "\nWorking directory: ", getwd())
  }
  icon_paths <- file.path(ICON_DIR, icon_filemap[desired_lf_order])
  names(icon_paths) <- desired_lf_order
  
  as_rgba <- function(img, light = 0.65, tint = c(0.55, 0.50, 0.60)) {
    d <- dim(img)
    apply_tint <- function(g) {
      g <- light + (1 - light) * g
      list(r = g * tint[1], g = g * tint[2], b = g * tint[3])
    }
  
    if (!is.null(d) && length(d) == 3 && d[3] == 2) {
      g <- img[,,1]; a <- img[,,2]
      col <- apply_tint(g)
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
  
  tinted_dir <- file.path(ICON_DIR, "_tinted_icons_ALL")
  if (!dir.exists(tinted_dir)) dir.create(tinted_dir, recursive = TRUE)
  
  tinted_icon_paths <- icon_paths
  for (lf in names(icon_paths)) {
    fp <- icon_paths[[lf]]
    if (!file.exists(fp)) next
    out_fp <- file.path(tinted_dir, paste0(tools::file_path_sans_ext(basename(fp)), "__ALL.png"))
    if (!file.exists(out_fp)) {
      img <- png::readPNG(fp)
      img <- as_rgba(img, light = 0.65, tint = c(0.55, 0.50, 0.60))
      png::writePNG(img, target = out_fp)
    }
    tinted_icon_paths[[lf]] <- out_fp
  }
  icon_paths <- tinted_icon_paths
  
  # ============================================================
  # 10) TABLE S16 - Relative-time keyword trajectories (BINOMIAL COUNTS)
  # ============================================================
  build_table_S16_binomcounts <- function(kw_df, win_lo = -5, win_hi = 10,
                                         kw_levels = c("Invasion","Detection","eCommerce","Threat")) {
  
    kw_df <- kw_df %>%
      mutate(
        created_at     = .to_posix_utc(created_at),
        FirstRecordDate= .to_posix_utc(FirstRecordDate),
        KeywordCategory= factor(KeywordCategory, levels = kw_levels),
        rel_year_cont  = as.numeric(difftime(created_at, FirstRecordDate, units = "days")) / 365.25,
        year_bin       = floor(rel_year_cont)
      ) %>%
      filter(is.finite(year_bin), year_bin >= win_lo, year_bin <= win_hi) %>%
      filter(!is.na(KeywordCategory))
  
    df_sum <- kw_df %>%
      count(year_bin, KeywordCategory, name = "n_kw") %>%
      group_by(year_bin) %>%
      mutate(n_tot = sum(n_kw)) %>%
      ungroup() %>%
      mutate(
        n_tot  = pmax(n_tot, 1L),
        n_fail = pmax(n_tot - n_kw, 0L)
      )
  
    # weights by year_bin from observed totals
    year_w <- df_sum %>%
      distinct(year_bin, n_tot) %>%
      group_by(year_bin) %>%
      summarise(n_tot = max(n_tot, na.rm = TRUE), .groups = "drop")
  
    pred_grid <- data.frame(year_bin = seq(win_lo, win_hi, by = 1))
  
    extract_smooth_stat <- function(g) {
      s <- summary(g)$s.table
      edf <- as.numeric(s[1, "edf"])
      stat <- if ("Chi.sq" %in% colnames(s)) as.numeric(s[1, "Chi.sq"]) else
        if ("F" %in% colnames(s)) as.numeric(s[1, "F"]) else NA_real_
      p <- as.numeric(s[1, "p-value"])
      list(edf = edf, stat = stat, p = p)
    }
  
    cats <- sort(unique(as.character(df_sum$KeywordCategory)))
    gam_fits <- lapply(cats, function(cat){
      d <- df_sum %>% filter(KeywordCategory == cat)
      mgcv::gam(
        cbind(n_kw, n_fail) ~ s(year_bin, k = 5),
        family = binomial(link = "logit"),
        method = "REML",
        data   = d
      )
    })
    names(gam_fits) <- cats
  
    out <- lapply(names(gam_fits), function(cat) {
      g <- gam_fits[[cat]]
  
      eta   <- predict(g, newdata = pred_grid, type = "link")
      p_hat <- plogis(eta)
  
      pred_df <- pred_grid %>%
        mutate(KeywordCategory = cat, pred = p_hat) %>%
        left_join(year_w, by = "year_bin") %>%
        mutate(n_tot = ifelse(is.na(n_tot), 1, n_tot))
  
      pre_mean  <- with(pred_df[pred_df$year_bin < 0, ],
                        weighted.mean(pred, w = n_tot, na.rm = TRUE))
      post_mean <- with(pred_df[pred_df$year_bin >= 0, ],
                        weighted.mean(pred, w = n_tot, na.rm = TRUE))
  
      st <- extract_smooth_stat(g)
  
      tibble(
        `Keyword category` = cat,
        Pre  = round(pre_mean, 3),
        Post = round(post_mean, 3),
        `? (Post-Pre)` = round(post_mean - pre_mean, 3),
        edf  = round(st$edf, 2),
        `?²/F` = round(st$stat, 2),
        p    = ifelse(is.na(st$p), NA_character_,
                      ifelse(st$p < 0.001, "<0.001", sprintf("%.4f", st$p)))
      )
    }) %>%
      bind_rows() %>%
      mutate(`Keyword category` = factor(`Keyword category`, levels = kw_levels)) %>%
      arrange(`Keyword category`)
  
    out
  }
  
  S16_ALL <- build_table_S16_binomcounts(kw_ALL, win_lo = -5, win_hi = 10, kw_levels = kw_levels)
  export_table_all(
    S16_ALL,
    out_dir = TAB_SUPP_DIR,
    stem = "Table_S16_relative_time_trends_ALL",
    caption = "Table S16. Relative time trends in category-specific keyword prevalence around species introduction (binomial GAMs; ALL tokens)."
  )
  
  # ============================================================
  # 11) MULTINOM RESULTS TABLE (Table 4) helpers (unchanged)
  # ============================================================
  tidy_multinom_or <- function(mod, digits_or = 4, max_or = 1e4) {
  
    fmt_or_ci <- function(or, lwr, upr, digits_or = 4, max_or = 1e4) {
      if (is.na(or)) return("-")
      if (!is.finite(or) || or < 0)  or  <- NA_real_
      if (!is.finite(lwr) || lwr < 0) lwr <- NA_real_
      if (!is.finite(upr) || upr < 0) upr <- NA_real_
      if (is.na(or)) return("-")
  
      or_r  <- round(or,  digits_or)
      lwr_r <- round(lwr, digits_or)
      upr_r <- round(upr, digits_or)
  
      upr_txt <- if (!is.na(upr_r) && is.finite(upr_r) && upr_r <= max_or) {
        formatC(upr_r, format = "f", digits = digits_or)
      } else {
        paste0(">", formatC(max_or, format = "f", digits = 0))
      }
  
      lwr_txt <- if (!is.na(lwr_r) && is.finite(lwr_r)) {
        formatC(lwr_r, format = "f", digits = digits_or)
      } else {
        formatC(0, format = "f", digits = digits_or)
      }
  
      sprintf(
        "%s (%s-%s)",
        formatC(or_r, format = "f", digits = digits_or),
        lwr_txt,
        upr_txt
      )
    }
  
    B <- coef(mod)
    if (is.list(B)) B <- do.call(rbind, B)
    out_levels  <- rownames(B)
    terms_names <- colnames(B)
  
    V <- try(vcov(mod), silent = TRUE)
    if (inherits(V, "try-error")) stop("vcov() not available; refit with Hess = TRUE.")
  
    res_list <- lapply(seq_along(out_levels), function(i){
      outcome <- out_levels[i]
      p <- ncol(B)
      idx <- ((i - 1) * p + 1):(i * p)
  
      beta <- as.numeric(B[i, ])
      se   <- sqrt(diag(V)[idx])
      z    <- beta / se
      pval <- 2 * pnorm(abs(z), lower.tail = FALSE)
  
      tibble::tibble(
        Outcome = outcome,
        term    = terms_names,
        beta    = beta,
        se      = se,
        z       = z,
        p_value = pval,
        OR      = exp(beta),
        lwr     = exp(beta - 1.96 * se),
        upr     = exp(beta + 1.96 * se)
      )
    })
  
    tab <- dplyr::bind_rows(res_list) %>%
      dplyr::mutate(
        Predictor = dplyr::case_when(
          stringr::str_starts(term, "time_period")   ~ "Time period",
          stringr::str_starts(term, "PresentStatus") ~ "Present Status",
          stringr::str_starts(term, "LifeForm")      ~ "LifeForm",
          TRUE                                       ~ term
        ),
        Contrast = dplyr::case_when(
          stringr::str_starts(term, "time_period")   ~ sub("^time_period", "", term),
          stringr::str_starts(term, "PresentStatus") ~ sub("^PresentStatus", "", term),
          stringr::str_starts(term, "LifeForm")      ~ sub("^LifeForm", "", term),
          TRUE                                       ~ term
        ),
        Contrast = stringr::str_trim(Contrast)
      )
  
    ref_levels <- list(
      "Time period"    = "Post-Introduction",
      "Present Status" = "present",
      "LifeForm"       = "Herptiles"
    )
  
    tab <- tab %>% dplyr::arrange(Outcome, Predictor, Contrast)
  
    tab_out <- tab %>%
      dplyr::group_by(Outcome) %>%
      dplyr::group_modify(function(d, key){
        preds <- c("Time period","Present Status","LifeForm")
        blocks <- list()
        for (pred in preds) {
          d_pred <- dplyr::filter(d, Predictor == pred)
          if (!nrow(d_pred)) next
          ref_row <- tibble::tibble(
            Outcome = unique(d$Outcome),
            Predictor = pred,
            Contrast  = paste0(ref_levels[[pred]], " (ref.)"),
            beta=NA_real_, se=NA_real_, z=NA_real_, p_value=NA_real_,
            OR=NA_real_, lwr=NA_real_, upr=NA_real_
          )
          blocks[[pred]] <- dplyr::bind_rows(ref_row, d_pred)
        }
        dplyr::bind_rows(blocks)
      }) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        `Adj. OR (95% CI)` = mapply(fmt_or_ci, OR, lwr, upr,
                                    MoreArgs = list(digits_or = digits_or, max_or = max_or)),
        P = dplyr::if_else(
          is.na(p_value), "-",
          dplyr::if_else(p_value < .001, "<0.001", sprintf("%.3f", p_value))
        )
      ) %>%
      dplyr::select(Outcome, Predictor, Contrast, `Adj. OR (95% CI)`, P)
  
    tab_out
  }
  
  # ============================================================
  # 12) FIGURE BUILDING HELPERS (icons + panels) [your code intact]
  # ============================================================
  
  add_x_icons_bars_bottom <- function(p, pred_A, icon_paths,
                                      icon_width_x    = 1.15,
                                      icon_height_rel = 0.40,
                                      gap_rel         = 0.085,
                                      bottom_margin_pts = 70) {
  
    x_levels <- levels(pred_A$LifeForm)
    bottom_level <- tail(levels(pred_A$time_period_plot), 1)
  
    df_icons <- data.frame(
      time_period_plot = factor(bottom_level, levels = levels(pred_A$time_period_plot)),
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
      theme(plot.margin = margin(t = 6, r = 6, b = bottom_margin_pts, l = 6))
  }
  
  add_x_icons_delta_outside <- function(p, pred_C, icon_paths,
                                        icon_width_x     = 0.85,
                                        icon_height_frac = 0.20,
                                        gap_frac         = 0.085,
                                        bottom_margin_pts = 70) {
  
    x_levels <- levels(pred_C$LifeForm)
    x_idx    <- seq_along(x_levels)
    y_max <- max(pred_C$delta, 0, na.rm = TRUE)
    y_min <- min(pred_C$delta, 0, na.rm = TRUE)
    yrng  <- max(1e-6, y_max - y_min)
    y_icon <- y_min - gap_frac*yrng - (icon_height_frac*yrng)/2
  
    df_icons <- data.frame(
      LifeForm = factor(x_levels, levels = x_levels),
      x        = x_idx,
      y        = y_icon,
      image    = unname(icon_paths[x_levels]),
      stringsAsFactors = FALSE
    )
  
    size_x <- icon_width_x / length(x_levels)
    size_y <- icon_height_frac
    size   <- max(size_x, size_y)
  
    p +
      ggimage::geom_image(
        data = df_icons,
        aes(x = x, y = y, image = image),
        inherit.aes = FALSE,
        size = size
      ) +
      coord_cartesian(ylim = c(y_min, y_max), clip = "off") +
      theme(plot.margin = margin(t = 6, r = 6, b = bottom_margin_pts, l = 6))
  }
  
  add_x_icons_heatmap_bottom <- function(p, pred_heat, icon_paths,
                                         icon_width_x   = 0.75,
                                         icon_height_y  = 0.35,
                                         gap_below      = 0.15,
                                         bottom_margin_pts = 60) {
  
    x_levels <- levels(pred_heat$LifeForm)
    n_rows   <- length(levels(pred_heat$KeywordCategory))
    bottom_level <- tail(levels(pred_heat$time_period_plot), 1)
  
    df_icons <- data.frame(
      time_period_plot = factor(bottom_level, levels = levels(pred_heat$time_period_plot)),
      LifeForm    = factor(x_levels, levels = x_levels),
      x           = seq_along(x_levels),
      y           = 0.5 - gap_below - icon_height_y/2,
      image       = unname(icon_paths[x_levels]),
      stringsAsFactors = FALSE
    )
  
    size_x <- icon_width_x / length(x_levels)
    size_y <- icon_height_y / n_rows
    size   <- max(size_x, size_y)
  
    p +
      ggimage::geom_image(
        data = df_icons,
        aes(x = x, y = y, image = image),
        inherit.aes = FALSE,
        size = size
      ) +
      coord_cartesian(ylim = c(0.5, n_rows + 0.5), clip = "off") +
      theme(plot.margin = margin(t = 2, r = 6, b = bottom_margin_pts, l = 6))
  }
  
  `%||%` <- function(a, b) if (!is.null(a)) a else b
  
  get_legend_safe <- function(p) {
    leg <- cowplot::get_legend(p)
    if (is.null(leg)) grid::nullGrob() else leg
  }
  
  draw_key_rectline <- function(data, params, size) {
    grid::grobTree(
      grid::rectGrob(
        x = 0.5, y = 0.5, width = 1, height = 0.65,
        gp = grid::gpar(col = NA, fill = data$fill %||% "grey90", alpha = 1)
      ),
      grid::segmentsGrob(
        x0 = 0.10, x1 = 0.90, y0 = 0.5, y1 = 0.5,
        gp = grid::gpar(
          col = data$colour %||% "black",
          lwd = (data$linewidth %||% 1) * size,
          lty = data$linetype %||% 1
        )
      )
    )
  }
  
  # ============================================================
  # 13) RENDER VARIANT: build Figure 4 + S3 + S6 (and Table 4) per model
  # ============================================================
  render_variant_ALL <- function(variant_label, m_pred, m_pred_ci,
                                 df_ALL, kw_ALL,
                                 dir_plots_base = dir_plots_ALL,
                                 dir_tables_base = dir_tables_ALL) {
  
    dir_plots_variant  <- file.path(dir_plots_base,  paste0("VARIANT_", variant_label))
    dir_tables_variant <- file.path(dir_tables_base, paste0("VARIANT_", variant_label))
    dir.create(dir_plots_variant,  recursive = TRUE, showWarnings = FALSE)
    dir.create(dir_tables_variant, recursive = TRUE, showWarnings = FALSE)
  
    cat("\n==============================\n")
    cat("RENDER VARIANT:", variant_label, "\n")
    cat("Model:", deparse(formula(m_pred)), "\n")
    cat("==============================\n")
  
    # ============================================================
    # 10) PREDICTIONS FOR PANELS A/B/C (ALL) - uses m_pred/m_pred_ci
    # ============================================================
    nd_A_ALL <- expand.grid(
      LifeForm      = levels(df_ALL$LifeForm),
      time_period   = levels(df_ALL$time_period),
      PresentStatus = levels(df_ALL$PresentStatus)[1],
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    for (v in names(nd_A_ALL)) {
      if (is.factor(df_ALL[[v]])) {
        nd_A_ALL[[v]] <- factor(nd_A_ALL[[v]], levels = levels(df_ALL[[v]]))
      }
    }
  
    probs_A_ALL <- as.data.frame(predict(m_pred, newdata = nd_A_ALL, type = "probs"))
    resp_levels_ALL <- levels(model.frame(m_pred)[[1]])
    keepK_ALL <- intersect(resp_levels_ALL, colnames(probs_A_ALL))
  
    pred_mean_A_ALL <- bind_cols(nd_A_ALL, probs_A_ALL[, keepK_ALL, drop = FALSE]) |>
      pivot_longer(all_of(keepK_ALL), names_to = "KeywordCategory", values_to = "fit") |>
      mutate(KeywordCategory = factor(KeywordCategory, levels = kw_levels))
  
    pred_Aci_ALL <- try(
      simulate_probs_ci_safe(m_pred_ci, nd_A_ALL, R = 800) |>
        rename(KeywordCategory = Class) |>
        mutate(KeywordCategory = factor(KeywordCategory, levels = kw_levels)),
      silent = TRUE
    )
    if (inherits(pred_Aci_ALL, "try-error")) pred_Aci_ALL <- NULL
  
    pred_A_ALL <- if (!is.null(pred_Aci_ALL)) {
      pred_mean_A_ALL |>
        left_join(
          pred_Aci_ALL |>
            dplyr::select(LifeForm, time_period, PresentStatus, KeywordCategory, lwr, upr),
          by = c("LifeForm","time_period","PresentStatus","KeywordCategory")
        )
    } else {
      pred_mean_A_ALL |>
        mutate(lwr = NA_real_, upr = NA_real_)
    }
  
    present_levels_A_ALL <- desired_lf_order[desired_lf_order %in% levels(pred_A_ALL$LifeForm)]
    pred_A_ALL <- pred_A_ALL %>%
      mutate(
        LifeForm = factor(LifeForm, levels = present_levels_A_ALL),
        time_period_plot = factor(as.character(time_period),
                                  levels = c("Pre-Introduction","Post-Introduction"))
      )
  
    # ============================================================
    # 11) PLOT A - Probabilities (bars) + icons (ALL)
    # ============================================================
    dodge <- position_dodge(width = 0.8)
  
    p_A_base_ALL <- ggplot(pred_A_ALL, aes(x = LifeForm, y = fit)) +
      geom_col(aes(fill = KeywordCategory, group = KeywordCategory),
               position = dodge, width = 0.8) +
      geom_errorbar(
        data = subset(pred_A_ALL, !is.na(lwr) & !is.na(upr)),
        aes(ymin = lwr, ymax = upr, group = KeywordCategory),
        position = dodge, width = 0.25, colour = "grey20"
      ) +
      scale_fill_manual(values = kw_cols_ALL, guide = "none") +
      labs(x = NULL, y = "Predicted probability") +
      theme_inat(16) +
      facet_wrap(~ time_period_plot, ncol = 1, strip.position = "right") +
      theme(
        strip.background   = element_rect(fill = NA, colour = NA),
        strip.text.y.right = element_text(face = "plain", colour = "black",
                                          margin = margin(l = 3), size = AXIS_TEXT_SIZE),
        strip.placement    = "inside",
        axis.text.x        = element_blank(),
        axis.ticks.x       = element_blank(),
        axis.title.y       = element_text(margin = margin(r = 18)),
        plot.margin        = margin(t = 6, r = 6, b = 6, l = 6)
      ) +
      scale_x_discrete(expand = c(0, 0))
  
    p_A_ALL <- add_x_icons_bars_bottom(p_A_base_ALL, pred_A_ALL, icon_paths)
    p_A_export_ALL <- p_A_ALL + scale_fill_manual(values = kw_cols_ALL, name = "Keyword category")
  
    # ============================================================
    # 12) PLOT C - Delta (Post - Pre) (ALL)
    # ============================================================
    pred_source_for_C <- if (!is.null(pred_Aci_ALL)) {
      pred_Aci_ALL %>% dplyr::select(LifeForm, time_period, KeywordCategory, fit)
    } else {
      pred_mean_A_ALL %>% dplyr::select(LifeForm, time_period, KeywordCategory, fit)
    }
  
    pred_C_ALL <- pred_source_for_C %>%
      pivot_wider(names_from = time_period, values_from = fit) %>%
      mutate(delta = `Post-Introduction` - `Pre-Introduction`)
  
    present_levels_C_ALL <- desired_lf_order[desired_lf_order %in% levels(pred_C_ALL$LifeForm)]
    pred_C_ALL <- pred_C_ALL %>% mutate(LifeForm = factor(LifeForm, levels = present_levels_C_ALL))
  
    offset_map_ALL <- c(Invasion = -0.33, Detection = -0.11, eCommerce = 0.11, Threat = 0.33)
    n_lf_ALL <- nlevels(pred_C_ALL$LifeForm)
  
    pred_C_ALL <- pred_C_ALL %>%
      mutate(
        x_idx = as.numeric(LifeForm),
        x_pos = x_idx + unname(offset_map_ALL[as.character(KeywordCategory)])
      )
  
    p_C_ALL <- ggplot(pred_C_ALL, aes(colour = KeywordCategory)) +
      geom_hline(yintercept = 0, linetype = 2) +
      geom_segment(aes(x = x_pos, xend = x_pos, y = 0, yend = delta), linewidth = 0.9) +
      geom_point(aes(x = x_pos, y = delta), size = 2.6) +
      scale_colour_manual(values = kw_cols_ALL, name = "Keyword category") +
      labs(x = NULL, y = expression(Delta~" probability (Post - Pre)")) +
      scale_x_continuous(
        limits = c(0.5, n_lf_ALL + 0.5),
        breaks = 1:n_lf_ALL, labels = levels(pred_C_ALL$LifeForm),
        expand = expansion(mult = c(0, 0))
      ) +
      theme_light(base_size = 11) +
      theme(
        axis.text.x        = element_blank(),
        axis.ticks.x       = element_blank(),
        axis.title.y       = element_text(size = AXIS_TITLE_SIZE, margin = margin(r = 18)),
        axis.text.y        = element_text(size = AXIS_TEXT_SIZE),
        legend.text        = element_text(size = LEG_TEXT_SIZE),
        plot.margin        = margin(t = 6, r = 6, b = 6, l = 6)
      )
  
    p_C_ALL <- add_x_icons_delta_outside(p_C_ALL, pred_C_ALL, icon_paths)
  
    # ============================================================
    # 13) PLOT B - Heatmap (ALL)
    # ============================================================
    tint_to_white <- function(hex, t, min_int = 0.10, max_int = 1.0){
      s <- min_int + (max_int - min_int) * pmin(pmax(t, 0), 1)
      b <- grDevices::col2rgb(hex) / 255
      out <- 1 - (1 - b) * s
      grDevices::rgb(out[1], out[2], out[3])
    }
  
    probs_mat_ALL <- as.data.frame(predict(m_pred, newdata = nd_A_ALL, type = "probs"))
    keep_cols_ALL <- intersect(resp_levels_ALL, colnames(probs_mat_ALL))
    stopifnot(length(keep_cols_ALL) > 0)
  
    pred_heat_ALL <- bind_cols(nd_A_ALL, probs_mat_ALL[, keep_cols_ALL, drop = FALSE]) %>%
      pivot_longer(all_of(keep_cols_ALL),
                   names_to="KeywordCategory", values_to="fit") %>%
      mutate(
        KeywordCategory = factor(KeywordCategory, levels = kw_levels),
        LifeForm = factor(LifeForm, levels = levels(df_ALL$LifeForm))
      ) %>%
      mutate(
        base_hex = unname(kw_cols_ALL[as.character(KeywordCategory)]),
        fill_col = mapply(tint_to_white, base_hex, fit)
      )
  
    present_levels_B_ALL <- desired_lf_order[desired_lf_order %in% levels(pred_heat_ALL$LifeForm)]
    pred_heat_ALL <- pred_heat_ALL %>%
      mutate(
        LifeForm = factor(LifeForm, levels = present_levels_B_ALL),
        time_period_plot = factor(as.character(time_period),
                                  levels = c("Pre-Introduction","Post-Introduction"))
      )
  
    anchor_x_ALL <- levels(pred_heat_ALL$LifeForm)[1]
    anchor_y_ALL <- levels(pred_heat_ALL$KeywordCategory)[1]
  
    p_B_base_ALL <- ggplot(pred_heat_ALL, aes(x = LifeForm, y = KeywordCategory)) +
      geom_tile(aes(fill = fill_col), width = 1, height = 1) +
      scale_fill_identity(guide = "none") +
      geom_text(aes(label = sprintf("%.2f", fit)), size = 4.5, colour = "black") +
      facet_wrap(~ time_period_plot, ncol = 1, strip.position = "right") +
      ggnewscale::new_scale_fill() +
      geom_point(
        data = data.frame(
          fit = seq(0, 1, length.out = 100),
          LifeForm = factor(anchor_x_ALL, levels = levels(pred_heat_ALL$LifeForm)),
          KeywordCategory = factor(anchor_y_ALL, levels = levels(pred_heat_ALL$KeywordCategory))
        ),
        aes(x = LifeForm, y = KeywordCategory, fill = fit),
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
          title.theme = element_text(margin = margin(b = 20), size = LEG_TITLE_SIZE),
          label.theme = element_text(margin = margin(l = 6), size = LEG_TEXT_SIZE)
        )
      ) +
      labs(x = NULL, y = NULL) +
      theme_light(base_size = 11) +
      theme(
        strip.background   = element_rect(fill = NA, colour = NA),
        strip.text.y.right = element_text(face = "plain", colour = "black", margin = margin(l = 3), size = AXIS_TEXT_SIZE),
        strip.placement    = "inside",
        axis.text.x        = element_blank(),
        axis.ticks.x       = element_blank(),
        axis.text.y        = element_blank(),
        panel.grid         = element_blank(),
        axis.ticks         = element_blank(),
        panel.spacing.y    = unit(0, "pt"),
        legend.title       = element_text(size = LEG_TITLE_SIZE),
        legend.text        = element_text(size = LEG_TEXT_SIZE),
        legend.box.spacing = unit(10, "pt"),
        plot.margin        = margin(t = 2, r = 6, b = 2, l = 8)
      ) +
      scale_x_discrete(expand = c(0, 0)) +
      scale_y_discrete(expand = c(0, 0))
  
    p_B_noicons_ALL <- p_B_base_ALL +
      labs(y = "Keywords proportion") +
      theme(
        axis.title.y = element_text(colour = "white", size = AXIS_TITLE_SIZE, margin = margin(r = 12)),
        axis.text.y  = element_text(colour = "white"),
        axis.ticks.y = element_blank()
      )
  
    p_B_ALL <- add_x_icons_heatmap_bottom(
      p_B_noicons_ALL, pred_heat_ALL, icon_paths,
      icon_width_x      = 1.12,
      icon_height_y     = 0.95,
      gap_below         = 0.002,
      bottom_margin_pts = 60
    )
  
    # ============================================================
    # 14) PLOT D - GAM trends (ALL) (your plot, unchanged)
    # ============================================================
    fmt_axis_ALL <- function(x) sub("([.]0+)$", "", format(x, trim = TRUE, nsmall = 1,
                                                          digits = 12, scientific = FALSE))
  
    kw_rel_ALL <- kw_ALL %>%
      mutate(
        created_at = .to_posix_utc(created_at),
        FirstRecordDate = .to_posix_utc(FirstRecordDate),
        rel_year_cont = as.numeric(difftime(created_at, FirstRecordDate, units = "days"))/365.25,
        year_bin      = floor(rel_year_cont),
        KeywordCategory = factor(KeywordCategory, levels = kw_levels)
      ) %>%
      filter(is.finite(year_bin))
  
    win_lo_ALL <- -5
    win_hi_ALL <- 10
  
    df_sum_ALL <- kw_rel_ALL %>%
      filter(year_bin >= win_lo_ALL, year_bin <= win_hi_ALL) %>%
      count(year_bin, KeywordCategory, name = "n_kw") %>%
      group_by(year_bin) %>%
      mutate(n_tot = sum(n_kw), prop = n_kw / pmax(n_tot, 1)) %>%
      ungroup() %>%
      mutate(strip_pad = factor("Pre-Introduction", levels = "Pre-Introduction"))
  
    ribbon_cols_ALL <- scales::alpha(kw_cols_ALL, 0.25)
  
    p_D_ALL <- ggplot(
      df_sum_ALL,
      aes(x = year_bin, y = prop, colour = KeywordCategory)
    ) +
      geom_point(aes(size = n_tot), alpha = 0.35, show.legend = FALSE) +
      stat_smooth(
        method = "gam", formula = y ~ s(x, k = 5),
        method.args = list(family = quasibinomial(link = "logit")),
        aes(weight = n_tot, fill = KeywordCategory),
        se = TRUE,
        linewidth = 2.2, alpha = 0.22
      ) +
      geom_vline(xintercept = 0, colour = "black", linetype = "dashed", linewidth = 0.3) +
      scale_x_continuous(
        limits = c(win_lo_ALL, win_hi_ALL),
        expand = c(0, 0),
        breaks = c(-3, 0, 3, 6, 9),
        labels = fmt_axis_ALL
      ) +
      scale_colour_manual(values = kw_cols_ALL, name = "Keyword category") +
      scale_fill_manual(values = ribbon_cols_ALL, guide = "none") +
      scale_size_continuous(range = c(1.5, 4), guide = "none") +
      labs(x = "Years from first Iberian record (Post-Intro, > 0)", y = "Keywords proportion") +
      facet_wrap(~ strip_pad, ncol = 1, strip.position = "right") +
      theme_light(base_size = 11) +
      theme(
        strip.background   = element_rect(fill = NA, colour = NA),
        strip.text.y.right = element_text(colour = "white", margin = margin(l = 24, r = 6), size = AXIS_TEXT_SIZE),
        axis.text.y        = element_text(size = AXIS_TEXT_SIZE),
        axis.text.x        = element_text(size = AXIS_TEXT_SIZE),
        axis.title.x       = element_text(margin = margin(t = 14), size = AXIS_TITLE_SIZE),
        axis.title.y       = element_text(margin = margin(r = 18), size = AXIS_TITLE_SIZE),
        legend.text        = element_text(size = LEG_TEXT_SIZE),
        plot.margin        = margin(t = 18, r = 6, b = 6, l = 6),
        legend.position    = "top",
        legend.direction   = "horizontal"
      ) +
      guides(colour = guide_legend(nrow = 1, title = "Keyword category"))
  
    # ============================================================
    # 15) EXPORT SINGLES (variant-specific filenames)
    # ============================================================
    ggsave(file.path(dir_plots_variant, paste0("Figure4_A_single_ALL_", variant_label, ".png")),
           p_A_export_ALL, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
    ggsave(file.path(dir_plots_variant, paste0("Figure4_B_single_ALL_", variant_label, ".png")),
           p_B_ALL, width = 240, height = 160, units = "mm", dpi = 300, bg = "white")
    ggsave(file.path(dir_plots_variant, paste0("Figure4_C_single_ALL_", variant_label, ".png")),
           p_C_ALL, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
    ggsave(file.path(dir_plots_variant, paste0("Figure4_D_single_ALL_", variant_label, ".png")),
           p_D_ALL, width = 225, height = 150, units = "mm", dpi = 300, bg = "white")
  
    # S3: A = heatmap no-icons; B = delta
    ggsave(file.path(dir_plots_variant, paste0("FigureS3_A_single_ALL_", variant_label, ".png")),
           p_B_noicons_ALL, width = 240, height = 160, units = "mm", dpi = 300, bg = "white")
    ggsave(file.path(dir_plots_variant, paste0("FigureS3_B_single_ALL_", variant_label, ".png")),
           p_C_ALL, width = 260, height = 180, units = "mm", dpi = 300, bg = "white")
  
    # ============================================================
    # 16) PANEL COMPOSITION (Figure 4, S3, S6) - same structure
    # ============================================================
    tag_style_ALL <- theme(
      plot.tag.position = c(0.00, 1.00),
      plot.tag = element_text(size = TAG_SIZE, face = "plain")
    )
  
    spacer_plot_ALL <- ggplot() + theme_void()
    LEGEND_COL_RELWIDTH <- 0.25
    SPACER_RELHEIGHT    <- 0.08
    LEFT_PAD  <- 0.025
    RIGHT_PAD <- 0.03
  
    legend_cols_ALL <- base_cols[c("Invasion","Detection","eCommerce","Threat")]
    legend_fill_vals_ALL <- scales::alpha(unname(legend_cols_ALL), 0.22)
  
    legend_D_plot_ALL <- ggplot(
      data.frame(
        KeywordCategory = factor(names(legend_cols_ALL), levels = names(legend_cols_ALL)),
        x = 1
      ),
      aes(x = x, y = x, fill = KeywordCategory, colour = KeywordCategory)
    ) +
      geom_tile(show.legend = TRUE, key_glyph = draw_key_rectline) +
      scale_fill_manual(values = legend_cols_ALL, name = "Keyword category") +
      scale_colour_manual(values = legend_cols_ALL, guide = "none") +
      theme_void() +
      theme(
        legend.position   = "right",
        legend.direction  = "vertical",
        legend.key        = element_rect(fill = "white", colour = NA),
        legend.title      = element_text(size = LEG_TITLE_SIZE),
        legend.text       = element_text(size = LEG_TEXT_SIZE)
      ) +
      guides(
        fill = guide_legend(
          title = "Keyword category",
          title.position = "top",
          title.hjust = 0,
          override.aes = list(
            fill      = legend_fill_vals_ALL,
            colour    = unname(legend_cols_ALL),
            linewidth = 1.2,
            linetype  = 1,
            alpha     = 1
          ),
          keyheight   = unit(22, "pt"),
          label.theme = element_text(margin = margin(t = 0, b = 6)),
          title.theme = element_text(margin = margin(b = 12))
        )
      )
  
    leg_D_ALL <- get_legend_safe(legend_D_plot_ALL)
  
    # ---- Figure 4 panel: TOP=D, BOTTOM=A ----
    p_D_panel_A_ALL <- (p_D_ALL + labs(tag = "A)") + tag_style_ALL) + theme(legend.position = "none")
    p_A_panel_B_ALL <- (p_A_export_ALL + labs(tag = "B)") + tag_style_ALL)
  
    p_A_for_leg_ALL <- p_A_panel_B_ALL +
      theme(
        legend.position    = "right",
        legend.direction   = "vertical",
        legend.title       = element_text(size = LEG_TITLE_SIZE, margin = margin(b = 10)),
        legend.text        = element_text(size = LEG_TEXT_SIZE),
        legend.spacing.y   = unit(25, "pt"),
        legend.key.height  = unit(20, "pt")
      ) +
      guides(fill = guide_legend(title = "Keyword category", title.position = "top", title.hjust = 0))
  
    leg_A_ALL <- get_legend_safe(p_A_for_leg_ALL)
    p_A_plot_ALL <- p_A_for_leg_ALL + theme(legend.position = "none")
  
    plots_Figure_4_left_ALL <- cowplot::plot_grid(
      p_D_panel_A_ALL,
      spacer_plot_ALL,
      p_A_plot_ALL,
      ncol = 1,
      rel_heights = c(1, SPACER_RELHEIGHT, 1),
      align = "v",
      axis  = "lr"
    )
  
    legs_Figure_4_right_ALL <- cowplot::plot_grid(
      leg_D_ALL,
      spacer_plot_ALL,
      leg_A_ALL,
      ncol = 1,
      rel_heights = c(1, SPACER_RELHEIGHT, 1),
      align = "v",
      axis  = "lr"
    )
  
    panel_Figure_4_core_ALL <- cowplot::plot_grid(
      plots_Figure_4_left_ALL,
      legs_Figure_4_right_ALL,
      ncol = 2,
      rel_widths = c(1, LEGEND_COL_RELWIDTH),
      align = "h",
      axis  = "tb"
    )
  
    panel_Figure_4_ALL <- cowplot::ggdraw() +
      cowplot::draw_plot(panel_Figure_4_core_ALL,
                         x = LEFT_PAD, y = 0,
                         width = 1 - LEFT_PAD - RIGHT_PAD, height = 1)
  
    ggsave(file.path(dir_plots_variant, paste0("Figure4_panel_ONECOL_TWOROWS_separate_legends_ALL_", variant_label, ".png")),
           panel_Figure_4_ALL, width = 350, height = 280, units = "mm", dpi = 300, bg = "white")
  
    # ---- Figure S3 panel: TOP=heatmap(no icons), BOTTOM=delta ----
    p_B_panel_A_ALL <- (p_B_noicons_ALL + labs(tag = "A)") + tag_style_ALL)
    p_C_panel_B_ALL <- (p_C_ALL + labs(tag = "B)") + tag_style_ALL)
  
    leg_B_ALL <- get_legend_safe(p_B_panel_A_ALL + theme(legend.position = "right", legend.direction = "vertical"))
    p_B_plot2_ALL <- p_B_panel_A_ALL + theme(legend.position = "none")
  
    leg_C_ALL <- get_legend_safe(p_C_panel_B_ALL + theme(legend.position = "right", legend.direction = "vertical"))
    p_C_plot2_ALL <- p_C_panel_B_ALL + theme(legend.position = "none")
  
    plots_S3_left_ALL <- cowplot::plot_grid(
      p_B_plot2_ALL,
      spacer_plot_ALL,
      p_C_plot2_ALL,
      ncol = 1,
      rel_heights = c(1, SPACER_RELHEIGHT, 1),
      align = "v",
      axis  = "lr"
    )
  
    legs_S3_right_ALL <- cowplot::plot_grid(
      leg_B_ALL,
      spacer_plot_ALL,
      leg_C_ALL,
      ncol = 1,
      rel_heights = c(1, SPACER_RELHEIGHT, 1),
      align = "v",
      axis  = "lr"
    )
  
    panel_S3_core_ALL <- cowplot::plot_grid(
      plots_S3_left_ALL,
      legs_S3_right_ALL,
      ncol = 2,
      rel_widths = c(1, LEGEND_COL_RELWIDTH),
      align = "h",
      axis  = "tb"
    )
  
    panel_Figure_S3_ALL <- cowplot::ggdraw() +
      cowplot::draw_plot(panel_S3_core_ALL,
                         x = LEFT_PAD, y = 0,
                         width = 1 - LEFT_PAD - RIGHT_PAD, height = 0.98)
  
    ggsave(file.path(dir_plots_variant, paste0("FigureS3_panel_ONECOL_TWOROWS_separate_legends_ALL_", variant_label, ".png")),
           panel_Figure_S3_ALL, width = 350, height = 280, units = "mm", dpi = 300, bg = "white")
  
    # ---- Figure S6 panel: A=delta, B=trends ----
    p_S6_A <- (p_C_ALL + labs(tag = "A)") + tag_style_ALL)
    p_S6_B <- (p_D_ALL + labs(tag = "B)") + tag_style_ALL)
  
    leg_S6_A <- get_legend_safe(p_S6_A + theme(legend.position = "right"))
    p_S6_A0  <- p_S6_A + theme(legend.position = "none")
  
    leg_S6_B <- leg_D_ALL
    p_S6_B0  <- p_S6_B + theme(legend.position = "none")
  
    plots_S6_left <- cowplot::plot_grid(
      p_S6_A0, spacer_plot_ALL, p_S6_B0,
      ncol = 1, rel_heights = c(1, SPACER_RELHEIGHT, 1),
      align = "v", axis = "lr"
    )
  
    legs_S6_right <- cowplot::plot_grid(
      leg_S6_A, spacer_plot_ALL, leg_S6_B,
      ncol = 1, rel_heights = c(1, SPACER_RELHEIGHT, 1),
      align = "v", axis = "lr"
    )
  
    panel_S6_core <- cowplot::plot_grid(
      plots_S6_left,
      legs_S6_right,
      ncol = 2,
      rel_widths = c(1, LEGEND_COL_RELWIDTH),
      align = "h",
      axis  = "tb"
    )
  
    panel_Figure_S6_ALL <- cowplot::ggdraw() +
      cowplot::draw_plot(panel_S6_core,
                         x = LEFT_PAD, y = 0,
                         width = 1 - LEFT_PAD - RIGHT_PAD, height = 1)
  
    ggsave(file.path(dir_plots_variant, paste0("FigureS6_panel_AB_separate_legends_ALL_", variant_label, ".png")),
           panel_Figure_S6_ALL, width = 350, height = 280, units = "mm", dpi = 300, bg = "white")
  
    # ============================================================
    # 17) GAM trend stats export (CSV) - ALL (your block)
    # ============================================================
    gam_fits_ALL <- df_sum_ALL %>%
      group_split(KeywordCategory) %>%
      setNames(unique(df_sum_ALL$KeywordCategory)) %>%
      lapply(function(d) {
        gam(prop ~ s(year_bin, k = 5),
            family = quasibinomial(link = "logit"),
            weights = n_tot,
            method = "REML",
            data = d)
      })
  
    gam_summary_ALL <- lapply(names(gam_fits_ALL), function(cat) {
      s <- summary(gam_fits_ALL[[cat]])
      data.frame(
        KeywordCategory = cat,
        edf      = round(s$s.table[1, "edf"], 2),
        F_value  = round(s$s.table[1, "F"], 2),
        p_value  = signif(s$s.table[1, "p-value"], 3)
      )
    }) %>% bind_rows()
  
    write.csv(gam_summary_ALL,
              file.path(TAB_QA_DIR, paste0("GAM_keyword_trends_summary_ALL_", variant_label, ".csv")),
              row.names = FALSE)
  
    # ============================================================
    # 18) MULTINOMIAL RESULTS TABLE + Table 4 (wide) - PER VARIANT
    # ============================================================
    multi_tab_ALL <- tidy_multinom_or(m_pred_ci)
  
    null_mod_ALL <- nnet::multinom(KeywordCategory ~ 1, data = df_ALL, trace = FALSE, Hess = TRUE)
    AIC_val_ALL  <- AIC(m_pred)
    R2_mcF_ALL   <- 1 - as.numeric(logLik(m_pred)) / as.numeric(logLik(null_mod_ALL))
  
    export_table_all(
      multi_tab_ALL,
      out_dir = TAB_QA_DIR,
      stem = paste0("Multinomial_results_table_ALL_", variant_label),
      caption = sprintf("Multinomial results (ALL) - %s. AIC: %.4f | McFadden R^2: %.4f",
                        variant_label, AIC_val_ALL, R2_mcF_ALL),
      doc_heading_style = "heading 1",
      doc_fontsize = 9
    )
  
    table4_wide_ALL <- multi_tab_ALL %>%
      mutate(
        cell = if_else(
          `Adj. OR (95% CI)` == "-" | P == "-",
          "-",
          paste0(`Adj. OR (95% CI)`, " (P=", P, ")")
        )
      ) %>%
      dplyr::select(Predictor, Contrast, Outcome, cell) %>%
      tidyr::pivot_wider(names_from = Outcome, values_from = cell, values_fill = "")
  
    want_cols <- c("Detection","eCommerce","Threat")
    have_cols <- intersect(want_cols, names(table4_wide_ALL))
    table4_wide_ALL <- table4_wide_ALL %>% dplyr::select(Predictor, Contrast, all_of(have_cols))
  
    export_table_all(
      table4_wide_ALL,
      out_dir = TAB_QA_DIR,
      stem = paste0("Table3_multinom_wide_ALL_", variant_label),
      caption = paste0("Table 3. Multinomial model results (Invasion as reference outcome) - ALL tokens (", variant_label, ")."),
      doc_heading_style = "heading 1",
      doc_fontsize = 9
    )
  
    invisible(list(plots_dir = dir_plots_variant, tables_dir = dir_tables_variant))
  }
  
  # ============================================================
  # 14) RUN BOTH REQUIRED VARIANTS
  # ============================================================
  
  # BEST: best unweighted stepAIC model (can drop time_period)
  res_best <- render_variant_ALL(
    variant_label = "BEST_UNW_STEP",
    m_pred = m_best_unw_ALL,
    m_pred_ci = m_best_unw_ci_ALL,
    df_ALL = df_ALL,
    kw_ALL = kw_ALL
  )
  
  # FORCED: best unweighted stepAIC model with time_period forced in
  res_forced <- render_variant_ALL(
    variant_label = "FORCED_UNW_STEP_TIME",
    m_pred = m_forced_unw_ALL,
    m_pred_ci = m_forced_unw_ci_ALL,
    df_ALL = df_ALL,
    kw_ALL = kw_ALL
  )
  
  cat("\n=== DONE (ALL) ===\n")
  cat("Base figures dir: ", dir_plots_ALL, "\n")
  cat("Base tables  dir: ", dir_tables_ALL, "\n")
  cat("Variant BEST plots:   ", res_best$plots_dir, "\n")
  cat("Variant FORCED plots: ", res_forced$plots_dir, "\n")
  cat("Variant BEST tables:  ", res_best$tables_dir, "\n")
  cat("Variant FORCED tables:", res_forced$tables_dir, "\n")
}


# ---- FINAL DIRECT EXPORT NAME ----------------------------------------------
if (exists("ANALYSIS_MODE") && ANALYSIS_MODE == "COMMENTS_ONLY") {
  # Keep comments-only sensitivity outputs in the dedicated sensitivity folder.
  # They are not exported to the Supplementary figures directory in the public release.
} else {
  for (ext in c(".png", ".tiff")) {
    src4 <- file.path(FIG_MAIN_DIR, paste0("models_multinom/Figure4_panel_Figure_4_ONECOL_TWOROWS_separate_legends_NO_COMMENTS", ext))
    if (!file.exists(src4)) src4 <- file.path(FIG_MAIN_DIR, paste0("Figure4_panel_Figure_4_ONECOL_TWOROWS_separate_legends_NO_COMMENTS", ext))
    dst4 <- file.path(FIG_MAIN_DIR, paste0("Figure_4", ext))
    if (file.exists(src4)) file.copy(src4, dst4, overwrite = TRUE)

    srcs3 <- file.path(FIG_MAIN_DIR, paste0("models_multinom/FigureS3_ONECOL_TWOROWS_shared_icons_separate_legends_NO_COMMENTS", ext))
    if (!file.exists(srcs3)) srcs3 <- file.path(FIG_MAIN_DIR, paste0("FigureS3_ONECOL_TWOROWS_shared_icons_separate_legends_NO_COMMENTS", ext))
    dsts3 <- file.path(FIG_SUPP_DIR, paste0("Figure_S4", ext))
    if (file.exists(srcs3)) file.copy(srcs3, dsts3, overwrite = TRUE)

    # The model-sensitivity figure is retained as an internal diagnostic output
    # and is not copied to the Supplementary figures directory.
  }
  # remove leftover model figure variants from main folder/model subfolder
  if (dir.exists(file.path(FIG_MAIN_DIR, "models_multinom"))) unlink(file.path(FIG_MAIN_DIR, "models_multinom"), recursive = TRUE, force = TRUE)
  keep_main <- file.path(FIG_MAIN_DIR, c("Figure_1.png","Figure_1.tiff","Figure_2.png","Figure_2.tiff",
                                         "Figure_3.png","Figure_3.tiff","Figure_4.png","Figure_4.tiff"))
  unlink(setdiff(list.files(FIG_MAIN_DIR, pattern = "^Figure4|^FigureS|^Figure_4_", full.names = TRUE), keep_main), force = TRUE)
}
