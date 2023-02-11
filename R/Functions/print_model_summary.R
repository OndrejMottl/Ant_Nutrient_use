print_model_summary <- function(data_source) {
  RUtilpol::output_comment("model fit:")
  data_source %>%
    dplyr::select(
      mod_name, AICc, delta, r2, d2, best_model
    ) %>%
    print(., n = 100)

  RUtilpol::output_comment("best model:")
  data_source %>%
    dplyr::filter(
      best_model == TRUE
    ) %>%
    purrr::pluck("mod_name") %>%
    print()

  RUtilpol::output_comment("parameters details:")
  data_source %>%
    dplyr::filter(
      best_model == TRUE
    ) %>%
    purrr::pluck("mod_anova") %>%
    print()

  RUtilpol::output_comment("check anova of best model to null:")
  data_source %>%
    dplyr::filter(
      best_model == TRUE
    ) %>%
    purrr::pluck("anova_to_null") %>%
    print()
}
