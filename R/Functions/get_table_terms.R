get_table_terms <- function(
    data_source,
    add_first_cols = NULL,
    add_last_cols = NULL) {
  data_source %>%
    dplyr::filter(best_model == TRUE) %>%
    dplyr::select(
      dplyr::any_of(
        c(
          add_first_cols,
          "mod",
          add_last_cols
        )
      )
    ) %>%
    dplyr::mutate(
      terms = purrr::map(
        .x = mod,
        .f = ~ parameters::model_parameters(.x) %>%
          as.data.frame() %>%
          janitor::clean_names() %>%
          dplyr::filter(component == "conditional") %>%
          dplyr::select(
            dplyr::any_of(
              c(
                "parameter",
                "coefficient",
                "se",
                "ci_low",
                "ci_high"
              )
            )
          )
      )
    ) %>%
    tidyr::unnest(terms) %>%
    dplyr::select(
      dplyr::any_of(
        c(
          add_first_cols,
          "parameter",
          "coefficient",
          "se",
          "ci_low",
          "ci_high",
          add_last_cols
        )
      )
    ) %>%
    round_all_numbers() %>%
    return()
}
