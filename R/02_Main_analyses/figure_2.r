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
  purrr::pluck("data_to_fit") %>%
  dplyr::mutate(
    trap_occupied = as.numeric(trap_occupied)
  )

# predict ----
mod_bait_occupancy %>%
  purrr::pluck("models") %>%
  dplyr::filter(best_model == TRUE) %>%
  purrr::pluck("mod_name", 1)

dummy_predict_table_interaction <-
  data_to_fit %>%
  dplyr::select(bait_type, elevation_mean, regions, seasons) %>%
  modelbased::visualisation_matrix(
    at = c("bait_type", "elevation_mean", "regions", "seasons"),
    length = 100,
    preserve_range = TRUE
  ) %>%
  tidyr::as_tibble()

data_pred_full <-
  get_predicted_data(
    mod = mod_bait_occupancy %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_interaction
  )

figure_2a <-
  plot_elev_trend(
    data_source = data_to_fit,
    data_pred_interaction = data_pred_full,
    facet_by = "bait_type ~ regions",
    y_var = "trap_occupied",
    y_var_name = "Proportion of occupied baits",
    shape_legend = c(dry = NA, wet = NA),
    p_value = mod_bait_occupancy %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      tidyr::unnest(anova_to_null) %>%
      purrr::pluck(stringr::str_subset(names(.), "pr_chi"), 1)
  )

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

data_pred_no_elev <-
  get_predict_by_emmeans(
    sel_mod = mod_bait_occupancy %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    sel_spec = ~ bait_type * regions * seasons
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
  ggplot2::scale_color_manual(
    values = c("dry" = "red", "wet" = "blue")
  ) +
  ggplot2::scale_shape_manual(
    values = c("dry" = 21, "wet" = 22)
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

figure_2b <-
  p_template +
  ggplot2::facet_wrap(~"Average", nrow = 1) +
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

figure_2c <-
  p_template +
  ggplot2::facet_wrap(~regions, nrow = 1) +
  ggplot2::geom_linerange(
    data = data_pred_no_elev,
    mapping = ggplot2::aes(
      x = bait_type,
      y = estimate,
      col = seasons,
      ymin = lower_cl,
      ymax = upper_cl
    ),
    linewidth = 1.5,
    lty = 1,
    position = ggplot2::position_dodge(.9)
  ) +
  ggplot2::geom_point(
    data = data_pred_no_elev,
    mapping = ggplot2::aes(
      x = bait_type,
      y = estimate,
      col = seasons,
      shape = seasons
    ),
    size = 3,
    fill = "white",
    position = ggplot2::position_dodge(.9)
  )

figure_2bc <-
  ggpubr::ggarrange(
    figure_2b,
    figure_2c +
      ggpubr::rremove("ylab") +
      ggpubr::rremove("y.ticks") +
      ggpubr::rremove("y.text"),
    nrow = 1,
    widths = c(1, 3),
    common.legend = TRUE,
    legend = "none",
    align = "hv"
  )

figure_2 <-
  ggpubr::ggarrange(
    figure_2a,
    figure_2bc,
    nrow = 2,
    heights = c(1, 0.5),
    common.legend = TRUE,
    legend = "top"
  )

save_figure(
  filename = "figure_2",
  dir = here::here("Outputs"),
  plot = figure_2,
  width = 168,
  height = 120
)

# alternative figure 2 ----
figure_2_alt <-
  data_to_fit %>%
  dplyr::group_by(bait_type, regions, seasons, et_pcode) %>%
  dplyr::summarise(
    .groups = "drop",
    n_total_baits = dplyr::n(),
    bait_occupied = sum(trap_occupied, na.rm = TRUE)
  ) %>%
  dplyr::mutate(
    rel_baits_occupied = bait_occupied / n_total_baits
  ) %>%
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = bait_type, region,
      y = rel_baits_occupied,
      col = seasons,
      fill = seasons
    )
  ) +
  ggplot2::facet_wrap(~regions) +
  ggplot2::geom_violin(
    alpha = 0.5,
    position = ggplot2::position_dodge(0.9),
    color = NA
  ) +
  ggplot2::geom_boxplot(
    fill = "white",
    width = 0.25,
    position = ggplot2::position_dodge(0.9),
    outlier.shape = NA
  ) +
  ggplot2::coord_cartesian(
    ylim = c(0, 1)
  ) +
  ggplot2::scale_fill_manual(
    values = c("dry" = "red", "wet" = "blue")
  ) +
  ggplot2::scale_color_manual(
    values = c("dry" = "red", "wet" = "blue")
  ) +
  ggplot2::scale_shape_manual(
    values = c("dry" = 21, "wet" = 22)
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

save_figure(
  filename = "figure_2_alt",
  dir = here::here("Outputs"),
  plot = figure_2_alt,
  width = 168,
  height = 100
)
