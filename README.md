# Data folders

- `paper_input/`: curated input files used by the main paper workflow.
- `preparation_input/`: optional upstream preparation files documenting the transition from raw YouTube API outputs to manually screened/validated candidate videos.
- `preparation_input/preparation_input_manifest.csv`: file-level manifest with row counts, column counts, file sizes, checksums, and descriptions.

The main paper analyses use `paper_input/`. The preparation files are included for transparency and to document how the validated paper inputs were derived.


## Key dataset names

- **RAW-REG** = `preparation_input/api_regioncode_raw.csv`: full raw region-code search pool before filtering.
- **GEO** = `preparation_input/api_geotagged_raw.csv`: geotagged candidate source when available.
- **REG-labelled** = `preparation_input/api_regioncode_labelled.csv`: region-code candidates after filtering and manual Iberian-relevance labelling.
- **LABEL / final paper dataset** = `paper_input/videos_validated.csv`: curated validated video-level dataset used by the main analyses.

Use `paper_input/videos_validated.csv` for reproducing the paper. Use `preparation_input/` only to inspect the upstream filtering and labelling path.

## Main paper input files

- `paper_input/videos_validated.csv`: validated video-level dataset used in the main paper analyses.
- `paper_input/comments_timestamped.csv`: timestamped comments and replies used for the comments-only sensitivity analysis.

## Preparation input files

See [`preparation_input/README.md`](preparation_input/README.md) for a file-by-file description of the optional upstream preparation files.
