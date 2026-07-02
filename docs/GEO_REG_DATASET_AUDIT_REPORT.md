# GEO/REG dataset audit

This audit compares the source-flagged working datasets with the current GitHub package to document the GEO and REG dataset pathways.

## Main conclusion

The geotag/location-based anchor can be derived consistently from older source-flagged working files by selecting rows where `source_flag` is `GEO` or `BOTH`.

Across all comparable source-flagged datasets, the same **305 unique GEO/BOTH video IDs** were recovered. The split between `GEO` and `BOTH` changes between working files because `BOTH` depends on which REG variant was compared with the GEO anchor. Therefore, the robust quantity is the combined `GEO or BOTH` set, not the exact `GEO`/`BOTH` split in any one intermediate file.

## Canonical repository files

| Label | File | Rows | Unique videos | Meaning |
|---|---|---:|---:|---|
| RAW-REG | `data/preparation_input/api_regioncode_raw.csv` (**RAW-REG**) | 16,844 | 16,844 | Full raw region-code video pool. |
| RAW-REG flagged | `data/preparation_input/api_regioncode_raw_flagged.csv` (**RAW-REG flagged**) | 16,844 | 16,844 | Same RAW-REG pool with retained/rejected flag. |
| REG post-filtered candidates | `data/preparation_input/api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**) | 6,935 | 6,935 | Clean filtered REG candidate set. |
| REG-labelled | `data/preparation_input/api_regioncode_labelled.csv` (**REG-labelled**) | 1,884 | 1,884 | REG videos labelled as Iberia-relevant. |
| GEO anchor / source-flagged GEO | `data/preparation_input/api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**) | 305 | 305 | Derived from older source-flagged working files by selecting `GEO` or `BOTH`. |
| Final LABEL dataset | `data/paper_input/videos_validated.csv` (**final LABEL dataset**) | 1,895 distinct videos | Final analysis-ready paper dataset. |

## GEO anchor overlap with current repository datasets

The 305-video GEO anchor is real and consistent across the older source-flagged working files. However, it is not identical to the current final LABEL dataset. Only 68 of the 305 GEO anchor video IDs overlap `data/paper_input/videos_validated.csv` (**final LABEL dataset**).

Therefore:

- `api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**) documents the geotag/location-based search pathway.
- `videos_validated.csv` (**final LABEL dataset**) remains the analysis-ready paper dataset used by the current scripts.
- The GEO anchor should not be used as a replacement for the final LABEL dataset.

## Supporting audit tables

- `docs/source_flag_file_summary.csv`: source-flag counts in the uploaded working files.
- `docs/geo_sourceflag_comparison_summary.csv`: comparison of GEO/BOTH video IDs across source-flagged working files.
- `docs/geo_anchor_overlap_with_repo_datasets.csv`: overlap between the source-flagged GEO anchor and current repository datasets.

### Counting note for the final LABEL dataset

`videos_validated.csv` (**final LABEL dataset**) contains **1,895 distinct video-level records**, and this is the count used in the manuscript and main workflow. The `video_id` field is unique in this final file after video-level deduplication.
