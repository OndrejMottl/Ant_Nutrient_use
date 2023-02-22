plot_food_pref <- function(
  data_source,
    sel_region,
    sel_bait_type,
    sel_mod_name,
    sel_mod,
    sel_p_value,
    ...) {
  message(
    paste(sel_region, sel_bait_type, sep = " - ")
  )

  data_to_plot <-
    data_source %>%
    dplyr::filter(regions == sel_region) %>%
    dplyr::filter(bait_type == sel_bait_type)

  data_pred_trend <- NULL
  data_pred_season <- NULL
  data_pred_interaction <- NULL

  switch(sel_mod_name,
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
          mod = sel_mod,
          dummy_table = dummy_predict_table_elev
        )
    },
    "elevation-poly" = {
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
          mod = sel_mod,
          dummy_table = dummy_predict_table_elev
        )
    },
    "season" = {
      dummy_predict_table_seasons <-
        data_to_plot %>%
        dplyr::select(seasons) %>%
        modelbased::visualisation_matrix(
          at = c("seasons"),
          length = 100,
          preserve_range = TRUE
        ) %>%
        tidyr::as_tibble()

      data_pred_season <-
        get_predicted_data(
          mod = sel_mod,
          dummy_table = dummy_predict_table_seasons
        )
    },
    "elevation + season" = {
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
          mod = sel_mod,
          dummy_table = dummy_predict_table_interaction
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
          mod = sel_mod,
          dummy_table = dummy_predict_table_interaction
        )
    },
    "elevation-poly + season" = {
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
          mod = sel_mod,
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
      p_value = sel_p_value,
      y_lim = c(0, 1),
      x_breaks = seq(0, 3e3, 500),
      ...
    )

  return(res_plot)
}
