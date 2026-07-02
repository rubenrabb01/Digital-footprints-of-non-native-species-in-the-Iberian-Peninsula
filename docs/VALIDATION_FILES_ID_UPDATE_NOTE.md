# Validation files ID update note

This package uses anonymised video identifiers in the public `data/paper_input/videos_validated.csv` file. Completed validation files originally returned by reviewers used the original YouTube video IDs so that reviewers could inspect the videos. For the public/reproducible package, the completed validation files have been updated so that their `video_id` values match the anonymised IDs used in `videos_validated.csv`; YouTube URLs are withheld and channel names are represented by anonymised channel identifiers.

The mapping from original YouTube IDs to anonymised IDs is not included in the public package.

The video-level LABEL dataset contains 1,895 distinct videos after deduplicating repeated query-level rows for four Xylocopa pubescens videos that appeared under more than one search term. The same trimmed-`video_id` deduplication logic is included in `scripts/01_load_prepare_video_dataset.R` and mirrored in the validation-pool construction in `scripts/15_validation_audits.R`.

Keyword-validation files may contain multi-category decisions from a validator either as multiple categories in one cell or as repeated rows for the same keyword occurrence. The validation script collapses these to one decision per validator and keyword occurrence before scoring. When a multi-category thematic decision includes the dictionary-assigned category, the occurrence is scored as that dictionary category; otherwise, it is treated as Ambiguous and excluded from the confusion matrix and scoring metrics.
