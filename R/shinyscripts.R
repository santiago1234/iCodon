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
    n_iterations = 7,
    n_Daughters = 10,
    make_more_optimal = T
  ) %>%
    dplyr::mutate(optmimization = "optimized")

  res_down <- optimizer(
    sequence_to_optimize = secuencia,
    specie = animal,
    n_iterations = 7,
    n_Daughters = 10,
    make_more_optimal = F
  ) %>%
    dplyr::mutate(optmimization = "deoptimized")

  result <- dplyr::bind_rows(res_up, res_down)

  # truncate results if they go beyond the limits
  # for some sequences the predictions are so high
  # i truncate this to a max value in case this happens

  result %>%
    dplyr::mutate(
      half_life = dplyr::if_else(.data$half_life > 15, 15, .data$half_life),
      half_life = dplyr::if_else(.data$half_life < 1, 1.5, .data$half_life)
    )
}


#' Visualize optimization results in shiny
#'
#' Plots the optimization result to be displaye in the shiny appo
#'
#' @param result tibble output of \code{\link{run_optimization_shinny}}
#'
#' @importFrom ggplot2 aes
#' @return ggplot object
#' @export
#'
#' @examples
viz_result_shiny <- function(result) {
  testing$half_life <- unscale_decay_to_mouse(testing$decay_rate)
  testing <-
    testing %>%
    dplyr::filter(.data$half_life > 0, .data$half_life < 15)


  brk <- c(2, 5, 10, 13)
  labs <- paste0(brk, " hrs")

  p_optimization <-
    result %>%
    dplyr::mutate(
      optmimization2 = purrr::map2_chr(.data$iteration, .data$optmimization, function(x, y) dplyr::if_else(x == 1, "initial", y))
    ) %>%
    ggplot2::ggplot(aes(y = .data$half_life, x = .data$iteration, group = .data$optmimization)) +
    ggplot2::geom_line(alpha = .3) +
    ggplot2::geom_point(aes(color = .data$optmimization2), size = 2) +
    ggrepel::geom_text_repel(ggplot2::aes(y = .data$half_life - .3, label = round(.data$half_life, 1))) +
    ggplot2::scale_y_log10(limits = c(1.5, 15), breaks = brk, labels = labs) +
    ggplot2::scale_x_continuous(breaks = 1:7, labels = c("initial", 2:6, "optimized/\ndeoptimized")) +
    ggplot2::labs(
      y = "half-life (hrs)",
      subtitle = "Optimization Path"
    ) +
    ggplot2::scale_color_manual(values = c('blue', 'grey', 'red')) +
    cowplot::theme_cowplot() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 30, hjust = 1),
      text = ggplot2::element_text(size = 15),
      legend.position = 'none'
    )


  p_density <- testing %>%
    ggplot2::ggplot(aes(x = .data$half_life)) +
    ggplot2::geom_density(fill = "black", alpha = .8) +
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(expand = c(0, 0)) +
    ggplot2::scale_x_log10(limits = c(1.5, 15), breaks = brk, labels = labs) +
    ggplot2::labs(
      x = NULL,
      subtitle = "Endogenous genes\nhalf-life distribution"
    ) +
    cowplot::theme_cowplot() +
    ggplot2::theme(panel.grid = ggplot2::element_blank(), text = ggplot2::element_text(size = 15))

  # the following plot creates quantiles bassed on the endegenous genes
  # half life distributions, this is a visualization aid

  qs <- quantile(testing$half_life, probs = c(1 / 3, 2 / 3, 3 / 3))

  optimality <- tibble::tibble(
    quantile = c(2.5, 4.3, 10),
    x = 0,
    label = c("non-optimal\ngenes", "neutral\ngenes", "optimal\ngenes")
  )

  p_opt <- tibble::tibble(x = 0:1) %>%
    ggplot2::ggplot(aes(x = .data$x)) +
    ggplot2::geom_ribbon(
      aes(ymin = 0, ymax = qs[1]),
      fill = "blue"
    ) +
    ggplot2::geom_ribbon(
      aes(ymin = qs[1], ymax = qs[2]),
      fill = "white"
    ) +
    ggplot2::geom_ribbon(
      aes(ymin = qs[2], ymax = qs[3]),
      fill = "red"
    ) +
    ggplot2::scale_y_log10(limits = c(1.5, 15)) +
    ggplot2::geom_text(
      data =  optimality,
      aes(y = .data$quantile - .5, label = .data$label, color = .data$label), nudge_x = .5,
      size = 4
    ) +
    ggplot2::scale_color_manual(values = c("black", "white", "black")) +
    ggplot2::theme_void() +
    ggplot2::theme(text = ggplot2::element_text(size = 13), legend.position = 'none')


  ## include a plot comparing log2fold change with respecto to initial sequence
  initial <- result %>%
    dplyr::filter(.data$iteration == 1) %>%
    dplyr::slice(1:1) %>%
    dplyr::pull(.data$half_life)

  p_fold <- result %>%
    dplyr::filter(.data$iteration == 7) %>%
    dplyr::mutate(initial_hl = initial) %>%
    ggplot2::ggplot(aes(
      x = .data$optmimization,
      y = log2(.data$half_life / .data$initial_hl)
    )) +
    ggplot2::geom_point() +
    ggplot2::geom_hline(yintercept = 0, linetype = 2) +
    ggplot2::geom_errorbar(aes(ymin = 0, ymax = log2(.data$half_life / .data$initial_hl)), width = 0) +
    ggplot2::labs(
      y = "log2 fold change\n compared to initial seq",
      x = NULL
    ) +
    cowplot::theme_cowplot() +
    ggplot2::theme(text = ggplot2::element_text(size = 13), axis.text.x = ggplot2::element_text(angle = 30, hjust = 1))

  cowplot::plot_grid(
    p_optimization,
    p_density,
    p_opt,
    p_fold,
    ncol = 4,
    align = "h",
    axis = "v",
    rel_widths = c(3, 1.5, 1, 1)
  )
}
