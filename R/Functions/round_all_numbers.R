round_all_numbers <- function(data_source, decimal_digits = 3) {
  data_source %>%
    dplyr::mutate(
      dplyr::across(
        .cols = tidyselect::where(
          is.numeric
        ),
        .fns = ~ round(.x, decimal_digits)
      )
    ) %>%
    return()
}
