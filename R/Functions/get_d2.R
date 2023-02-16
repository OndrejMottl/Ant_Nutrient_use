get_d2 <- function(data_source, null_model) {
  res <- NA_real_
  try(
    expr = {
      null_dev <- insight::get_deviance(null_model)
      mod_dev <- insight::get_deviance(data_source)

      # in case models are the same
      if (
        null_dev == mod_dev
      ) {
        res <- 1
      } else {
        res <-
          (null_dev - mod_dev) / null_dev
      }
    },
    silent = TRUE
  )
  return(res)
}
