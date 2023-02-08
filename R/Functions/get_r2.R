get_r2 <- function(data_source) {
  res <- NA_real_

  if (
    "glmmTMB" %in% class(data_source)
  ) {
    suppressWarnings(
      res <-
        performance::r2_tjur(data_source)
    )
  }

  if (
    "glm" %in% class(data_source)
  ) {
    suppressWarnings(
      res <-
        performance::r2_nagelkerke(data_source) %>%
        as.double()
    )
  }

  return(res)
}
