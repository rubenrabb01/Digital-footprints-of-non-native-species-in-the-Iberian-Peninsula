# Optional YouTube API pre-workflow

This folder contains optional scripts for retrieving YouTube API search results.

The main manuscript analyses do not require rerunning the API search. They are reproducible from the curated files in `data/paper_input/` and the lineage files in `data/preparation_input/`. Rerunning the API search is useful only for testing, transparency, or future updates because YouTube API results can change over time and are quota-limited.

## Contents

- `scripts/00_youtube_search_config.R`: API search settings and run modes.
- `scripts/01_youtube_api_helpers.R`: helper functions for YouTube API calls.
- `scripts/02_run_youtube_search_lists.R`: runs the search lists.
- `scripts/03_combine_youtube_search_outputs.R`: combines per-list outputs.
- `scripts/04_inspect_api_outputs.R`: summarises API outputs.
- `scripts/99_run_youtube_api_preworkflow.R`: wrapper script.

## Small API test from the repository root

The easiest way to test the API workflow is to run the root-level wrapper:

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
RUN_MODE <- "test_REG"
source("scripts/99_run_optional_api_test.R", encoding = "UTF-8")
```

Other small test modes are:

```r
RUN_MODE <- "test_GEO"
RUN_MODE <- "test_REG_GEO"
RUN_MODE <- "test_comments"
```

Do not save or commit your API key.

## Direct run from inside this folder

You can also run the optional API scripts directly from this folder:

```r
rm(list = ls())
setwd(file.path("YOUR_PROJECT_FOLDER", "optional_youtube_api_preworkflow"))
Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
RUN_MODE <- "test_REG"
source("scripts/99_run_youtube_api_preworkflow.R", encoding = "UTF-8")
```

## API key

The API key can also be stored in a local `.Renviron` file outside version control:

```text
YOUTUBE_API_KEY=YOUR_KEY_HERE
```

Never commit `.Renviron` or any file containing an API key.
