prepare_accessions <- function(blast) {
  blast %>%
    dplyr::mutate(
      qseqid = as.character(qseqid),
      sseqid = as.character(sseqid),
      accession_version = stringr::str_extract(sseqid, "[A-Z]{1,4}_?[A-Z0-9]+\\.[0-9]+"),
      pident = as.numeric(pident),
      length = as.numeric(length),
      evalue = as.numeric(evalue),
      bitscore = as.numeric(bitscore)
    ) %>%
    dplyr::filter(!is.na(qseqid), !is.na(accession_version))
}

fetch_taxonomy_metabark <- function(blast, output_file, api_key = Sys.getenv("NCBI_API_KEY")) {
  if (!requireNamespace("metabark", quietly = TRUE)) {
    stop("Install metabark or supply a BLAST table already joined to lineage columns.")
  }
  if (!nzchar(api_key)) {
    warning("NCBI_API_KEY is not set; online retrieval may be rate limited.")
    api_key <- NULL
  }
  metabark::assign_taxonomy_to_blast(
    data = blast,
    path_taxdb = "",
    accession_col = "sseqid",
    entrez_key = api_key,
    merge_data_and_taxonomy = TRUE,
    write_to_csv = TRUE,
    output_name = output_file
  )
}

retain_candidate_hits <- function(blast_taxonomy, marker, marker_config,
                                  score_fraction = settings$candidate_bitscore_fraction) {
  cfg <- marker_config %>% dplyr::filter(.data$marker == marker)
  if (nrow(cfg) != 1) stop("Marker configuration not found for ", marker)
  x <- blast_taxonomy
  if ("qcovs" %in% names(x)) {
    x <- x %>% dplyr::filter(is.na(qcovs) | qcovs >= cfg$min_query_coverage)
  }
  x %>%
    dplyr::filter(length >= cfg$min_alignment_length) %>%
    dplyr::group_by(qseqid) %>%
    dplyr::filter(bitscore >= max(bitscore, na.rm = TRUE) * score_fraction) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(marker = marker)
}

consensus_value <- function(x) {
  x <- unique(stats::na.omit(trimws(as.character(x))))
  x <- x[nzchar(x)]
  if (length(x) == 1) x else NA_character_
}

assign_lca <- function(candidates, marker_config) {
  ranks <- c("kingdom", "phylum", "class", "order", "family", "genus", "species")
  missing_ranks <- setdiff(ranks, names(candidates))
  if (length(missing_ranks)) stop("Missing lineage columns: ", paste(missing_ranks, collapse = ", "))

  candidates %>%
    dplyr::group_by(marker, qseqid) %>%
    dplyr::summarise(
      best_pident = max(pident, na.rm = TRUE),
      n_candidate_hits = dplyr::n(),
      dplyr::across(dplyr::all_of(ranks), consensus_value),
      .groups = "drop"
    ) %>%
    dplyr::left_join(marker_config, by = "marker") %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      identity_ceiling = dplyr::case_when(
        best_pident >= species_min ~ "species",
        best_pident >= genus_min ~ "genus",
        best_pident >= family_min ~ "family",
        !is.na(order_min) & best_pident >= order_min ~ "order",
        TRUE ~ "higher"
      ),
      lca_rank = {
        present <- ranks[!is.na(c_across(dplyr::all_of(ranks)))]
        if (length(present)) tail(present, 1) else "unassigned"
      },
      assignment_rank = {
        rank_order <- c("unassigned", "higher", "kingdom", "phylum", "class",
                        "order", "family", "genus", "species")
        allowed <- if (identity_ceiling == "higher") "class" else identity_ceiling
        rank_order[min(match(lca_rank, rank_order), match(allowed, rank_order), na.rm = TRUE)]
      },
      final_taxon = dplyr::case_when(
        assignment_rank == "species" ~ species,
        assignment_rank == "genus" ~ paste0(genus, " sp."),
        assignment_rank == "family" ~ family,
        assignment_rank == "order" ~ order,
        assignment_rank == "class" ~ class,
        assignment_rank == "phylum" ~ phylum,
        assignment_rank == "kingdom" ~ kingdom,
        TRUE ~ NA_character_
      )
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(marker, qseqid, best_pident, n_candidate_hits,
                  dplyr::all_of(ranks), lca_rank, identity_ceiling,
                  assignment_rank, final_taxon)
}

clean_assignments <- function(lca) {
  lca %>%
    dplyr::mutate(final_taxon = stringr::str_squish(final_taxon)) %>%
    dplyr::filter(!is.na(final_taxon), final_taxon != "")
}

collapse_esvs_to_taxa <- function(occurrence, assignments) {
  occurrence %>%
    dplyr::inner_join(assignments %>% dplyr::select(qseqid, final_taxon, assignment_rank),
                      by = "qseqid") %>%
    dplyr::group_by(final_taxon, assignment_rank) %>%
    dplyr::summarise(dplyr::across(where(is.numeric), ~ sum(.x, na.rm = TRUE)),
                     n_esvs = dplyr::n(), .groups = "drop")
}
