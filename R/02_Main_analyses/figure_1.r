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

data_pred_richness_trend <-
  get_predicted_data(
    mod = mod_richness %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_elev
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
    data_pred_trend = data_pred_richness_trend,
    y_var = "n_species",
    y_var_name = "Species richness",
    facet_by = "~ regions",
    x_line = c(1000, 3000),
    p_value = mod_richness %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      tidyr::unnest(anova_to_null) %>%
      purrr::pluck(stringr::str_subset(names(.), "pr_chi"), 1)
  )

figure_1b <-
  plot_elev_trend(
    data_source = data_to_fit,
    data_pred_interaction = data_pred_occurences_interaction,
    y_var = "n_occurecnes",
    y_var_name = "Species occurences",
    facet_by = "~ regions",
    x_line = c(1000, 3000),
    p_value = mod_occurences %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      tidyr::unnest(anova_to_null) %>%
      purrr::pluck(stringr::str_subset(names(.), "pr_chi"), 1)
  )

figure_1 <-
  figure_1a + figure_1b +
    patchwork::plot_layout(guides = "collect", ncol = 1) +
    patchwork::plot_annotation(
      tag_levels = "a",
      tag_prefix = "(",
      tag_suffix = ")"
    ) &
    ggplot2::theme(legend.position = "top")

# save ----
save_figure(
  filename = "figure_1",
  dir = here::here("Outputs"),
  plot = figure_1,
  width = 168,
  height = 150
)
