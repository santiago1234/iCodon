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
#' @return
#' @export
#'
#' @examples
plot_optimization <- function(optimization_run) {
  initial <- dplyr::filter(optimization_run, .data$iteration == 1) %>%
    dplyr::mutate(etiqueta = "initial sequence")


  ending <- dplyr::filter(optimization_run, .data$iteration == nrow(optimization_run)) %>%
    dplyr::mutate(etiqueta = "optimized sequence")


  trajectory <- dplyr::bind_rows(initial, ending)
  label_pos <- initial$predicted_stability

  testing %>%
    ggplot2::ggplot(ggplot2::aes(x=.data$decay_rate)) +
    ggplot2::geom_freqpoly(bins=50, color="darkblue") +
    ggplot2::geom_point(
      data = optimization_run,
      ggplot2::aes(y=200, x=.data$predicted_stability, color=.data$iteration),
      shape=18,
      size=3
    ) +
    ggplot2::geom_rect(data=trajectory, mapping=ggplot2::aes(
      xmin=min(.data$predicted_stability),x=NULL,
      xmax=max(.data$predicted_stability),
      ymin=0, ymax=450), fill="black", alpha=0.1) +
    ggplot2::geom_line(
      data = optimization_run,
      ggplot2::aes(y=200, x=.data$predicted_stability, color=.data$iteration)
    ) +
    ggplot2::scale_x_continuous(expand = c(0,0)) +
    ggplot2::scale_y_continuous(expand = c(0,0)) +
    ggrepel::geom_text_repel(
      data = initial,
      ggplot2::aes(x=.data$predicted_stability, y=160, label=.data$etiqueta),
      color="#132B43"
    ) +
    ggrepel::geom_text_repel(
      data = ending,
      ggplot2::aes(x=.data$predicted_stability, y=240, label=.data$etiqueta),
      color="#56B1F7"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      x = "scaled decay rate",
      title = "mRNA stability level",
      color="iteration\nstep"
    ) +
    ggplot2::annotate("text", x = -2, y = 55, label = "distribution of \nendogenous genes", color="darkblue") +
    ggplot2::annotate("text", x = label_pos, y = 430, label = "optimization trajectory") +
    ggplot2::theme(text = ggplot2::element_text(size = 17, family = "Helvetica"))


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
      ggplot2::scale_fill_viridis_c(option = "C", limits = c(-.03, .03), oob = scales::squish, breaks = c(-.02, 0, .02)) +
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


