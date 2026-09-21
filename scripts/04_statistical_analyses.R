source("scripts/00_packages.R")
source("R/io_helpers.R")
source("R/analysis_functions.R")

run_statistical_analyses <- function(pa_wide, event_metadata,
                                     event_group = "event_type") {
  alpha <- alpha_diversity(pa_wide, event_metadata)
  alpha_kw <- kruskal.test(reformulate(event_group, response = "richness"), data = alpha)
  alpha_posthoc <- pairwise.wilcox.test(alpha$richness, alpha[[event_group]],
                                        p.adjust.method = "BH")
  beta <- run_beta_diversity(pa_wide, event_metadata, event_group,
                             settings$permutations, settings$random_seed)
  lcbd <- run_lcbd(pa_wide, settings$permutations)
  indicators <- run_indicator_taxa(pa_wide, event_metadata, event_group,
                                   settings$permutations, settings$random_seed)
  network <- build_codetection_network(
    pa_wide, settings$network_min_prevalence,
    settings$network_min_abs_rho, settings$network_alpha
  )
  list(alpha = alpha, alpha_kw = alpha_kw, alpha_posthoc = alpha_posthoc,
       beta = beta, lcbd = lcbd, indicators = indicators, network = network)
}
