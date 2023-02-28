#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Figure 4
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

# load models ----
mod_guilds_proportions_occurences <-
  RUtilpol::get_latest_file(
    file_name = "mod_guilds_proportions_occurences",
    dir = here::here("Data/Processed/Models/")
  )

data_to_fit <-
  mod_guilds_proportions_occurences %>%
  purrr::pluck("data_to_fit")

# predict -----
# check the final model
mod_guilds_proportions_occurences %>%
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
    mod = mod_guilds_proportions_occurences %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_interaction
  ) %>%
  dplyr::mutate(
    guild = as.character(guild),
    guild = dplyr::case_when(
      guild == "n_occ_generalistic_prop" ~ "G",
      guild == "n_occ_herbivorous_trophobiotic_prop" ~ "HT",
      guild == "n_occ_predator_scavenger_prop" ~ "PS"
    ),
    regions = forcats::fct_recode(
      regions,
      "Papua New Guinea" = "png",
      "Ecuador" = "ecuador",
      "Tanzania" = "tanzania"
    )
  )

# plot ----
figure_guilds_proportions_occurences <-
  plot_elev_trend(
    data_source = data_to_fit %>%
      dplyr::mutate(
        guild = as.character(guild),
        guild = dplyr::case_when(
          guild == "n_occ_generalistic_prop" ~ "G",
          guild == "n_occ_herbivorous_trophobiotic_prop" ~ "HT",
          guild == "n_occ_predator_scavenger_prop" ~ "PS"
        ),
       regions = forcats::fct_recode(
         regions,
         "Papua New Guinea" = "png",
         "Ecuador" = "ecuador",
         "Tanzania" = "tanzania"
       )
      ),
    data_pred_interaction = data_pred_guilds_proportions,
    y_var = "n_occ_prop",
    y_var_name = "Proportion of species occurences",
    facet_by = ". ~ regions",
    color_by = "guild",
    shape_legend = c(
      "G" = 23,
      "HT" = 24,
      "PS" = 25
    ),
    color_legend = c(
      "G" = "#00FF8C",
      "HT" = "#8C00FF",
      "PS" = "darkorange"
    ),
    p_value = mod_guilds_proportions_occurences %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      tidyr::unnest(test_to_null) %>%
      purrr::pluck("p_value_chisq", 1),
    legend_position = "top",
    y_lim = c(0, 1)
  )

save_figure(
  filename = "figure_guilds_proportions_occurences",
  dir = here::here("Outputs"),
  plot = figure_guilds_proportions_occurences,
  width = 168,
  height = 100
)
