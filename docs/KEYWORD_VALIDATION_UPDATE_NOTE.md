# Keyword validation update note

The completed keyword-validation inputs are stored under the anonymised validator folders in `data/validation_input/completed/validation_files_by_validator/`.

The final keyword-validation summary uses the two active keyword validators with comparable completed files: `Reviewer_B` and `Reviewer_D`. `Reviewer_A` contributed video-level Iberia-relevance validation only.

Multi-category keyword decisions are collapsed to one decision per validator and keyword occurrence before scoring. When a multi-category thematic decision includes the dictionary-assigned category, the occurrence is scored as that dictionary category; otherwise, it is treated as Ambiguous. Ambiguous/unresolved cases are summarised separately and excluded from the confusion matrix and scoring metrics. Manual `None` / not thematic cases are retained in the confusion matrix so dictionary-assigned keyword occurrences judged invalid or non-thematic remain visible.
