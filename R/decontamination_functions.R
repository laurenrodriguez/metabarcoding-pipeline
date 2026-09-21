subtract_control_scope <- function(counts, metadata, control_type, scope_col) {
  controls <- metadata %>%
    dplyr::filter(sample_type == control_type) %>%
    dplyr::select(sample_rep_id, scope = dplyr::all_of(scope_col))
  if (!nrow(controls)) return(counts)

  control_max <- counts %>%
    dplyr::inner_join(controls, by = "sample_rep_id") %>%
    dplyr::group_by(qseqid, scope) %>%
    dplyr::summarise(control_reads = max(reads, na.rm = TRUE), .groups = "drop")

  sample_scope <- metadata %>%
    dplyr::select(sample_rep_id, scope = dplyr::all_of(scope_col))

  counts %>%
    dplyr::left_join(sample_scope, by = "sample_rep_id") %>%
    dplyr::left_join(control_max, by = c("qseqid", "scope")) %>%
    dplyr::mutate(
      control_reads = tidyr::replace_na(control_reads, 0),
      reads = pmax(reads - control_reads, 0)
    ) %>%
    dplyr::select(-scope, -control_reads)
}

apply_hierarchical_control_subtraction <- function(esv_long, metadata) {
  required <- c("sample_rep_id", "sample_type", "pcr_plate",
                "extraction_batch", "field_interval")
  missing <- setdiff(required, names(metadata))
  if (length(missing)) stop("Missing metadata columns: ", paste(missing, collapse = ", "))

  esv_long %>%
    subtract_control_scope(metadata, "pcr_control", "pcr_plate") %>%
    subtract_control_scope(metadata, "extraction_control", "extraction_batch") %>%
    subtract_control_scope(metadata, "field_control", "field_interval")
}

average_positive_pcr_replicates <- function(corrected, metadata) {
  environmental <- metadata %>%
    dplyr::filter(sample_type == "environmental") %>%
    dplyr::select(sample_rep_id, filter_id, event_id)

  corrected %>%
    dplyr::inner_join(environmental, by = "sample_rep_id") %>%
    dplyr::group_by(qseqid, filter_id, event_id) %>%
    dplyr::summarise(
      reads = if (any(reads > 0)) mean(reads[reads > 0]) else 0,
      positive_pcr_replicates = sum(reads > 0),
      total_pcr_replicates = dplyr::n(),
      .groups = "drop"
    )
}

collapse_filter_esvs_to_taxa <- function(filter_esvs, assignments) {
  if (!"accepted" %in% names(assignments)) assignments$accepted <- TRUE
  filter_esvs %>%
    dplyr::inner_join(assignments %>%
                        dplyr::filter(is.na(accepted) | accepted) %>%
                        dplyr::select(marker, qseqid, final_taxon, assignment_rank),
                      by = c("marker", "qseqid")) %>%
    dplyr::group_by(marker, filter_id, event_id, final_taxon, assignment_rank) %>%
    dplyr::summarise(reads = sum(reads, na.rm = TRUE), .groups = "drop")
}

apply_light_support_filter <- function(taxon_filter_long, settings) {
  supported <- taxon_filter_long %>%
    dplyr::group_by(marker, final_taxon) %>%
    dplyr::summarise(total_reads = sum(reads, na.rm = TRUE),
                     n_filters = sum(reads > 0), .groups = "drop") %>%
    dplyr::filter(total_reads >= settings$min_total_reads |
                    n_filters >= settings$min_filter_detections)
  taxon_filter_long %>%
    dplyr::semi_join(supported, by = c("marker", "final_taxon"))
}
