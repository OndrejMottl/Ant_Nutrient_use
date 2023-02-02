get_anova <- function(data_source, sel_test = "Chisq") {
  suppressWarnings(
    test_res <-
      stats::anova(
        data_source,
        test = sel_test
      )
  )

  test_res %>%
    as.data.frame() %>%
    tibble::rownames_to_column("term") %>%
    tibble::as_tibble() %>%
    janitor::clean_names() %>%
    return()
}
