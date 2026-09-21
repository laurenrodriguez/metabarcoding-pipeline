community_components <- function(wide, metadata) {
  ids <- wide$event_id
  matrix <- as.data.frame(wide[, setdiff(names(wide), "event_id"), drop = FALSE])
  rownames(matrix) <- ids
  metadata <- metadata %>% dplyr::distinct(event_id, .keep_all = TRUE)
  metadata <- metadata[match(ids, metadata$event_id), , drop = FALSE]
  list(ids = ids, matrix = matrix, metadata = metadata)
}

alpha_diversity <- function(pa_wide, event_metadata) {
  x <- community_components(pa_wide, event_metadata)
  tibble::tibble(event_id = x$ids, richness = rowSums(x$matrix > 0)) %>%
    dplyr::left_join(x$metadata, by = "event_id")
}

run_beta_diversity <- function(community_wide, event_metadata, group_col,
                               permutations = 999, seed = 2026) {
  set.seed(seed)
  x <- community_components(community_wide, event_metadata)
  distance <- vegan::vegdist(x$matrix, method = "bray")
  ordination <- vegan::metaMDS(distance, k = 2, trymax = 100, trace = FALSE)
  formula <- stats::as.formula(paste("distance ~", group_col))
  permanova <- vegan::adonis2(formula, data = x$metadata,
                              permutations = permutations)
  dispersion <- vegan::betadisper(distance, group = x$metadata[[group_col]])
  dispersion_test <- vegan::permutest(dispersion, permutations = permutations)
  scores <- as.data.frame(vegan::scores(ordination, display = "sites")) %>%
    tibble::rownames_to_column("event_id") %>%
    dplyr::left_join(x$metadata, by = "event_id")
  list(distance = distance, ordination = ordination, scores = scores,
       stress = ordination$stress, permanova = permanova,
       dispersion = dispersion, dispersion_test = dispersion_test)
}

run_lcbd <- function(pa_wide, permutations = 999) {
  x <- community_components(pa_wide, tibble::tibble(event_id = pa_wide$event_id))
  result <- adespatial::beta.div(x$matrix, method = "hellinger",
                                 nperm = permutations)
  tibble::tibble(event_id = x$ids, LCBD = result$LCBD,
                 p_value = result$p.LCBD)
}

run_indicator_taxa <- function(pa_wide, event_metadata, group_col,
                               permutations = 999, seed = 2026) {
  set.seed(seed)
  x <- community_components(pa_wide, event_metadata)
  control <- permute::how(nperm = permutations)
  fit <- indicspecies::multipatt(x$matrix, x$metadata[[group_col]],
                                 func = "IndVal.g", control = control)
  summary_table <- as.data.frame(fit$sign) %>%
    tibble::rownames_to_column("taxon") %>%
    dplyr::arrange(p.value)
  list(model = fit, table = summary_table)
}

build_codetection_network <- function(pa_wide, min_prevalence = 0.10,
                                      min_abs_rho = 0.35, alpha = 0.05) {
  matrix <- as.data.frame(pa_wide[, setdiff(names(pa_wide), "event_id"), drop = FALSE])
  prevalence <- colMeans(matrix > 0)
  matrix <- matrix[, prevalence >= min_prevalence, drop = FALSE]
  if (ncol(matrix) < 2) stop("Fewer than two taxa passed the network prevalence filter.")

  corr <- Hmisc::rcorr(as.matrix(matrix), type = "spearman")
  pairs <- which(upper.tri(corr$r), arr.ind = TRUE)
  edges <- tibble::tibble(
    from = colnames(matrix)[pairs[, 1]],
    to = colnames(matrix)[pairs[, 2]],
    rho = corr$r[pairs],
    p_value = corr$P[pairs]
  ) %>%
    dplyr::mutate(p_adjusted = p.adjust(p_value, method = "BH")) %>%
    dplyr::filter(!is.na(rho), abs(rho) >= min_abs_rho, p_adjusted < alpha)

  graph <- igraph::graph_from_data_frame(edges, directed = FALSE,
                                         vertices = tibble::tibble(name = colnames(matrix)))
  metrics <- tibble::tibble(
    taxon = igraph::V(graph)$name,
    degree = igraph::degree(graph),
    betweenness = igraph::betweenness(graph, normalized = TRUE),
    closeness = igraph::closeness(graph, normalized = TRUE),
    eigenvector = igraph::eigen_centrality(graph)$vector,
    prevalence = prevalence[igraph::V(graph)$name]
  )
  community <- if (igraph::ecount(graph)) igraph::cluster_louvain(graph) else NULL
  summary <- tibble::tibble(
    nodes = igraph::vcount(graph), edges = igraph::ecount(graph),
    positive_edges = sum(edges$rho > 0), negative_edges = sum(edges$rho < 0),
    density = igraph::edge_density(graph),
    modularity = if (is.null(community)) NA_real_ else igraph::modularity(community)
  )
  list(graph = graph, edges = edges, metrics = metrics, summary = summary)
}

plot_network <- function(network, guild_table = NULL) {
  graph <- network$graph
  if (!is.null(guild_table)) {
    groups <- guild_table$ecological_group[match(igraph::V(graph)$name, guild_table$taxon)]
    igraph::V(graph)$ecological_group <- tidyr::replace_na(groups, "unclassified")
  } else {
    igraph::V(graph)$ecological_group <- "unclassified"
  }
  ggraph::ggraph(graph, layout = "fr") +
    ggraph::geom_edge_link(ggplot2::aes(alpha = abs(rho), colour = rho > 0),
                           show.legend = FALSE) +
    ggraph::geom_node_point(ggplot2::aes(colour = ecological_group, size = degree)) +
    ggraph::geom_node_text(ggplot2::aes(label = name), repel = TRUE, size = 2.5) +
    ggplot2::scale_edge_colour_manual(values = c(`TRUE` = "#3568A8", `FALSE` = "#B24A4A")) +
    ggplot2::theme_void()
}

run_accumulation <- function(pa_wide, event_metadata, group_col = NULL,
                             permutations = 999) {
  x <- community_components(pa_wide, event_metadata)
  acc <- vegan::specaccum(x$matrix, method = "random", permutations = permutations)
  tibble::tibble(sites = acc$sites, richness = acc$richness, sd = acc$sd)
}

run_inext <- function(marker_pa_tables) {
  incidence <- purrr::map(marker_pa_tables, function(pa) {
    matrix <- as.matrix(pa[, setdiff(names(pa), "event_id"), drop = FALSE])
    c(nrow(matrix), colSums(matrix > 0))
  })
  iNEXT::iNEXT(incidence, q = 0, datatype = "incidence_freq")
}

paired_filter_tests <- function(filter_long, event_map) {
  filter_richness <- filter_long %>%
    dplyr::filter(reads > 0) %>%
    dplyr::distinct(marker, filter_id, final_taxon) %>%
    dplyr::count(marker, filter_id, name = "filter_richness") %>%
    dplyr::left_join(event_map %>% dplyr::distinct(filter_id, event_id), by = "filter_id")
  event_richness <- filter_long %>%
    dplyr::filter(reads > 0) %>%
    dplyr::distinct(marker, event_id, final_taxon) %>%
    dplyr::count(marker, event_id, name = "event_richness")
  joined <- filter_richness %>% dplyr::left_join(event_richness, by = c("marker", "event_id"))
  tests <- joined %>%
    dplyr::group_by(marker) %>%
    dplyr::summarise(
      n = dplyr::n(),
      mean_filter = mean(filter_richness),
      mean_event = mean(event_richness),
      p_value = stats::wilcox.test(filter_richness, event_richness, paired = TRUE)$p.value,
      .groups = "drop"
    )
  list(values = joined, tests = tests)
}

paired_filter_similarity <- function(filter_wide, event_map) {
  pairs <- event_map %>%
    dplyr::distinct(event_id, filter_id) %>%
    dplyr::count(event_id) %>% dplyr::filter(n == 2) %>% dplyr::pull(event_id)
  purrr::map_dfr(pairs, function(id) {
    filters <- event_map %>% dplyr::filter(event_id == id) %>% dplyr::pull(filter_id) %>% unique()
    x <- filter_wide %>% dplyr::filter(filter_id %in% filters)
    matrix <- as.matrix(x[, setdiff(names(x), "filter_id"), drop = FALSE])
    tibble::tibble(event_id = id,
                   jaccard_similarity = 1 - as.numeric(vegan::vegdist(matrix > 0, method = "jaccard")),
                   bray_curtis_dissimilarity = as.numeric(vegan::vegdist(matrix, method = "bray")))
  })
}
