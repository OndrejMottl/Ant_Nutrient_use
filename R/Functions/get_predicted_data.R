get_predicted_data <- function(
    mod,
    dummy_table) {
  dummy_table %>%
    dplyr::bind_cols(
      stats::predict.glm(
        mod,
        newdata = .,
        type = "response",
        se.fit = TRUE
      )
    ) %>%
    dplyr::rename(
      "predicted" = fit, "se_fit" = se.fit
    ) %>%
    return()
}