#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#            food preference models - abundance
#
#
#           --- authors are hidden for review ---
#                         2023
#
#----------------------------------------------------------#

# Load configuration ----
library(here)
source(
  here::here(
    "R/00_Config_file.R"
  )
)

# load data ----
data_bait_type_rel_use <-
  RUtilpol::get_latest_file(
    file_name = "data_bait_type",
    dir = here::here("Data/Processed/")
  )

dplyr::glimpse(data_bait_type_rel_use)

data_mean_elevation <-
  RUtilpol::get_latest_file(
    file_name  = "data_mean_elevation",
    dir = here::here("Data/Processed")
  )

dplyr::glimpse(data_mean_elevation)

# data wrangling ----
data_to_fit <-
  dplyr::left_join(
    data_bait_type_rel_use,
    data_mean_elevation,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    n_abundance_log = log10(n_abundance + 1),
    max_abundance_log = log10(max_abundance + 1)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.character
      ),
      as.factor
    )
  )

summary(data_to_fit)

# fit models ----
# - individual models ----
# create a table to apply model to
data_all_possibilies <-
  expand.grid(
    regions = data_to_fit$regions %>%
      unique(),
    sel_bait_type = data_to_fit$bait_type %>%
      unique()
  ) %>%
  tibble::as_tibble()

food_pref_models <-
  data_all_possibilies %>%
  dplyr::mutate(
    models = purrr::map2(
      .x = regions,
      .y = sel_bait_type,
      .f = ~ {
        message(
          paste(.x, .y, sep = " - ")
        )

        fit_elev_season(
          data_source = data_to_fit %>%
            dplyr::filter(regions %in% .x) %>%
            dplyr::filter(bait_type %in% .y),
          sel_var = "cbind(n_abundance_log, max_abundance_log - n_abundance_log)",
          sel_family = glmmTMB::betabinomial(link = "logit"),
          sel_method = "glmmTMB",
          compare_aic = TRUE,
          control = glmmTMBControl(
            optimizer = optim,
            optArgs = list(method = "BFGS")
          )
        ) %>%
          return()
      }
    )
  )

food_pref_models_individual <-
  food_pref_models %>%
  tidyr::unnest(models)

food_pref_models_individual %>%
  dplyr::arrange(regions) %>%
  dplyr::filter(best_model == TRUE) %>%
  tidyr::unnest(test_to_null) %>%
  dplyr::select(regions, sel_bait_type, mod_name, p_value_chisq)

# save
list(
  data_to_fit = data_to_fit,
  models = food_pref_models_individual
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "food_pref_models_abundance",
    dir = here::here("Data/Processed/Models/")
  )
