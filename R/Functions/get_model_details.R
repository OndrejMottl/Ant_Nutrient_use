get_model_details <- function(
    data_source,
    compare_aic = TRUE,
    test_overdispersion = FALSE,
    est_r2 = FALSE,
    min_delta_aic = 2) {
  if (
    isTRUE(est_r2)
  ) {
    data_work <-
      data_source %>%
      dplyr::mutate(
        r2 = purrr::map_dbl(
          .x = mod,
          .f = purrr::possibly(
            .f = ~ get_r2_possibly(.x),
            otherwise = NA_real_
          )
        )
      )
  } else {
    data_work <- data_source
  }

  if (
    isTRUE(test_overdispersion)
  ) {
    data_work <-
      data_work %>%
      dplyr::mutate(
        overdispersed = purrr::map_lgl(
          .x = mod,
          .f = ~ performance::check_overdispersion(.x) %>%
            purrr::pluck("p_value") < 0.05
        )
      )
  }

  data_anova <-
    data_work %>%
    dplyr::mutate(
      mod_anova = purrr::map(
        .x = mod,
        .f = purrr::possibly(
          .f = ~ get_anova(.x) %>%
            dplyr::mutate(
              signif = insight::format_p(
                p = pr_chisq,
                stars_only = TRUE
              )
            ),
          otherwise = NA_real_
        )
      )
    )

  data_partial <-
    data_anova %>%
    dplyr::mutate(
      mod_r2_partial = purrr::map(
        .x = mod,
        .f = purrr::possibly(
          .f = ~ get_r2_partial(.x),
          otherwise = NA_real_
        )
      )
    )

  mod_null <-
    data_partial %>%
    dplyr::filter(
      mod_name == "null"
    ) %>%
    purrr::pluck("mod", 1)

  data_deviance <-
    data_partial %>%
    dplyr::mutate(
      d2 = purrr::map_dbl(
        .x = mod,
        .f = purrr::possibly(
          .f = ~ get_d2(
            data_source = .x,
            null_model = mod_null
          ),
          otherwise = NA_real_
        )
      )
    )

  data_anova_to_null <-
    data_deviance %>%
    dplyr::mutate(
      anova_to_null = purrr::map(
        .x = mod,
        .f = purrr::possibly(
          .f = ~ get_anova_to_null(
            data_source = .x,
            null_model = mod_null
          ),
          otherwise = NA_real_
        )
      )
    )

  data_to_compare <-
    data_anova_to_null

  if (
    isTRUE(compare_aic)
  ) {
    # model comp
    suppressWarnings(
      mod_comp <-
        MuMIn::model.sel(
          data_to_compare$mod
        ) %>%
        as.data.frame() %>%
        tibble::rownames_to_column("mod_name") %>%
        tibble::as_tibble() %>%
        dplyr::relocate(mod_name) %>%
        dplyr::mutate(
          best_model_candidate = delta < min_delta_aic
        ) %>%
        dplyr::select(
          dplyr::any_of(
            c(
              "mod_name",
              "df",
              "AICc",
              "delta",
              "weight",
              "best_model_candidate"
            )
          )
        )
    )

    if (
      # several models have delta < min_delta_aic
      sum(mod_comp$best_model_candidate, na.rm = TRUE) > 1
    ) {
      RUtilpol::output_warning(
        msg = "Cannot select the best model just by AIC"
      )

      RUtilpol::output_comment(
        msg = "Here is the importance of individual terms in best models:"
      )

      data_all_best_model_candidates <-
        mod_comp %>%
        dplyr::filter(
          best_model_candidate == TRUE
        ) %>%
        dplyr::inner_join(
          data_to_compare,
          by = dplyr::join_by(mod_name)
        ) %>%
        dplyr::mutate(
          model_id = dplyr::row_number()
        ) %>%
        dplyr::relocate(model_id)

      RUtilpol::output_comment(
        msg = "General rule of thimb is to keep terms with > 0.6 importance"
      )

      # Therefoere, estimate the importance of predictors across models
      data_all_best_model_candidates %>%
        purrr::pluck("mod") %>%
        MuMIn::model.avg() %>%
        MuMIn::sw() %>%
        as.data.frame() %>%
        tibble::rownames_to_column("term") %>%
        tibble::as_tibble() %>%
        dplyr::rename(
          importance = "."
        ) %>%
        print()

      data_all_best_model_candidates %>%
        tidyr::unnest(anova_to_null) %>%
        dplyr::select(
          mod_name, AICc, delta, weight,
          r2, d2,
          aov_pr_chisq, aov_signif
        ) %>%
        print()

      data_all_best_model_candidates %>%
        dplyr::select(
          model_id, mod_name
        ) %>%
        print()

      # open custom menu to select model
      best_model_candidate_id <-
        utils::menu(
          choices = data_all_best_model_candidates$mod_name,
          title = "Please select model to KEEP:"
        )

      mod_with_best_model <-
        mod_comp %>%
        dplyr::left_join(
          data_all_best_model_candidates %>%
            dplyr::filter(
              model_id == best_model_candidate_id
            ) %>%
            dplyr::select(mod_name) %>%
            dplyr::mutate(best_model = TRUE),
          by = dplyr::join_by(mod_name)
        ) %>%
        dplyr::mutate(
          best_model = ifelse(is.na(best_model), FALSE, best_model)
        )
    } else {
      mod_with_best_model <-
        mod_comp %>%
        dplyr::mutate(
          best_model = best_model_candidate
        )
    }

    res <-
      dplyr::inner_join(
        data_to_compare,
        mod_with_best_model,
        by = dplyr::join_by(mod_name)
      ) %>%
      dplyr::relocate(
        dplyr::all_of(
          names(mod_comp)
        )
      )
  } else {
    res <-
      data_anova_to_null[nrow(data_anova_to_null), ]
  }

  return(res)
}
