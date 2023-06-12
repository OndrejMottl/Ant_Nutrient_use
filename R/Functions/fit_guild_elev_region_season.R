fit_guild_elev_region_season <-
  function(data_source,
           sel_var = "n_occ_prop",
           elev_poly = 1,
           sel_family = glmmTMB::ordbeta(link = "logit"),
           compare_aic = TRUE) {
    # singl pred
    mod_null <-
      glmmTMB::glmmTMB(
        formula = as.formula(paste(sel_var, "~ 1")),
        family = sel_family,
        data = data_source,
        ziformula = ~0,
        na.action = "na.fail"
      )

    # single pred
    mod_elev <-
      stats::update(mod_null, . ~ poly(elevation_mean, elev_poly))
    mod_region <-
      stats::update(mod_null, . ~ regions)
    mod_season <-
      stats::update(mod_null, . ~ seasons)

    # two predictors
    mod_elev_region <-
      stats::update(mod_elev, . ~ . + regions)
    mod_elev_region_int <-
      stats::update(mod_elev, . ~ . * regions)
    mod_elev_season <-
      stats::update(mod_elev, . ~ . + seasons)
    mod_elev_season_int <-
      stats::update(mod_elev, . ~ . * seasons)

    mod_region_season <-
      stats::update(mod_region, . ~ . + seasons)
    mod_region_season_int <-
      stats::update(mod_region, . ~ . * seasons)

    # three predictors
    mod_elev_region_seasons <-
      stats::update(mod_elev_region, . ~ . + seasons)
    mod_elev_region_seasons_int <-
      stats::update(mod_elev_region, . ~ . * seasons)
    mod_elev_region_int_seasons <-
      stats::update(mod_elev_region_int, . ~ . + seasons)
    mod_elev_region_int_seasons_int <-
      stats::update(mod_elev_region_int, . ~ . * seasons)

    mod_table <-
      tibble::tibble(
        mod_name = c(
          "null",
          "elevation",
          "region",
          "season",
          "elevation + region",
          "elevation * region",
          "elevation + season",
          "elevation * season",
          "region + season",
          "region * season",
          "elevation + region + season",
          "elevation + region * season",
          "elevation * region + season",
          "elevation * region * season"
        )
      ) %>%
      dplyr::mutate(
        mod = list(
          mod_null,
          mod_elev,
          mod_region,
          mod_season,
          mod_elev_region,
          mod_elev_region_int,
          mod_elev_season,
          mod_elev_season_int,
          mod_region_season,
          mod_region_season_int,
          mod_elev_region_seasons,
          mod_elev_region_seasons_int,
          mod_elev_region_int_seasons,
          mod_elev_region_int_seasons_int
        ) %>%
          rlang::set_names(
            nm = mod_name
          )
      )

    res <-
      get_model_details(
        data_source = mod_table,
        compare_aic = compare_aic,
        test_overdispersion = FALSE
      )


    return(res)
  }
