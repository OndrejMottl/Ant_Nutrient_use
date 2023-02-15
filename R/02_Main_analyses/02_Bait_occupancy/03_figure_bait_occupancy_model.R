#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                   Figure 2 models
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
    prop_trap_occupied = traps_occupied / n
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

figure_bait_occupancy_model <-
  plot_elev_trend(
    data_source = data_to_fit,
    data_pred_interaction = data_pred_full,
    facet_by = "bait_type ~ regions",
    y_var = "prop_trap_occupied",
    y_var_name = "Proportion of occupied baits",
    p_value = mod_bait_occupancy %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      tidyr::unnest(anova_to_null) %>%
      purrr::pluck(stringr::str_subset(names(.), "pr_chi"), 1),
    x_breaks = seq(0, 4e3, 1e3),
    x_lim = c(0, 4e3),
    legend_position = "top"
  )

save_figure(
  filename = "figure_bait_occupancy_model",
  dir = here::here("Outputs"),
  plot = figure_bait_occupancy_model,
  width = 168,
  height = 170
)
