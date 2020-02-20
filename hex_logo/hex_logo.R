plot_cool <- ggplot2::ggplot(data = optimalcodonR::testing) +
  ggridges::stat_density_ridges(
    ggplot2::aes(x = .data$decay_rate, y = 0, fill=factor(stat(quantile))),
    geom = "density_ridges_gradient",
    quantile_lines = TRUE,
    quantiles = 10,
    calc_ecdf = T,
    color=NA
  ) +
  ggplot2::scale_fill_viridis_d() +
  ggplot2::labs(
    y = NULL
  ) +
  ggplot2::ylim(-1, 1) +
  ggplot2::theme_void() +
  ggplot2::theme(axis.ticks.y = ggplot2::element_blank(), axis.text.y = ggplot2::element_blank(), text = ggplot2::element_text(size=17),
                 legend.position = "none")


hexSticker::sticker(plot_cool, package="optimalcodonR",
        p_size=6, s_x=1, s_y=.75, s_width=1.3, s_height=1,p_color = "white",u_color = "white",
        h_fill="black",url = "research.stowers.org/bazzinilab",
        filename="logo.png")

