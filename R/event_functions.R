aggregate_filters_to_events <- function(filter_taxa, event_metadata) {
  event_lookup <- event_metadata %>%
    dplyr::filter(sample_type == "environmental") %>%
    dplyr::distinct(filter_id, event_id, event_type)

  filter_taxa %>%
    dplyr::select(-dplyr::any_of(c("event_id", "event_type"))) %>%
    dplyr::left_join(event_lookup, by = "filter_id") %>%
    dplyr::group_by(marker, event_id, event_type, final_taxon, assignment_rank) %>%
    dplyr::summarise(reads = sum(reads, na.rm = TRUE),
                     n_filters = dplyr::n_distinct(filter_id), .groups = "drop")
}

remove_event_target <- function(event_reads, target_lookup) {
  event_reads %>%
    dplyr::left_join(target_lookup, by = "event_id") %>%
    dplyr::filter(is.na(target_taxon) | target_taxon == "" | final_taxon != target_taxon) %>%
    dplyr::select(-target_taxon)
}

calculate_marker_rra <- function(event_reads, cutoff = 0.01) {
  event_reads %>%
    dplyr::group_by(marker, event_id) %>%
    dplyr::mutate(RRA_raw = reads / sum(reads, na.rm = TRUE)) %>%
    dplyr::filter(is.finite(RRA_raw), RRA_raw >= cutoff) %>%
    dplyr::mutate(RRA = RRA_raw / sum(RRA_raw, na.rm = TRUE), presence = 1L) %>%
    dplyr::ungroup()
}

combine_markers_presence <- function(marker_rra) {
  marker_rra %>%
    dplyr::group_by(event_id, event_type, final_taxon) %>%
    dplyr::summarise(
      presence = 1L,
      markers = paste(sort(unique(marker)), collapse = ";"),
      marker_count = dplyr::n_distinct(marker),
      .groups = "drop"
    )
}

marker_configuration_summary <- function(marker_rra) {
  marker_sets <- list(
    COI = "COI", `18S` = "18S", `16S` = "16S",
    `COI + 18S` = c("COI", "18S"),
    `COI + 16S` = c("COI", "16S"),
    `18S + 16S` = c("18S", "16S"),
    `COI + 18S + 16S` = c("COI", "18S", "16S")
  )
  purrr::imap_dfr(marker_sets, function(markers, label) {
    x <- marker_rra %>% dplyr::filter(marker %in% markers)
    tibble::tibble(
      configuration = label,
      n_markers = length(markers),
      total_taxa = dplyr::n_distinct(x$final_taxon),
      mean_taxa_per_event = x %>%
        dplyr::distinct(event_id, final_taxon) %>%
        dplyr::count(event_id) %>%
        dplyr::summarise(value = mean(n)) %>% dplyr::pull(value)
    )
  })
}
