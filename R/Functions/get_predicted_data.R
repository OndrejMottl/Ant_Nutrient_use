get_predicted_data <- function(
    mod,
    dummy_table) {
      dummy_table  %>% 
      dplyr::bind_cols(
        predict(
          object = mod,
          newdata = dummy_table,
          type = "response",
          se.fit = TRUE
        ) %>%
          as.data.frame() %>%
          janitor::clean_names()
      )  %>% 
      dplyr::mutate(
        estimate = fit,
          conf_high = estimate + se_fit,
          conf_low = estimate - se_fit
      ) %>%
    tibble::as_tibble() %>%
    dplyr::relocate(names(dummy_table)) %>%
    return()
}
