get_anova <- function(data_source, sel_test = "Chisq") {
  mod_class <- class(data_source)


  switch(mod_class,
    "glm" = {
      suppressWarnings(
        test_res <-
          stats::anova(
            data_source,
            test = sel_test
          )
      )
    },
    "glmmTMB" = {
      suppressWarnings(
        test_res <-
          car::Anova(
            data_source
          )
      )
    }
  )

  test_res %>%
    as.data.frame() %>%
    tibble::rownames_to_column("term") %>%
    tibble::as_tibble() %>%
    janitor::clean_names() %>%
    return()
}
