get_nice_table <- function(data_source, decimal_digits = 2) {
  data_source %>%
    dplyr::mutate(
      dplyr::across(
        .cols = tidyselect::where(
          is.numeric
        ),
        .fns = ~ round(.x, decimal_digits)
      )
    ) %>%
    knitr::kable(
      .,
      digits = decimal_digits,
      align = "l"
    ) %>%
    return()
}
