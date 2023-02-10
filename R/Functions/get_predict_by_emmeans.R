get_predict_by_emmeans <- function(
    sel_mod,
    sel_spec) {
  res <-
    emmeans::emmeans(
      object = sel_mod,
      spec = sel_spec,
      type = "response"
    ) %>%
    as.data.frame() %>%
    tibble::as_tibble() %>%
    janitor::clean_names()

  if (
    "response" %in% names(res)
  ) {
    res <-
      res %>%
      dplyr::rename(
        estimate = response
      )
  }

  if (
    "prob" %in% names(res)
  ) {
    res <-
      res %>%
      dplyr::rename(
        estimate = prob
      )
  }

  return(res)
}
