# Release notes v1.0.2

This release updates the reproducible package for the revised manuscript.

## Main updates

- Final corpus corrected to **1,895 distinct YouTube videos**, **1,002 channels**, and **94 species**.
- Video-level deduplication included in the dataset-preparation workflow.
- Validation files reorganised under `data/validation_input/` with anonymised validator IDs.
- Final video validation uses three validators: `Reviewer_A`, `Reviewer_B`, and `Reviewer_D`.
- Final keyword validation uses two validators: `Reviewer_B` and `Reviewer_D`.
- Validation scripts and Supplementary Figure S9 updated to the final validation summaries.
- `None / not thematic` is retained in the keyword confusion matrix; ambiguous/unresolved keyword cases are summarised separately and excluded from scoring metrics.
- Documentation clarifies that LABEL is an internal workflow name for the final manually curated Iberia-relevant corpus.

## Main corpus file

```text
data/paper_input/videos_validated.csv
```

Recommended manuscript-aligned wording:

> The final manually curated Iberia-relevant corpus contained 1,895 distinct YouTube videos from 1,002 channels and 94 species.
