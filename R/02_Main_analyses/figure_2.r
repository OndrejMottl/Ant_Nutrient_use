#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                       Figure 2
#
#
#             O. Mottl, J. Mosses, P. Klimes
#                         2023
#
#----------------------------------------------------------#

# Load configuration ----
library(here)
source(
  here::here(
    "R/00_Config_file.R"
  )
)

# load data ----
mod_bait_occupancy <-
  RUtilpol::get_latest_file(
    file_name = "mod_bait_occupancy",
    dir = here::here("Data/Processed/Models/")
  )

data_to_fit <-
  mod_bait_occupancy %>%
  purrr::pluck("data_to_fit")


# predict ----
mod_bait_occupancy %>%
  purrr::pluck("models") %>%
  dplyr::filter(best_model == TRUE) %>%
  purrr::pluck("mod_name", 1)

data_pred_bait_type <-
  get_predict_by_emmeans(
    sel_mod = mod_bait_occupancy %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    sel_spec = ~bait_type
  ) %>%
  dplyr::mutate(
    regions = "Average"
  )

data_pred_full <-
  get_predict_by_emmeans(
    sel_mod = mod_bait_occupancy %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    sel_spec = ~ bait_type + poly(elevation_mean, 2) * regions * seasons
  )

p_template <-
  tibble::tibble() %>%
  ggplot2::ggplot() +
  ggplot2::coord_cartesian(
    ylim = c(0, 1)
  ) +
  ggplot2::scale_fill_manual(
    values = c("dry" = "red", "wet" = "blue")
  ) +
  ggplot2::theme_bw(
    base_size = 12,
    base_family = "arial"
  ) +
  ggplot2::theme(
    legend.position = "bottom",
    axis.text.x = ggplot2::element_text(
      angle = 45,
      hjust = 1,
      size = 10
    ),
    axis.text.y = ggplot2::element_text(size = 10),
    plot.title = ggplot2::element_text(hjust = 0.5, size = 13),
    axis.title.x = ggplot2::element_text(size = 12),
    axis.title.y = ggplot2::element_text(size = 12),
    legend.title = ggplot2::element_text(size = 13),
    legend.text = ggplot2::element_text(size = 12),
    legend.key.size = unit(0.5, "cm"),
    legend.key.width = unit(0.5, "cm"),
    panel.grid = ggplot2::element_blank()
  ) +
  ggplot2::labs(
    y = "Proportion of occupied baits",
    x = ""
  )

figure_2a <-
  p_template +
  ggplot2::facet_wrap(~"Average", nrow = 1) +
  ggbeeswarm::geom_quasirandom(
    data = data_to_fit,
    mapping = ggplot2::aes(
      x = bait_type,
      y = traps_occupied / (traps_occupied + traps_empty),
    ),
    size = 2,
    shape = 20,
    alpha = 0.25,
    varwidth = TRUE,
    col = "gray50"
  ) +
  ggplot2::geom_linerange(
    data = data_pred_bait_type,
    mapping = ggplot2::aes(
      x = bait_type,
      y = estimate,
      ymin = lower_cl,
      ymax = upper_cl
    ),
    linewidth = 1.5,
    lty = 1
  ) +
  ggplot2::geom_point(
    data = data_pred_bait_type,
    mapping = ggplot2::aes(
      x = bait_type,
      y = estimate,
    ),
    size = 3,
    fill = "white",
    shape = 21
  )

figure_2b <-
  p_template +
  ggplot2::facet_wrap(~regions, nrow = 1) +
  ggbeeswarm::geom_beeswarm(
    data = data_to_fit,
    mapping = ggplot2::aes(
      x = bait_type,
      y = traps_occupied / (traps_occupied + traps_empty),
      col = seasons
    ),
    size = 2,
    shape = 20,
    alpha = 0.25,
    dodge.width = 0.9
  ) +
  ggplot2::geom_linerange(
    data = data_pred_full,
    mapping = ggplot2::aes(
      x = bait_type,
      y = estimate,
      col = seasons,
      ymin = lower_cl,
      ymax = upper_cl
    ),
    linewidth = 1.5,
    lty = 1,
    size = 1,
    position = ggplot2::position_dodge(.9)
  ) +
  ggplot2::geom_point(
    data = data_pred_full,
    mapping = ggplot2::aes(
      x = bait_type,
      y = estimate,
      col = seasons
    ),
    size = 3,
    fill = "white",
    shape = 21,
    position = ggplot2::position_dodge(.9)
  )

figure_2 <-
  ggpubr::ggarrange(
    figure_2a,
    figure_2b +
      ggpubr::rremove("ylab") +
      ggpubr::rremove("y.ticks") +
      ggpubr::rremove("y.text"),
    nrow = 1,
    widths = c(1, 3),
    common.legend = TRUE,
    legend = "bottom",
    align = "hv"
  )

save_figure(
  filename = "figure_2",
  dir = here::here("Outputs"),
  plot = figure_2,
  width = 168,
  height = 120
)
