get_model_family_name <- function(data_source) {
  family_name <-
    insight::get_family(data_source) %>%
    unlist() %>%
    purrr::pluck("family")

  if (
    stringr::str_detect(family_name, "Negative Binomial")
  ) {
    family_name <- "Negative Binomial"
  }

  if (
    stringr::str_detect(family_name, "nbinom")
  ) {
    family_name <- "nbinom"
  }

  return(family_name)
}
