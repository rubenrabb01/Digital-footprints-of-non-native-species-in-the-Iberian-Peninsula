# Preparation-input data

This folder documents the upstream filtering path from API-derived candidate videos to the final paper input. The manuscript analyses use the curated files in `data/paper_input/`.

## Canonical files

| File | Description |
|---|---|
| `api_regioncode_raw.csv` | Full raw region-code candidate pool after deduplication: 16,844 unique videos. |
| `api_regioncode_raw_flagged.csv` | The same region-code pool with an Iberia-relevance flag. |
| `api_regioncode_postfiltered_candidates.csv` | Post-filtered REG candidate dataset after ecological, linguistic, and Iberian locality filters: 6,935 unique videos. |
| `api_regioncode_labelled.csv` | REG videos retained as Iberia-relevant after filtering and labelling: 1,884 unique videos. |
| `api_geotagged_anchor_sourceflag.csv` | Geotag/location-based GEO anchor: 305 unique videos. |
| `../paper_input/videos_validated.csv` | Final manually curated Iberia-relevant video-level corpus used by the manuscript scripts: 1,895 distinct YouTube videos. |

## Simplified lineage

```text
Raw region-code pool
  -> post-filtered REG candidates
  -> manually verified REG records
  -> integration with GEO/manual additions
  -> video-level deduplication
  -> final LABEL corpus used in the analyses
```

The GEO and REG pathways were treated differently because the API `regionCode` parameter does not identify upload, filming, or species-observation location. REG records were screened and manually reviewed before inclusion in the final corpus.

The final corpus should be interpreted as an Iberia-relevant, manually validated YouTube corpus, not as confirmed species occurrence records.
