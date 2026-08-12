# Project-specific driver template. Run from the repository root.
source("scripts/01_taxonomic_assignment.R")
source("scripts/02_controls_and_replicates.R")
source("scripts/03_event_and_multimarker_matrices.R")
source("scripts/04_statistical_analyses.R")
source("scripts/05_sampling_effort_and_filter_tests.R")
source("scripts/06_network_plot.R")

metadata <- read_csv("data/metadata/sample_metadata.csv", show_col_types = FALSE)
targets <- read_csv("data/metadata/target_taxa.csv", show_col_types = FALSE)

# Define the actual APSCALE occurrence-table parts and BLAST output for each marker.
input_files <- list(
  COI = list(occurrence = character(), blast = ""),
  `16S` = list(occurrence = character(), blast = ""),
  `18S` = list(occurrence = character(), blast = "")
)

# Example taxonomy call after populating input_files:
# taxonomy_coi <- run_taxonomy("COI", input_files$COI$occurrence, input_files$COI$blast)

# Example replicate-processing call:
# filters_coi <- process_marker_replicates("COI", coi_esv_occurrence, metadata)

# After manual LCA review, combine marker objects and build event matrices:
# matrices <- build_event_dataset(
#   filter_esvs = bind_rows(filters_coi, filters_16s, filters_18s),
#   lca_assignments = bind_rows(lca_coi, lca_16s, lca_18s),
#   event_metadata = metadata,
#   target_lookup = targets
# )

# analyses <- run_statistical_analyses(
#   matrices$rra, matrices$pa, distinct(metadata, event_id, .keep_all = TRUE)
# )
# save_network_outputs(analyses$network, ecological_guild_table)

