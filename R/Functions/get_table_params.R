get_table_params <- function(
    data_source,
    add_first_cols = NULL,
    add_last_cols = NULL) {
  data_source %>%
    dplyr::filter(best_model == TRUE) %>%
    dplyr::select(
      dplyr::any_of(
        c(
          add_first_cols,
          "mod_anova",
          add_last_cols
        )
      )
    ) %>%
    tidyr::unnest(mod_anova) %>%
    dplyr::select(
      dplyr::any_of(
        c(
          add_first_cols,
          "term",
          "chisq",
          "df",
          "pr_chisq",
          "signif",
          add_last_cols
        )
      )
    ) %>%
    round_all_numbers() %>%
    return()
}
