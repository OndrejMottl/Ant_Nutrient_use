fit_elev_models <-
  function(data_source,
           sel_var,
           sel_family,
           sel_mod = c("glm", "nb_glm"),
           compare_aic = FALSE,
           sel_dev_test = "Chisq",
           test_overdispersion = FALSE) {
    sel_mod <- match.arg(sel_mod)

    switch(sel_mod,
      "glm" = {
        mod_null <-
          stats::glm(
            formula = as.formula(paste0(sel_var, " ~ 1")),
            family = sel_family,
            data = data_source,
            na.action = "na.fail"
          )
      },
      "nb_glm" = {
        mod_null <-
          MASS::glm.nb(
            formula = as.formula(paste0(sel_var, " ~ 1")),
            link = "log",
            data = data_source,
            na.action = "na.fail"
          )
      }
    )

    suppressWarnings({
      mod_ln <-
        stats::update(mod_null, . ~ poly(meanElevation, 1) * Regions)

      mod_poly <-
        stats::update(mod_null, . ~ poly(meanElevation, 2) * Regions)

      mod_ln_full <-
        stats::update(mod_ln, . ~ . * Seasons)

      mod_poly_full <-
        stats::update(mod_poly, . ~ . * Seasons)
    })

    mod_table <-
      tibble::tibble(
        mod_name = c(
          "null",
          "linear",
          "poly",
          "linerar_full",
          "poly_full"
        )
      ) %>%
      dplyr::mutate(
        mod = list(
          mod_null,
          mod_ln,
          mod_poly,
          mod_ln_full,
          mod_poly_full
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
