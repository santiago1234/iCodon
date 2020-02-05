#' Check correct input DNA sequence
#'
#' @param secuencia string: coding dna,  must be in frame
#'
#' @return throws an error if the sequence contains invalid characters or is not a
#' multiple of 3
#' @export
#'
#' @examples
validate_sequence <- function(secuencia) {
  secuencia <- stringr::str_to_upper(secuencia)
  stopifnot(nchar(secuencia) %% 3 == 0)

  nucs_in_seq <-
    stringr::str_split(secuencia, "") %>%
    unlist() %>%
    unique()

  stopifnot(all(nucs_in_seq %in% c("A", "C", "G", "T")))
}


#' translate DNA sequence to amino acid
#'
#' @inheritParams validate_sequence
#'
#' @return string, amino acid sequence
#' @export
#'
#' @examples
#' translate("ATG")
translate <- function(secuencia) {
  secuencia <- stringr::str_to_upper(secuencia)
  validate_sequence(secuencia)
  seq(from = 1, to = nchar(secuencia), by = 3) %>%
    purrr::map(function(x) optimalcodonR::gc_codons_to_amino[stringr::str_sub(secuencia, x, x + 2)]) %>%
    purrr::reduce(paste0)
}


#' Codon distance
#'
#' compute the number of codon differences between the two sequences
#'
#' @param seq_variant1 string: coding dna,  must be in frame
#' @param seq_variant2 string: coding dna,  must be in frame
#'
#' @return int, number of codon diferences
#' @export
#'
#' @examples
codon_distance <- function(seq_variant1, seq_variant2, proportion = FALSE) {

  if (translate(seq_variant1) != translate(seq_variant2)) {
    warning("sequences are not synonimous")
  }

  distance <-
    seq(from = 1, to = nchar(seq_variant1), by = 3) %>%
    purrr::map_lgl(
      function(x) stringr::str_sub(seq_variant1, x, x + 2) != stringr::str_sub(seq_variant2, x, x + 2)
      ) %>%
    sum()

  if (proportion) {
    distance <- distance / (nchar(seq_variant1)/3)

  }

  distance
}




