get_table_models <- function(data_source, ...) {
  data_source %>%
    dplyr::mutate(
      mod_formula = purrr::map_chr(
        .x = mod,
        .f = ~ insight::find_formula(.x) %>%
          as.character()
      )
    ) %>%
    tidyr::unnest(test_to_null) %>%
    get_cols_for_model_table(., ...) %>%
    round_all_numbers()
}
