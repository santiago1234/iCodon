#' Add codon counts to data
#'
#' Add the codon counts to input data. The codon counts is the frequency of
#' each of the 64 codons in the input data frame
#'
#' @param datos: A data frame with at least the following variables
#' \describe{
#' \item{gene_id}{id, to identify each particular secuence}
#' \item{coding}{DNA, coding sequence in frame}
#' }
#'
#' @return a tibble with the codon counts as columns append to the input tibble
#' the columns are named with c_CODN (i.e c_AAA, ..., c_TTT)
#' @export
#'
#' @examples
#' add_codon_counts(testing[1:5, ])
add_codon_counts <- function(datos) {
  stopifnot("gene_id" %in% colnames(datos))
  stopifnot("coding" %in% colnames(datos))

  codon_counter <- function(secuencia) {
    count_codons(secuencia) %>%
      dplyr::filter(.data$codon %in% codones)
  }

  counts <- dplyr::select(datos, .data$gene_id, .data$coding) %>%
    unique() %>%
    dplyr::mutate(
      counts = purrr::map(coding, codon_counter)
    )

  # NA values represent zero counts
  zero_count <- function(x) {
    dplyr::mutate_all(x, ~ ifelse(is.na(.), 0, .))
  }

  counts <-
    counts %>%
    tidyr::unnest(.data$counts) %>%
    tidyr::spread(key = .data$codon, value = .data$n) %>%
    zero_count()

  # add prefix c_ to the counts columns

  colnames(counts) <- paste0("c_", colnames(counts))

  # put the names back to coding and gend_id

  counts <- dplyr::rename(counts, "gene_id" = "c_gene_id") %>%
    dplyr::rename("coding" = "c_coding")

  dplyr::inner_join(datos, counts, by = c("gene_id", "coding"))
}
