# ============================================================
# 02_run_youtube_search_lists.R
# Runs REG/GEO YouTube API searches for each search-term batch.
# Outputs per-batch CSV/RDS files to yt_api_outputs/per_list/.
# ============================================================

if (!exists("CONFIG", inherits = FALSE)) source(file.path("scripts", "00_youtube_search_config.R"), encoding = "UTF-8")
source(file.path("scripts", "01_youtube_api_helpers.R"), encoding = "UTF-8")

if (!nzchar(CONFIG$api_key)) {
  stop("YOUTUBE_API_KEY is not set. Run: Sys.setenv(YOUTUBE_API_KEY = 'YOUR_KEY')")
}

species_terms <- load_species_terms(CONFIG$species_terms_file)
search_plan <- make_search_plan(species_terms, max_species_per_batch = CONFIG$max_species_per_batch)
readr::write_csv(search_plan, file.path(YT_OUTPUT_DIR, "search_plan.csv"))

cat("Search plan created:\n")
cat("  Species:", dplyr::n_distinct(search_plan$TaxonName), "\n")
cat("  Search terms:", nrow(search_plan), "\n")
cat("  Batches:", dplyr::n_distinct(search_plan$batch), "\n")
cat("  Modes:", paste(CONFIG$search_modes, collapse = ", "), "\n")

run_one_batch_mode <- function(batch_name, mode, plan, config) {
  batch_plan <- plan %>% dplyr::filter(.data$batch == batch_name)
  if (nrow(batch_plan) == 0) return(invisible(NULL))

  mode <- toupper(mode)
  if (!mode %in% c("REG", "GEO")) stop("Unknown mode: ", mode)

  out_prefix <- paste0("yt_", batch_name, "_", mode)
  out_dir <- file.path(YT_PER_LIST_DIR, mode)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  videos_all <- list()

  for (i in seq_len(nrow(batch_plan))) {
    taxon <- batch_plan$TaxonName[[i]]
    term  <- batch_plan$query[[i]]

    if (mode == "REG") {
      for (rc in config$region_codes) {
        cat(sprintf("[%s | %s] %s -> %s\n", batch_name, mode, taxon, term))
        df <- tryCatch(
          search_youtube_videos_by_region(
            query = term,
            TaxonName = taxon,
            region_code = rc,
            max_results_total = config$max_videos_per_term,
            published_after = config$published_after,
            published_before = config$published_before,
            relevance_language = config$relevance_language,
            postfilter = config$postfilter_query_in_title_or_description,
            api_key = config$api_key,
            sleep_seconds = config$sleep_seconds
          ),
          error = function(e) {
            warning("REG search failed for ", taxon, " / ", term, " / ", rc, ": ", e$message)
            empty_search_tbl()
          }
        )
        if (nrow(df) > 0) videos_all[[paste(taxon, term, rc, sep = "__")]] <- df
      }
    }

    if (mode == "GEO") {
      for (geo_name in names(config$geo_locations)) {
        loc <- config$geo_locations[[geo_name]]
        cat(sprintf("[%s | %s] %s -> %s (%s)\n", batch_name, mode, taxon, term, geo_name))
        df <- tryCatch(
          search_youtube_videos_with_location(
            query = term,
            TaxonName = taxon,
            location = loc$coord,
            location_radius = loc$radius,
            geo_id = geo_name,
            max_results_total = config$max_videos_per_term,
            published_after = config$published_after,
            published_before = config$published_before,
            relevance_language = config$relevance_language,
            postfilter = config$postfilter_query_in_title_or_description,
            api_key = config$api_key,
            sleep_seconds = config$sleep_seconds
          ),
          error = function(e) {
            warning("GEO search failed for ", taxon, " / ", term, " / ", geo_name, ": ", e$message)
            empty_search_tbl()
          }
        )
        if (nrow(df) > 0) videos_all[[paste(taxon, term, geo_name, sep = "__")]] <- df
      }
    }
  }

  if (length(videos_all) == 0) {
    videos_tbl <- empty_search_tbl()
  } else {
    videos_tbl <- dplyr::bind_rows(videos_all) %>%
      dplyr::filter(!is.na(.data$video_id), .data$video_id != "") %>%
      dplyr::mutate(video_url = paste0("https://www.youtube.com/watch?v=", .data$video_id)) %>%
      dplyr::distinct(.data$video_id, .data$TaxonName, .data$query, .data$search_type, .data$search_unit, .keep_all = TRUE)
  }

  if (config$extract_video_stats && nrow(videos_tbl) > 0) {
    stats_tbl <- get_video_stats_batch(
      video_ids = videos_tbl$video_id,
      api_key = config$api_key,
      sleep_seconds = config$sleep_seconds
    )
    videos_tbl <- videos_tbl %>% dplyr::left_join(stats_tbl, by = "video_id")
  }

  # Ensure optional statistic columns exist even when extract_video_stats = FALSE.
  for (cc in c("viewCount", "likeCount", "commentCount")) {
    if (!cc %in% names(videos_tbl)) videos_tbl[[cc]] <- NA_real_
  }
  if (!"duration" %in% names(videos_tbl)) videos_tbl$duration <- NA_character_

  comments_tbl <- empty_comments_tbl()
  if (config$extract_comments && nrow(videos_tbl) > 0) {
    comments_tbl <- purrr::map_dfr(seq_len(nrow(videos_tbl)), function(i) {
      id <- videos_tbl$video_id[[i]]
      cat("Comments:", id, "\n")
      tryCatch(
        get_comments_for_video(
          video_id = id,
          TaxonName = videos_tbl$TaxonName[[i]],
          query = videos_tbl$query[[i]],
          api_key = config$api_key,
          max_comments_per_video = config$max_comments_per_video,
          include_replies = config$include_replies,
          sleep_seconds = config$sleep_seconds
        ),
        error = function(e) {
          tibble::tibble(
            video_id = id, TaxonName = videos_tbl$TaxonName[[i]], query = videos_tbl$query[[i]],
            error_status = NA_integer_, error_text = paste("R error:", e$message),
            comment_id = NA_character_, parent_id = NA_character_, is_reply = NA,
            author = NA_character_, text = NA_character_, likeCount = NA_real_,
            publishedAt = as.POSIXct(NA, tz = "UTC"), updatedAt = as.POSIXct(NA, tz = "UTC")
          )
        }
      )
    })
  }

  comments_joined_tbl <- comments_tbl
  if (nrow(comments_tbl) > 0 && nrow(videos_tbl) > 0) {
    comments_joined_tbl <- comments_tbl %>%
      dplyr::left_join(
        videos_tbl %>%
          dplyr::select(
            video_id, video_title = title, video_description = description,
            video_publishedAt = publishedAt, channelTitle, search_type,
            search_unit, regionCode, geo_id, location,
            locationRadius, video_url, viewCount, likeCount,
            commentCount, duration
          ),
        by = "video_id"
      )
  }

  readr::write_csv(videos_tbl, file.path(out_dir, paste0(out_prefix, "_videos.csv")), na = "")
  readr::write_csv(comments_tbl, file.path(out_dir, paste0(out_prefix, "_comments_long.csv")), na = "")
  readr::write_csv(comments_joined_tbl, file.path(out_dir, paste0(out_prefix, "_comments_joined.csv")), na = "")
  saveRDS(list(videos = videos_tbl, comments = comments_tbl, comments_joined = comments_joined_tbl),
          file.path(out_dir, paste0(out_prefix, "_FULL_RESULTS.rds")))

  cat("Saved:", file.path(out_dir, paste0(out_prefix, "_videos.csv")), " rows=", nrow(videos_tbl), "\n")
  invisible(list(videos = videos_tbl, comments = comments_tbl, comments_joined = comments_joined_tbl))
}

for (batch_name in unique(search_plan$batch)) {
  for (mode in CONFIG$search_modes) {
    run_one_batch_mode(batch_name, mode, search_plan, CONFIG)
  }
}

cat("\nFinished API search batches. Now run scripts/03_combine_youtube_search_outputs.R\n")
