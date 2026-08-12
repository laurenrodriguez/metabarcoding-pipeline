# Running the workflow

The numbered scripts define functions and can be sourced from a project-specific
driver script. 

## 1\. Configure inputs

Copy the metadata templates and replace the example rows. Confirm that every
PCR replicate column in the APSCALE occurrence table has one metadata row.

## 2\. Taxonomic assignment

Source `scripts/01\_taxonomic\_assignment.R`, then call `run\_taxonomy()` once per
marker. This creates LCA assignments and marker-specific taxon read tables.

## 3\. Control subtraction and PCR replicate averaging

Source `scripts/02\_controls\_and\_replicates.R`, then call
`process\_marker\_replicates()` on the ESV occurrence table and PCR-replicate
metadata for each marker.

## 4\. Manual review

Review the LCA assignment tables and store the accepted, documented versions in
`data/reviewed\_taxonomy/`. Use those reviewed assignments in subsequent steps.

## 5\. Event and multi-marker matrices

Combine the three marker-specific filter/ESV tables and reviewed LCA tables,
then call `build\_event\_dataset()` from
`scripts/03\_event\_and\_multimarker\_matrices.R`.

## 6\. Statistical analyses

Use `run\_statistical\_analyses()` for richness, NMDS, PERMANOVA, multivariate
dispersion, LCBD, indicator taxa, and the co-detection network. Use
`run\_sampling\_effort()` for species accumulation, iNEXT, paired filter-versus-
event richness, Jaccard similarity, and Bray-Curtis dissimilarity.

## 7\. Network outputs

Use `save\_network\_outputs()` to save the network figure, edges, node metrics,
and topology summary. Supply the manually reviewed ecological-guild table to
color nodes by functional group.

