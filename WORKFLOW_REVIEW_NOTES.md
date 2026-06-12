# Workflow review notes

Conservative changes were made only to documentation and minor robustness checks. The analysis order and script logic were not redesigned.

## Minor edits made

- Updated the root `README.md` to make the run options shorter and clearer.
- Updated `scripts/HOW_TO_RUN_WORKFLOW.R` so the project path instructions are less tied to one local machine.
- Corrected `README_DUMMY_VALIDATION_FILES.txt`, which referred to an old validation script/folder name.
- Clarified `data/README.md`.
- Removed a duplicated candidate path in `scripts/01_load_prepare_video_dataset.R`.
- Added fallback support in `scripts/15_validation_audits.R` so compact public releases can use consensus validation files without reviewer-specific folders.

## Naming notes

The numbered script names are already clear and should not be changed now, because the runner scripts source them directly. Renaming would add risk without improving reproducibility.

For public release, consider keeping the full internal archive separate from a compact reproducible release. The compact release can exclude raw API outputs, reviewer-specific validation files, old archived scripts, and generated intermediate outputs.
