# Data folders

- `paper_input/`: curated input files used by the main paper workflow.
- `preparation_input/`: optional upstream preparation files documenting the transition from raw YouTube API outputs to manually screened/validated candidate videos.
- `preparation_input/preparation_input_manifest.csv`: file-level manifest with row counts, column counts, file sizes, checksums, and descriptions.

The main paper analyses use `paper_input/`. The preparation files are included for transparency and to document how the validated paper inputs were derived.

## Main paper input files

- `paper_input/videos_validated.csv`: validated video-level dataset used in the main paper analyses.
- `paper_input/comments_timestamped.csv`: timestamped comments and replies used for the comments-only sensitivity analysis.

## Preparation input files

See [`preparation_input/README.md`](preparation_input/README.md) for a file-by-file description of the optional upstream preparation files.
