get_test_to_null <- function(data_source, null_model) {
  res <- NA_real_
  try(
    expr = {
      anova_res <-
        lmtest::lrtest(null_model, data_source) %>%
        as.data.frame() %>%
        tibble::as_tibble() %>%
        dplyr::slice(2) %>%
        janitor::clean_names() %>%
        dplyr::mutate(
          deviance = insight::get_deviance(data_source),
          residual_df = insight::get_df(data_source, type = "residual")
        ) %>%
        dplyr::select(
          model_df = number_df,
          log_lik,
          deviance,
          residual_df,
          lr_chisq = chisq,
          chisq_df = df,
          p_value_chisq = pr_chisq
        )

      p_value_col_name <-
        stringr::str_subset(names(anova_res), "p_value_chisq")

      res <-
        anova_res %>%
        dplyr::mutate(
          lr_signif = insight::format_p(
            p = get(p_value_col_name),
            stars_only = TRUE
          )
        )
    },
    silent = TRUE
  )
  return(res)
}
