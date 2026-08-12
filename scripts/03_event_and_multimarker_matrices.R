source("scripts/00_packages.R")
source("R/io_helpers.R")
source("R/decontamination_functions.R")
source("R/event_functions.R")

build_event_dataset <- function(filter_esvs, lca_assignments,
                                event_metadata, target_lookup) {
  taxon_filter_long <- collapse_filter_esvs_to_taxa(filter_esvs, lca_assignments)
  filtered <- apply_light_support_filter(taxon_filter_long, settings)
  event_reads <- aggregate_filters_to_events(filtered, event_metadata)
  event_no_target <- remove_event_target(event_reads, target_lookup)
  marker_rra <- calculate_marker_rra(event_no_target, settings$rra_cutoff)
  multimarker <- combine_markers(marker_rra)

  rra_matrix <- make_community_matrix(multimarker, "RRA_final")
  pa_matrix <- make_community_matrix(multimarker, "presence")

  write_checkpoint(marker_rra, file.path(paths$tables, "marker_event_RRA.csv"))
  write_checkpoint(multimarker, file.path(paths$tables, "multimarker_event_RRA.csv"))
  write_checkpoint(rra_matrix, file.path(paths$tables, "multimarker_RRA_matrix.csv"))
  write_checkpoint(pa_matrix, file.path(paths$tables, "multimarker_PA_matrix.csv"))
  invisible(list(marker_rra = marker_rra, multimarker = multimarker,
                 rra = rra_matrix, pa = pa_matrix))
}
