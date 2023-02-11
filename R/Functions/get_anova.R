get_anova <- function(data_source, sel_type = "III") {
  suppressWarnings(
    test_res <-
      car::Anova(
        mod = data_source,
        type = sel_type
      )
  )

  test_res %>%
    as.data.frame() %>%
    tibble::rownames_to_column("term") %>%
    tibble::as_tibble() %>%
    janitor::clean_names() %>%
    return()
}
