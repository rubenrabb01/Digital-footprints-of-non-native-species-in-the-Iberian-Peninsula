# Validation outputs

This folder contains validation-related outputs and compatibility folders for completed validation files.

Recommended input location for completed validation files:

```text
data/validation_input/completed/
```

Legacy input locations are also supported here for compatibility with earlier workflow versions:

```text
outputs/validation/completed/validation_files_by_reviewer/
outputs/validation/completed/validation_files_by_validator/
```

Running `scripts/99_run_validation_audits.R` updates validation tables in `outputs/validation/tables/` and validation figures in `outputs/figures/supplement/`.
