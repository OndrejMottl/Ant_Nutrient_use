get_model_details <- function(
    data_source,
    compare_aic = FALSE,
    test_overdispersion = TRUE) {
  if (
    isTRUE(compare_aic)
  ) {
    # model comp
    suppressWarnings(
      mod_comp <-
        MuMIn::model.sel(
          data_source$mod
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
    )

    if (
      # several models have delta < 2
      sum(mod_comp$best_model, na.rm = TRUE) > 1
    ) {
      RUtilpol::output_warning(
        msg = "Cannot select the best model just by AIC"
      )

      RUtilpol::output_comment(
        msg = "Here is the importance of individual terms in best models:"
      )

      data_all_best_models <-
        mod_comp %>%
        dplyr::filter(
          best_model == TRUE
        ) %>%
        dplyr::inner_join(
          data_source,
          by = dplyr::join_by(mod_name)
        ) %>%
        dplyr::mutate(
          model_id = dplyr::row_number()
        ) %>%
        dplyr::relocate(model_id)

      RUtilpol::output_comment(
        msg = "General rule of thimb is to keep terms with > 70 importance"
      )

      # Therefoere, estimate the importance of predictors across models
      data_all_best_models %>%
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

      data_all_best_models %>%
        dplyr::select(-mod) %>%
        print()

      # open custom menu to select model
      best_model_id <-
        utils::menu(
          choices = data_all_best_models$model_id,
          title = "Please select model to KEEP:"
        )

      mod_comp <-
        mod_comp %>%
        dplyr::select(-best_model) %>%
        dplyr::left_join(
          data_all_best_models %>%
            dplyr::filter(
              model_id == best_model_id
            ) %>%
            dplyr::select(mod_name, best_model),
          by = dplyr::join_by(mod_name)
        ) %>%
        dplyr::mutate(
          best_model = ifelse(is.na(best_model), FALSE, best_model)
        )
    }

    table_best_model <-
      data_source %>%
      dplyr::inner_join(
        mod_comp,
        by = dplyr::join_by(mod_name)
      )
  } else {
    table_best_model <-
      data_source[nrow(data_source), ]
  }

  table_best_model_r2 <-
    table_best_model %>%
    dplyr::mutate(
      r2 = purrr::map_dbl(
        .x = mod,
        .f = ~ get_r2(.x)
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
      ),
      mod_r2_partial = purrr::map(
        .x = mod,
        .f = purrr::possibly(
          .f = ~ get_r2_partial(.x),
          otherwise = NA_real_
        )
      )
    )

  return(res)
}
