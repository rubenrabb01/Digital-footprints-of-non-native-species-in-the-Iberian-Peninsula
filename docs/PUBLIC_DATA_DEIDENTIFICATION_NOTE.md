# Data de-identification note

The repository uses de-identified YouTube-derived data. Direct YouTube video identifiers, video URLs, channel names, comment identifiers, and comment-author names have been replaced with stable internal labels or withheld in the CSV files. The lookup table linking internal labels to original YouTube identifiers is not included.

This preserves the structure needed for the manuscript workflow: repeated videos and channels retain consistent internal labels, so deduplication, channel-concentration analyses, validation summaries, and temporal analyses can still be reproduced.

Video titles, descriptions, and comment text fields are retained in the analysis input files because they are required to reproduce the tokenisation and thematic-classification steps. These fields should be handled as platform-derived text and should not be interpreted as author-created content. API keys, direct video URLs, original video IDs, original channel names, and raw RDS API objects are not included in the repository files.

Inline web links found inside text fields were replaced with `[link withheld]`.
