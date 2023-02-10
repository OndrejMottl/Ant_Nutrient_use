plot_elev_trend <- function(
    data_source,
    data_pred_trend = NULL,
    data_pred_season = NULL,
    data_pred_interaction = NULL,
    facet_by = NULL,
    y_var,
    y_var_name,
    y_trans = "identity",
    y_breaks = ggplot2::waiver()) {
  use_elev_trend <- isFALSE(is.null(data_pred_trend))
  use_season <- isFALSE(is.null(data_pred_season))
  use_interaction <- isFALSE(is.null(data_pred_interaction))
  use_facet <- isFALSE(is.null(facet_by))

  p_0 <-
    ggplot2::ggplot(
      data = data_source,
      mapping = ggplot2::aes(
        x = elevation_mean,
        y = get(y_var)
      )
    ) +
    ggplot2::scale_shape_manual(
      values = c(21, 22)
    ) +
    ggplot2::scale_colour_manual(
      values = c("dry" = "red", "wet" = "blue")
    ) +
    ggplot2::scale_y_continuous(
      trans = y_trans,
      breaks = y_breaks
    ) +
    ggplot2::xlab("Elevation (m.a.s.l.)") +
    ggplot2::ylab(y_var_name) +
    ggplot2::theme_bw(
      base_size = 12,
      base_family = "arial"
    ) +
    ggplot2::theme(legend.position = "none") +
    ggplot2::geom_vline(
      xintercept = c(1000, 3000),
      linetype = "dashed",
      color = "darkgrey",
      linewidth = 1
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        shape = seasons,
        col = seasons
      ),
      size = 5
    )

  if (
    isTRUE(use_facet)
  ) {
    p_0 <-
      p_0 +
      ggplot2::facet_grid(
        as.formula(paste("~", facet_by))
      )
  }

  if (
    isTRUE(use_elev_trend)
  ) {
    p_0 <-
      p_0 +
      ggplot2::geom_line(
        data = data_pred_trend,
        ggplot2::aes(
          x = elevation_mean,
          y = estimate
        ),
        lty = 1,
        linewidth = 1.5
      )
  }

  if (
    isTRUE(use_interaction)
  ) {
    p_0 <-
      p_0 +
      ggplot2::geom_line(
        data = data_pred_interaction,
        ggplot2::aes(
          x = elevation_mean,
          y = estimate,
          col = seasons
        ),
        lty = 1,
        linewidth = 1.5
      )
  }

  if (
    isTRUE(use_season)
  ) {
    p_0 <-
      p_0 +
      ggplot2::geom_rect(
        data = data_pred_season,
        mapping = ggplot2::aes(
          x = NULL,
          y = NULL,
          xmin = -Inf,
          xmax = Inf,
          ymin = lower_cl,
          ymax = upper_cl,
          fill = seasons
        ),
        alpha = 0.15
      ) +
      ggplot2::geom_hline(
        yintercept = data_pred_season %>%
          dplyr::filter(
            seasons == "dry"
          ) %>%
          purrr::pluck("estimate"),
        col = "red",
        lty = 1,
        linewidth = 1.5
      ) +
      ggplot2::geom_hline(
        yintercept = data_pred_season %>%
          dplyr::filter(
            seasons == "wet"
          ) %>%
          purrr::pluck("estimate"),
        col = "blue",
        lty = 1,
        linewidth = 1.5
      )
  }

  return(p_0)
}
