seq_to_positional_codon_frame <- function(secuencia) {
  seq(from = 1, to = nchar(secuencia), by = 3) %>%
    purrr::map_chr(function(x) stringr::str_sub(secuencia, x, x + 2)) %>%
    tibble::tibble(
      codon = .,
      position = 1:length(.)
    )
}


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
      ggplot2::ggplot(aes(x=.data$position, y=.data$iteration, fill = optimality)) +
      ggplot2::geom_tile() +
      ggplot2::scale_x_continuous(expand = c(0, 0)) +
      ggplot2::scale_y_continuous(expand = c(0, 0)) +
      ggplot2::scale_fill_viridis_c(option = "C",limits = c(-.03, .03), oob = scales::squish, breaks = c(-.02, 0, .02))
  } else {
    optimality_content_at_each_iteration %>%
      ggplot2::ggplot(aes(x=optimality, group=iteration, color = iteration))+
      ggplot2::geom_density(alpha = .5, size=1/3) +
      ggplot2::scale_color_viridis_c() +
      ggplot2::theme_light()

  }
}
