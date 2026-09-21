source("scripts/00_packages.R")
source("R/io_helpers.R")
source("R/analysis_functions.R")

run_sampling_effort <- function(marker_pa_tables, event_metadata, group_col,
                                filter_long = NULL, event_map = NULL,
                                filter_wide = NULL) {
  accumulation <- purrr::imap_dfr(marker_pa_tables, function(pa, marker) {
    run_accumulation(pa, event_metadata, group_col, settings$permutations) %>%
      mutate(marker = marker)
  })
  inext <- run_inext(marker_pa_tables)

  filter_tests <- NULL
  similarity <- NULL
  if (!is.null(filter_long) && !is.null(event_map)) {
    filter_tests <- paired_filter_tests(filter_long, event_map)
  }
  if (!is.null(filter_wide) && !is.null(event_map)) {
    similarity <- paired_filter_similarity(filter_wide, event_map)
  }

  list(accumulation = accumulation, inext = inext,
       filter_tests = filter_tests, similarity = similarity)
}

