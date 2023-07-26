fit_food_elev_region_season <-
  function(data_source,
           sel_var = "cbind(total_occurrence, max occurrence - total_occurrence)",
           sel_var_random = NULL,
           sel_family = glmmTMB::betabinomial(link = "logit"),
           ...) {
    # singl pred
    mod_null <-
      glmmTMB::glmmTMB(
        formula = as.formula(paste(sel_var, "~ 1")),
        family = sel_family,
        data = data_source,
        ziformula = ~0,
        na.action = "na.fail",
        ...
      )
    mod_food <-
      stats::update(mod_null, . ~ bait_type)
    mod_elev <-
      stats::update(mod_null, . ~ poly(elevation_mean, 2))
    mod_region <-
      stats::update(mod_null, . ~ regions)
    mod_season <-
      stats::update(mod_null, . ~ seasons)

    # two predictors
    # bait type + elevation"
    mod_food_elev <-
      stats::update(mod_food, . ~ . + poly(elevation_mean, 2))
    # bait type * elevation"
    mod_food_elev_int <-
      stats::update(mod_food, . ~ . * poly(elevation_mean, 2))
    # bait type + region"
    mod_food_region <-
      stats::update(mod_food, . ~ . + regions)
    # bait type * region"
    mod_food_region_int <-
      stats::update(mod_food, . ~ . * regions)
    # bait type + season"
    mod_food_season <-
      stats::update(mod_food, . ~ . + seasons)
    # bait type * season"
    mod_food_season_int <-
      stats::update(mod_food, . ~ . * seasons)
    # elevation + region"
    mod_elev_region <-
      stats::update(mod_elev, . ~ . + regions)
    # elevation * region"
    mod_elev_region_int <-
      stats::update(mod_elev, . ~ . * regions)
    # elevation + season"
    mod_elev_season <-
      stats::update(mod_elev, . ~ . + seasons)
    # elevation * season"
    mod_elev_season_int <-
      stats::update(mod_elev, . ~ . * seasons)
    # region + season"
    mod_region_season <-
      stats::update(mod_region, . ~ . + seasons)
    # region * season"
    mod_region_season_int <-
      stats::update(mod_region, . ~ . * seasons)

    # three predictors
    # bait type + elevation + region",
    mod_food_elev_region <-
      stats::update(mod_food_elev, . ~ . + regions)
    # bait type * elevation + region",
    mod_food_elev_int_region <-
      stats::update(mod_food_elev_int, . ~ . + regions)
    # bait type + elevation * region",
    mod_food_elev_region_int <-
      stats::update(mod_food_elev, . ~ . * regions)
    # bait type * elevation * region",
    mod_food_elev_int_region_int <-
      stats::update(mod_food_elev_int, . ~ . * regions)
    # bait type + elevation + season",
    mod_food_elev_season <-
      stats::update(mod_food_elev, . ~ . + seasons)
    # bait type * elevation + season",
    mod_food_elev_int_season <-
      stats::update(mod_food_elev_int, . ~ . + seasons)
    # bait type + elevation * season",
    mod_food_elev_season_int <-
      stats::update(mod_food_elev, . ~ . * seasons)
    # bait type * elevation * season",
    mod_food_elev_int_season_int <-
      stats::update(mod_food_elev_int, . ~ . * seasons)
    # elevation + region + season",
    mod_elev_region_seasons <-
      stats::update(mod_elev_region, . ~ . + seasons)
    # elevation * region + season",
    mod_elev_region_int_seasons <-
      stats::update(mod_elev_region_int, . ~ . + seasons)
    # elevation + region * season",
    mod_elev_region_seasons_int <-
      stats::update(mod_elev_region, . ~ . * seasons)
    # elevation * region * season",
    mod_elev_region_int_seasons_int <-
      stats::update(mod_elev_region_int, . ~ . * seasons)
    # bait type + region + season",
    mod_food_region_season <-
      stats::update(mod_food_region, . ~ . + seasons)
    # bait type * region + season",
    mod_food_region_int_season <-
      stats::update(mod_food_region_int, . ~ . + seasons)
    # bait type + region * season",
    mod_food_region_season_int <-
      stats::update(mod_food_region, . ~ . * seasons)
    # bait type * region * season",
    mod_food_region_int_season_int <-
      stats::update(mod_food_region_int, . ~ . * seasons)

    # four predictors
    # bait type + elevation + region + season"
    mod_food_elev_region_season <-
      stats::update(mod_food_elev_region, . ~ . + seasons)
    # bait type * elevation + region + season"
    mod_food_elev_int_region_season <-
      stats::update(mod_food_elev_int_region, . ~ . + seasons)
    # bait type + elevation * region + season"
    mod_food_elev_region_int_season <-
      stats::update(mod_food_elev_region_int, . ~ . + seasons)
    # bait type + elevation + region * season"
    mod_food_elev_region_season_it <-
      stats::update(mod_food_elev_region, . ~ . * seasons)
    # bait type * elevation * region + season"
    mod_food_elev_int_region_int_season <-
      stats::update(mod_food_elev_int_region_int, . ~ . + seasons)
    # bait type * elevation + region * season"
    mod_food_elev_int_region_season_int <-
      stats::update(mod_food_elev_int_region, . ~ . * seasons)
    # bait type + elevation * region * season"
    mod_food_elev_region_int_season_int <-
      stats::update(mod_food_elev_region_int, . ~ . * seasons)
    # bait type * elevation * region * season"
    mod_food_elev_int_region_int_season_int <-
      stats::update(mod_food_elev_int_region_int, . ~ . * seasons)

    mod_table <-
      tibble::tibble(
        mod_name = c(
          # single
          "null",
          "bait type",
          "elevation",
          "region",
          "season",
          # two
          "bait type + elevation",
          "bait type * elevation",
          "bait type + region",
          "bait type * region",
          "bait type + season",
          "bait type * season",
          "elevation + region",
          "elevation * region",
          "elevation + season",
          "elevation * season",
          "region + season",
          "region * season",
          # three
          "bait type + elevation + region",
          "bait type * elevation + region",
          "bait type + elevation * region",
          "bait type * elevation * region",
          "bait type + elevation + season",
          "bait type * elevation + season",
          "bait type + elevation * season",
          "bait type * elevation * season",
          "elevation + region + season",
          "elevation * region + season",
          "elevation + region * season",
          "elevation * region * season",
          "bait type + region + season",
          "bait type * region + season",
          "bait type + region * season",
          "bait type * region * season",
          # four
          "bait type + elevation + region + season",
          "bait type * elevation + region + season",
          "bait type + elevation * region + season",
          "bait type + elevation + region * season",
          "bait type * elevation * region + season",
          "bait type * elevation + region * season",
          "bait type + elevation * region * season",
          "bait type * elevation * region * season"
        )
      ) %>%
      dplyr::mutate(
        mod = list(
          # single
          mod_null,
          mod_food,
          mod_elev,
          mod_region,
          mod_season,
          # two
          mod_food_elev,
          mod_food_elev_int,
          mod_food_region,
          mod_food_region_int,
          mod_food_season,
          mod_food_season_int,
          mod_elev_region,
          mod_elev_region_int,
          mod_elev_season,
          mod_elev_season_int,
          mod_region_season,
          mod_region_season_int,
          # three
          mod_food_elev_region,
          mod_food_elev_int_region,
          mod_food_elev_region_int,
          mod_food_elev_int_region_int,
          mod_food_elev_season,
          mod_food_elev_int_season,
          mod_food_elev_season_int,
          mod_food_elev_int_season_int,
          mod_elev_region_seasons,
          mod_elev_region_int_seasons,
          mod_elev_region_seasons_int,
          mod_elev_region_int_seasons_int,
          mod_food_region_season,
          mod_food_region_int_season,
          mod_food_region_season_int,
          mod_food_region_int_season_int,
          # four
          mod_food_elev_region_season,
          mod_food_elev_int_region_season,
          mod_food_elev_region_int_season,
          mod_food_elev_region_season_it,
          mod_food_elev_int_region_int_season,
          mod_food_elev_int_region_season_int,
          mod_food_elev_region_int_season_int,
          mod_food_elev_int_region_int_season_int
        ) %>%
          rlang::set_names(
            nm = mod_name
          )
      )

    if (
      isFALSE(is.null(sel_var_random))
    ) {
      random_formula <-
        paste(
          ". ~ . + (1 |", sel_var_random, ")"
        ) %>%
        as.formula()

      mod_table <-
        mod_table %>%
        dplyr::mutate(
          mod = purrr::map(
            .progress = TRUE,
            .x = mod,
            .f = purrr::possibly(
              ~ stats::update(.x, random_formula)
            )
          )
        )
    }

    res <-
      get_model_details(
        data_source = mod_table,
        compare_aic = TRUE,
        test_overdispersion = FALSE
      )

    return(res)
  }
