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

data_food_pref_individual_plot <-
  food_pref_models_individual %>%
  purrr::pluck("models") %>%
  dplyr::filter(best_model == TRUE) %>%
  tidyr::unnest(anova_to_null) %>%
  dplyr::mutate(
    indiv_plot = purrr::pmap(
      .l = list(
        regions, # ..1
        sel_bait_type, # ..2
        mod_name, # ..3
        mod, # ..4
        aov_pr_chisq # ..5
      ),
      .f = ~ {
        message(
          paste(..1, ..2, sep = " - ")
        )

        data_to_plot <-
          data_to_fit %>%
          dplyr::filter(regions == ..1) %>%
          dplyr::filter(bait_type == ..2)

        data_pred_trend <- NULL
        data_pred_season <- NULL
        data_pred_interaction <- NULL

        switch(..3,
          "elevation" = {
            dummy_predict_table_elev <-
              data_to_plot %>%
              dplyr::select(elevation_mean) %>%
              modelbased::visualisation_matrix(
                at = c("elevation_mean"),
                length = 100,
                preserve_range = TRUE
              ) %>%
              tidyr::as_tibble()

            data_pred_trend <-
              get_predicted_data(
                mod = ..4,
                dummy_table = dummy_predict_table_elev
              )
          },
          "season" = {
            data_pred_season <-
              get_predict_by_emmeans(
                sel_mod = ..4,
                sel_spec = ~seasons
              )
          },
          "elevation * season" = {
            dummy_predict_table_interaction <-
              data_to_plot %>%
              dplyr::select(elevation_mean, seasons) %>%
              modelbased::visualisation_matrix(
                at = c("elevation_mean", "seasons"),
                length = 100,
                preserve_range = TRUE
              ) %>%
              tidyr::as_tibble()
            data_pred_interaction <-
              get_predicted_data(
                mod = ..4,
                dummy_table = dummy_predict_table_interaction
              )
          }
        )

        res_plot <-
          plot_elev_trend(
            data_source = data_to_plot,
            y_var = "rel_occurences",
            y_var_name = "Relative nutrient use",
            data_pred_trend = data_pred_trend,
            data_pred_season = data_pred_season,
            data_pred_interaction = data_pred_interaction,
            p_value = ..5,
            y_lim = c(0, 1)
          ) +
          ggpubr::rremove("xylab")

        return(res_plot)
      }
    )
  )

figure_3 <-
  ggpubr::ggarrange(
    plotlist = data_food_pref_individual_plot$indiv_plot,
    ncol = 3,
    nrow = 6,
    common.legend = TRUE,
    legend = "right"
  ) %>%
  ggpubr::annotate_figure(
    left = ggpubr::text_grob(
      "Relative nutrient use",
      family = "arial",
      size = 12,
      rot = 90
    ),
    bottom = ggpubr::text_grob(
      "Elevation (m.a.s.l.)",
      family = "arial",
      size = 12
    )
  )

save_figure(
  filename = "figure_3",
  dir = here::here("Outputs"),
  plot = figure_3,
  width = 168,
  height = 250
)
