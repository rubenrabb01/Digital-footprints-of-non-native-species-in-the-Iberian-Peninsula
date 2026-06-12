# ============================================================
# 00_species_search_terms_template.R
# Search terms used by the YouTube API pre-workflow.
#
# Replace this example with the full species list used in the study.
# The recommended structure is a NAMED list:
#   names = TaxonName using underscores
#   values = scientific and/or common names to query on YouTube
#
# You can either:
#   1) put all species in SPECIES_SEARCH_TERMS below, or
#   2) point CONFIG$species_terms_file to another R file defining one of:
#        SPECIES_SEARCH_TERMS, all_lists, all_lists_NEW_ES_PT_regioncode_scientific_common,
#        all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded, etc.
# ============================================================

SPECIES_SEARCH_TERMS <- list(
  Vespa_velutina = c(
    "Vespa velutina",
    "avispa asiática",
    "avispa asiatica",
    "vespa asiática",
    "vespa asiatica"
  ),
  Psittacus_erithacus = c(
    "Psittacus erithacus",
    "loro gris africano",
    "papagaio cinzento"
  ),
  Xylella_fastidiosa = c(
    "Xylella fastidiosa"
  ),
  Rugulopteryx_okamurae = c(
    "Rugulopteryx okamurae"
  ),
  Phthorimaea_absoluta = c(
    "Phthorimaea absoluta",
    "Tuta absoluta",
    "polilla del tomate"
  )
)
