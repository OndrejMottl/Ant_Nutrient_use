#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                     Figure abundance
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
  # we selected only one site as there needs to be a valid value.
  # However, the function `get_predicted_data()` is set to ignore random effects
  dplyr::mutate(
    et_pcode = data_to_fit$et_pcode %>%
      unique() %>%
      .[[1]]
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
  ) %>%
  dplyr::mutate(
    regions = forcats::fct_recode(
      regions,
      "Papua New Guinea" = "png",
      "Ecuador" = "ecuador",
      "Tanzania" = "tanzania"
    )
  )

figure_abundance <-
  plot_elev_trend(
    data_source = data_to_fit %>%
      dplyr::mutate(
        regions = forcats::fct_recode(
          regions,
          "Papua New Guinea" = "png",
          "Ecuador" = "ecuador",
          "Tanzania" = "tanzania"
        )
      ),
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
      tidyr::unnest(test_to_null) %>%
      purrr::pluck(stringr::str_subset(names(.), "p_value_chisq"), 1),
    y_trans = "log1p",
    y_breaks = c(0, 1, 10, 100, 500, 1500, 4000),
    legend_position = "top"
  )

# save ----
save_figure(
  filename = "figure_abundance",
  dir = here::here("Outputs"),
  plot = figure_abundance,
  width = 168,
  height = 100
)
