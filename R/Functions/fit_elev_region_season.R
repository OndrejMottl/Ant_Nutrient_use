fit_elev_region_season <-
  function(data_source,
           sel_var,
           sel_family = NULL,
           compare_aic = FALSE,
           sel_method = c("glmmTMB", "glm.nb"),
           test_overdispersion = FALSE,
           ...) {
    sel_method <- match.arg(sel_method)
    switch(sel_method,
      "glmmTMB" = {
        mod_null <-
          glmmTMB::glmmTMB(
            formula = as.formula(paste0(sel_var, " ~ 1")),
            family = sel_family,
            data = data_source,
            ziformula = ~0,
            na.action = "na.fail",
            ...
          )
      },
      "glm.nb" = {
        mod_null <-
          MASS::glm.nb(
            formula = as.formula(paste0(sel_var, " ~ 1")),
            link = "log",
            data = data_source,
            na.action = "na.fail",
            control = stats::glm.control(maxit = 100)
          )
      }
    )

    # single pred
    mod_elev <-
      stats::update(mod_null, . ~ poly(elevation_mean, 1))
    mod_elev_poly <-
      stats::update(mod_null, . ~ poly(elevation_mean, 2))
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

    mod_elev_poly_region <-
      stats::update(mod_elev_poly, . ~ . + regions)
    mod_elev_poly_region_int <-
      stats::update(mod_elev_poly, . ~ . * regions)
    mod_elev_poly_season <-
      stats::update(mod_elev_poly, . ~ . + seasons)
    mod_elev_poly_season_int <-
      stats::update(mod_elev_poly, . ~ . * seasons)

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

    mod_elev_poly_region_seasons <-
      stats::update(mod_elev_poly_region, . ~ . + seasons)
    mod_elev_poly_region_seasons_int <-
      stats::update(mod_elev_poly_region, . ~ . * seasons)
    mod_elev_poly_region_int_seasons <-
      stats::update(mod_elev_poly_region_int, . ~ . + seasons)
    mod_elev_poly_region_int_seasons_int <-
      stats::update(mod_elev_poly_region_int, . ~ . * seasons)

    mod_table <-
      tibble::tibble(
        mod_name = c(
          "null",
          "elevation",
          "elevation-poly",
          "region",
          "season",
          "elevation + region",
          "elevation * region",
          "elevation + season",
          "elevation * season",
          "elevation-poly + region",
          "elevation-poly * region",
          "elevation-poly + season",
          "elevation-poly * season",
          "region + season",
          "region * season",
          "elevation + region + season",
          "elevation + region * season",
          "elevation * region + season",
          "elevation * region * season",
          "elevation-poly + region + season",
          "elevation-poly + region * season",
          "elevation-poly * region + season",
          "elevation-poly * region * season"
        )
      ) %>%
      dplyr::mutate(
        mod = list(
          mod_null,
          mod_elev,
          mod_elev_poly,
          mod_region,
          mod_season,
          mod_elev_region,
          mod_elev_region_int,
          mod_elev_season,
          mod_elev_season_int,
          mod_elev_poly_region,
          mod_elev_poly_region_int,
          mod_elev_poly_season,
          mod_elev_poly_season_int,
          mod_region_season,
          mod_region_season_int,
          mod_elev_region_seasons,
          mod_elev_region_seasons_int,
          mod_elev_region_int_seasons,
          mod_elev_region_int_seasons_int,
          mod_elev_poly_region_seasons,
          mod_elev_poly_region_seasons_int,
          mod_elev_poly_region_int_seasons,
          mod_elev_poly_region_int_seasons_int
        ) %>%
          rlang::set_names(
            nm = mod_name
          )
      )

    res <-
      get_model_details(
        data_source = mod_table,
        compare_aic = compare_aic,
        test_overdispersion = test_overdispersion
      )

    return(res)
  }
