print_model_summary <- function(data_source) {
  RUtilpol::output_comment("model fit:")
  data_source %>%
    dplyr::select(
     dplyr::any_of(
      c(
         "mod_name", "AICc", "delta", "r2", "d2", "best_model", 
         "best_model_candidate"
      )
     )
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
    purrr::pluck("test_to_null") %>%
    print()
}
