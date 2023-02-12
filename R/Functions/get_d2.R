get_d2 <- function(data_source, null_model) {
  data_source %>%
    dplyr::mutate(
      d2 = purrr::map_dbl(
        .x = mod,
        .f = purrr::possibly(
          .f = ~ {
            null_dev <- insight::get_deviance(null_model)
            mod_dev <- insight::get_deviance(.x)

            res <-
              (null_dev - mod_dev) / null_dev
          },
          otherwise = NA_real_
        )
      )
    ) %>%
    return()
}
