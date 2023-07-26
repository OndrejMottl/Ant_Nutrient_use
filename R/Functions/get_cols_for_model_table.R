get_cols_for_model_table <- function(
    data_source,
    add_first_cols = NULL,
    add_last_cols = NULL) {
  data_source %>%
    dplyr::select(
      dplyr::any_of(
        c(
          add_first_cols,
          "mod_name", "mod_formula",
          "AICc", "delta",
          "model_df", "deviance", "d2",
          "residual_df",
          "lr_chisq", "chisq_df", "p_value_chisq", "lr_signif",
          add_last_cols,
          "best_model_candidate", "best_model"
        )
      )
    )
}