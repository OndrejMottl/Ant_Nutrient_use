get_nice_table <- function(data_source) {
  knitr::kable(data_source,
    digits = c(2, 4),
    align = "l"
  ) %>%
    return()
}
