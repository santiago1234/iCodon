seq_to_positional_codon_frame <- function(secuencia) {
  seq(from = 1, to = nchar(secuencia), by = 3) %>%
    purrr::map_chr(function(x) stringr::str_sub(secuencia, x, x + 2)) %>%
    tibble::tibble(
      codon = .,
      position = 1:length(.)
    )
}

#' Convert scaled decay rate to unscaled versio (half-life)
#'
#' For the purpose of training the model I scaled the decay rates to std = 1
#' and mean = 0. This function puts the decay rate in the slam-seq mouse scale.
#' So I can get back a half life
#'
#' @param scaled_decay_rate double: decay rate (observed or predicted value)
#' @param return_hl logical: if true returns the half life else the decay rata (unscaled)
#'
#' @return half life
#' @export
#'
#' @examples
#' unscale_decay_to_mouse(-2)
unscale_decay_to_mouse <- function(scaled_decay_rate, return_hl = TRUE) {

  # check smedina/projectos/190108-mzt-rna-stability/results/19-04-30-PredictiveModelDecayAllSpecies/19-04-30-EDA/EDAanalysos.Rmd
  mouse_mu <- -0.196103668871582
  mouse_std <- 0.0853732703692994

  decay_unscaled <- (scaled_decay_rate * mouse_std) + mouse_mu

  if (return_hl) {
    decay_unscaled <- -log(2) / decay_unscaled
  }

  decay_unscaled
}


#' Plot optimization path and mRNA stability level
#'
#' plots the optimization path and the mRNA stability level (half life)
#'
#' @param optimization_run tibble: the output result of \code{\link{optimizer}}
#'
#' @importFrom stats quantile
#' @importFrom ggplot2 stat
#' @return ggplot2 object
#' @export
#'
#' @examples
plot_optimization <- function(optimization_run) {

  # put the decay rate and predicted stability in half-life units
  optimization_run <-
    optimization_run %>%
    dplyr::mutate(
      # set a max treshold
      half_life = purrr::map_dbl(.data$half_life, ~ dplyr::if_else(condition = . > 15, true = 14, false = .))
    )

  # the same for the training
  testing$half_life <- unscale_decay_to_mouse(testing$decay_rate)


  initial <- dplyr::filter(optimization_run, .data$iteration == 1) %>%
    dplyr::mutate(etiqueta = "initial\nsequence")


  ending <- dplyr::filter(optimization_run, .data$iteration == nrow(optimization_run)) %>%
    dplyr::mutate(etiqueta = "optimized\nsequence")

  # compute percentiles: What proportion of endegenous genes is less then the
  # given half life?

  initial_percentili <- mean(testing$half_life < initial$half_life) %>%
    round(2)

  ending_percentili <- mean(testing$half_life < ending$half_life) %>%
    round(2)

  initial$etiqueta <- paste0(initial$etiqueta, "\n", initial_percentili * 100, "%")
  ending$etiqueta <- paste0(ending$etiqueta, "\n", ending_percentili * 100, "%")

  trajectory <- dplyr::bind_rows(initial, ending)

  log_fc_half_life <- log2(ending$half_life / initial$half_life) %>%
    round(2)

  # make the plot -----------------------------------------------------------

  ggplot2::ggplot(trajectory) +
    ggridges::stat_density_ridges(
      data = testing, ggplot2::aes(x = .data$half_life, y = 0, fill = factor(stat(quantile))),
      geom = "density_ridges_gradient",
      quantile_lines = TRUE,
      quantiles = 10,
      calc_ecdf = T,
      color = NA
    ) +
    ggplot2::scale_x_continuous(expand = c(0, 0), limits = c(0, 15), breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15), labels = function(x) paste0(x, " hrs")) +
    ggplot2::scale_y_continuous(expand = c(0, 0), breaks = c(.1, .2, .3)) +
    ggplot2::scale_fill_viridis_d(
      name = "mRNA half-life\ndistribution\n(endogenous genes)\n",
      labels = c(
        "[0, 10)%",
        "[10, 20)%",
        "[20, 30)%",
        "[30, 40)%",
        "[40, 50)%",
        "[50, 60)%",
        "[60, 70)%",
        "[70, 80)%",
        "[80, 90)%",
        "[90, 100]%"
      ),
      alpha = 7 / 8
    ) +
    ggplot2::geom_point(data = ending, ggplot2::aes(x = .data$half_life, y = .2), shape = 19, size = 3) +
    ggplot2::geom_point(data = optimization_run, ggplot2::aes(x = .data$half_life, y = .2), shape = 1, size = 2) +
    ggrepel::geom_text_repel(ggplot2::aes(x = .data$half_life, y = .2, label = .data$etiqueta), size = 6, color = "grey30") +
    ggplot2::labs(
      x = "mRNA stability (half life)",
      y = NULL,
      title = paste0("log2 fold = ", log_fc_half_life, "  (prediction)")
    ) +
    ggplot2::geom_text(
      data = data.frame(
        x = 2.2, y = 0.028024362949714,
        label = "Top unstable\ngenes"
      ),
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$label), angle = 0L, lineheight = 1L, hjust = 0.5,
      vjust = 0.5, colour = "grey60",
      inherit.aes = FALSE, show.legend = FALSE, size = 4
    ) +
    ggplot2::geom_text(
      data = data.frame(
        x = 7.5, y = 0.028024362949714,
        label = "Top stable\ngenes"
      ),
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$label), angle = 0L, lineheight = 1L, hjust = 0.5,
      vjust = 0.5, colour = "grey60",
      inherit.aes = FALSE, show.legend = FALSE, size = 4
    ) +
    ggplot2::geom_errorbar(
      data = trajectory,
      inherit.aes = F,
      ggplot2::aes(x = .data$half_life, ymin = 0, ymax = .2),
      width = 0,
      linetype = 2,
      size = 1 / 5
    ) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      text = ggplot2::element_text(size = 16),
      axis.title.x = ggplot2::element_text(size = 17, hjust = 1, color = "grey40"),
      axis.text.x = ggplot2::element_text(colour = "grey"),
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_line(size = 1 / 3, colour = "grey"),
      legend.position = c(.9, .5)
    )
}

#' Visualiztion tools
#'
#' Helper function to visualize the optimization
#' @inheritParams plot_optimization
#' @param draw_heatmap logical: If true draws a heatmap, otherwise draws ... TODO
#'
#' @return plot: ggplot2 object
#' @export
visualize_evolution <- function(optimization_run, draw_heatmap = T) {
  optimality_content_at_each_iteration <-
    optimization_run %>%
    dplyr::select(.data$iteration, .data$synonymous_seq) %>%
    dplyr::mutate(
      codon_positon_data = purrr::map(.data$synonymous_seq, seq_to_positional_codon_frame)
    ) %>%
    dplyr::select(-.data$synonymous_seq) %>%
    tidyr::unnest(.data$codon_positon_data) %>%
    dplyr::inner_join(human_optimality, by = "codon")


  if (draw_heatmap) {
    max_iteration <- max(optimality_content_at_each_iteration$iteration)
    optimality_content_at_each_iteration %>%
      ggplot2::ggplot(ggplot2::aes(x = .data$position, y = .data$iteration, fill = .data$optimality)) +
      ggplot2::geom_tile() +
      ggplot2::scale_x_continuous(expand = c(0, 0)) +
      ggplot2::scale_y_continuous(expand = c(0, 0), breaks = c(1, max_iteration / 2, max_iteration), labels = c("initial\nsequence", "intermediate\nsequences", "optimized\nsequence")) +
      ggplot2::scale_fill_viridis_c(option = "B", limits = c(-.03, .03), oob = scales::squish, breaks = c(-.02, 0, .02)) +
      ggplot2::labs(
        x = "codon position",
        y = "iteration step\n(Genetic Algorithm)",
        fill = "codon optimality\nlevel",
        title = "Sequence Evolution",
        subtitle = "Each change in color represents the introduction of synonymous codon change"
      ) +
      ggplot2::theme(text = ggplot2::element_text(size = 17))
  } else {
    optimality_content_at_each_iteration %>%
      ggplot2::ggplot(ggplot2::aes(x = .data$optimality, group = .data$iteration, color = .data$iteration)) +
      ggplot2::geom_density(alpha = .5, size = 1 / 3) +
      ggplot2::scale_color_viridis_c() +
      ggplot2::theme_light()
  }
}
