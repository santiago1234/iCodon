#' Genetic algorithm for mRNA stability optimization
#'
#' @param sequence_to_optimize character, coding DNA sequence from start codon to
#' stop codon
#' @param specie character, species
#' @param n_iterations integer, number of evolution iterations
#' @param make_more_optimal logical, If true the sequence is optimized, if false
#' @param mutation_Rate double, number of mutation to introduce at each iteration
#' given as a probability (1 = max (mutate all positions), 0 = min (no mutations))
#' @param max_abs_val A maximum value (absolute value) such that the sequences
#' cannot go beyond that value. Infinite is used as default, in this case there is not
#' a limit for the sequences
#' @param n_Daughters integer, number of child sequences to explore at each iteration
#' @param random_seed integer, random seed for getting reproducible results
#'
#' @return a [tibble][tibble::tibble-package], the best sequence at each iteration
#' @export
#'
#' @examples
#' suppressMessages(optimizer(test_seq, n_iterations = 1))
optimizer <- function(sequence_to_optimize,
                      specie = "human",
                      n_iterations = 15,
                      make_more_optimal = T,
                      mutation_Rate = .4,
                      max_abs_val = Inf,
                      n_Daughters = 3,
                      random_seed = 123) {
  sequence_to_optimize <- stringr::str_to_upper(sequence_to_optimize) %>%
    stringr::str_replace_all("[\r\n ]", "") # remove white spaces

  validate_sequence(sequence_to_optimize) # sanity check

  # set a seed for reproducibility
  set.seed(random_seed)

  # initialize the mRNA stability predictor
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
    mutation_rate = mutation_Rate,
    n_daughters = n_Daughters # how many daughters sequences are explored
  )

  message("starting genetic algorithm ...")
  best_at_each_iteration <- vector("list", n_iterations)
  current_best <- selector(sequence_to_optimize, 1)
  best_at_each_iteration[[1]] <- current_best

  for (i in 2:(n_iterations + 1)) {
    message(paste0(i, "."), appendLF = FALSE)

    hijas_mutantes <- evolucionador(current_seq = current_best$synonymous_seq)


    # check if the sequences have gone beyond the value max_abs_val
    # in case this case we will keep always the previous sequence
    current_best_tmp <- selector(hijas_mutantes, i)

    if (current_best_tmp$predicted_stability < max_abs_val & make_more_optimal) {
      current_best <- current_best_tmp
    } else if (current_best_tmp$predicted_stability > -1 * max_abs_val & !make_more_optimal) {
      current_best <- current_best_tmp
    } else {
      current_best$iteration <- current_best$iteration + 1
    }
    best_at_each_iteration[[i]] <- current_best
  }

  dplyr::bind_rows(best_at_each_iteration) %>%
    dplyr::mutate(
      iteration = as.integer(.data$iteration) - 1 #  substrack 1 so 0 is the original seq
    )
}
