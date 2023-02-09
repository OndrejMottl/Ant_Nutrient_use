get_emmeans <- function(
    sel_mod,
    sel_spec) {
  emmeans::emmeans(
    object = sel_mod,
    spec = sel_spec,
    type = "response"
  ) %>%
    as.data.frame() %>%
    tibble::as_tibble() %>%
    janitor::clean_names() %>%
    dplyr::rename(
      estimate = response
    )
}