get_predicted_by_marginaleffects <- function(
    mod,
    dummy_table) {
  marginaleffects::predictions(
    model = mod,
    newdata = dummy_table
  ) %>%
    as.data.frame() %>%
    janitor::clean_names() %>%
    tibble::as_tibble() %>%
    dplyr::filter(
      type == "response"
    ) %>%
    dplyr::select(
      -c(rowid, type, statistic, p_value)
    ) %>%
    dplyr::relocate(names(dummy_table), dplyr::last_col()) %>%
    return()
}
