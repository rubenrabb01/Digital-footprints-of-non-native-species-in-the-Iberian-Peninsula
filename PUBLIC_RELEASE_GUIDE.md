# Suggested public GitHub/Zenodo release

This project can be shared in two forms.

## 1. Full internal archive

Keep this privately for you and coauthors. It can include raw API outputs, archived exploratory scripts, reviewer-specific validation files, generated outputs, and all intermediate files.

## 2. Compact reproducible public release

Use this for GitHub/Zenodo if the goal is paper reproducibility without exposing every development file.

Recommended contents:

- `README.md`
- `scripts/`
- `data/paper_input/videos_validated.csv`
- `data/paper_input/comments_timestamped.csv`
- `fig_assets/`
- `docs/keyword_lists_cleaned.R`
- consensus validation files:
  - `outputs/validation/completed/LABEL_iberian_relevance_validation_completed_consensus.csv`
  - `outputs/validation/completed/keyword_occurrence_validation_completed_consensus.csv`
  - `outputs/validation/lead_lag_context/completed/lead_lag_prerecord_context_completed.csv`
- optional metadata files: `CITATION.cff`, `.zenodo.json`, `LICENSE` or `LICENSE.txt`

Files that are usually not necessary in the public release:

- raw YouTube API output folders
- per-reviewer/per-validator validation files
- old archived scripts
- generated figures/tables/intermediate outputs, unless the journal specifically wants them deposited
- local machine paths or API keys

The compact release should still be tested by deleting `outputs/`, running the scripts from a clean session, and confirming that the expected figures and tables are regenerated.
