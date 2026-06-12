# ============================================================
# 04_tokenization_strict.R
# Unified strict tokenization. Based on submitted comments-timestamp script,
# with one change: in NO_COMMENTS mode, missing comments_joined is allowed and
# only the submitted title/description token table is required.
# ============================================================

if (!exists("PROJECT_ROOT", inherits = FALSE)) PROJECT_ROOT <- getwd()
if (!exists("BUILD_COMMENTS_TOKENS", inherits = FALSE)) BUILD_COMMENTS_TOKENS <- TRUE
if (!exists("TABLES_ROOT", inherits = FALSE)) TABLES_ROOT <- file.path("outputs", "intermediate")
if (!exists("OUTPUTS_ROOT", inherits = FALSE)) OUTPUTS_ROOT <- file.path("outputs", "intermediate")

# ============================================
# 00_tokenize_keywords.R  (UPDATED: WITH COMMENTS + REPLIES)
# Canonical tokens for Iberian YT IAS
# - Reads combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN (video-level)
# - Reads comments_joined (comment-level; includes replies; has publishedAt)
# - Uses keyword_lists.R (Invasion, Detection, Threat, eCommerce)
# - Writes token CSVs used by figures + multinomial workflow
# ============================================

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(stringr); library(purrr); library(readr)
  library(lubridate); library(tidytext); library(forcats)
})

# ---------- Inputs expected ----------
stopifnot(exists("combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN"))
source(file.path(SCRIPTS_DIR, "03_keyword_lists.R"), encoding = "UTF-8")  # defines Invasion, Detection, Threat, eCommerce

# ---------- IO dirs (write to BOTH 'tables' and 'outputs' trees) ----------
ensure_dir <- function(p) if (!dir.exists(p)) dir.create(p, recursive = TRUE, showWarnings = FALSE)

out_root_tables  <- TABLES_ROOT
out_root_outputs <- OUTPUTS_ROOT

out_kw_tables  <- file.path(out_root_tables,  "keywords")
out_kw_outputs <- file.path(out_root_outputs, "keywords")

invisible(lapply(c(out_root_tables, out_root_outputs, out_kw_tables, out_kw_outputs), ensure_dir))

# ---------- Helpers ----------
`%||%` <- function(a, b) if (!is.null(a) && length(a) > 0 && !all(is.na(a))) a else b

squash <- function(x) {
  x <- tolower(trimws(x))
  if (requireNamespace("stringi", quietly = TRUE))
    x <- stringi::stri_trans_general(x, "Latin-ASCII")
  x
}

normalize_time_period_vec <- function(x) dplyr::case_when(
  is.na(x) ~ NA_character_,
  x %in% c("Before","Pre-Intro","Pre-Introduction") ~ "Pre-Introduction",
  x %in% c("After","Post-Intro","Post-Introduction") ~ "Post-Introduction",
  TRUE ~ as.character(x)
)

# Optionally extend/normalize lists if you used a `keyword_lists` list object
if (exists("keyword_lists") && is.list(keyword_lists)) {
  get_vec <- function(x) {
    v <- keyword_lists[[x]]
    if (is.null(v)) character() else unique(as.character(v))
  }
  Threat    <- get_vec("Threat")
  Detection <- get_vec("Detection")
  eCommerce <- get_vec("eCommerce")
  Invasion  <- get_vec("Invasion")
}

dicts <- list(
  Invasion   = unique(squash(Invasion)),
  Detection  = unique(squash(Detection)),
  Threat     = unique(squash(Threat)),
  eCommerce  = unique(squash(eCommerce))
)

categorize_word <- function(word) {
  w <- squash(word)
  if (w %in% dicts$Invasion)   return("Invasion")
  if (w %in% dicts$Detection)  return("Detection")
  if (w %in% dicts$Threat)     return("Threat")
  if (w %in% dicts$eCommerce)  return("eCommerce")
  NA_character_
}

# Optional exact FirstRecord fixes if you�ve been using them
exact_first_record_dates <- c(
  "Obolodiplosis_robiniae"="2011-08-15","Blastopsylla_occidentalis"="2009-11-01",
  "Psyllaephagus_bliteus"="2010-07-01","Aphis_illinoisensis"="2011-08-07",
  "Vespa_velutina"="2010-08-21","Tockus_deckeni"="2015-04-13","Sipha_flava"="2014-06-17",
  "Mimus_gilvus"="2012-12-16","Leuciscus_aspius"="2017-07-20","Crangonyx_pseudogracilis"="2011-09-01",
  "Apalone_ferox"="2015-01-10","Aedes_japonicus"="2018-06-08","Aedes_albopictus"="2017-07-31",
  "Brachymyrmex_patagonicus"="2016-09-16","Rapana_venosa"="2007-03-15","Wasmannia_auropunctata"="2018-05-12",
  "Mauremys_sinensis"="2014-10-10","Mauremys_reevesii"="2016-04-05","Tobamovirus_fructirugosum"="2019-10-01",
  "Xylella_fastidiosa"="2016-11-01","Spodoptera_frugiperda"="2020-07-01","Procambarus_virginalis"="2022-10-01",
  "Hydrocharis_laevigata"="2018-10-06","Halyomorpha_halys"="2016-09-01","Euwallacea_fornicatus"="2024-07-01",
  "Cherax_quadricarinatus"="2013-09-01","Schizoporella_errata"="2013-08-01","Stenothoe_georgiana"="2010-05-01"
)

# extra stopwords
extra.stop.words <- c(
  "mosquito","va","mosquit","para","2018","08","2020","16","ciencia","tigre","ow.ly","nhtml","japonicus",
  "por","bit.ly","nos","puede","dlvr.it","mosquitoes","mosquitoe","mosquitos","el","en","se","los","ha",
  "con","vez","es","of","https","t.co","the","a","in","and","to","i","di","una","del","e","is","rt","http",
  "la","de","il","q","della","lo","al","nt.html","tw","y","como","�","che","libro","cio�","per","one","new",
  "dan","just","si","??","???","????","??????"
)

# stopwords::stopwords() needs the stopwords pkg
if (!requireNamespace("stopwords", quietly = TRUE)) {
  stop("Package 'stopwords' is required. Please install.packages('stopwords').")
}

stopwords.df <- tibble::tibble(
  word = c(stopwords::stopwords("en"), stopwords::stopwords("es"), extra.stop.words)
) |> mutate(word = squash(word))

# ---------- Load base video table ----------
base_df <- combined_data_common_NEW_ES_PT_RAW_FLAGGED_IS_IBERIAN

# Require only essential fields for BASE tokens (titles + descriptions)
stopifnot(all(c(
  "video_id","TaxonName","created_at","FirstRecord","title","description",
  "Region","LifeForm","PresentStatus","viewCount","likeCount"
) %in% names(base_df)))

# Prefer Iberian-validated rows if present
if ("is_iberian" %in% names(base_df)) {
  base_df <- base_df %>% filter(.data$is_iberian %in% TRUE)
}

# ---------- Prepare base_df with FirstRecordDate, CleanName ----------
# IMPORTANT FIXES:
#  - avoid ifelse() on POSIXct (it can coerce to numeric)
#  - compute base FirstRecordDate as POSIXct, then override with a POSIXct join
base_df_prepped <- base_df %>%
  mutate(
    created_at  = suppressWarnings(lubridate::ymd_hms(as.character(.data$created_at), tz = "UTC")),
    FirstRecord = suppressWarnings(as.integer(.data$FirstRecord)),

    FirstRecordDate = suppressWarnings(as.POSIXct(
      paste0(pmax(.data$FirstRecord, 1L), "-06-01"),
      tz = "UTC"
    )),

    Region        = as.character(.data$Region),
    LifeForm      = as.character(.data$LifeForm),
    PresentStatus = as.character(.data$PresentStatus),
    CleanName     = if ("CleanName" %in% names(base_df)) as.character(.data$CleanName) else gsub("_"," ", .data$TaxonName),
    title         = as.character(.data$title),
    description   = as.character(.data$description),

    viewCount     = suppressWarnings(as.numeric(.data$viewCount)),
    likeCount     = suppressWarnings(as.numeric(.data$likeCount)),
    commentCount  = if ("commentCount" %in% names(base_df)) suppressWarnings(as.numeric(.data$commentCount)) else NA_real_
  ) %>%
  distinct(.data$video_id, .keep_all = TRUE)

# Apply exact FirstRecordDate overrides safely (POSIXct -> POSIXct)
override_tbl <- tibble::tibble(
  TaxonName = names(exact_first_record_dates),
  FirstRecordDate_override = as.POSIXct(unname(exact_first_record_dates), tz = "UTC")
)

base_df_prepped <- base_df_prepped %>%
  left_join(override_tbl, by = "TaxonName") %>%
  mutate(
    FirstRecordDate = dplyr::coalesce(.data$FirstRecordDate_override, .data$FirstRecordDate)
  ) %>%
  dplyr::select(-.data$FirstRecordDate_override)

# =========================================================
# PART 1 � TOKENISE TITLES + DESCRIPTIONS (NO COMMENTS)
# =========================================================

dat_meta <- base_df_prepped %>%
  mutate(
    text_all = purrr::pmap_chr(
      dplyr::pick(dplyr::any_of(c("title","description"))),
      function(...) {
        parts <- c(...)
        parts <- parts[!is.na(parts) & nzchar(parts)]
        paste(parts, collapse = " | ")
      }
    )
  )

raw_tokens_meta <- dat_meta %>%
  dplyr::select(
    video_id, created_at, viewCount, likeCount,
    any_of("commentCount"),
    TaxonName, FirstRecord, FirstRecordDate, Region, LifeForm, PresentStatus, CleanName,
    text_all
  ) %>%
  tidytext::unnest_tokens(word, text_all, token = "words") %>%
  mutate(word = squash(.data$word)) %>%
  filter(
    !str_detect(.data$word, "^(http|www\\.)"),
    !str_detect(.data$word, "^[0-9]+$"),
    nchar(.data$word) > 1
  ) %>%
  # remove species-name words (based on CleanName split)
  filter(!(.data$word %in% squash(str_split(.data$CleanName, "\\s+", simplify = TRUE)))) %>%
  anti_join(stopwords.df, by = "word")

toks_meta <- raw_tokens_meta %>%
  mutate(
    KeywordCategory = vapply(.data$word, categorize_word, FUN.VALUE = character(1)),
    category        = .data$KeywordCategory,  # keep both (compat)

    time_period = case_when(
      !is.na(.data$created_at) & !is.na(.data$FirstRecordDate) & .data$created_at <  .data$FirstRecordDate ~ "Pre-Introduction",
      !is.na(.data$created_at) & !is.na(.data$FirstRecordDate) & .data$created_at >= .data$FirstRecordDate ~ "Post-Introduction",
      TRUE ~ NA_character_
    ),
    time_period   = normalize_time_period_vec(.data$time_period),
    token_source  = "title_description"
  ) %>%
  filter(!is.na(.data$KeywordCategory), !is.na(.data$time_period)) %>%
  dplyr::select(
    video_id, created_at, viewCount, likeCount,
    any_of("commentCount"),
    TaxonName, Region, LifeForm, PresentStatus,
    word, time_period, KeywordCategory, category,
    FirstRecord, FirstRecordDate,
    token_source
  )

# =========================================================
# PART 2 � TOKENISE COMMENTS + REPLIES (NEW; uses publishedAt)
# =========================================================

# Expect comments_joined in memory OR optionally read from CSV
if (!exists("comments_joined")) {
  if (isTRUE(BUILD_COMMENTS_TOKENS)) {
    stop("Object 'comments_joined' not found. Load it first with 02_prepare_timestamped_comments.R or provide a timestamped comments CSV.")
  } else {
    message("comments_joined not found; creating empty comments table because BUILD_COMMENTS_TOKENS is FALSE.")
    comments_joined <- tibble::tibble(
      error_status = character(), video_id = character(), publishedAt = as.POSIXct(character()),
      text = character(), is_iberian = logical(), TaxonName = character(), FirstRecord = integer(),
      FirstRecordDate = as.POSIXct(character()), Region = character(), LifeForm = character(),
      PresentStatus = character(), likeCount = numeric(), comment_id = character(),
      parent_id = character(), is_reply = logical()
    )
  }
}

comments_df <- comments_joined

# Keep only successful rows with usable timestamps/text
comments_df <- comments_df %>%
  filter(is.na(.data$error_status)) %>%
  mutate(
    # publishedAt is often already <dttm>; coercing via as.POSIXct is safest
    publishedAt = as.POSIXct(.data$publishedAt, tz = "UTC"),
    text        = as.character(.data$text)
  ) %>%
  filter(!is.na(.data$video_id), nzchar(.data$video_id),
         !is.na(.data$publishedAt),
         !is.na(.data$text), nzchar(.data$text))

# Prefer Iberian-validated videos if column exists
if ("is_iberian" %in% names(comments_df)) {
  comments_df <- comments_df %>% filter(.data$is_iberian %in% TRUE)
}

# ---- FIXED JOIN STRATEGY (robust + avoids your earlier errors) ----
# We DO NOT re-join TaxonName/FirstRecordDate/etc (comments_df already has them).
# We ONLY bring in CleanName + video-level counts, and we use suffixes + rename.
meta_join <- base_df_prepped %>%
  dplyr::select(video_id, CleanName, viewCount, likeCount, any_of("commentCount")) %>%
  distinct(.data$video_id, .keep_all = TRUE)

comments_df2 <- comments_df %>%
  mutate(
    created_at = .data$publishedAt,   # comment timestamp for pre/post split
    text_all   = .data$text,
    TaxonName  = as.character(.data$TaxonName),
    FirstRecord = suppressWarnings(as.integer(.data$FirstRecord)),
    FirstRecordDate = as.POSIXct(.data$FirstRecordDate, tz = "UTC"),
    Region = as.character(.data$Region),
    LifeForm = as.character(.data$LifeForm),
    PresentStatus = as.character(.data$PresentStatus)
  ) %>%
  left_join(meta_join, by = "video_id", suffix = c(".comment", ".video")) %>%
  rename(
    comment_likeCount = likeCount.comment,
    video_likeCount   = likeCount.video
  ) %>%
  # IMPORTANT FIX: use .data$TaxonName to avoid size-mismatch from env objects
  filter(!is.na(.data$TaxonName), nzchar(.data$TaxonName))

raw_tokens_comments <- comments_df2 %>%
  dplyr::select(
    video_id, comment_id, parent_id, is_reply,
    created_at, viewCount, video_likeCount, comment_likeCount,
    any_of("commentCount"),
    TaxonName, FirstRecord, FirstRecordDate, Region, LifeForm, PresentStatus, CleanName,
    text_all
  ) %>%
  tidytext::unnest_tokens(word, text_all, token = "words") %>%
  mutate(word = squash(.data$word)) %>%
  filter(
    !str_detect(.data$word, "^(http|www\\.)"),
    !str_detect(.data$word, "^[0-9]+$"),
    nchar(.data$word) > 1
  ) %>%
  # remove species-name words
  filter(!(.data$word %in% squash(str_split(.data$CleanName, "\\s+", simplify = TRUE)))) %>%
  anti_join(stopwords.df, by = "word")

toks_comments <- raw_tokens_comments %>%
  mutate(
    KeywordCategory = vapply(.data$word, categorize_word, FUN.VALUE = character(1)),
    category        = .data$KeywordCategory,
    time_period = case_when(
      !is.na(.data$created_at) & !is.na(.data$FirstRecordDate) & .data$created_at <  .data$FirstRecordDate ~ "Pre-Introduction",
      !is.na(.data$created_at) & !is.na(.data$FirstRecordDate) & .data$created_at >= .data$FirstRecordDate ~ "Post-Introduction",
      TRUE ~ NA_character_
    ),
    time_period  = normalize_time_period_vec(.data$time_period),
    token_source = "comment"
  ) %>%
  filter(!is.na(.data$KeywordCategory), !is.na(.data$time_period)) %>%
  dplyr::select(
    video_id, created_at, viewCount,
    video_likeCount, comment_likeCount,
    any_of("commentCount"),
    TaxonName, Region, LifeForm, PresentStatus,
    word, time_period, KeywordCategory, category,
    FirstRecord, FirstRecordDate,
    token_source,
    comment_id, parent_id, is_reply
  )

# =========================================================
# PART 3 � COMBINE + DIAGNOSTICS + SAVE
# =========================================================

# Ensure consistent types
toks_meta <- toks_meta %>% mutate(created_at = as.POSIXct(.data$created_at, tz = "UTC"))
toks_comments <- toks_comments %>% mutate(created_at = as.POSIXct(.data$created_at, tz = "UTC"))

# (A) NO COMMENTS token table (titles+descriptions only) � used in Fig2 B/C
toks_no_comments <- toks_meta

# (B) COMMENTS ONLY token table
toks_comments_only <- toks_comments

# (C) ALL tokens combined (titles+descriptions + comments)
# Ensure both tables have the same core columns; extra comment columns will be filled with NA in meta.
toks_all <- bind_rows(
  toks_meta %>%
    mutate(
      video_likeCount   = NA_real_,
      comment_likeCount = NA_real_,
      comment_id = NA_character_,
      parent_id  = NA_character_,
      is_reply   = NA
    ),
  toks_comments
)

# ---------- Diagnostics ----------
diag_tbl <- tibble(
  block = c("META_raw","META_matched","COMMENTS_raw","COMMENTS_matched","ALL_combined"),
  n_rows = c(
    nrow(raw_tokens_meta),
    nrow(toks_meta),
    nrow(raw_tokens_comments),
    nrow(toks_comments),
    nrow(toks_all)
  ),
  vocab = c(
    raw_tokens_meta |> summarise(vocab = n_distinct(.data$word)) |> pull(vocab),
    toks_meta       |> summarise(vocab = n_distinct(.data$word)) |> pull(vocab),
    raw_tokens_comments |> summarise(vocab = n_distinct(.data$word)) |> pull(vocab),
    toks_comments       |> summarise(vocab = n_distinct(.data$word)) |> pull(vocab),
    toks_all            |> summarise(vocab = n_distinct(.data$word)) |> pull(vocab)
  )
)

print(diag_tbl)

# ---------- Save paths ----------
out_csv_outputs_no_comments <- file.path(out_kw_outputs, "token_table_from_BASE_raw_NO_COMMENTS.csv")
out_csv_tables_no_comments  <- file.path(out_kw_tables,  "token_table_from_BASE_raw_NO_COMMENTS.csv")

out_csv_outputs_comments <- file.path(out_kw_outputs, "token_table_from_BASE_raw_COMMENTS.csv")
out_csv_tables_comments  <- file.path(out_kw_tables,  "token_table_from_BASE_raw_COMMENTS.csv")

out_csv_outputs_all <- file.path(out_kw_outputs, "token_table_from_BASE_raw.csv")
out_csv_tables_all  <- file.path(out_kw_tables,  "token_table_from_BASE_raw.csv")

# ---------- Write ----------
readr::write_csv(toks_no_comments,   out_csv_outputs_no_comments, na = "")
readr::write_csv(toks_no_comments,   out_csv_tables_no_comments,  na = "")

readr::write_csv(toks_comments_only, out_csv_outputs_comments,    na = "")
readr::write_csv(toks_comments_only, out_csv_tables_comments,     na = "")

readr::write_csv(toks_all, out_csv_outputs_all, na = "")
readr::write_csv(toks_all, out_csv_tables_all,  na = "")

message(
  "Tokens built:\n",
  "  - NO_COMMENTS (titles+descriptions): ", nrow(toks_no_comments), " rows\n",
  "  - COMMENTS_ONLY (all comments+replies): ", nrow(toks_comments_only), " rows\n",
  "  - ALL (meta + comments): ", nrow(toks_all), " rows\n\n",
  "Saved to:\n",
  "  - ", out_csv_outputs_no_comments, "\n",
  "  - ", out_csv_outputs_comments, "\n",
  "  - ", out_csv_outputs_all, "\n",
  "and mirrored under:\n",
  "  - ", out_kw_tables, "\n"
)

# ---------- Objects created (for downstream scripts) ----------
# base_df_prepped
# comments_df2
# raw_tokens_meta, toks_meta
# raw_tokens_comments, toks_comments
# toks_no_comments, toks_comments_only, toks_all
# diag_tbl

