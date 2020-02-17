#' Genetic algorithm for mRNA stability optimization
#'
#' @param sequence_to_optimize character, coding DNA sequence from start codon to
#' stop codon
#' @param specie character, species
#' @param n_iterations integer, number of evolution iterations
#' @param make_more_optimal logical, If true the sequence is optimized, if false
#' is is deoptimized (less optimal)
#'
#' @return tibble data frame, the best sequence at each iteration
#' @export
#'
#' @examples
#' suppressMessages(optimizer(test_seq, n_iterations = 1))
optimizer <- function(sequence_to_optimize,
                      specie = "human",
                      n_iterations = 100,
                      make_more_optimal = T) {
  sequence_to_optimize <- stringr::str_to_upper(sequence_to_optimize)
  validate_sequence(sequence_to_optimize) # sanity check

  # initialize the mRNA stabilitiy predictor
  stability_predictor <- predict_stability(specie)

  # initialize function for optimization
  # sample codon according to optimality
  if (make_more_optimal) {
    message("optimizing sequence (more optimal)")
    codon_sampling_distribution <- sampling_optimization
    # create the selecion function bassed on optimization/deoptimization
    selector <- selection(stability_predictor, optimization = make_more_optimal)
  } else {
    message("deoptimizing sequence (more non-optimal)")
    codon_sampling_distribution <- sampling_deoptimization
    selector <- selection(stability_predictor, optimization = make_more_optimal)
  }


  # create the sampling function
  sampling_function <- sample_synonimous_codon(codon_sampling_distribution)
  # create the function to evolve the sequences
  # IMPORTANT: evolution parameters specified here
  evolucionador <- evolution(
    starting_sequence = sequence_to_optimize,
    sampling_distribution = sampling_function,
    mutation_rate = .3,
    n_daughters = 10 # how many daughters sequences are explored
  )

  message("starting genetic algorithm ...")
  best_at_each_iteration <- vector("list", n_iterations)
  current_best <- selector(sequence_to_optimize, 1)
  best_at_each_iteration[[1]] <- current_best

  for (i in 2:n_iterations) {
    message(i)

    hijas_mutantes <- evolucionador(current_seq = current_best$synonymous_seq)
    current_best <- selector(hijas_mutantes, i)
    best_at_each_iteration[[i]] <- current_best
  }

  dplyr::bind_rows(best_at_each_iteration)
}
