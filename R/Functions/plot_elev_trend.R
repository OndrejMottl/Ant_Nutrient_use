plot_elev_trend <- function(
    data_source,
    data_pred_trend = NULL,
    data_pred_season = NULL,
    data_pred_interaction = NULL,
    facet_by = NULL,
    facet_scales = "fixed",
    color_by = "seasons",
    color_by_name = "Season",
    line_type_by = NULL,
    point_size = 5,
    y_var,
    y_var_name,
    y_trans = "identity",
    y_breaks = ggplot2::waiver(),
    x_breaks = ggplot2::waiver(),
    x_line = NULL,
    p_value = 0,
    x_lim = c(NA, NA),
    y_lim = c(NA, NA),
    shape_legend = c("dry" = 21, "wet" = 22),
    color_legend = c("dry" = "red", "wet" = "blue"),
    line_type_legend = c("dry" = "solid", "wet" = "solid"),
    legend_position = "none") {
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
      values = shape_legend
    ) +
    ggplot2::scale_colour_manual(
      values = color_legend
    ) +
    ggplot2::scale_fill_manual(
      values = color_legend
    ) +
    ggplot2::scale_linetype_manual(
      values = line_type_legend
    ) +
    ggplot2::scale_y_continuous(
      trans = y_trans,
      breaks = y_breaks
    ) +
    ggplot2::scale_x_continuous(
      breaks = x_breaks
    ) +
    ggplot2::labs(
      x = "Elevation (m.a.s.l.)",
      y = y_var_name,
      color = color_by_name,
      fill = color_by_name,
      shape = color_by_name,
      linetype = line_type_by
    ) +
    ggplot2::coord_cartesian(
      xlim = x_lim,
      ylim = y_lim
    ) +
    ggplot2::theme_bw(
      base_size = 12,
      base_family = "sans"
    ) +
    ggplot2::guides(
      fill = "none",
      linetype = ggplot2::guide_legend(
        override.aes = list(linewidth = 0.5))
    ) +
    ggplot2::theme(
      legend.position = legend_position,
      legend.key.width = ggplot2::unit(0.5, "cm")) +
    ggplot2::geom_vline(
      xintercept = x_line,
      linetype = "dashed",
      color = "darkgrey",
      linewidth = 1
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        shape = get(color_by),
        col = get(color_by)
      ),
      size = point_size
    )

  if (
    isTRUE(use_facet)
  ) {
    p_0 <-
      p_0 +
      ggplot2::facet_grid(
        as.formula(paste(facet_by)),
        scales = facet_scales
      )
  }

  if (
    isTRUE(use_elev_trend)
  ) {
    p_0 <-
      p_0 +
      ggplot2::geom_ribbon(
        data = data_pred_trend,
        mapping = ggplot2::aes(
          x = elevation_mean,
          y = estimate,
          ymax = conf_high,
          ymin = conf_low,
          lty = lget(line_type_by)
        ),
        color = NA,
        fill = "gray50",
        alpha = dplyr::case_when(
          p_value < 0.05 ~ 0.15,
          p_value < 0.1 ~ 0.10,
          .default = 0
        )
      ) +
      ggplot2::geom_line(
        data = data_pred_trend,
        ggplot2::aes(
          x = elevation_mean,
          y = estimate
        ),
        lty = dplyr::case_when(
          p_value < 0.05 ~ 1,
          p_value < 0.1 ~ 2,
          .default = 0
        ),
        alpha = dplyr::case_when(
          p_value < 0.1 ~ 1,
          .default = 0
        ),
        linewidth = 1.5
      )
  }

  if (
    isTRUE(use_interaction)
  ) {
    if (
      isTRUE(
        is.null(line_type_by)
      )
    ) {
      p_0 <-
        p_0 +
        ggplot2::geom_ribbon(
          data = data_pred_interaction,
          mapping = ggplot2::aes(
            x = elevation_mean,
            y = estimate,
            ymax = conf_high,
            ymin = conf_low,
            fill = get(color_by),
          ),
          color = NA,
          alpha = dplyr::case_when(
            p_value < 0.05 ~ 0.15,
            p_value < 0.1 ~ 0.10,
            .default = 0
          )
        ) +
        ggplot2::geom_line(
          data = data_pred_interaction,
          ggplot2::aes(
            x = elevation_mean,
            y = estimate,
            col = get(color_by)
          ),
          lty = dplyr::case_when(
            p_value < 0.05 ~ 1,
            p_value < 0.1 ~ 2,
            .default = 0
          ),
          alpha = dplyr::case_when(
            p_value < 0.1 ~ 1,
            .default = 0
          ),
          linewidth = 1.5
        )
    } else {
      p_0 <-
        p_0 +
        ggplot2::geom_ribbon(
          data = data_pred_interaction,
          mapping = ggplot2::aes(
            x = elevation_mean,
            y = estimate,
            ymax = conf_high,
            ymin = conf_low,
            fill = get(color_by),
            lty = get(line_type_by)
          ),
          color = NA,
          alpha = dplyr::case_when(
            p_value < 0.05 ~ 0.15,
            p_value < 0.1 ~ 0.10,
            .default = 0
          ),
          show.legend = FALSE
        ) +
        ggplot2::geom_line(
          data = data_pred_interaction,
          ggplot2::aes(
            x = elevation_mean,
            y = estimate,
            col = get(color_by),
            lty = get(line_type_by)
          ),
          alpha = dplyr::case_when(
            p_value < 0.1 ~ 1,
            .default = 0
          ),
          linewidth = 1.5,
          show.legend = c(linetype = TRUE)
        )
    }
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
          ymin = conf_low,
          ymax = conf_high,
          fill = get(color_by)
        ),
        alpha = dplyr::case_when(
          p_value < 0.05 ~ 0.15,
          p_value < 0.1 ~ 0.10,
          .default = 0
        )
      ) +
      ggplot2::geom_hline(
        yintercept = data_pred_season %>%
          dplyr::filter(
            get(color_by) == "dry"
          ) %>%
          purrr::pluck("estimate"),
        col = "red",
        linewidth = 1.5,
        lty = dplyr::case_when(
          p_value < 0.05 ~ 1,
          p_value < 0.1 ~ 2,
          .default = 0
        ),
        alpha = dplyr::case_when(
          p_value < 0.1 ~ 1,
          .default = 0
        )
      ) +
      ggplot2::geom_hline(
        yintercept = data_pred_season %>%
          dplyr::filter(
            get(color_by) == "wet"
          ) %>%
          purrr::pluck("estimate"),
        col = "blue",
        linewidth = 1.5,
        lty = dplyr::case_when(
          p_value < 0.05 ~ 1,
          p_value < 0.1 ~ 2,
          .default = 0
        ),
        alpha = dplyr::case_when(
          p_value < 0.1 ~ 1,
          .default = 0
        )
      )
  }

  return(p_0)
}
