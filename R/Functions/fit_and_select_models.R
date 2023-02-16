data_source <- data_to_fit
sel_y_var <- "n_occurecnes"
sel_x_vars <- c("elevation_mean", "seasons")
sel_method <- "glmmTMB"
sel_family <- glmmTMB::nbinom2(link = "log")
test_overdispersion <- FALSE
poly_var <- "elevation_mean"
verbose_fit <- TRUE
min_delta_aic <- 2

fit_and_select_models <- function(
    data_source,
    sel_y_var,
    sel_x_vars,
    poly_var = NULL,
    sel_method = c("glmmTMB", "glm.nb", "aods3.bb"),
    test_overdispersion = FALSE,
    min_delta_aic = 2,
    ...) {
  sel_method <- match.arg(sel_method)

  x_vars <- paste(sel_x_vars, collapse = " * ")

  sel_formula_vec <- paste(sel_y_var, x_vars, sep = " ~ ")

  if (
    isFALSE(is.null(poly_var))
  ) {
    sel_formula <-
      c(1, 2) %>%
      rlang::set_names(
        nm = paste0("poly_", .)
      ) %>%
      purrr::map(
        .f = ~ {
          sel_poly_term <- paste0("poly(", poly_var, ", ", .x, ")")

          stringr::str_replace(
            string = sel_formula_vec,
            pattern = poly_var,
            replacement = sel_poly_term
          ) %>%
            as.formula() %>%
            return()
        }
      )
  } else {
    sel_formula <-
      list(as.formula(sel_formula_vec)) %>%
      rlang::set_names(nm = "poly_1")
  }

  suppressWarnings(
    mod_full <-
      sel_formula %>%
      purrr::map(
        .f = ~ switch(sel_method,
          "glmmTMB" = {
            glmmTMB::glmmTMB(
              formula = .x,
              family = sel_family,
              data = data_source,
              ziformula = ~0,
              na.action = "na.fail",
              ...
            )
          },
          "glm.nb" = {
            MASS::glm.nb(
              formula = .x,
              link = "log",
              data = data_source,
              na.action = "na.fail"
            )
          },
          "aods3.bb" = {
            aods3::aodml(
              formula = .x,
              family = "bb",
              link = "log",
              phi.formula = ~1,
              phi.scale = "log",
              method = "BFGS",
              control = list(maxit = 5000, trace = 0),
              data = data_source
            )
          }
        )
      )
  )

  cl <- parallel::makeCluster(parallel::detectCores())
  parallel::clusterExport(
    cl,
    c(
      "data_source",
      "sel_family"
    )
  )

  mod_table <-
    mod_full %>%
    purrr::map_dfr(
      .id = "type",
      .f = ~ {
        sel_model_full <- .x

        all_terms <-
          MuMIn::getAllTerms(sel_model_full) %>%
          as.character()

        subset_matrix <-
          matrix(
            TRUE,
            nrow = length(all_terms), ncol = length(all_terms),
            dimnames = list(all_terms, all_terms)
          ) %>%
          as.data.frame() %>%
          tibble::rownames_to_column("term_a") %>%
          tidyr::pivot_longer(
            cols = -term_a,
            names_to = "term_b"
          ) %>%
          dplyr::mutate(
            value = purrr::map2_lgl(
              .x = term_a,
              .y = term_b,
              .f = ~ stringr::str_detect(.x, pattern = "disp", negate = TRUE) &
                stringr::str_detect(.y, pattern = "disp", negate = TRUE)
            )
          ) %>%
          tidyr::pivot_wider(
            names_from = "term_b",
            values_from = value,
            values_fill = TRUE
          ) %>%
          tibble::column_to_rownames("term_a") %>%
          as.matrix()

        subset_matrix[!lower.tri(subset_matrix)] <- FALSE

        data_dredge_list <-
          lapply(
            MuMIn::dredge(
              global.model = sel_model_full,
              subset = subset_matrix,
              trace = verbose_fit,
              cluster = cl,
              evaluate = FALSE
            ), eval
          )

        get_form_as_text <- function(data_source) {
          Reduce(paste, deparse(data_source))
        }

        data_models <-
          tibble::tibble(
            mod = data_dredge_list
          ) %>%
          dplyr::mutate(
            mod_formula_full = purrr::map(
              .x = mod,
              .f = ~ insight::find_formula(.x)
            ),
            mod_formula = purrr::map_chr(
              .x = mod_formula_full,
              .f = ~ purrr::pluck(.x, "conditional") %>%
                get_form_as_text()
            ),
            mod_formula_disp = purrr::map_chr(
              .x = mod_formula_full,
              .f = purrr::possibly(
                .f = ~ purrr::pluck(.x, "dispersion") %>%
                  get_form_as_text(),
                otherwise = NA_character_
              )
            )
          ) %>%
          dplyr::filter(
            purrr::map_lgl(mod_formula_disp, ~ .x == "NULL")
          ) %>%
          dplyr::select(mod_formula, mod)  %>% 
          dplyr::mutate(
            mod = rlang::set_names(mod, nm = mod_formula)
          )

        return(data_models)
      }
    ) %>%
    dplyr::distinct(mod_formula, .keep_all = TRUE)

  parallel::stopCluster(cl)
  cl <- NULL

  if (
    isFALSE(is.null(poly_var))
  ) {
    mod_table <-
      mod_table %>%
      dplyr::mutate(
        mod_formula = stringr::str_replace(
          string = mod_formula,
          pattern = "poly\\(.*\\)",
          replacement = poly_var
        )
      )
  }

  res <-
    get_model_details(
      data_source = mod_table,
      test_overdispersion = test_overdispersion,
      compare_aic = TRUE,
      min_delta_aic = min_delta_aic
    )
}
