#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Figure 4
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

# load models ----
mod_guilds_proportions <-
  RUtilpol::get_latest_file(
    file_name = "mod_guilds_proportions",
    dir = here::here("Data/Processed/Models/")
  )

data_to_fit <-
  mod_guilds_proportions %>%
  purrr::pluck("data_to_fit") 

# predict -----
# check the final model
mod_guilds_proportions %>%
  purrr::pluck("models") %>%
  dplyr::filter(best_model == TRUE) %>%
  purrr::pluck("mod_name", 1)

# dummy tables to predict upon
dummy_predict_table_interaction <-
  data_to_fit %>%
  dplyr::select(guild, elevation_mean, regions) %>%
  modelbased::visualisation_matrix(
    at = c("guild", "elevation_mean", "regions"),
    length = 100,
    preserve_range = TRUE
  ) %>%
  tidyr::as_tibble()

data_pred_guilds_proportions <-
  get_predicted_data(
    mod = mod_guilds_proportions %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_interaction
  ) %>%
  dplyr::mutate(
    guild = as.character(guild)
  )

# plot ----
figure_4 <-
  plot_elev_trend(
    data_source = data_to_fit %>%
      dplyr::mutate(
        guild = as.character(guild)
      ),
    data_pred_interaction = data_pred_guilds_proportions,
    y_var = "n_occ_prop",
    y_var_name = "Proportion of species occurences",
    facet_by = ". ~ regions",
    color_by = "guild",
    shape_legend = c(
      "n_occ_generalistic_prop" = 23,
      "n_occ_herbivorous_trophobiotic_prop" = 24,
      "n_occ_predator_scavenger_prop" = 25
    ),
    color_legend = c(
      "n_occ_generalistic_prop" = "#00FF8C",
      "n_occ_herbivorous_trophobiotic_prop" = "#8C00FF",
      "n_occ_predator_scavenger_prop" = "darkorange"
    ),
    p_value = mod_guilds_proportions %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      tidyr::unnest(anova_to_null) %>%
      purrr::pluck("lr_pr_chisq", 1),
    legend_position = "top"
  )

save_figure(
  filename = "figure_4",
  dir = here::here("Outputs"),
  plot = figure_4,
  width = 168,
  height = 150
)
