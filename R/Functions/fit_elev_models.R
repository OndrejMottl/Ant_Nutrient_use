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

    if (
      isTRUE(compare_aic)
    ) {
      # model comp
      mod_comp <-
        MuMIn::model.sel(
          mod_table$mod,
          rank = "AICc"
        ) %>%
        as.data.frame() %>%
        tibble::rownames_to_column("mod_name") %>%
        tibble::as_tibble() %>%
        dplyr::relocate(mod_name) %>%
        dplyr::mutate(
          best_model = delta < 2
        ) %>%
        dplyr::select(
          dplyr::any_of(
            c(
              "mod_name",
              "df",
              "AICc",
              "delta",
              "weight",
              "best_model"
            )
          )
        )

      if (
        sum(mod_comp$best_model) > 1
      ) {
        message(
          paste("Cannot select the best model just by AICc")
        )
      }

      table_best_model <-
        mod_table %>%
        dplyr::inner_join(
          mod_comp,
          by = dplyr::join_by(mod_name)
        ) %>%
        dplyr::arrange(-weight)
    } else {
      table_best_model <-
        mod_table %>%
        dplyr::filter(
          mod_name == "poly_full"
        )
    }

    table_best_model_r2 <-
      table_best_model %>%
      dplyr::mutate(
        r2 = purrr::map_dbl(
          .x = mod,
          .f = ~ performance::r2_nagelkerke(.x)
        )
      )

    if (
      isTRUE(test_overdispersion)
    ) {
      table_best_model_r2 <-
        table_best_model_r2 %>%
        dplyr::mutate(
          overdispersed = purrr::map_lgl(
            .x = mod,
            .f = ~ performance::check_overdispersion(.x) %>%
              purrr::pluck("p_value") < 0.05
          )
        )
    }

    res <-
      table_best_model_r2 %>%
      dplyr::mutate(
        model_details = purrr::map(
          .x = mod,
          .f = purrr::possibly(
            .f = ~ dplyr::full_join(
              get_anova(.x),
              get_r2_partial(.x),
              by = dplyr::join_by(term)
            ) %>%
              dplyr::mutate(
                signif = insight::format_p(
                  p = pr_chi,
                  stars_only = TRUE
                )
              ),
            otherwise = "NA_real"
          )
        )
      )

    return(res)
  }
