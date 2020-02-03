#' Title
#'
#' @param codon
#'
#' @return
#' @export
#'
#' @examples
sample_synonimous_codon <- function(codon) {
  # the idea of this function is to sample proportional to the optimality scores
  # noteL use the softmax function, this
  syn_codons <- optimalcodonR::gc_amino_to_codons_l[[optimalcodonR::gc_codons_to_amino[codon]]]
  sample(syn_codons, 1)
}


#' Generate synonimous mutant variant
#'
#' @param secuencia
#' @param percentage
#'
#' @return
#' @export
#'
#' @examples
variante_sinonima <- function(secuencia, percentage = .3) {

  stopifnot(nchar(secuencia) > 6)
  stopifnot(percentage >= 0)
  stopifnot(percentage <= 1)

    # pick n positions proportional to the percentage of mutations
  mutante_sinonima <- secuencia
  n_positions <- floor(((nchar(secuencia) / 3 ) - 6) * percentage)

  # i start from 4 so the star codon is never touched
  # also the last codon is never touched
  posiciones <- seq(from=4, to = nchar(mutante_sinonima) - 3, by = 3) %>%
    sample(size = n_positions)

  for (position in posiciones) {
    current_codon <- substr(mutante_sinonima, position, position+2)

    # sample one current amino randomly
    substr(mutante_sinonima, position, position+2) <- sample_synonimous_codon(current_codon)
  }

  mutante_sinonima
}


