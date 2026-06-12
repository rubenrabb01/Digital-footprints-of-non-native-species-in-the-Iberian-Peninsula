# Data file guide

This repository contains two main data levels: curated paper inputs and optional preparation inputs. The preparation files document how raw YouTube API candidate records were filtered and labelled before the final paper dataset was exported.

## Dataset terminology

- **RAW-REG**: `data/preparation_input/api_regioncode_raw.csv`. Full raw region-code video pool retrieved from YouTube searches before filtering. This is the broad upstream set of videos found through ES/PT region-code searches. It is not manually validated and should not be interpreted as the final Iberian dataset.
- **GEO**: `data/preparation_input/api_geotagged_raw.csv` when available. Geotagged, location-based candidate source. GEO differs from REG because it depends on video geolocation information rather than only region-code/search-result retrieval.
- **REG**: region-code candidate pathway. REG begins with `api_regioncode_raw.csv`, then passes through filtering and labelling files.
- **REG-labelled**: `data/preparation_input/api_regioncode_labelled.csv`. Region-code candidate dataset after filtering and manual Iberian-relevance labelling. The main label column is `is_iberian`.
- **LABEL / final paper dataset**: `data/paper_input/videos_validated.csv`. Curated validated video-level dataset used for the manuscript analyses, figures, and tables. This is the main file for reproducing the paper results.

A short way to read the workflow is:

```text
RAW-REG api_regioncode_raw.csv
  -> filtered REG candidates
  -> REG-labelled api_regioncode_labelled.csv
  -> LABEL / final paper dataset videos_validated.csv
```

## 1. Curated paper inputs

These are the files required to reproduce the main analyses and figures in the manuscript.

- `data/paper_input/videos_validated.csv`: final curated validated video-level dataset used by the main paper workflow.
- `data/paper_input/comments_timestamped.csv`: timestamped comments and replies used only for the comments-only sensitivity analysis.

## 2. Optional preparation inputs

These files document the upstream path from YouTube API outputs to the curated paper inputs. They are not required for a normal rerun of the main paper workflow, but they improve transparency and make it possible to inspect the filtering, manual-screening, and candidate-selection stages.

Key files:

- `data/preparation_input/api_regioncode_raw.csv`: full raw region-code video pool before filtering (**RAW-REG**).
- `data/preparation_input/api_regioncode_filtered_candidates.csv`: region-code candidates retained after light screening.
- `data/preparation_input/api_regioncode_labelled.csv`: region-code candidates with manual Iberian-relevance labels (**REG-labelled**).
- `data/preparation_input/api_geotagged_raw.csv`: geotagged candidate source when available (**GEO**).
- `data/preparation_input/api_reg_geo_candidates_long.csv`: combined long-format candidate table joining the REG and GEO candidate pathways when both are available.
- `data/preparation_input/api_candidates_for_manual_labeling.csv`: candidate table prepared for manual labelling.
- `data/preparation_input/api_candidates_labelled.csv`: labelled candidate table after manual screening.
- `data/preparation_input/videos_validated_from_api.csv`: validated videos exported from the optional preparation workflow.
- `data/preparation_input/videos_excluded_after_labeling.csv`: videos excluded after manual labelling.
- `data/preparation_input/preparation_input_manifest.csv`: row counts, column counts, file sizes, checksums, and descriptions for all preparation files.

The main manuscript results should be reproduced from `data/paper_input/`, not by rerunning the YouTube API search, because YouTube API results and comments can change over time.
