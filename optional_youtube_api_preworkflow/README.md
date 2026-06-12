# Optional YouTube API pre-workflow

This folder contains the optional upstream scripts used to retrieve YouTube API search results.

The main manuscript analyses do **not** require rerunning the API search. They are reproducible from the curated files in `data/paper_input/` and the lineage files in `data/preparation_input/`.

## What this folder is for

Use this folder only if you want to inspect or rerun the upstream YouTube API retrieval step.

- `scripts/00_youtube_search_config.R`: API search settings.
- `scripts/01_youtube_api_helpers.R`: helper functions for YouTube API calls.
- `scripts/02_run_youtube_search_lists.R`: runs the search lists.
- `scripts/03_combine_youtube_search_outputs.R`: combines per-list outputs.
- `scripts/04_inspect_api_outputs.R`: summarizes API outputs.
- `scripts/99_run_youtube_api_preworkflow.R`: wrapper script.

## API key

Set the API key locally before running. Do not write the key into any script.

```r
Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
```

## Outputs

New API outputs are written locally to:

- `optional_youtube_api_preworkflow/data_raw/`
- `optional_youtube_api_preworkflow/yt_api_outputs/`

These generated outputs are not required for normal paper reproduction and are intentionally not treated as canonical repository inputs.

## Canonical public data files

For the frozen manuscript workflow, use:

- `data/preparation_input/api_regioncode_raw.csv` (**RAW-REG**)
- `data/preparation_input/api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**)
- `data/preparation_input/api_regioncode_labelled.csv` (**REG-labelled**)
- `data/preparation_input/api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**)
- `data/paper_input/videos_validated.csv` (**final LABEL dataset**)
