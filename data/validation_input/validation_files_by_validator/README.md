# Validation files by validator

This folder contains anonymised validation templates for two manual checks:

1. `*_LABEL_Iberia_relevance_validation.csv`: video-level Iberia-relevance validation.
2. `*_keyword_category_validation.csv`: keyword-occurrence validation for thematic classification.

Each file contains a shared block of records plus validator-specific records. Completed files can be placed in:

```text
data/validation_input/completed/validation_files_by_validator/
```

The workflow also supports legacy completed-file locations under `outputs/validation/completed/`. Artificial completed examples are provided only for testing and should be replaced before reporting final validation values.
