fit_elev_models_per_region <-
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
            na.action = "na.fail"
          )
      }
    )

    mod_elev <-
      stats::update(mod_null, . ~ poly(elevation_mean, 2))
    mod_season <-
      stats::update(mod_null, . ~ seasons)
    mod_elev_season <-
      stats::update(mod_elev, . ~ . + seasons)
    mod_elev_season_int <-
      stats::update(mod_elev, . ~ . * seasons)

    mod_table <-
      tibble::tibble(
        mod_name = c(
          "null",
          "elevation",
          "season",
          "elevation + season",
          "elevation * season"
        )
      ) %>%
      dplyr::mutate(
        mod = list(
          mod_null,
          mod_elev,
          mod_season,
          mod_elev_season,
          mod_elev_season_int
        ) %>%
          rlang::set_names(
            nm = mod_name
          )
      )

    mod_details <-
      get_model_details(
        data_source = mod_table,
        compare_aic = compare_aic,
        test_overdispersion = test_overdispersion
      )

    res <-
      get_anova_to_null(mod_details, mod_null)


    return(res)
  }
