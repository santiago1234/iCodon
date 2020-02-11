#' Check correct input DNA sequence
#'
#' @param secuencia character: coding dna,  must be in frame
#'
#' @return throws an error if the sequence contains invalid characters or is not a
#' multiple of 3
#' @export
#'
#' @examples
#' validate_sequence(test_seq)
validate_sequence <- function(secuencia) {
  secuencia <- stringr::str_to_upper(secuencia)
  stopifnot(nchar(secuencia) %% 3 == 0)

  nucs_in_seq <-
    stringr::str_split(secuencia, "") %>%
    unlist() %>%
    unique()

  stopifnot(all(nucs_in_seq %in% c("A", "C", "G", "T")))
}


#' Split a sequence by codons
#'
#' This is an internal function
#' @inheritParams validate_sequence
#'
#' @return character vector, each element is a codon
#' and they come in the same order
split_by_codons <- function(secuencia) {
  gsub("(.{3})", "\\1 ", secuencia) %>%
    stringr::str_split(" ") %>%
    unlist() %>%
    # this approach insets an extra empty element
    # to the vetor that i need to remove
    .[-length(.)]
}


#' translate DNA sequence to amino acid
#'
#' @inheritParams validate_sequence
#'
#' @return string, amino acid sequence
#' @export
#'
#' @examples
#' translate("ATGTTT")
translate <- function(secuencia) {
  secuencia <- stringr::str_to_upper(secuencia)
  validate_sequence(secuencia)
  split_by_codons(secuencia) %>%
    purrr::map_chr(function(x) optimalcodonR::gc_codons_to_amino[x]) %>%
    stringr::str_c(collapse = "")
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
#' codon_distance("ATGCTG", "ATGCTT")
codon_distance <- function(seq_variant1, seq_variant2, proportion = FALSE) {
  if (translate(seq_variant1) != translate(seq_variant2)) {
    warning("sequences are not synonimous")
  }

  distance <- sum(split_by_codons(seq_variant1) != split_by_codons(seq_variant2))

  if (proportion) {
    distance <- distance / (nchar(seq_variant1) / 3)
  }

  distance
}


#' Count codons in DNA sequence
#'
#' Counts the frequency of each triplete in sequence, assumes
#' the sequences is in frame
#'
#' @inheritParams validate_sequence
#'
#' @return The frequency of the codons in \code{seq}
#' @export
#' @importFrom magrittr %>%
#' @examples
#' count_codons("ACGGGG")
count_codons <- function(secuencia) {
  if (nchar(secuencia) %% 3 != 0) {
    stop("sequence not a multiple of 3")
  }

  secuencia <- toupper(secuencia)

  tibble::tibble(codon = split_by_codons(secuencia)) %>%
    dplyr::count(.data$codon)

}


