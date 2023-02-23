fit_guild_addtion <-
  function(data_source,
           sel_var = "n_occ_prop",
           sel_family = glmmTMB::betabinomial(link = "logit"),
           mod_null,
           ...) {
    suppressWarnings({
      mod_g <-
        stats::update(mod_null, . ~  . * n_occ_generalistic_prop)

      mod_ht <-
        stats::update(mod_null, . ~ . * n_occ_herbivorous_trophobiotic_prop)

      mod_ps <-
        stats::update(mod_null, . ~ . * n_occ_predator_scavenger_prop)
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

    res <-
      get_model_details(
        data_source = mod_table,
        compare_aic = TRUE,
        test_overdispersion = FALSE
      )

    return(res)
  }
