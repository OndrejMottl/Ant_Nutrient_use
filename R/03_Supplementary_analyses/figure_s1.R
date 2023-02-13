#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Figure S1
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
mod_abundnace <-
  RUtilpol::get_latest_file(
    file_name = "mod_abundnace",
    dir = here::here("Data/Processed/Models/")
  )

data_to_fit <-
  mod_abundnace %>%
  purrr::pluck("data_to_fit")

# dummy tables ----
mod_abundnace %>%
  purrr::pluck("models") %>%
  dplyr::filter(best_model == TRUE) %>%
  purrr::pluck("mod_name", 1)

# dummy tables to predict upon
dummy_predict_table_trend <-
  data_to_fit %>%
  dplyr::select(elevation_mean, regions) %>%
  modelbased::visualisation_matrix(
    at = c("elevation_mean", "regions"),
    length = 100,
    preserve_range = TRUE
  ) %>%
  tidyr::as_tibble()

# predict -----
data_pred_abundance_trend <-
  get_predicted_data(
    mod = mod_abundnace %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_trend
  )

firure_s1 <-
  plot_elev_trend(
    data_source = data_to_fit,
    data_pred_trend = data_pred_abundance_trend,
    y_var = "n_abundance",
    y_var_name = "Ant worker abundance",
    x_breaks = seq(0, 4e3, 1e3),
    x_lim = c(0, 4e3),
    facet_by = "~ regions",
    facet_scales = "fixed",
    x_line = c(1000, 3000),
    p_value = mod_abundnace %>%
      purrr::pluck("models") %>%
      dplyr::filter(best_model == TRUE) %>%
      tidyr::unnest(anova_to_null) %>%
      purrr::pluck(stringr::str_subset(names(.), "pr_chi"), 1),
    y_trans = "log1p",
    y_breaks = c(0, 1, 10, 100, 500, 1500, 4000),
    legend_position = "top"
  )

# save ----
save_figure(
  filename = "figure_s1",
  dir = here::here("Outputs"),
  plot = firure_s1,
  width = 168,
  height = 100
)
