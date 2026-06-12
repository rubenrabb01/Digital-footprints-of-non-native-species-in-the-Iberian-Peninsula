# Data file guide

This repository contains two main data levels.

## 1. Curated paper inputs

These are the files required to reproduce the main analyses and figures in the manuscript.

- `data/paper_input/videos_validated.csv`: final validated video-level dataset.
- `data/paper_input/comments_timestamped.csv`: timestamped comments and replies used only for the comments-only sensitivity analysis.

## 2. Optional preparation inputs

These files document the upstream path from YouTube API outputs to the curated paper inputs. They are not required for a normal rerun of the main paper workflow, but they improve transparency and make it possible to inspect the filtering, manual-screening, and candidate-selection stages.

Key files:

- `data/preparation_input/api_regioncode_raw.csv`: full raw region-code video pool before filtering.
- `data/preparation_input/api_regioncode_filtered_candidates.csv`: region-code candidates retained after light screening.
- `data/preparation_input/api_regioncode_labelled.csv`: region-code candidates with manual Iberian-relevance labels.
- `data/preparation_input/api_candidates_for_manual_labeling.csv`: candidate table prepared for manual labelling.
- `data/preparation_input/api_candidates_labelled.csv`: labelled candidate table after manual screening.
- `data/preparation_input/videos_validated_from_api.csv`: validated videos exported from the optional preparation workflow.
- `data/preparation_input/videos_excluded_after_labeling.csv`: videos excluded after manual labelling.
- `data/preparation_input/preparation_input_manifest.csv`: row counts, column counts, file sizes, checksums, and descriptions for all preparation files.

The main manuscript results should be reproduced from `data/paper_input/`, not by rerunning the YouTube API search, because YouTube API results and comments can change over time.
