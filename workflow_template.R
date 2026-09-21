# Project-specific driver template. Run from the repository root.
source("scripts/01_taxonomic_assignment.R")
source("scripts/02_controls_and_replicates.R")
source("scripts/03_event_and_multimarker_matrices.R")
source("scripts/04_statistical_analyses.R")
source("scripts/05_sampling_effort_and_filter_tests.R")
source("scripts/06_network_plot.R")

metadata <- readr::read_csv("data/metadata/sample_metadata.csv", show_col_types = FALSE)
targets <- readr::read_csv("data/metadata/target_taxa.csv", show_col_types = FALSE)

# Replace these examples with APSCALE occurrence tables and full BLAST outputs.
input_files <- list(
  COI = list(occurrence = c("data/raw/coi_occurrence.xlsx"),
             blast = "data/blast/coi_blast.tsv"),
  `16S` = list(occurrence = c("data/raw/16s_occurrence.xlsx"),
               blast = "data/blast/16s_blast.tsv"),
  `18S` = list(occurrence = c("data/raw/18s_occurrence_part_0.xlsx",
                              "data/raw/18s_occurrence_part_1.xlsx"),
               blast = "data/blast/18s_blast.tsv")
)

# 1. Taxonomic assignment. Review the resulting LCA tables before continuing.
# taxonomy_coi <- run_taxonomy("COI", input_files$COI$occurrence, input_files$COI$blast)
# taxonomy_16s <- run_taxonomy("16S", input_files$`16S`$occurrence, input_files$`16S`$blast)
# taxonomy_18s <- run_taxonomy("18S", input_files$`18S`$occurrence, input_files$`18S`$blast)

# 2. Control subtraction and non-zero PCR-replicate averaging.
# filters_coi <- process_marker_replicates("COI", coi_esv_occurrence, metadata)
# filters_16s <- process_marker_replicates("16S", s16_esv_occurrence, metadata)
# filters_18s <- process_marker_replicates("18S", s18_esv_occurrence, metadata)

# 3. Read the manually reviewed taxonomy tables and build event matrices.
# reviewed_taxonomy <- bind_rows(
#   read_csv("data/reviewed_taxonomy/COI_reviewed.csv"),
#   read_csv("data/reviewed_taxonomy/16S_reviewed.csv"),
#   read_csv("data/reviewed_taxonomy/18S_reviewed.csv")
# )
# matrices <- build_event_dataset(
#   filter_esvs = bind_rows(filters_coi, filters_16s, filters_18s),
#   lca_assignments = reviewed_taxonomy,
#   event_metadata = metadata,
#   target_lookup = targets
# )

# 4. Community analyses use the cross-marker presence-absence matrix.
# analyses <- run_statistical_analyses(
#   pa_wide = matrices$pa,
#   event_metadata = distinct(metadata, event_id, .keep_all = TRUE)
# )

# 5. Save network outputs after supplying the reviewed ecological-group table.
# ecological_groups <- read_csv("data/metadata/ecological_groups.csv")
# save_network_outputs(analyses$network, ecological_groups)
