#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                       Figure 3
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
food_pref_models_individual <-
  RUtilpol::get_latest_file(
    file_name = "food_pref_models_individual",
    dir = here::here("Data/Processed/Models/")
  )

data_to_fit <-
  food_pref_models_individual %>%
  purrr::pluck("data_to_fit")

data_food_pref_individual_plots <-
  food_pref_models_individual %>%
  purrr::pluck("models") %>%
  dplyr::filter(best_model == TRUE) %>%
  tidyr::unnest(test_to_null) %>%
  dplyr::mutate(
    indiv_plot = purrr::pmap(
      .l = list(
        regions, # ..1
        sel_bait_type, # ..2
        mod_name, # ..3
        mod, # ..4
        p_value_chisq # ..5
      ),
      .f = ~ plot_food_pref(
        data_source = data_to_fit,
        sel_region = ..1,
        sel_bait_type = ..2,
        sel_mod_name = ..3,
        sel_mod = ..4,
        sel_p_value = ..5,
        point_size = 3
      )
    )
  )

# maunal edit of headings
data_plots_headings <-
  data_food_pref_individual_plots$indiv_plot %>%
  purrr::map(
    .f = ~ .x + ggplot2::labs(
      x = "",
      y = ""
    ) +
      ggplot2::theme(
        plot.margin = unit(c(0, 0.3, 0, 0), "cm"),
        axis.text.x = ggplot2::element_text(size = 7),
        plot.title = ggplot2::element_text(hjust = 0.5, vjust = 0, size = 10)
      )
  )

# add column heading
data_plots_headings[1:3] <-
  purrr::map2(
    .x = data_plots_headings[1:3],
    .y = c("Ecuador", "Papue New Guinea", "Tanzania"),
    .f = ~ .x + ggplot2::labs(title = .y)
  )

# add row heading
data_plots_headings[seq(0, 17, 3) + 1] <-
  purrr::map2(
    .x = data_plots_headings[seq(0, 17, 3) + 1],
    .y = c("Amino Acid", "CHO", "CHO + Amino Acid", "H20", "Lipid", "NaCl"),
    .f = ~ .x +
      ggplot2::labs(y = .y)
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

figure_food_preferences_occurence <-
  ggpubr::ggarrange(
    plotlist = data_plots_headings,
    ncol = 3,
    nrow = 6,
    common.legend = TRUE,
    legend = "right"
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

save_figure(
  filename = "figure_food_preferences_occurence",
  dir = here::here("Outputs"),
  plot = figure_food_preferences_occurence,
  width = 168,
  height = 230
)

