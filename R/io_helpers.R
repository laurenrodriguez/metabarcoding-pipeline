read_occurrence_parts <- function(files) {
  if (!length(files)) stop("No occurrence files supplied.")
  purrr::map_dfr(files, function(path) {
    ext <- tolower(tools::file_ext(path))
    if (ext == "csv") return(readr::read_csv(path, show_col_types = FALSE))
    if (ext %in% c("xlsx", "xls")) return(readxl::read_excel(path))
    if (ext %in% c("parquet", "snappy")) {
      if (!requireNamespace("arrow", quietly = TRUE)) {
        stop("Install package 'arrow' to read Parquet files.")
      }
      return(dplyr::as_tibble(arrow::read_parquet(path)))
    }
    stop("Unsupported occurrence-table format: ", path)
  })
}

read_blast_table <- function(path) {
  x <- readr::read_tsv(path, col_names = FALSE, comment = "#",
                       show_col_types = FALSE, progress = FALSE)
  standard <- c("qseqid", "sseqid", "pident", "length", "evalue", "bitscore")
  extended <- c("qseqid", "sseqid", "sacc", "pident", "qcovs", "length",
                "mismatch", "gapopen", "qstart", "qend", "sstart", "send",
                "evalue", "bitscore")
  if (ncol(x) == length(standard)) names(x) <- standard
  else if (ncol(x) == length(extended)) names(x) <- extended
  else stop("BLAST table must contain either 6 or 14 documented columns. See docs/INPUT_SCHEMAS.md.")
  x
}

write_checkpoint <- function(x, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(x, path, na = "")
  invisible(x)
}

make_community_matrix <- function(long_table, value_col = "presence") {
  long_table %>%
    dplyr::select(event_id, final_taxon, value = dplyr::all_of(value_col)) %>%
    dplyr::group_by(event_id, final_taxon) %>%
    dplyr::summarise(value = max(value, na.rm = TRUE), .groups = "drop") %>%
    tidyr::pivot_wider(names_from = final_taxon, values_from = value,
                       values_fill = 0)
}
