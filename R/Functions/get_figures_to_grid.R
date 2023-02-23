get_figures_to_grid <- function(data_source) {
  # maunal edit of headings
  data_plots_headings <-
    data_source %>%
    purrr::map(
      .f = ~ .x + ggpubr::rremove("xlab")
    )

  # add column heading
  data_plots_headings[1:3] <-
    purrr::map2(
      .x = data_plots_headings[1:3],
      .y = c("Ecuador", "Papua New Guinea", "Tanzania"),
      .f = ~ .x + ggplot2::labs(title = .y)
    )

  row_heading_n <- seq(0, 17, 3) + 1

  # add row heading
  data_plots_headings[row_heading_n] <-
    purrr::map2(
      .x = data_plots_headings[row_heading_n],
      .y = c("Amino Acid", "CHO", "CHO + Amino Acid", "H20", "Lipid", "NaCl"),
      .f = ~ .x +
        ggplot2::labs(y = .y)
    )

  data_plots_headings[c(1:18)[-row_heading_n]] <-
    purrr::map(
      .x = data_plots_headings[c(1:18)[-row_heading_n]],
      .f = ~ .x + ggpubr::rremove("ylab")
    )

  # tanzania x-asis breaks
  data_plots_headings[seq(3, 18, 3)] <-
    purrr::map(
      .x = data_plots_headings[seq(3, 18, 3)],
      .f = ~ .x +
        ggplot2::scale_x_continuous(
          breaks = seq(800, 2500, 400),
          limits = c(600, 2500)
        )
    )

  res <-
    ggpubr::ggarrange(
      plotlist = data_plots_headings,
      ncol = 3,
      nrow = 6,
      common.legend = TRUE,
      legend = "top",
      widths = c(1.05, 1, 1),
      heights = c(1.2, rep(1, 5))
    ) %>%
    ggpubr::annotate_figure(
      left = ggpubr::text_grob(
        "Relative nutrient use",
        family = "sans",
        size = 12,
        rot = 90
      ),
      bottom = ggpubr::text_grob(
        "Elevation (m.a.s.l.)",
        family = "sans",
        size = 12
      )
    )
  return(res)
}