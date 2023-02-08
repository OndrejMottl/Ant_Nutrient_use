get_anova_to_null <- function(data_source, null_model) {
  data_source %>%
    dplyr::mutate(
      anova_to_null = purrr::map(
        .x = mod,
        .f = purrr::possibly(
          .f = ~ stats::anova(null_model, .x) %>%
            as.data.frame() %>%
            tibble::as_tibble() %>%
            dplyr::slice(2) %>%
            dplyr::rename_with(
              .fn = ~ paste("aov_", .x)
            ) %>%
            janitor::clean_names() %>%
            dplyr::mutate(
              aov_signif = insight::format_p(
                p = aov_pr_chisq,
                stars_only = TRUE
              )
            ),
          otherwise = NA_real_
        )
      )
    ) %>%
    return()
}
