#' Sample synonymous codons according to the optimality effect
#'
#' @param sampling_codon_distribution list object with sampling probabilities,
#' either \code{\link{sampling_deoptimization}} or \code{\link{sampling_optimization}}
#'
#' @return function to sample codons, this function takes as input the amino acid
#' and returns a synonimous codon
#' @export
#'
#' @examples
#' # sample I for deoptimization
#' sample_synonimous_codon(sampling_codon_distribution = sampling_deoptimization)("I")
sample_synonimous_codon <- function(sampling_codon_distribution) {
  # the idea of this function is to sample proportional to the optimality scores
  # noteL use the softmax function, this
  function(amino_acid) {
    sample(
      x = sampling_codon_distribution[[amino_acid]]$codon,
      size = 1,
      prob = sampling_codon_distribution[[amino_acid]]$sampling_probility
    )
  }
}


#' Generate synonimous mutant variant
#'
#' @param secuencia string, coding DNA sequence in frame
#' @param sampling_distribution function, \code{\link{sample_synonimous_codon}}
#' the sampling codon distribution
#' @param percentage float, the percentage of the sequence to be mutated
#' max = 1 (mutate all codons), min = 0 (mutate no codons). This function wont change
#' the 1st and last codon
#'
#' @return function, sinonimous generator: A function that takes as input
#' a sequence and will create sinonimous mutations in that sequence
#' @export
#'
#' @examples
#' sampling_distribution <- sample_synonimous_codon(sampling_codon_distribution = sampling_deoptimization)
#' seq <- "ATGCCCGGGATGATGTTT"
#' variante_sinonima(seq, sampling_distribution, .5)
variante_sinonima <- function(secuencia, sampling_distribution, percentage = .3) {

  stopifnot(nchar(secuencia) > 6)
  stopifnot(percentage >= 0)
  stopifnot(percentage <= 1)

  # pick n positions proportional to the percentage of mutations
  n_positions <- floor(((nchar(secuencia) / 3 ) - 6) * percentage)

  # i start from 4 so the star codon is never touched
  # also the last codon is never touched
  posiciones <- seq(from=4, to = nchar(secuencia) - 3, by = 3)


  function(seq2) {
    mutante_sinonima <- seq2
    # seq2 is the sequence to mutate
    positiones_a_mutar <- sample(posiciones, size = n_positions)

    for (position in positiones_a_mutar) {
      current_codon <- substr(mutante_sinonima, position, position+2)

      # sample one current amino randomly
      substr(mutante_sinonima, position, position+2) <- sampling_distribution(translate(current_codon))
    }

    mutante_sinonima

  }
}
