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


#' Generate synonimous mutant variants
#'
#' @param secuencia string, coding DNA sequence in frame
#' @param sampling_distribution function, \code{\link{sample_synonimous_codon}}
#' the sampling codon distribution
#' @param mutation_rate number of positions to be mutated expressed as a percentage
#' max = 1 (mutate all codons), min = 0 (mutate no codons).
#' the 1st and last codon are never changed
#' @param n_daughters int, the number of random synonimous sequences to generate
#' at each function call
#'
#' @return function, sinonimous generator: A function that takes as input
#' a sequence and will create sinonimous mutations in that sequence
#' @export
#'
#' @examples
#' sampling_distribution <- sample_synonimous_codon(
#'   sampling_codon_distribution = sampling_deoptimization
#' )
#' seq <- "ATGCCCGGGATGATGTTT"
#' evolution(seq, sampling_distribution)
evolution <- function(secuencia, sampling_distribution, mutation_rate = .3, n_daughters = 10) {

  stopifnot(nchar(secuencia) > 6)
  stopifnot(mutation_rate >= 0)
  stopifnot(mutation_rate <= 1)

  # pick n positions proportional to the mutation_rate of mutations
  n_positions <- floor(((nchar(secuencia) / 3 ) - 6) * mutation_rate)

  # i start from 4 so the star codon is never touched
  # also the last codon is never touched
  posiciones <- seq(from=4, to = nchar(secuencia) - 3, by = 3)

  # this an internal function to generate a sinonimous variant sequence
  # from the given sequence
  variant_generator <- function(seq2) {
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


  function(current_seq) {
    purrr::map_chr(1:n_daughters, ~variant_generator(current_seq))
  }
}


