get_anova_to_null <- function(data_source, null_model) {
  data_source %>%
    dplyr::mutate(
      anova_to_null = purrr::map(
        .x = mod,
        .f = purrr::possibly(
          .f = ~ {
            anova_res <-
              anova(null_model, .x) %>%
              as.data.frame() %>%
              tibble::as_tibble() %>%
              dplyr::slice(2) %>%
              dplyr::rename_with(
                .fn = ~ paste("aov_", .x)
              ) %>%
              janitor::clean_names()

            p_value_col_name <-
              stringr::str_subset(names(anova_res), "pr_chi")

            anova_res %>%
              dplyr::mutate(
                aov_signif = insight::format_p(
                  p = get(p_value_col_name),
                  stars_only = TRUE
                )
              ) %>%
              return()
          },
          otherwise = NA_real_
        )
      )
    ) %>%
    return()
}
