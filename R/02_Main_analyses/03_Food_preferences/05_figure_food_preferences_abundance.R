#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                       Figure S2
#
#
#           --- authors are hidden for review ---
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
food_pref_models_abundance <-
  RUtilpol::get_latest_file(
    file_name = "food_pref_models_abundance",
    dir = here::here("Data/Processed/Models/")
  )

data_to_fit <-
  food_pref_models_abundance %>%
  purrr::pluck("data_to_fit")

food_pref_abundance_individual_plots <-
  food_pref_models_abundance %>%
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
        point_size = 3,
        y_lim = c(-0.1, 1.1),
        x_breaks = seq(-500, 3.5e3, 500),
        y_breaks = seq(0, 1, 0.25)
      ) +
        ggplot2::theme(
          plot.margin = unit(c(0, 0.3, 0, 0), "cm"),
          axis.text.x = ggplot2::element_text(size = 9),
          plot.title = ggplot2::element_text(hjust = 0.5, vjust = 0, size = 10)
        )
    )
  )


figure_food_preferences_abundance <-
  figure_food_preferences_occurence <-
  get_figures_to_grid(food_pref_abundance_individual_plots$indiv_plot)

save_figure(
  filename = "figure_food_preferences_abundance",
  dir = here::here("Outputs"),
  plot = figure_food_preferences_abundance,
  width = 168,
  height = 230
)
