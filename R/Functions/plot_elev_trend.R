plot_elev_trend <- function(
    data_source,
    data_pred_simple,
    data_pred_full,
    y_var,
    y_var_name,
    y_trans = "identity",
    y_breaks = ggplot2::waiver()) {
  data_source %>%
    ggplot2::ggplot(
      ggplot2::aes(
        x = meanElevation,
        y = get(y_var)
      )
    ) +
    ggplot2::geom_vline(
      xintercept = c(1000, 3000),
      linetype = "dashed",
      color = "darkgrey",
      linewidth = 1
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        shape = Seasons,
        col = Seasons
      ),
      size = 5
    ) +
    ggplot2::geom_line(
      data = data_pred_simple,
      ggplot2::aes(
        x = meanElevation,
        y = predicted
      ),
      lty = 1,
      lwd = 1.5
    ) +
    ggplot2::geom_line(
      data = data_pred_full,
      ggplot2::aes(
        x = meanElevation,
        y = predicted,
        col = Seasons
      ),
      lty = 1, lwd = 1.5
    ) +
    ggplot2::scale_shape_manual(
      values = c(21, 22)
    ) +
    ggplot2::scale_colour_manual(
      values = c("Dry" = "red", "Wet" = "blue")
    ) +
    ggplot2::scale_y_continuous(
      trans = y_trans,
      breaks = y_breaks
    ) +
    ggplot2::facet_grid(~Regions) +
    ggplot2::xlab("Elevation (m.a.s.l.)") +
    ggplot2::ylab(y_var_name) +
    ggplot2::theme_bw(
      base_size = 12,
      base_family = "arial"
    ) +
    ggplot2::theme(legend.position = "none") %>%
    return()
}
