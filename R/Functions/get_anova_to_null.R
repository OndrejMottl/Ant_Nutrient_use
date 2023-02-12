get_anova_to_null <- function(data_source, null_model) {
  res <- NA_real_
  try(
    expr = {
      anova_res <-
        lmtest::lrtest(null_model, data_source) %>%
        as.data.frame() %>%
        tibble::as_tibble() %>%
        dplyr::slice(2) %>%
        dplyr::rename_with(
          .fn = ~ paste("LR_", .x)
        ) %>%
        janitor::clean_names()

      p_value_col_name <-
        stringr::str_subset(names(anova_res), "pr_chi")

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
