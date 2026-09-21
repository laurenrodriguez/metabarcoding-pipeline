settings <- list(
  candidate_bitscore_fraction = 0.99,
  min_total_reads = 10,
  min_filter_detections = 2,
  rra_cutoff = 0.01,
  permutations = 999,
  random_seed = 2026,
  network_min_prevalence = 0.10,
  network_min_abs_rho = 0.35,
  network_alpha = 0.05
)

paths <- list(
  raw = "data/raw",
  intermediate = "data/intermediate",
  reviewed_taxonomy = "data/reviewed_taxonomy",
  results = "results",
  tables = "results/tables",
  figures = "results/figures"
)

invisible(lapply(paths[c("intermediate", "results", "tables", "figures")],
                 dir.create, recursive = TRUE, showWarnings = FALSE))
