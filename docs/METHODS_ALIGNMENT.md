# Alignment with the manuscript workflow

This implementation intentionally follows these methodological decisions:

- Markers are named COI, 16S, and 18S.
- Full BLAST output is retained before candidate-hit filtering and LCA collapse.
- Marker-specific percentage-identity thresholds are defined in configuration.
- Contamination subtraction is performed on ESV counts at the PCR-replicate
  level, using the maximum observed contaminant count when multiple relevant
  controls contain the same ESV.
- Non-zero PCR-replicate counts are averaged within each environmental filter.
- Duplicate taxonomic labels are collapsed by summing ESV reads.
- Paired environmental filters are summed within ecological sampling events.
- Event-specific target-whale assignments are removed before RRA calculation.
- Taxa below 1% within a marker/event are excluded and retained RRA values are
  renormalized.
- Overlapping multi-marker assignments are summed and renormalized by event.
- The additional light support filter retains taxa with at least 10 reads across
  the dataset or presence in at least two filters.
- No family-level derivative table is created.
- Network thresholds are prevalence >=10%, |rho| >=0.35, and BH-adjusted
  p <0.05.
- Permutation-based analyses use 999 permutations and a recorded random seed.

Project-specific manual taxonomy review and ecological-guild annotation remain
explicit input tables rather than hard-coded rules.

