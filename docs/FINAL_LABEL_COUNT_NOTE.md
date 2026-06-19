# Final LABEL dataset count note

The manuscript count should remain **1,899 videos / video records**.

In the public workflow, `data/paper_input/videos_validated.csv` (**final LABEL dataset**) contains **1,899 analysed video records**. This is the final corpus count used by the manuscript analyses.

A smaller number can appear if the file is summarised only by distinct values in the `video_id` column. That distinct-ID count should not replace the manuscript count. A small number of records may be repeated across search queries or may display oddly in spreadsheet software (for example as `#¿NOMBRE?` in some older working files or spreadsheet views), but these records correspond to valid analysed videos and were retained in the final dataset.

Recommended wording:

> The final LABEL dataset contained 1,899 analysed YouTube video records.

For technical checks, row counts can be inspected with `scripts/00_check_dataset_lineage.R`, but the manuscript/reporting count for the final corpus is 1,899 analysed records.
