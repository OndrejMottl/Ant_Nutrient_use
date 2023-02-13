get_d2 <- function(data_source, null_model) {
  res <- NA_real_
  try(
    expr = {
      null_dev <- insight::get_deviance(null_model)
      mod_dev <- insight::get_deviance(data_source)

      res <-
        (null_dev - mod_dev) / null_dev
    },
    silent = TRUE
  )
  return(res)
}
