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

# load data ----# load data ----
data_full <-
  RUtilpol::get_latest_file(
    file_name = "data_full_clean",
    dir = here::here("Data/Processed")
  )

dplyr::glimpse(data_full)

data_mean_elevation <-
  RUtilpol::get_latest_file(
    file_name  = "data_mean_elevation",
    dir = here::here("Data/Processed")
  )

dplyr::glimpse(data_mean_elevation)

# data wrangling ----
data_to_traps <-
  data_full %>%
  dplyr::filter(
    excl_occupancy == FALSE
  ) %>%
  dplyr::group_by(
    regions, seasons, et_pcode, trap_number_code, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    total_abundance = sum(abundance)
  ) %>%
  dplyr::mutate(
    trap_occupied = ifelse(total_abundance > 0, 1, 0)
  ) %>%
  dplyr::group_by(
    regions, seasons, et_pcode, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n = dplyr::n(),
    traps_occupied = sum(trap_occupied),
    traps_empty = n - traps_occupied
  )

data_to_fit <-
  dplyr::left_join(
    data_to_traps,
    data_mean_elevation,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    prop_baits_occup = traps_occupied / n
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(is.character),
      as.factor
    )
  )

data_mean_season <-
  data_to_fit %>%
  dplyr::group_by(regions, seasons, bait_type) %>%
  dplyr:::summarise(
    .groups = "keep",
    n = dplyr::n(),
    mean_prop_baits_occup = mean(prop_baits_occup),
    sd = sd(prop_baits_occup),
    upper_q = stats::quantile(prop_baits_occup, 0.975),
    lower_q = stats::quantile(prop_baits_occup, 0.025)
  ) %>%
  dplyr::mutate(
    upper = mean_prop_baits_occup + sd,
    lower = max(c(0, mean_prop_baits_occup - sd), na.rm = TRUE)
  )

data_mean <-
  data_to_fit %>%
  dplyr::group_by(bait_type) %>%
  dplyr:::summarise(
    .groups = "keep",
    n = dplyr::n(),
    mean_prop_baits_occup = mean(prop_baits_occup),
    sd = sd(prop_baits_occup),
    upper_q = stats::quantile(prop_baits_occup, 0.975),
    lower_q = stats::quantile(prop_baits_occup, 0.025)
  ) %>%
  dplyr::mutate(
    upper = mean_prop_baits_occup + sd,
    lower = max(c(0, mean_prop_baits_occup - sd), na.rm = TRUE)
  )

p_template <-
  tibble::tibble() %>%
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = bait_type
    )
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
    base_family = "sans"
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
  ggplot2::geom_bar(
    data = data_mean,
    mapping = ggplot2::aes(
      y = mean_prop_baits_occup
    ),
    stat = "identity",
    col = "gray30",
    alpha = 0.75,
    position = ggplot2::position_dodge(0.9)
  ) +
  ggplot2::geom_errorbar(
    data = data_mean,
    mapping = ggplot2::aes(
      y = mean_prop_baits_occup,
      ymin = lower,
      ymax = upper
    ),
    col = "gray30",
    width = .5,
    position = ggplot2::position_dodge(0.9)
  ) +
  ggplot2::geom_point(
    data = data_mean,
    mapping = ggplot2::aes(
      y = mean_prop_baits_occup
    ),
    position = ggplot2::position_dodge(0.9)
  )

figure_2b <-
  p_template +
  ggplot2::facet_wrap(~regions, nrow = 1) +
  ggplot2::geom_bar(
    data = data_mean_season,
    mapping = ggplot2::aes(
      y = mean_prop_baits_occup,
      fill = seasons
    ),
    stat = "identity",
    col = "gray30",
    alpha = 0.75,
    position = ggplot2::position_dodge(0.9)
  ) +
  ggplot2::geom_errorbar(
    data = data_mean_season,
    mapping = ggplot2::aes(
      y = mean_prop_baits_occup,
      ymin = lower,
      ymax = upper,
      group = seasons
    ),
    col = "gray30",
    width = .5,
    position = ggplot2::position_dodge(0.9)
  ) +
  ggplot2::geom_point(
    data = data_mean_season,
    mapping = ggplot2::aes(
      y = mean_prop_baits_occup,
      col = seasons,
      shape = seasons
    ),
    position = ggplot2::position_dodge(0.9)
  )

figure_2 <-
  ggpubr::ggarrange(
    figure_2a,
    figure_2b +
      ggpubr::rremove("ylab") +
      ggpubr::rremove("y.ticks") +
      ggpubr::rremove("y.text"),
    nrow = 1,
    widths = c(0.3, 1),
    common.legend = TRUE,
    legend = "top"
  )

save_figure(
  filename = "figure_2",
  dir = here::here("Outputs"),
  plot = figure_2,
  width = 168,
  height = 80
)
