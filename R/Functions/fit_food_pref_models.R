fit_food_pref_models <-
  function(data_source) {
    mod_null <-
      glmmTMB::glmmTMB(
        formula = cbind(total_occurrence, ma_xoccurrence - total_occurrence) ~ 1,
        family = glmmTMB::betabinomial(link = "logit"),
        data = data_source,
        ziformula = ~0,
        na.action = "na.fail"
      )

    mod_food <-
      stats::update(mod_null, . ~ bait_type)

    mod_elev <-
      stats::update(mod_null, . ~ poly(mean_elevation, 2))

    mod_season <-
      stats::update(mod_null, . ~ seasons)

    mod_food_elev <-
      stats::update(mod_food, . ~ . + poly(mean_elevation, 2))

    mod_food_elev_int <-
      stats::update(mod_food, . ~ . * poly(mean_elevation, 2))

    mod_food_season <-
      stats::update(mod_food, . ~ . + seasons)

    mod_food_season_int <-
      stats::update(mod_food, . ~ . * seasons)

    mod_food_elev_season <-
      stats::update(mod_food_elev, . ~ . + seasons)

    mod_food_elev_season_int <-
      stats::update(mod_food_elev, . ~ . * seasons)

    mod_food_elev_int_season <-
      stats::update(mod_food_elev_int, . ~ . + seasons)

    mod_food_elev_int_season_int <-
      stats::update(mod_food_elev_int, . ~ . * seasons)

    mod_elev_season <-
      stats::update(mod_elev, . ~ . + seasons)

    mod_elev_season_int <-
      stats::update(mod_elev, . ~ . * seasons)

    mod_table <-
      tibble::tibble(
        mod_name = c(
          "null",
          "bait type",
          "elevation",
          "season",
          "elevation + season",
          "elevation * season",
          "bait type + elevation",
          "bait type * elevation",
          "bait type + season",
          "bait type * season",
          "bait type + elevation + season",
          "bait type * elevation + season",
          "bait type + elevation * season",
          "bait type * elevation * season"
        )
      ) %>%
      dplyr::mutate(
        mod = list(
          mod_null,
          mod_food,
          mod_elev,
          mod_season,
          mod_elev_season,
          mod_elev_season_int,
          mod_food_elev,
          mod_food_elev_int,
          mod_food_season,
          mod_food_season_int,
          mod_food_elev_season,
          mod_food_elev_int_season,
          mod_food_elev_season_int,
          mod_food_elev_int_season_int
        ) %>%
          rlang::set_names(
            nm = mod_name
          )
      )

    mod_details <-
      get_model_details(
        data_source = mod_table,
        compare_aic = TRUE,
        test_overdispersion = FALSE
      )

    res <-
      get_anova_to_null(mod_details, mod_null)

    return(res)
  }
