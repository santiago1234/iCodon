seq_to_positional_codon_frame <- function(secuencia) {
  seq(from = 1, to = nchar(secuencia), by = 3) %>%
    purrr::map_chr(function(x) stringr::str_sub(secuencia, x, x + 2)) %>%
    tibble::tibble(
      codon = .,
      position = 1:length(.)
    )
}

#' Plot optimization path and mRNA stability level
#'
#' plots the optimization path and the mRNA stability level
#'
#' @param optimization_run tibble: the output result of \code{\link{optimizer}}
#'
#' @importFrom stats quantile
#' @return ggplot2 object
#' @export
#'
#' @examples
plot_optimization <- function(optimization_run) {
  initial <- dplyr::filter(optimization_run, .data$iteration == 1) %>%
    dplyr::mutate(etiqueta = "initial\nsequence")


  ending <- dplyr::filter(optimization_run, .data$iteration == nrow(optimization_run)) %>%
    dplyr::mutate(etiqueta = "optimized\nsequence")


  trajectory <- dplyr::bind_rows(initial, ending)

  cool_plot <- ggplot2::ggplot(trajectory) +
    ggridges::stat_density_ridges(
      data = testing, ggplot2::aes(x = .data$decay_rate, y = 0, fill=factor(stat(quantile))),
      geom = "density_ridges_gradient",
      quantile_lines = TRUE,
      quantiles = 10,
      calc_ecdf = T,
      color=NA
    ) +
    ggplot2::scale_fill_viridis_d(
      name="mRNA stability\ndistribution\n(endogenous genes)\n",
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
      )
    ) +
    ggplot2::geom_line(ggplot2::aes(x=.data$predicted_stability, y=.4)) +
    ggplot2::geom_point(data = ending, ggplot2::aes(x=.data$predicted_stability, y=.4), shape=19, size=3) +
    ggplot2::geom_point(data = optimization_run, ggplot2::aes(x=.data$predicted_stability, y=.4), shape=1, size=2) +
    ggrepel::geom_text_repel(ggplot2::aes(x=.data$predicted_stability, y=.4, label=.data$etiqueta), size=7) +
    ggplot2::labs(
      x = "mRNA degradation rate (scaled)",
      y = NULL,
      subtitle = "Gene optimization trajectory",
      title = "Predicted mRNA stability"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.ticks.y = ggplot2::element_blank(), axis.text.y = ggplot2::element_blank(), text = ggplot2::element_text(size=17))

  # add some annotation
  # to indicate the top stable and unstable genes
  cool_plot +
    ggplot2::geom_label(data = data.frame(x = 1.8151971625381, y = 0.058024362949714,
                                 label = "Top stable genes"),
               mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$label), angle = 0L, lineheight = 1L, hjust = 0.5,
               vjust = 0.5, colour = "black", family = "sans", fontface = "plain",
               inherit.aes = FALSE, show.legend = FALSE, size=5) +
    ggplot2::geom_label(data = data.frame(x = -1.8151971625381, y = 0.058024362949714,
                                 label = "Top unstable genes"),
               mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$label), angle = 0L, lineheight = 1L, hjust = 0.5,
               vjust = 0.5, colour = "black", family = "sans", fontface = "plain",
               inherit.aes = FALSE, show.legend = FALSE, size=5)

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
    optimality_content_at_each_iteration %>%
      ggplot2::ggplot(ggplot2::aes(x = .data$position, y = .data$iteration, fill = .data$optimality)) +
      ggplot2::geom_tile() +
      ggplot2::scale_x_continuous(expand = c(0, 0)) +
      ggplot2::scale_y_continuous(expand = c(0, 0)) +
      ggplot2::scale_fill_viridis_c(option = "B", limits = c(-.03, .03), oob = scales::squish, breaks = c(-.02, 0, .02)) +
      ggplot2::labs(
        x = "codon position",
        y = "iteration step\n(Genetic Algorithm)",
        fill = "codon optimality\nlevel",
        title = "Sequence Evolution",
        subtitle = "Each change in color represents the introduction of synonymous codon change"
      ) +
      ggplot2::theme(text = ggplot2::element_text(size = 17, family = "Helvetica"))
  } else {
    optimality_content_at_each_iteration %>%
      ggplot2::ggplot(ggplot2::aes(x = .data$optimality, group = .data$iteration, color = .data$iteration)) +
      ggplot2::geom_density(alpha = .5, size = 1 / 3) +
      ggplot2::scale_color_viridis_c() +
      ggplot2::theme_light()
  }
}
