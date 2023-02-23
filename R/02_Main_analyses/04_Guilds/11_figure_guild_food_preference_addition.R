#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#           Figure guild food preferences addition
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
mod_guild_models <-
  RUtilpol::get_latest_file(
    file_name = "data_guild_models_addtion",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

data_to_fit <-
  RUtilpol::get_latest_file(
    file_name = "data_guild_models_addtion",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("data_to_fit")

dummy_predict_table_interaction <-
  data_to_fit %>%
  dplyr::select(seasons, n_occ_generalistic_prop) %>%
  modelbased::visualisation_matrix(
    at = c("seasons", "n_occ_generalistic_prop"),
    length = 100,
    preserve_range = TRUE
  ) %>%
  tidyr::as_tibble()

figure_ecuador_nacl_g <-
  get_predicted_data(
    mod = mod_guild_models %>%
      dplyr::filter(regions == "ecuador" & sel_bait_type == "nacl") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_interaction
  ) %>%
  ggplot2::ggplot(
    ggplot2::aes(x = n_occ_generalistic_prop, y = fit, col = seasons)
  ) +
  ggplot2::geom_line() +
  ggplot2::geom_point(
    data = data_to_fit %>%
      dplyr::filter(regions == "ecuador" & bait_type == "nacl"),
    ggplot2::aes(
      y = rel_occurences
    )
  ) +
  ggplot2::labs(
    x = "Proportion of generalists",
    y = "Relative Nutrient use NaCl",
    title = "Ecuador"
  ) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(hjust = 0.5, vjust = 0, size = 10)
  )

figure_png_nacl_g <-
  get_predicted_data(
    mod = mod_guild_models %>%
      dplyr::filter(regions == "png" & sel_bait_type == "nacl") %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_interaction
  ) %>%
  ggplot2::ggplot(
    ggplot2::aes(x = n_occ_generalistic_prop, y = fit, col = seasons)
  ) +
  ggplot2::geom_line() +
  ggplot2::geom_point(
    data = data_to_fit %>%
      dplyr::filter(regions == "png" & bait_type == "nacl"),
    ggplot2::aes(
      y = rel_occurences
    )
  ) +
  ggplot2::labs(
    x = "Proportion of generalists",
    y = "Relative Nutrient use NaCl",
    title = "Papua New Guinea"
  ) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(hjust = 0.5, vjust = 0, size = 10)
  )

ggpubr::ggarrange(
  figure_ecuador_nacl_g + ggpubr::rremove("xylab"),
  figure_png_nacl_g + ggpubr::rremove("xylab"),
  ncol = 2,
  common.legend = TRUE,
  legend = "right"
) %>%
  ggpubr::annotate_figure(
    left = ggpubr::text_grob(
      "Relative nutrient use - NaCl",
      family = "sans",
      size = 12,
      rot = 90
    ),
    bottom = ggpubr::text_grob(
      "Proportion of generalists",
      family = "sans",
      size = 12
    )
  ) %>%
  save_figure(
    filename = "suppl_figure_guild_addtion",
    dir = here::here("Outputs"),
    width = 168,
    height = 100
  )
