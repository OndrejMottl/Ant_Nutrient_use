#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Figure 1
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
mod_richness <-
  RUtilpol::get_latest_file(
    file_name = "mod_richness",
    dir = here::here("Data/Processed/Models/")
  )

mod_occurences <-
  RUtilpol::get_latest_file(
    file_name = "mod_occurences",
    dir = here::here("Data/Processed/Models/")
  )

data_to_fit <-
  mod_richness %>%
  purrr::pluck("data_to_fit")

# dummy tables ----
# dummy tables to predict upon
dummy_predict_table_elev <-
  data_to_fit %>%
  dplyr::select(elevation_mean, regions) %>%
  modelbased::visualisation_matrix(
    at = c("elevation_mean", "regions"),
    length = 100,
    preserve_range = TRUE
  ) %>%
  tidyr::as_tibble()

dummy_predict_table_interaction <-
  data_to_fit %>%
  dplyr::select(elevation_mean, regions, seasons) %>%
  modelbased::visualisation_matrix(
    at = c("elevation_mean", "regions", "seasons"),
    length = 100,
    preserve_range = TRUE
  ) %>%
  tidyr::as_tibble()

# predict -----
# richness
mod_richness %>%
  purrr::pluck("models") %>%
  dplyr::filter(best_model == TRUE) %>%
  purrr::pluck("mod_name", 1)

data_pred_richness_interaction <-
  get_predicted_data(
    mod = mod_richness %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_interaction
  )

# occurences
mod_occurences %>%
  purrr::pluck("models") %>%
  dplyr::filter(best_model == TRUE) %>%
  purrr::pluck("mod_name", 1)

data_pred_occurences_interaction <-
  get_predicted_data(
    mod = mod_occurences %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_interaction
  )

# plot the figure -----

figure_1a <-
  plot_elev_trend(
    data_source = data_to_fit,
    data_pred_interaction = data_pred_richness_interaction,
    y_var = "n_species",
    y_var_name = "Species richness",
    x_breaks = seq(0, 4e3, 1e3),
    x_lim = c(0, 4e3),
    facet_by = "~ regions",
    x_line = c(1000, 3000),
    p_value = mod_richness %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      tidyr::unnest(anova_to_null) %>%
      purrr::pluck(stringr::str_subset(names(.), "pr_chi"), 1),
    legend_position = "top"
  )

figure_1b <-
  plot_elev_trend(
    data_source = data_to_fit,
    data_pred_interaction = data_pred_occurences_interaction,
    y_var = "n_occurecnes",
    y_var_name = "Species occurences",
    x_breaks = seq(0, 4e3, 1e3),
    x_lim = c(0, 4e3),
    facet_by = "~ regions",
    x_line = c(1000, 3000),
    p_value = mod_occurences %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      tidyr::unnest(anova_to_null) %>%
      purrr::pluck(stringr::str_subset(names(.), "pr_chi"), 1),
    legend_position = "top"
  )

figure_1_legend <-
  cowplot::get_legend(figure_1b)

figure_1 <-
  ggpubr::ggarrange(
    figure_1_legend,
    figure_1a + ggpubr::rremove("legend"),
    figure_1b + ggpubr::rremove("legend"),
    nrow = 3,
    heights = c(0.1, 1, 1),
    align = "hv",
    labels = c("", "(a)", "(b)")
  )

# save ----
save_figure(
  filename = "figure_1",
  dir = here::here("Outputs"),
  plot = figure_1,
  width = 168,
  height = 150
)
