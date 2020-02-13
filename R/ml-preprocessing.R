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
      dplyr::full_join(codones, by = "codon") %>%
      dplyr::filter(.data$codon %in% codones$codon)
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



preprocess_secuences <- function(secuences, specie_="human") {

  maketible <- function(s, c, d) {
    tibble::tibble(
      specie = s,
      cell_type = c,
      datatype = d
    )
  }

  if (specie_ == "human") {
    tmp <- maketible("human", "k562", "slam-seq")
  }
  if (specie_ == "fish") {
    tmp <- maketible("fish", "embryo mzt", "aamanitin polya")
  }
  if (specie_ == "mouse") {
    tmp <- maketible("mouse", "mES cells", "slam-seq")
  }
  if (specie_ == "xenopus") {
    tmp <- maketible("xenopus", "embryo mzt", "aamanitin ribo")
  }

  dta_to_pred <-
    tibble::tibble(
    gene_id = secuences,
    coding = secuences,
    cdslenlog = log(nchar(secuences)),
    utrlenlog = NA_real_,
    decay_rate = NA_real_,
  ) %>%
    tidyr::crossing(tmp) %>%
    add_codon_counts()


  # preprocess the data with the pipeline
  recipes::bake(preprocessing_recipe, dta_to_pred)
}





