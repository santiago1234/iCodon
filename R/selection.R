#' Selection (functional factory)
#'
#' produces a function for the selection. This function performs the following"
#' 1. for a set of synonymous sequences predicts the mRNA stability with  @param stability_predictor
#' 2. Using the selection criterion @param optimization selects the fittest individual
#'
#' @param stability_predictor mRNA stability preditor: takes as input a dna sequence
#' and produces a predicted stability (decay rate)
#' @param optimization logical: True for optimization (more stable sequence) and False
#' for deoptimization (more unstable sequence)
#'
#' @return function, selector function that take as input:
#' @param syn_daughters character: synonymous sequences to evaluate (only for output function)
#' @param current_iteration integer: current iteration (only for output function)
#' @export
selection <- function(stability_predictor, optimization = TRUE) {

  # function to select the most advantageous sequence bassed on
  # the optimization/deoptimization
  optimization_selector <- function(df) {
    dplyr::arrange(df, -.data$predicted_stability) %>% dplyr::slice(1:1)
  }

  deoptimization_selector <- function(df) {
    dplyr::arrange(df, .data$predicted_stability) %>% dplyr::slice(1:1)
  }

  artificial_selector <- optimization_selector
  if (!optimization) {
    artificial_selector <- deoptimization_selector
  }


  function(syn_daughters, current_iteration) {
    # syn_daughters: character vector, synonymous sequences
    # returns: sequence with the highest fitness as defined by the predicted
    # stability

    tibble::tibble(
      iteration = current_iteration,
      synonymous_seq = syn_daughters
    ) %>%
      dplyr::mutate(
        predicted_stability = purrr::map_dbl(synonymous_seq, stability_predictor)
      ) %>%
      artificial_selector()
  }
}
