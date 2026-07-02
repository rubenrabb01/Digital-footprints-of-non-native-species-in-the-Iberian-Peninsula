# Validation input files

This folder contains the manually completed validation inputs used by the validation workflow.

## Active completed validation files

Use only this folder as the source of completed reviewer/validator input files:

```text
data/validation_input/completed/validation_files_by_validator/
```

The active completed files are anonymised and use the same anonymised video identifiers as `data/paper_input/videos_validated.csv`; YouTube URLs are withheld.

The active completed files are:

- `Reviewer_A`: video-level Iberia-relevance validation only.
- `Reviewer_B`: video-level Iberia-relevance validation and keyword-category validation.
- `Reviewer_D`: video-level Iberia-relevance validation and keyword-category validation.

The manually completed pre-record context file used to regenerate Figure S8 is stored in:

```text
data/validation_input/completed/lead_lag_context/lead_lag_prerecord_context_completed.csv
```

## Generated outputs

Do not place completed reviewer files in `outputs/`. When the scripts are run, they write generated consensus tables, metrics, and figure-index files under `outputs/validation/`, and paper-ready figures under `outputs/figures/supplement/`.
