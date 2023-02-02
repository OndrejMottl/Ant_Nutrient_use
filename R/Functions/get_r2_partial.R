get_r2_partial <- function(data_source) {
  effectsize::r2_semipartial(data_source) %>%
    as.data.frame() %>%
    tibble::as_tibble() %>%
    janitor::clean_names() %>%
    dplyr::rename(
      r2_ci = ci,
      r2_ci_low = ci_low,
      r2_ci_high = ci_high
    ) %>%
    return()
}
