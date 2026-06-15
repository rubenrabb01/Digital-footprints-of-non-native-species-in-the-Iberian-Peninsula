# ============================================================
# 01_youtube_api_helpers.R
# Generic helper functions for REG and GEO YouTube API searches.
# Based on the separate REG/GEO scripts and the later unified API test script,
# but with hard-coded API keys removed.
# ============================================================

suppressPackageStartupMessages({
  library(httr)
  library(jsonlite)
  library(dplyr)
  library(tibble)
  library(stringr)
  library(purrr)
  library(lubridate)
  library(readr)
})

`%||%` <- function(a, b) if (!is.null(a)) a else b

safe_sleep <- function(seconds) {
  if (is.numeric(seconds) && !is.na(seconds) && seconds > 0) Sys.sleep(seconds)
}

ensure_posixct_utc <- function(x) {
  suppressWarnings(as.POSIXct(x, tz = "UTC"))
}

safe_filename <- function(x) {
  x <- gsub("[^A-Za-z0-9_]+", "_", x)
  x <- gsub("_+", "_", x)
  gsub("^_|_$", "", x)
}

query_in_text <- function(title, description, query) {
  q <- stringr::str_to_lower(as.character(query %||% ""))
  stringr::str_detect(stringr::str_to_lower(as.character(title %||% "")), fixed(q)) |
    stringr::str_detect(stringr::str_to_lower(as.character(description %||% "")), fixed(q))
}

yt_get <- function(url, query, sleep_seconds = 0) {
  safe_sleep(sleep_seconds)
  resp <- httr::GET(url, query = query)
  txt <- httr::content(resp, "text", encoding = "UTF-8")

  if (httr::status_code(resp) != 200) {
    return(list(ok = FALSE, status = httr::status_code(resp), text = txt, parsed = NULL))
  }

  parsed <- tryCatch(
    httr::content(resp, as = "parsed", encoding = "UTF-8"),
    error = function(e) NULL
  )

  list(ok = TRUE, status = 200, text = txt, parsed = parsed)
}

empty_search_tbl <- function() {
  tibble::tibble(
    video_id = character(), title = character(), description = character(),
    publishedAt = as.POSIXct(character(), tz = "UTC"), channelTitle = character(),
    TaxonName = character(), query = character(), search_type = character(), search_unit = character(),
    regionCode = character(), geo_id = character(), location = character(), locationRadius = character(),
    video_url = character()
  )
}

empty_stats_tbl <- function() {
  tibble::tibble(
    video_id = character(), viewCount = numeric(), likeCount = numeric(),
    commentCount = numeric(), duration = character()
  )
}

empty_comments_tbl <- function() {
  tibble::tibble(
    video_id = character(), TaxonName = character(), query = character(),
    error_status = integer(), error_text = character(), comment_id = character(),
    parent_id = character(), is_reply = logical(), author = character(), text = character(),
    likeCount = numeric(), publishedAt = as.POSIXct(character(), tz = "UTC"),
    updatedAt = as.POSIXct(character(), tz = "UTC")
  )
}

# ------------------------------------------------------------
# Search terms
# ------------------------------------------------------------
load_species_terms <- function(species_terms_file) {
  env <- new.env(parent = baseenv())
  source(species_terms_file, local = env, encoding = "UTF-8")

  candidate_names <- c(
    "SPECIES_SEARCH_TERMS",
    "all_lists",
    "all_lists_NEW_ES_PT_regioncode_scientific_common",
    "all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded",
    "all_lists_ccommon_NEW_ES_PT_ENRICHED_deduped",
    "all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded"
  )

  for (nm in candidate_names) {
    if (exists(nm, envir = env, inherits = FALSE)) {
      obj <- get(nm, envir = env)
      if (is.list(obj) && !is.null(names(obj))) {
        obj <- lapply(obj, function(x) unique(stats::na.omit(as.character(x))))
        obj <- obj[lengths(obj) > 0]
        if (length(obj) > 0) return(obj)
      }
    }
  }

  stop("No named species search-term list was found in: ", species_terms_file)
}

make_search_plan <- function(species_terms, max_species_per_batch = 20) {
  if (is.infinite(max_species_per_batch)) max_species_per_batch <- length(species_terms)
  species_names <- names(species_terms)
  batch_id <- ceiling(seq_along(species_names) / max_species_per_batch)

  purrr::map_dfr(seq_along(species_terms), function(i) {
    taxon <- species_names[[i]]
    tibble::tibble(
      batch = sprintf("search_terms_%02d", batch_id[[i]]),
      TaxonName = taxon,
      query = unique(stats::na.omit(as.character(species_terms[[i]])))
    )
  }) %>%
    dplyr::filter(!is.na(.data$query), .data$query != "") %>%
    dplyr::distinct(.data$batch, .data$TaxonName, .data$query)
}

# ------------------------------------------------------------
# REG search
# ------------------------------------------------------------
search_youtube_videos_by_region <- function(
  query, TaxonName,
  region_code = "ES",
  max_results_total = 100,
  published_after = "2005-03-01T00:00:00Z",
  published_before = paste0(format(Sys.Date(), "%Y-%m-%d"), "T00:00:00Z"),
  relevance_language = "es",
  postfilter = TRUE,
  api_key,
  sleep_seconds = 0.10
) {
  base_url <- "https://youtube.googleapis.com/youtube/v3/search"
  per_page <- min(50, max_results_total)
  collected <- list()
  fetched <- 0
  next_token <- NULL

  repeat {
    q_list <- list(
      part = "snippet", q = query, type = "video", maxResults = per_page,
      regionCode = region_code, publishedAfter = published_after,
      publishedBefore = published_before, relevanceLanguage = relevance_language,
      key = api_key
    )
    if (!is.null(next_token)) q_list$pageToken <- next_token

    res <- yt_get(base_url, q_list, sleep_seconds = sleep_seconds)
    if (!res$ok || is.null(res$parsed)) {
      warning(sprintf("REG request failed: query='%s', region='%s', status=%s", query, region_code, res$status))
      break
    }

    items <- res$parsed$items
    if (is.null(items) || length(items) == 0) break

    df <- purrr::map_dfr(items, function(item) {
      tibble::tibble(
        video_id = item$id$videoId %||% NA_character_,
        title = item$snippet$title %||% NA_character_,
        description = item$snippet$description %||% NA_character_,
        publishedAt = ensure_posixct_utc(item$snippet$publishedAt),
        channelTitle = item$snippet$channelTitle %||% NA_character_,
        TaxonName = TaxonName,
        query = query,
        search_type = "REG",
        search_unit = region_code,
        regionCode = region_code,
        geo_id = NA_character_,
        location = NA_character_,
        locationRadius = NA_character_
      )
    })

    if (postfilter) df <- df %>% dplyr::filter(query_in_text(.data$title, .data$description, .data$query))
    if (nrow(df) > 0) {
      collected[[length(collected) + 1]] <- df
      fetched <- fetched + nrow(df)
    }

    next_token <- res$parsed$nextPageToken
    if (is.null(next_token) || fetched >= max_results_total) break
  }

  if (length(collected) == 0) return(empty_search_tbl())
  dplyr::bind_rows(collected) %>%
    dplyr::filter(!is.na(.data$video_id), .data$video_id != "") %>%
    dplyr::distinct(.data$video_id, .data$TaxonName, .data$query, .data$regionCode, .keep_all = TRUE) %>%
    dplyr::mutate(video_url = paste0("https://www.youtube.com/watch?v=", .data$video_id))
}

# ------------------------------------------------------------
# GEO search
# ------------------------------------------------------------
search_youtube_videos_with_location <- function(
  query, TaxonName,
  location, location_radius = "1200km", geo_id = "GEO_AREA",
  max_results_total = 100,
  published_after = "2005-03-01T00:00:00Z",
  published_before = paste0(format(Sys.Date(), "%Y-%m-%d"), "T00:00:00Z"),
  relevance_language = "es",
  postfilter = TRUE,
  api_key,
  sleep_seconds = 0.10
) {
  base_url <- "https://youtube.googleapis.com/youtube/v3/search"
  per_page <- min(50, max_results_total)
  collected <- list()
  fetched <- 0
  next_token <- NULL

  repeat {
    q_list <- list(
      part = "snippet", q = query, type = "video", maxResults = per_page,
      publishedAfter = published_after, publishedBefore = published_before,
      location = location, locationRadius = location_radius,
      relevanceLanguage = relevance_language, key = api_key
    )
    if (!is.null(next_token)) q_list$pageToken <- next_token

    res <- yt_get(base_url, q_list, sleep_seconds = sleep_seconds)
    if (!res$ok || is.null(res$parsed)) {
      warning(sprintf("GEO request failed: query='%s', geo='%s', status=%s", query, geo_id, res$status))
      break
    }

    items <- res$parsed$items
    if (is.null(items) || length(items) == 0) break

    df <- purrr::map_dfr(items, function(item) {
      tibble::tibble(
        video_id = item$id$videoId %||% NA_character_,
        title = item$snippet$title %||% NA_character_,
        description = item$snippet$description %||% NA_character_,
        publishedAt = ensure_posixct_utc(item$snippet$publishedAt),
        channelTitle = item$snippet$channelTitle %||% NA_character_,
        TaxonName = TaxonName,
        query = query,
        search_type = "GEO",
        search_unit = geo_id,
        regionCode = NA_character_,
        geo_id = geo_id,
        location = location,
        locationRadius = location_radius
      )
    })

    if (postfilter) df <- df %>% dplyr::filter(query_in_text(.data$title, .data$description, .data$query))
    if (nrow(df) > 0) {
      collected[[length(collected) + 1]] <- df
      fetched <- fetched + nrow(df)
    }

    next_token <- res$parsed$nextPageToken
    if (is.null(next_token) || fetched >= max_results_total) break
  }

  if (length(collected) == 0) return(empty_search_tbl())
  dplyr::bind_rows(collected) %>%
    dplyr::filter(!is.na(.data$video_id), .data$video_id != "") %>%
    dplyr::distinct(.data$video_id, .data$TaxonName, .data$query, .data$geo_id, .keep_all = TRUE) %>%
    dplyr::mutate(video_url = paste0("https://www.youtube.com/watch?v=", .data$video_id))
}

# ------------------------------------------------------------
# Video stats and comments
# ------------------------------------------------------------
get_video_stats_batch <- function(video_ids, api_key, sleep_seconds = 0.10) {
  url <- "https://youtube.googleapis.com/youtube/v3/videos"
  video_ids <- unique(stats::na.omit(as.character(video_ids)))
  if (length(video_ids) == 0) return(empty_stats_tbl())
  batches <- split(video_ids, ceiling(seq_along(video_ids) / 50))

  purrr::map_dfr(batches, function(batch_ids) {
    res <- yt_get(url, list(
      part = "snippet,statistics,contentDetails",
      id = paste(batch_ids, collapse = ","), key = api_key
    ), sleep_seconds = sleep_seconds)

    if (!res$ok || is.null(res$parsed) || is.null(res$parsed$items)) {
      return(tibble::tibble(
        video_id = batch_ids, viewCount = NA_real_, likeCount = NA_real_,
        commentCount = NA_real_, duration = NA_character_
      ))
    }

    got <- purrr::map_dfr(res$parsed$items, function(it) {
      tibble::tibble(
        video_id = it$id %||% NA_character_,
        viewCount = as.numeric(it$statistics$viewCount %||% NA),
        likeCount = as.numeric(it$statistics$likeCount %||% NA),
        commentCount = as.numeric(it$statistics$commentCount %||% NA),
        duration = it$contentDetails$duration %||% NA_character_
      )
    })

    missing_ids <- setdiff(batch_ids, got$video_id)
    if (length(missing_ids) > 0) {
      got <- dplyr::bind_rows(got, tibble::tibble(
        video_id = missing_ids, viewCount = NA_real_, likeCount = NA_real_,
        commentCount = NA_real_, duration = NA_character_
      ))
    }
    got
  }) %>% dplyr::distinct(.data$video_id, .keep_all = TRUE)
}

get_all_replies_for_parent <- function(parent_comment_id, api_key, sleep_seconds = 0.10) {
  url <- "https://www.googleapis.com/youtube/v3/comments"
  next_token <- NULL
  out <- list()

  repeat {
    q <- list(
      part = "snippet", parentId = parent_comment_id,
      maxResults = 100, textFormat = "plainText", key = api_key
    )
    if (!is.null(next_token)) q$pageToken <- next_token

    res <- yt_get(url, q, sleep_seconds = sleep_seconds)
    if (!res$ok || is.null(res$parsed)) {
      return(tibble::tibble(
        comment_id = NA_character_, parent_id = parent_comment_id, is_reply = TRUE,
        author = NA_character_, text = NA_character_, likeCount = NA_real_,
        publishedAt = as.POSIXct(NA, tz = "UTC"), updatedAt = as.POSIXct(NA, tz = "UTC"),
        error_status = res$status %||% NA_integer_, error_text = substr(res$text %||% "", 1, 500)
      ))
    }

    items <- res$parsed$items
    if (is.null(items) || length(items) == 0) break

    out[[length(out) + 1]] <- purrr::map_dfr(items, function(r) {
      sn <- r$snippet
      tibble::tibble(
        comment_id = r$id %||% NA_character_, parent_id = sn$parentId %||% NA_character_,
        is_reply = TRUE, author = sn$authorDisplayName %||% NA_character_,
        text = sn$textDisplay %||% NA_character_, likeCount = as.numeric(sn$likeCount %||% NA),
        publishedAt = ensure_posixct_utc(sn$publishedAt), updatedAt = ensure_posixct_utc(sn$updatedAt),
        error_status = NA_integer_, error_text = NA_character_
      )
    })

    next_token <- res$parsed$nextPageToken
    if (is.null(next_token)) break
  }

  if (length(out) == 0) return(empty_comments_tbl() %>% dplyr::select(-video_id, -TaxonName, -query))
  dplyr::bind_rows(out)
}

get_comments_for_video <- function(video_id, TaxonName, query, api_key,
                                   max_comments_per_video = 10,
                                   include_replies = TRUE,
                                   sleep_seconds = 0.10) {
  url <- "https://www.googleapis.com/youtube/v3/commentThreads"
  next_token <- NULL
  out <- list()
  fetched_top <- 0

  repeat {
    q <- list(
      part = if (include_replies) "snippet,replies" else "snippet",
      videoId = video_id, maxResults = 100, textFormat = "plainText", key = api_key
    )
    if (!is.null(next_token)) q$pageToken <- next_token

    res <- yt_get(url, q, sleep_seconds = sleep_seconds)
    if (!res$ok || is.null(res$parsed)) {
      return(tibble::tibble(
        video_id = video_id, TaxonName = TaxonName, query = query,
        error_status = res$status %||% NA_integer_, error_text = substr(res$text %||% "", 1, 500),
        comment_id = NA_character_, parent_id = NA_character_, is_reply = NA,
        author = NA_character_, text = NA_character_, likeCount = NA_real_,
        publishedAt = as.POSIXct(NA, tz = "UTC"), updatedAt = as.POSIXct(NA, tz = "UTC")
      ))
    }

    items <- res$parsed$items
    if (is.null(items) || length(items) == 0) break

    top_df <- purrr::map_dfr(items, function(it) {
      cmt <- it$snippet$topLevelComment
      sn <- cmt$snippet
      tibble::tibble(
        video_id = video_id, TaxonName = TaxonName, query = query,
        error_status = NA_integer_, error_text = NA_character_,
        comment_id = cmt$id %||% NA_character_, parent_id = NA_character_, is_reply = FALSE,
        author = sn$authorDisplayName %||% NA_character_, text = sn$textDisplay %||% NA_character_,
        likeCount = as.numeric(sn$likeCount %||% NA),
        publishedAt = ensure_posixct_utc(sn$publishedAt), updatedAt = ensure_posixct_utc(sn$updatedAt)
      )
    })

    if (nrow(top_df) > 0) {
      out[[length(out) + 1]] <- top_df
      fetched_top <- fetched_top + nrow(top_df)
    }

    if (include_replies && nrow(top_df) > 0) {
      bundled_replies <- purrr::map_dfr(items, function(it) {
        reps <- it$replies$comments
        if (is.null(reps) || length(reps) == 0) return(NULL)
        purrr::map_dfr(reps, function(r) {
          sn <- r$snippet
          tibble::tibble(
            video_id = video_id, TaxonName = TaxonName, query = query,
            error_status = NA_integer_, error_text = NA_character_,
            comment_id = r$id %||% NA_character_, parent_id = sn$parentId %||% NA_character_, is_reply = TRUE,
            author = sn$authorDisplayName %||% NA_character_, text = sn$textDisplay %||% NA_character_,
            likeCount = as.numeric(sn$likeCount %||% NA),
            publishedAt = ensure_posixct_utc(sn$publishedAt), updatedAt = ensure_posixct_utc(sn$updatedAt)
          )
        })
      })
      if (nrow(bundled_replies) > 0) out[[length(out) + 1]] <- bundled_replies

      full_replies <- purrr::map_dfr(top_df$comment_id, function(pid) {
        rr <- get_all_replies_for_parent(pid, api_key = api_key, sleep_seconds = sleep_seconds)
        if (nrow(rr) == 0) return(NULL)
        rr %>% dplyr::mutate(video_id = video_id, TaxonName = TaxonName, query = query, .before = 1)
      })
      if (nrow(full_replies) > 0) out[[length(out) + 1]] <- full_replies
    }

    next_token <- res$parsed$nextPageToken
    if (is.null(next_token) || fetched_top >= max_comments_per_video) break
  }

  if (length(out) == 0) return(empty_comments_tbl())
  dplyr::bind_rows(out) %>%
    dplyr::filter(!is.na(.data$comment_id) | !is.na(.data$error_status)) %>%
    dplyr::distinct(.data$video_id, .data$comment_id, .keep_all = TRUE)
}
