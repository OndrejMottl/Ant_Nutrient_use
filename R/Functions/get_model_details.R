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
          data_source$mod,
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
    )

    if (
      sum(mod_comp$best_model, na.rm = TRUE) > 1
    ) {
      message(
        paste("WARNING: Cannot select the best model just by AICc")
      )
    }

    table_best_model <-
      data_source %>%
      dplyr::inner_join(
        mod_comp,
        by = dplyr::join_by(mod_name)
      ) %>%
      dplyr::arrange(-weight)
  } else {
    table_best_model <-
      data_source %>%
      dplyr::filter(
        mod_name == "poly_full"
      )
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
          .f = ~ get_anova(.x),
          otherwise = NA_real_
        )
      ),
      mod_r2_partial = purrr::map(
        .x = mod,
        .f = purrr::possibly(
          .f = ~ get_r2_partial(.x),
          otherwise = NA_real_
        )
      ),
      model_details = purrr::map2(
        .x = mod_anova,
        .y = mod_r2_partial,
        .f = purrr::possibly(
          .f = ~ dplyr::full_join(
            .x, .y,
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
