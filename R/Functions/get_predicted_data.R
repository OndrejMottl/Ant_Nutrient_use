get_predicted_data <- function(
    mod,
    dummy_table) {
  data_predicted <-
    dummy_table %>%
    dplyr::bind_cols(
      predict(
        object = mod,
        newdata = dummy_table,
        type = "response",
        se.fit = TRUE,
        phi = FALSE
      ) %>%
        as.data.frame() %>%
        janitor::clean_names()
    )

  if (
    all(
      c("fit", "se_fit") %in% names(data_predicted)
    )
  ) {
    data_predicted %>%
      dplyr::mutate(
        estimate = fit,
        conf_high = estimate + se_fit,
        conf_low = estimate - se_fit
      ) %>%
      tibble::as_tibble() %>%
      dplyr::relocate(names(dummy_table)) %>%
      return()
  } else {
    data_predicted %>%
      dplyr::mutate(
        !!mod$varnames[1] := v1,
        !!mod$varnames[2] := v1,
        !!mod$varnames[3] := v3
      ) %>%
      tibble::as_tibble() %>%
      dplyr::relocate(names(dummy_table)) %>%
      return()
  }
}
