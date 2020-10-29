#' Script to run the optimization in shiny app
#'
#' This optimization is run in both direction -> up (optimized) and down (deoptimized)
#'
#' @param secuencia character coding DNA.
#' @param animal character specie.
#'
#' @return tibble: results with optimizatin path
#' @export
#'
#' @examples
run_optimization_shinny <- function(secuencia, animal) {
  res_up <- optimizer(
    sequence_to_optimize = secuencia,
    specie = animal,
    n_iterations = 10,
    n_Daughters = 10,
    mutation_Rate = 0.05,
    make_more_optimal = T
  ) %>%
    dplyr::mutate(optmimization = "optimized")

  res_down <- optimizer(
    sequence_to_optimize = secuencia,
    specie = animal,
    n_iterations = 10,
    n_Daughters = 10,
    mutation_Rate = 0.05,
    make_more_optimal = F
  ) %>%
    dplyr::mutate(optmimization = "deoptimized")

  result <- dplyr::bind_rows(res_up, res_down)


}


#' Visualize optimization results in shiny
#'
#' Plots the optimization result to be displaye in the shiny appo
#'
#' @param result tibble output of \code{\link{run_optimization_shinny}}
#' @param animal string one of (fish, human, mouse, or xenopus)
#'
#' @importFrom ggplot2 aes
#' @return ggplot object
#' @export
#'
#' @examples
viz_result_shiny <- function(result, animal) {

  optipred_specie <- dplyr::filter(optipred, .data$specie == animal, optimality < 2.5, optimality > -2.5)
  endo_qs <- quantile(optipred_specie$optimality)
  # draw a helper tibble
  endo_qs_t <- tibble::tibble(per = names(endo_qs), qs = endo_qs, iteration = 10.7)

  p_optimization <-
    result %>%
    dplyr::mutate(
      optmimization2 = purrr::map2_chr(.data$iteration, .data$optmimization, function(x, y) dplyr::if_else(x == 1, "initial", y))
    ) %>%
    ggplot2::ggplot(aes(y = .data$predicted_stability, x = .data$iteration, group = .data$optmimization)) +
    ggplot2::geom_line(alpha = .3) +
    ggplot2::geom_point(aes(color = .data$optmimization2), size = 2) +
    ggrepel::geom_text_repel(ggplot2::aes(y = .data$predicted_stability - .3, label = round(.data$predicted_stability, 1))) +
    ggplot2::scale_x_continuous(breaks = 1:10, labels = c("initial", 2:9, "optimized/\ndeoptimized")) +
    ggplot2::labs(
      y = "mRNA stability (prediction)",
      subtitle = "Optimization Path"
    ) +
    ggplot2::scale_color_manual(values = c('blue', 'grey', 'red')) +
    cowplot::theme_cowplot() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 30, hjust = 1),
      text = ggplot2::element_text(size = 15),
      legend.position = 'none'
    ) +
    # drw the lines for the quantil in the endogenous genes distribution
    ggplot2::geom_text(data = endo_qs_t, aes(x = .data$iteration, y = .data$qs, group = 1.5, label = per), color = "grey", size = 5) +
    ggplot2::geom_hline(yintercept = endo_qs[1], color = "#2166ac", linetype = 3, size = 1/4) +
    ggplot2::geom_hline(yintercept = endo_qs[2], color = "#4393c3", linetype = 3, size = 1/4) +
    ggplot2::geom_hline(yintercept = endo_qs[3], color = "#92c5de", linetype = 3, size = 1/4) +
    ggplot2::geom_hline(yintercept = endo_qs[4], color = "#f4a582", linetype = 3, size = 1/4) +
    ggplot2::geom_hline(yintercept = endo_qs[5], color = "#b2182b", linetype = 3, size = 1/4)



  p_density <- optipred_specie %>%
    ggplot2::ggplot(aes(x = .data$optimality)) +
    ggplot2::geom_density(fill = "grey", color = NA, alpha = .8) +
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(expand = c(0, 0)) +
    ggplot2::labs(
      x = NULL,
      subtitle = paste0(animal, " genes\n mRNA stability")
    ) +
    cowplot::theme_cowplot() +
    ggplot2::theme(panel.grid = ggplot2::element_blank(), text = ggplot2::element_text(size = 15)) +
    ggplot2::geom_vline(xintercept = endo_qs[1], color = "#2166ac", linetype = 3, size = 1/2) +
    ggplot2::geom_vline(xintercept = endo_qs[2], color = "#4393c3", linetype = 3, size = 1/2) +
    ggplot2::geom_vline(xintercept = endo_qs[3], color = "#92c5de", linetype = 3, size = 1/2) +
    ggplot2::geom_vline(xintercept = endo_qs[4], color = "#f4a582", linetype = 3, size = 1/2) +
    ggplot2::geom_vline(xintercept = endo_qs[5], color = "#b2182b", linetype = 3, size = 1/2) +
    ggplot2::annotate(geom="text", x=-1, y=.7, label="Non-optimal genes",
                      color="blue", size = 7) +
    ggplot2::annotate(geom="text", x=1, y=.7, label="Optimal genes",
                      color="red", size = 7)


  cowplot::plot_grid(
    p_optimization,
    p_density,
    #p_opt,
    #p_fold,
    ncol = 2,
    align = "h",
    axis = "v",
    rel_widths = c(2.5, 1.5)
  )
}
