add_codon_counts <- function(datos) {
  stopifnot("gene_id" %in% colnames(datos))
  stopifnot("coding" %in% colnames(datos))


  dplyr::select(datos, .data$gene_id, .data$coding) %>%
    unique()
}
