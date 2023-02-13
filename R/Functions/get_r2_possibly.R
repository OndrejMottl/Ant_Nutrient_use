get_r2_possibly <- function(data_source) {
  res <- NA_real_

  mod_family <- get_model_family_name(data_source)

  if (
    is.null(mod_family)
  ) {
    mod_family <- NA
  }

  switch(mod_family,
    "Negative Binomial" = {
      capture.output(
        suppressWarnings(
          res <-
            performance::r2_nagelkerke(data_source)
        ),
        file = "NUL"
      )
    },
    "betabinomial" = {
      capture.output(
        suppressWarnings(
          res <-
            performance::r2_tjur(data_source)
        ),
        file = "NUL"
      )
    },
    "binomial" = {
      capture.output(
        suppressWarnings(
          res <-
            performance::r2_tjur(data_source)
        ),
        file = "NUL"
      )
    },
    "nbinom" = {
      suppressWarnings(
        res <-
          performance::r2_nakagawa(data_source) %>%
          as.data.frame() %>%
          purrr::pluck("R2_marginal") %>%
          mean(., na.rm = TRUE)
      )
    },
    "ordbeta" = {
      capture.output(
        suppressWarnings(
          res <-
            performance::r2_nakagawa(data_source) %>%
            as.data.frame() %>%
            purrr::pluck("R2_marginal") %>%
            mean(., na.rm = TRUE)
        ),
        file = "NUL"
      )
    },
    {
      capture.output(
        suppressWarnings(
          res <-
            performance::r2(data_source)
        ),
        file = "NUL"
      )
    }
  )

  res <-
    as.double(res)

  return(res)
}
