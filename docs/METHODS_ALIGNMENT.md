# Methodological decisions represented in the workflow

- COI, 18S, and vertebrate-targeted 16S are processed independently through
  denoising and initial taxonomic assignment.
- Full BLAST output is retained before near-best-hit filtering and LCA
  reconciliation.
- Marker-specific identity thresholds limit the most specific reportable rank.
- Candidate-hit agreement is required in addition to percentage identity.
- Control subtraction is performed on ESV counts at the PCR-replicate level.
- The maximum count among controls of the same type and scope is subtracted
  once from each potentially affected replicate.
- Non-zero PCR-replicate counts are averaged within environmental filters.
- ESVs sharing a reviewed marker-specific taxonomic label are collapsed by
  summing reads.
- Filters belonging to the same sampling event are summed.
- An event-associated target taxon can be removed before community analysis.
- The 1% RRA threshold is applied independently within each marker and event.
- The cross-marker community matrix uses presence-absence by default rather
  than treating RRA from different assays as directly comparable.
- Network defaults are prevalence >=10%, absolute Spearman rho >=0.35, and
  Benjamini-Hochberg-adjusted p <0.05.
- Permutation-based analyses use 999 permutations and a recorded random seed.
- Manual taxonomy review and ecological-group annotation are versioned inputs,
  not undocumented hard-coded exclusions.

These decisions reproduce the associated study design but are exposed in
configuration or helper functions so they can be evaluated and changed for
other datasets.
