fit_guild_models <-
  function(data_source,
           sel_nutrient,
           max_nutrient,
           sel_mod = c(
             "betabinomial_aod",
             "betabinomial_glmmTMB",
             "quasibinomial_aod",
             "quasibinomial_glmmTMB"
           ),
           test_overdispersion = FALSE) {
    sel_mod <- match.arg(sel_mod)

    switch(sel_mod,
      "betabinomial_aod" = {
        mod_null <-
          aods3::aodml(
            formula = as.formula(
              paste0(
                "cbind(", sel_nutrient, " , ",
                max_nutrient, " - ", sel_nutrient, ")  ~ 1"
              )
            ),
            phi.formula = ~1,
            link = "logit",
            family = "bb",
            method = "Nelder-Mead",
            control = list(maxit = 500, trace = 0),
            data = data_source
          )
      },
      "betabinomial_glmmTMB" = {
        mod_null <-
          glmmTMB::glmmTMB(
            formula = as.formula(
              paste0(
                "cbind(", sel_nutrient, " , ",
                max_nutrient, " - ", sel_nutrient, ")  ~ 1"
              )
            ),
            family = glmmTMB::betabinomial(link = "logit"),
            data = data_source
          )
      },
      "quasibinomial_aod" = {
        mod_null <-
          aods3::aodql(
            formula = as.formula(
              paste0(
                "cbind(", sel_nutrient, " , ",
                max_nutrient, " - ", sel_nutrient, ")  ~ 1"
              )
            ),
            phi.formula = ~1,
            link = "logit",
            family = "qbin",
            method = "chisq",
            method = "Nelder-Mead",
            control = list(maxit = 500, trace = 0),
            data = data_source
          )
      },
      "quasibinomial_glmmTMB" = {
        mod_null <-
          glmmTMB::glmmTMB(
            formula = as.formula(
              paste0(
                "cbind(", sel_nutrient, " , ",
                max_nutrient, " - ", sel_nutrient, ")  ~ 1"
              )
            ),
            family = stats::quasibinomial(link = "logit"),
            data = data_source
          )
      }
    )

    suppressWarnings({
      mod_g <-
        stats::update(mod_null, . ~ G_prop)

      mod_ht <-
        stats::update(mod_null, . ~ HT_prop)

      mod_ps <-
        stats::update(mod_null, . ~ PS_prop)
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
        test_overdispersion = test_overdispersion
      )

    res <-
      mod_details %>%
      dplyr::mutate(
        anova_res = purrr::map(
          .x = mod,
          .f = purrr::possibly(
            .f = ~ stats::anova(mod_details$mod[[1]], .x) %>%
              as.data.frame() %>%
              tibble::as_tibble() %>%
              dplyr::slice(2) %>%
              dplyr::rename_with(
                .fn = ~ paste("aov_", .x)
              ) %>%
              janitor::clean_names()
          )
        )
      ) %>%
      tidyr::unnest(anova_res)


    return(res)
  }
