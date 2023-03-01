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
  # make all characters into factors
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.character
      ),
      as.factor
    )
  ) %>%
  dplyr::mutate(
    regions = forcats::fct_recode(
      regions,
      "Papua New Guinea" = "png",
      "Ecuador" = "ecuador",
      "Tanzania" = "tanzania"
    ),
    bait_type = forcats::fct_recode(
      bait_type,
      "Amino Acid" = "amino_acid",
      "CHO" = "cho",
      "CHO + Amino Acid" = "cho_amino_acid",
      "H2O" = "h2o",
      "Lipid" = "lipid",
      "NaCl" = "nacl"
    )
  )

data_traps_region <-
  data_to_traps %>%
  dplyr::group_by(
    regions, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n = dplyr::n(),
    traps_occupied = sum(trap_occupied),
    trap_occupancy = (traps_occupied / n) * 100
  ) %>%
  dplyr::group_by(bait_type) %>%
  dplyr::summarise(
    .groups = "drop",
    mean_trap_occupancy = mean(trap_occupancy),
    sd_trap_occupancy = sd(trap_occupancy),
    lower = mean_trap_occupancy - sd_trap_occupancy,
    upper = mean_trap_occupancy + sd_trap_occupancy
  )

data_traps_seasons <-
  data_to_traps %>%
  dplyr::group_by(
    regions, seasons, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n = dplyr::n(),
    traps_occupied = sum(trap_occupied),
    trap_occupancy = (traps_occupied / n) * 100
  )

p_template <-
  tibble::tibble() %>%
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = bait_type
    )
  ) +
  ggplot2::coord_cartesian(
    ylim = c(0, 100)
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
    y = "% occupaby of baits",
    x = ""
  )

plot_list <- vector("list", length = 4)

plot_list[[1]] <-
  p_template +
  ggplot2::facet_wrap(~"Average per region", nrow = 1) +
  ggplot2::geom_bar(
    data = data_traps_region,
    mapping = ggplot2::aes(
      y = mean_trap_occupancy
    ),
    stat = "identity",
    col = "gray30",
    alpha = 0.75,
    position = ggplot2::position_dodge(0.9)
  ) +
  ggplot2::geom_errorbar(
    data = data_traps_region,
    mapping = ggplot2::aes(
      y = mean_trap_occupancy,
      ymin = lower,
      ymax = upper
    ),
    col = "gray30",
    width = .5,
    position = ggplot2::position_dodge(0.9)
  ) +
  ggplot2::geom_hline(
    yintercept = mean(data_traps_region$mean_trap_occupancy),
    lty = 2,
    linewidth = .5,
    col = "black",
    alpha = .5
  )

plot_list[2:4] <-
  purrr::map(
    .x = levels(data_traps_seasons$regions),
    .f = ~ p_template +
      ggplot2::facet_wrap(as.formula(paste0("~ '", .x, "'")), nrow = 1) +
      ggplot2::geom_bar(
        data = data_traps_seasons %>%
          dplyr::filter(regions == .x),
        mapping = ggplot2::aes(
          y = trap_occupancy,
          fill = seasons
        ),
        stat = "identity",
        col = "gray30",
        alpha = 0.75,
        position = ggplot2::position_dodge(0.9)
      ) +
      ggplot2::geom_hline(
        yintercept = data_traps_seasons %>%
          dplyr::filter(regions == .x) %>%
          purrr::pluck("trap_occupancy") %>%
          mean(),
        lty = 2,
        linewidth = .5,
        col = "black",
        alpha = .5
      )
  )

figure_bait_occupancy_data <-
  ggpubr::ggarrange(
   plotlist = plot_list,
    nrow = 2,
    ncol = 2,
    common.legend = TRUE,
    legend = "bottom",
    labels = c("(a)", "(b)", "(c)", "(d)")
  )

save_figure(
  filename = "figure_bait_occupancy_data",
  dir = here::here("Outputs"),
  plot = figure_bait_occupancy_data,
  width = 168,
  height = 180
)
