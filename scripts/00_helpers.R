# ============================================================
# 00_helpers.R
# Shared utilities for the unified workflow.
# ============================================================

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}

`%||%` <- function(a, b) {
  if (!is.null(a) && length(a) > 0 && !all(is.na(a))) a else b
}

safe_source <- function(path, echo = FALSE) {
  if (!file.exists(path)) stop("Cannot source missing file: ", path)
  message("Sourcing: ", path)
  source(path, echo = echo, encoding = "UTF-8", local = .GlobalEnv)
}

read_script_text <- function(path) {
  # Robust reader for submitted scripts that may mix UTF-8 and Windows-1252/Latin-1
  # symbols (for example en dash and plus-minus). We always return safe UTF-8 text.
  raw <- readBin(path, what = "raw", n = file.info(path)$size)

  txt <- tryCatch(
    readLines(textConnection(rawToChar(raw)), warn = FALSE),
    error = function(e) NULL
  )

  if (is.null(txt) || any(is.na(iconv(txt, from = "UTF-8", to = "UTF-8")))) {
    con <- rawConnection(raw)
    on.exit(close(con), add = TRUE)
    txt <- readLines(con, warn = FALSE, encoding = "latin1")
  }

  txt <- iconv(txt, from = "", to = "UTF-8", sub = "")
  txt[is.na(txt)] <- ""

  # Make generated temporary scripts ASCII-safe. These replacements only affect
  # display strings in tables, not the analysis logic.
  txt <- gsub("\u2013|\u2014|\u2212", "-", txt)
  txt <- gsub("\u00B1", "+/-", txt)
  txt <- gsub("\u0394", "Delta", txt)
  txt <- gsub("\u03C7", "chi", txt)
  txt <- gsub("\u2264", "<=", txt)
  txt <- gsub("\u2265", ">=", txt)
  txt <- gsub("\u2260", "!=", txt)

  enc2utf8(txt)
}

source_text_in_global <- function(txt, label = "<generated text>") {
  tf <- tempfile(fileext = ".R")
  txt <- enc2utf8(txt)
  txt[is.na(txt)] <- ""
  txt <- gsub("\u2013|\u2014|\u2212", "-", txt)
  txt <- gsub("\u00B1", "+/-", txt)
  txt <- gsub("\u0394", "Delta", txt)
  txt <- gsub("\u03C7", "chi", txt)
  txt <- gsub("\u2264", "<=", txt)
  txt <- gsub("\u2265", ">=", txt)
  txt <- gsub("\u2260", "!=", txt)

  con <- file(tf, open = "wb")
  writeBin(charToRaw(paste(txt, collapse = "\n")), con)
  close(con)

  on.exit(unlink(tf), add = TRUE)
  message("Sourcing generated script: ", label)
  source(tf, encoding = "UTF-8", local = .GlobalEnv)
}
first_existing_file <- function(paths) {
  paths <- paths[!is.na(paths) & nzchar(paths)]
  hit <- paths[file.exists(paths)]
  if (length(hit) == 0) return(NA_character_)
  hit[[1]]
}

read_csv_first <- function(paths, show_col_types = FALSE) {
  p <- first_existing_file(paths)
  if (is.na(p)) stop("None of these files exists:\n - ", paste(paths, collapse = "\n - "))
  readr::read_csv(p, show_col_types = show_col_types)
}

normalize_time_period_vec <- function(x) dplyr::case_when(
  is.na(x) ~ NA_character_,
  x %in% c("Before", "Pre", "Pre-Intro", "Pre-Introduction") ~ "Pre-Introduction",
  x %in% c("After", "Post", "Post-Intro", "Post-Introduction") ~ "Post-Introduction",
  TRUE ~ as.character(x)
)

parse_datetime_utc <- function(x) {
  if (inherits(x, "POSIXt")) return(as.POSIXct(x, tz = "UTC"))
  suppressWarnings(lubridate::ymd_hms(as.character(x), tz = "UTC", quiet = TRUE)) %||%
    suppressWarnings(as.POSIXct(x, tz = "UTC", origin = "1970-01-01"))
}

harmonize_token_table <- function(df) {
  if ("KeywordCategory" %in% names(df) && !"category" %in% names(df)) {
    df <- dplyr::rename(df, category = .data$KeywordCategory)
  }
  if ("category" %in% names(df) && !"KeywordCategory" %in% names(df)) {
    df <- dplyr::mutate(df, KeywordCategory = .data$category)
  }
  if ("TimePeriod" %in% names(df) && !"time_period" %in% names(df)) {
    df <- dplyr::rename(df, time_period = .data$TimePeriod)
  }
  required <- c(
    "video_id", "TaxonName", "LifeForm", "PresentStatus", "word",
    "KeywordCategory", "category", "time_period", "created_at", "viewCount",
    "FirstRecord", "FirstRecordDate"
  )
  for (cc in required) if (!cc %in% names(df)) df[[cc]] <- NA
  df %>%
    dplyr::mutate(
      KeywordCategory = as.character(.data$KeywordCategory),
      category = as.character(.data$category),
      time_period = normalize_time_period_vec(.data$time_period),
      TaxonName = as.character(.data$TaxonName),
      LifeForm = as.character(.data$LifeForm),
      PresentStatus = as.character(.data$PresentStatus),
      word = as.character(.data$word),
      created_at = suppressWarnings(as.POSIXct(.data$created_at, tz = "UTC")),
      FirstRecordDate = suppressWarnings(as.POSIXct(.data$FirstRecordDate, tz = "UTC", origin = "1970-01-01")),
      viewCount = suppressWarnings(as.numeric(.data$viewCount))
    ) %>%
    dplyr::filter(!is.na(.data$KeywordCategory), .data$KeywordCategory != "",
                  !is.na(.data$time_period), .data$time_period != "")
}

make_multinom_frame <- function(kw) {
  kw %>%
    harmonize_token_table() %>%
    dplyr::filter(
      .data$KeywordCategory %in% c("Invasion", "Detection", "eCommerce", "Threat"),
      .data$time_period %in% c("Pre-Introduction", "Post-Introduction"),
      !is.na(.data$LifeForm), .data$LifeForm != "",
      !is.na(.data$PresentStatus), .data$PresentStatus != ""
    ) %>%
    dplyr::mutate(
      KeywordCategory = factor(.data$KeywordCategory, levels = c("Invasion", "Detection", "eCommerce", "Threat")),
      time_period = factor(.data$time_period, levels = c("Pre-Introduction", "Post-Introduction")),
      LifeForm = factor(.data$LifeForm),
      PresentStatus = factor(.data$PresentStatus),
      viewCount = dplyr::if_else(is.na(.data$viewCount) | .data$viewCount <= 0, 1, .data$viewCount)
    ) %>%
    dplyr::distinct()
}

copy_with_suffix <- function(from, suffix, before_ext = TRUE) {
  if (!file.exists(from)) return(invisible(NA_character_))
  ext <- tools::file_ext(from)
  stem <- sub(paste0("\\.", ext, "$"), "", from)
  to <- if (before_ext && nzchar(ext)) paste0(stem, suffix, ".", ext) else paste0(from, suffix)
  file.copy(from, to, overwrite = TRUE)
  invisible(to)
}

# Patch Figure 2 token-source block without altering its plotting code.
run_patched_figure2 <- function() {
  txt <- read_script_text(ORIG_FIG2)
  # Replace the three sequential FIG2_TOKEN_SOURCE assignments with a single mode-controlled assignment.
  start <- grep("# 1) Titles + descriptions ONLY", txt, fixed = TRUE)[1]
  end <- grep("tokens_path_no_comments <-", txt, fixed = TRUE)[1] - 1
  if (is.na(start) || is.na(end) || end <= start) {
    stop("Could not find Figure 2 token-source assignment block to patch.")
  }
  replacement <- c(
    "# Mode-controlled token source injected by unified workflow.",
    "# NO_COMMENTS => submitted title/description branch; COMMENTS_TIMESTAMPS => ALL tokens.",
    "if (!exists('TOKEN_SOURCE_LABEL')) TOKEN_SOURCE_LABEL <- 'NO_COMMENTS'",
    "FIG2_TOKEN_SOURCE <- TOKEN_SOURCE_LABEL"
  )
  txt <- c(txt[seq_len(start - 1)], replacement, txt[(end + 1):length(txt)])
  # After token files have been selected/read, relabel outputs for the revision branch.
  marker <- "kw_df_C  <- harmonize_tokens(kw_df_C)"
  idx <- grep(marker, txt, fixed = TRUE)[1]
  if (!is.na(idx)) {
    inject <- c(
      "",
      "# Relabel output files while keeping token-source logic as ALL.",
      "if (exists('ANALYSIS_MODE') && ANALYSIS_MODE == 'COMMENTS_TIMESTAMPS') FIG2_TOKEN_SOURCE <- 'COMMENTS_TIMESTAMPS'"
    )
    txt <- c(txt[seq_len(idx)], inject, txt[(idx + 1):length(txt)])
  }
  source_text_in_global(txt, label = paste0("Figure 2 patched for ", ANALYSIS_MODE))
}

# Patch Tables S6-S8 so it can use active comments-timestamped tokens without changing table logic/style.
run_patched_tables_s6_s8 <- function() {
  txt <- read_script_text(ORIG_TABLES_S6_S8)
  if (ANALYSIS_MODE == "COMMENTS_TIMESTAMPS") {
    txt <- gsub("NO_COMMENTS", "COMMENTS_TIMESTAMPS", txt, fixed = TRUE)
    txt <- gsub("token_table_from_BASE_raw_COMMENTS_TIMESTAMPS.csv", "token_table_from_BASE_raw.csv", txt, fixed = TRUE)
    txt <- gsub("keywords_long_before_after_FOR_FIG2_COMMENTS_TIMESTAMPS.csv", "keywords_long_before_after_FOR_FIG2.csv", txt, fixed = TRUE)
    txt <- gsub("# kdat should be your COMMENTS_TIMESTAMPS tokens after harmonization", "# kdat uses comments-timestamped ALL tokens after harmonization", txt, fixed = TRUE)
  }
  source_text_in_global(txt, label = paste0("Tables S6-S8 patched for ", ANALYSIS_MODE))
}
