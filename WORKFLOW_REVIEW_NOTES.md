# Workflow review notes

This note summarises documentation and robustness updates made to the reproducible workflow. The analytical sequence, model structure, and figure-generation logic were preserved.

## Updates in this release

- The final video-level corpus is deduplicated to **1,895 distinct videos**, **1,002 channels**, and **94 species**.
- `scripts/01_load_prepare_video_dataset.R` includes the video-level deduplication used by the final corpus.
- Validation inputs are organised under `data/validation_input/`, with generated summaries under `outputs/validation/`.
- Validation scripts use the active anonymised validator files: `Reviewer_A` for video validation and `Reviewer_B`/`Reviewer_D` for video and keyword validation.
- Supplementary Figure S9 and its source tables reflect the final validation summaries.
- Documentation maps the internal workflow term LABEL to the final manually curated Iberia-relevant corpus used in the manuscript.

The numbered script names are retained because they define the execution order used by the runner scripts.
