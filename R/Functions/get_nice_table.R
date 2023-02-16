get_nice_table <- function(data_source, decimal_digits = 2) {
  data_source %>%
    round_all_numbers(., decimal_digits = decimal_digits) %>%
    knitr::kable(
      .,
      digits = decimal_digits,
      align = "l"
    ) %>%
    return()
}
