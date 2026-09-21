source("scripts/00_packages.R")
source("R/analysis_functions.R")

save_network_outputs <- function(network, guild_table = NULL) {
  plot <- plot_network(network, guild_table)
  ggsave(file.path(paths$figures, "codetection_network.pdf"), plot,
         width = 11, height = 8)
  write_csv(network$edges, file.path(paths$tables, "network_edges.csv"))
  write_csv(network$metrics, file.path(paths$tables, "network_node_metrics.csv"))
  write_csv(network$summary, file.path(paths$tables, "network_summary.csv"))
  invisible(plot)
}

