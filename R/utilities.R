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

  ## check the sequence is in frame ---------

  if (!nchar(secuencia) %% 3 == 0) {
    err_msg <- paste0(
      "Secuence not in frame, sequence length is: ",
      nchar(secuencia),
      "  (not a multiple of 3)"
    )
    stop(err_msg)
  }

  ## check for valid characters ---------

  nucs_in_seq <-
    stringr::str_split(secuencia, "") %>%
    unlist() %>%
    unique()

  invalid <- nucs_in_seq[!nucs_in_seq %in% c("A", "G", "T", "C")]

  if (length(invalid) > 0) {
    err_msg <- paste0(
      "Invalid charcter(s) found: ",
      invalid[1]
    )
    stop(err_msg)
  }

  ## give a warning when the sequence is too short  ---------
  min_value <- 70
  max_value <- 43524

  if (nchar(secuencia) < min_value) {
    stop("The sequence is too short, results might be inaccurate")
  }

  if (nchar(secuencia) > max_value) {
    stop("The sequence is too long!")
  }

  ## Premature stop codon maybe the sequence is not in frame  ---------
  stop_codons <- c("TAG", "TAA", "TGA")

  codones_en_seq <- split_by_codons(secuencia) %>%
    utils::head(-1) # remove the stop codon (the last codon)

  stop_codons_found <- codones_en_seq[codones_en_seq %in% stop_codons]

  if (length(stop_codons_found) > 0) {
    err_msg <- paste0("Secuence contains a premature stop codon: ", stop_codons_found[1])
    stop(err_msg)
  }
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
  # validate_sequence(secuencia) calling this gives a bug
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
#' @param proportion logical: if true, returns the distance as a proportion
#' (1 = all codons are different, 0 = no differences)
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


#' Nucleotide distance
#'
#' compute the number of nucleotide differences between the two sequences
#' assumes the sequences are same length and aligned
#'
#' @param seq_variant1 string: coding dna,  must be in frame
#' @param seq_variant2 string: coding dna,  must be in frame
#' @param proportion logical: if true, returns the distance as a proportion
#' (1 = all codons are different, 0 = no differences)
#' @return int, number of codon diferences
#' @export
#'
#' @examples
#' nucleotide_distance("ATGCTG", "ATGCTT")
nucleotide_distance <- function(seq_variant1, seq_variant2, proportion = FALSE) {
  if (length(seq_variant1) != length(seq_variant2)) {
    warning("sequences are not the same length")
  }

  nucs1 <- strsplit(seq_variant1, "") %>% unlist()
  nucs2 <- strsplit(seq_variant2, "") %>% unlist()
  distance <- sum(nucs1 != nucs2)

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



#' Pretty print DNA sequence
#'
#' adds a line break every 80 characters to pretty print the secuence on screen
#'
#' @inheritParams validate_sequence
#'
#' @return
#' @export
#'
#' @examples
#' cat(pretty_print_seq(test_seq))
pretty_print_seq <- function(secuencia) {
  gsub("(.{80})", "\\1 ", secuencia) %>%
    stringr::str_replace_all(pattern = " ", replacement = "\n")
}
