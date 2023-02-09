get_r2 <- function(data_source) {
  opt <-
    options(show.error.messages = FALSE)
  on.exit(options(opt))

  res <- NA_real_

  mod_family <- get_model_family_name(data_source)

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
    "nbinom" = {
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

  as.double(res) %>%
    return()
}
