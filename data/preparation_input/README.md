# Preparation-input data

This folder documents the upstream filtering path from raw/API-derived candidate videos to the final paper input. These files are included for transparency and auditability; the manuscript analyses themselves use the curated files in `data/paper_input/`.

## Canonical files

| Label | File | Description |
|---|---|---|
| RAW-REG | `api_regioncode_raw.csv` (**RAW-REG**) | Full raw region-code video pool after deduplication: 16,844 unique videos. This is the raw REG starting point. |
| RAW-REG flagged | `api_regioncode_raw_flagged.csv` (**RAW-REG flagged**) | Same 16,844-video pool with an `is_iberian` flag documenting rows retained or rejected during filtering/labelling. |
| REG post-filtered candidates | `api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**) | Clean post-filtered REG candidate dataset after language and Iberian locality filters: 6,935 unique videos. |
| REG-labelled | `api_regioncode_labelled.csv` (**REG-labelled**) | REG videos labelled as Iberia-relevant after filtering and labelling: 1,884 unique videos. |
| GEO anchor reconstructed / reconstructed RAW-GEO | `api_geotagged_anchor_reconstructed.csv` (**GEO anchor reconstructed / reconstructed RAW-GEO**) | Geotag/location-based anchor recovered from older source-flagged working files by selecting rows with `source_flag` equal to `GEO` or `BOTH`: 305 unique videos. |
| Final LABEL dataset | `../paper_input/videos_validated.csv` (**final LABEL dataset**) | Final validated video-level dataset used by the manuscript scripts: 1,899 rows and 1,895 unique videos. |

## Simplified lineage

```text
api_regioncode_raw.csv (RAW-REG; 16,844 videos)
  -> api_regioncode_postfiltered_candidates.csv (REG post-filtered candidates; 6,935 videos)
  -> api_regioncode_labelled.csv (REG-labelled; 1,884 videos)
  -> data/paper_input/videos_validated.csv (final LABEL dataset; 1,899 rows / 1,895 unique videos)

api_geotagged_anchor_reconstructed.csv (GEO anchor reconstructed / reconstructed RAW-GEO; 305 videos)
  -> recovered from older source-flagged working files using source_flag == GEO or BOTH
```

The final LABEL dataset contains the REG-labelled videos plus a small set of manually added *Xylocopa pubescens* videos and comment-timing metadata used by the analysis workflow.

## GEO and REG terminology

- **REG** refers to the region-code search path, represented here by `api_regioncode_raw.csv` (**RAW-REG**), `api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**), and `api_regioncode_labelled.csv` (**REG-labelled**).
- **GEO** refers to the geotag/location-based search path. The recovered GEO anchor is included as `api_geotagged_anchor_reconstructed.csv` (**GEO anchor reconstructed / reconstructed RAW-GEO**). Across the comparable older source-flagged working files, the same 305 GEO/BOTH video IDs were recovered, although the split between `GEO` and `BOTH` changed depending on which REG variant was compared with GEO.
- The file name uses `reconstructed` because this GEO anchor was recovered from older source-flagged working files rather than from a standalone raw GEO API export.
- Small optional API-test GEO files, if present, are kept under `data/api_test_input/` and should not be interpreted as the historical GEO anchor.

## Relationship between GEO and the current LABEL dataset

The current `data/paper_input/videos_validated.csv` (**final LABEL dataset**) is the analysis-ready dataset. In this audit, 68 of the 305 GEO anchor reconstructed video IDs overlapped the current final LABEL dataset. Therefore, `api_geotagged_anchor_reconstructed.csv` (**GEO anchor reconstructed / reconstructed RAW-GEO**) documents an upstream/historical source component, not a replacement for the final paper dataset used by the current scripts.
