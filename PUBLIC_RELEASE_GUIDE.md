# Repository release guide

This repository provides a reproducible version of the workflow used in the associated manuscript.

## Included materials

- `scripts/`: main analysis, validation, figure, table, and runner scripts.
- `data/paper_input/`: curated analysis inputs.
- `data/species_input/`: derived species-list and search-term inputs.
- `data/preparation_input/`: lineage files documenting the REG/GEO preparation path.
- `data/validation_input/`: validation templates and completed anonymised validation files.
- `outputs/`: generated figures, tables, validation summaries, and intermediate files.
- `docs/`: data guides and release notes.
- `optional_youtube_api_preworkflow/`: optional YouTube API retrieval scripts.
- `data_preparation_workflow/`: optional upstream data-preparation scripts.

## Main analytical corpus

The manuscript analyses use:

```text
data/paper_input/videos_validated.csv
```

This file contains the final manually curated Iberia-relevant corpus: **1,895 distinct YouTube videos from 1,002 channels and 94 species**. In the workflow this file is also referred to as the final LABEL dataset.

## Validation files

Completed validation files are stored under:

```text
data/validation_input/completed/validation_files_by_validator/
```

Active validators are `Reviewer_A` for video validation and `Reviewer_B`/`Reviewer_D` for both video and keyword validation. The validation workflow writes summary tables and Figures S8-S9 under `outputs/`.


