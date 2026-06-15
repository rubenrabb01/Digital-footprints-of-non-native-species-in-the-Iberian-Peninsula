# 02_filter_regioncode_outputs.R
# Apply a light screen to regionCode results before manual review.

source(file.path("scripts", "00_config_paths_mode.R"), encoding = "UTF-8")

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(stringr)
  library(tibble)
})

PREP_DIR <- file.path(PROJECT_ROOT, "data", "preparation_input")
dir.create(PREP_DIR, recursive = TRUE, showWarnings = FALSE)

read_csv_chr <- function(path) {
  if (!file.exists(path)) return(tibble())
  readr::read_csv(path, col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE)
}

reg <- read_csv_chr(file.path(PREP_DIR, "api_regioncode_raw.csv"))

if (nrow(reg) == 0) {
  warning("No regionCode API file found. Run 01_collect_api_outputs.R first.")
  reg_candidates <- tibble()
  reg_rejected <- tibble()
} else {
  latam_country_rx <- stringr::regex(
    paste(c(
      "chile", "argentina", "uruguay", "paraguay", "bolivia", "per[uú]",
      "ecuador", "colombia", "venezuela", "m[eé]xico", "guatemala",
      "honduras", "nicaragua", "costa rica", "panam[aá]", "cuba",
      "rep[uú]blica dominicana", "dominican republic", "puerto rico"
    ), collapse = "|"),
    ignore_case = TRUE
  )

  reg_screened <- reg %>%
    mutate(
      text_for_screening = str_squish(paste(title, description, channelTitle, sep = " ")),
      possible_non_iberian_country = str_detect(text_for_screening, latam_country_rx),
      regionCode = if ("regionCode" %in% names(.)) as.character(regionCode) else NA_character_,
      keep_after_light_screen = regionCode %in% c("ES", "PT") & !possible_non_iberian_country,
      screening_note = case_when(
        !regionCode %in% c("ES", "PT") ~ "regionCode is not ES/PT",
        possible_non_iberian_country ~ "text mentions a non-Iberian country; check manually if needed",
        TRUE ~ "kept for manual Iberian relevance review"
      )
    )

  reg_candidates <- reg_screened %>%
    filter(.data$keep_after_light_screen | is.na(.data$keep_after_light_screen)) %>%
    dplyr::select(-text_for_screening)

  reg_rejected <- reg_screened %>%
    filter(!.data$keep_after_light_screen) %>%
    dplyr::select(-text_for_screening)
}

readr::write_csv(reg_candidates, file.path(PREP_DIR, "api_regioncode_filtered_candidates.csv"), na = "")
readr::write_csv(reg_rejected, file.path(PREP_DIR, "api_regioncode_light_screen_rejected.csv"), na = "")

message("RegionCode candidates: ", nrow(reg_candidates))
message("Light-screen rejected rows: ", nrow(reg_rejected))
message("Note: this is only a light screen. Final Iberian relevance is assigned manually.")
