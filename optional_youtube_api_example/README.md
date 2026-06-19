# Optional YouTube API example

This folder contains a minimal illustrative YouTube Data API example. It is not required to reproduce the manuscript analyses.

The full manuscript analyses are reproduced from the curated, de-identified files in `data/paper_input/` and the supporting lineage files in `data/preparation_input/`. The complete bulk API retrieval workflow and raw API outputs are not redistributed in the public package because YouTube API results are dynamic, quota-limited, and may include platform-level metadata that should not be treated as stable public analytical input.

The example script demonstrates only the basic structure of a single API query using one example search term and a placeholder API key. It does not reproduce the full search strategy, batching, filtering, validation, or corpus construction workflow used in the study. Those steps are described in the manuscript, Supplementary Methods, and repository documentation.

## How to run

From the repository root:

```r
Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
source("optional_youtube_api_example/example_single_species_youtube_api_query.R", encoding = "UTF-8")
```

The example writes a small demonstration CSV to:

```text
optional_youtube_api_example/outputs/example_single_query_results.csv
```

Do not save or commit API keys. API results may differ across dates, accounts, quota states, and YouTube ranking/indexing changes.
