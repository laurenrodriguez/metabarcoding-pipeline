source("scripts/00_packages.R")
source("R/io_helpers.R")
source("R/taxonomy_functions.R")

marker_config <- read_csv("config/marker_config.csv", show_col_types = FALSE)

run_taxonomy <- function(marker, occurrence_files, blast_file) {
  marker_dir <- file.path(paths$intermediate, tolower(marker))
  chunk_dir <- file.path(marker_dir, "taxonomy_chunks")
  retry_dir <- file.path(marker_dir, "taxonomy_retries")

  occurrence <- read_occurrence_parts(occurrence_files)
  blast <- read_blast_table(blast_file) %>% prepare_accessions()
  unique_accessions <- blast %>%
    distinct(accession_version) %>% rename(sseqid = accession_version)

  fetch_taxonomy_chunks(unique_accessions, chunk_dir)
  retry_failed_accessions(chunk_dir, retry_dir)
  taxonomy <- combine_taxonomy_chunks(chunk_dir, retry_dir) %>%
    rename(accession_version = sseqid)

  blast_taxonomy <- blast %>% left_join(taxonomy, by = "accession_version")
  candidates <- retain_candidate_hits(blast_taxonomy, marker, marker_config)
  lca <- assign_lca(candidates) %>% clean_assignments(settings)
  collapsed <- collapse_esvs_to_taxa(occurrence, lca)

  write_checkpoint(lca, file.path(marker_dir, paste0(marker, "_lca_assignments.csv")))
  write_checkpoint(collapsed,
                   file.path(marker_dir, paste0(marker, "_taxon_read_table.csv")))
  invisible(list(lca = lca, taxon_reads = collapsed))
}

# Provide project-specific files here, then run one marker at a time:
# coi <- run_taxonomy("COI", c("part_0.xlsx", "part_1.xlsx"), "coi_blast.tsv")
# s16 <- run_taxonomy("16S", c("part_0.xlsx", "part_1.xlsx"), "16s_blast.tsv")
# s18 <- run_taxonomy("18S", c("part_0.xlsx", "part_1.xlsx"), "18s_blast.tsv")

