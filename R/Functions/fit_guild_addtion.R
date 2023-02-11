fit_guild_addtion <-
  function(data_source,
           sel_var = "n_occ_prop",
           sel_family = glmmTMB::betabinomial(link = "logit"),
           ...) {
    mod_null <-
      glmmTMB::glmmTMB(
        formula = as.formula(
          paste0(sel_var, "  ~ 1")
        ),
        family = sel_family,
        data = data_source,
        ziformula = ~0,
        ...
      )

    suppressWarnings({
      mod_g <-
        stats::update(mod_null, . ~ n_occ_generalistic_prop)

      mod_ht <-
        stats::update(mod_null, . ~ n_occ_herbivorous_trophobiotic)

      mod_ps <-
        stats::update(mod_null, . ~ n_occ_predator_scavenger)
    })

    mod_table <-
      tibble::tibble(
        mod_name = c(
          "null",
          "g",
          "ht",
          "ps"
        )
      ) %>%
      dplyr::mutate(
        mod = list(
          mod_null,
          mod_g,
          mod_ht,
          mod_ps
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

    mod_deviance <-
      get_d2(mod_details, mod_null)

    res <-
      get_anova_to_null(mod_deviance, mod_null)

    return(res)
  }
