source("scripts/00_packages.R")
source("R/io_helpers.R")
source("R/decontamination_functions.R")

process_marker_replicates <- function(marker, esv_table, metadata) {
  sample_cols <- intersect(metadata$sample_rep_id, names(esv_table))
  esv_long <- esv_table %>%
    select(qseqid, all_of(sample_cols)) %>%
    pivot_longer(all_of(sample_cols), names_to = "sample_rep_id", values_to = "reads") %>%
    mutate(reads = replace_na(as.numeric(reads), 0))

  corrected <- apply_hierarchical_control_subtraction(esv_long, metadata)
  filters <- average_positive_pcr_replicates(corrected, metadata) %>%
    mutate(marker = marker)

  write_checkpoint(corrected,
                   file.path(paths$intermediate, tolower(marker),
                             paste0(marker, "_control_corrected_replicates.csv")))
  write_checkpoint(filters,
                   file.path(paths$intermediate, tolower(marker),
                             paste0(marker, "_positive_replicates_averaged.csv")))
  invisible(filters)
}

