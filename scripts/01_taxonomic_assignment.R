source("scripts/00_packages.R")
source("R/io_helpers.R")
source("R/taxonomy_functions.R")

marker_config <- read_csv("config/marker_config.csv", show_col_types = FALSE)

run_taxonomy <- function(marker, occurrence_files, blast_file) {
  marker_dir <- file.path(paths$intermediate, tolower(marker))

  occurrence <- read_occurrence_parts(occurrence_files)
  blast <- read_blast_table(blast_file) %>% prepare_accessions()
  blast_taxonomy <- fetch_taxonomy_metabark(
    blast,
    file.path(marker_dir, paste0(marker, "_all_hits_with_taxonomy.csv"))
  )
  candidates <- retain_candidate_hits(blast_taxonomy, marker, marker_config)
  lca <- assign_lca(candidates, marker_config) %>% clean_assignments()

  write_checkpoint(lca, file.path(marker_dir, paste0(marker, "_lca_assignments.csv")))
  invisible(list(lca = lca, occurrence = occurrence,
                 candidate_hits = candidates))
}

# Provide project-specific files here, then run one marker at a time:
# coi <- run_taxonomy("COI", c("part_0.xlsx", "part_1.xlsx"), "coi_blast.tsv")
# s16 <- run_taxonomy("16S", c("part_0.xlsx", "part_1.xlsx"), "16s_blast.tsv")
# s18 <- run_taxonomy("18S", c("part_0.xlsx", "part_1.xlsx"), "18s_blast.tsv")
