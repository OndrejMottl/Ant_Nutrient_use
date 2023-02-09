#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                  Ant abundances models
#
#
#             O. Mottl, J. Mosses, P. Klimes
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
    dplyr::across(
      tidyselect::where(
        is.character
      ),
      as.factor
    )
  )

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

        fit_elev_models_per_region(
          data_source = data_to_fit %>%
            dplyr::filter(regions %in% .x) %>%
            dplyr::filter(bait_type %in% .y),
          sel_var = "cbind(n_occurecnes, max_occurecnes - n_occurecnes)",
          sel_family = glmmTMB::betabinomial(link = "logit"),
          compare_aic = TRUE
        ) %>%
          return()
      }
    )
  )

food_pref_models_individual <-
  food_pref_models %>%
  tidyr::unnest(models) %>%
  dplyr::filter(best_model == TRUE)

food_pref_models_individual %>%
  dplyr::arrange(regions) %>%
  dplyr::select(regions, sel_bait_type, mod_name)

# save
list(
  data_to_fit = data_to_fit,
  models = food_pref_models_individual
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "food_pref_models_individual",
    dir = here::here("Data/Processed/Models/")
  )

# - regional models ----
food_pref_models_per_region <-
  tibble::tibble(
    regions = data_to_fit$regions %>%
      unique()
  ) %>%
  dplyr::mutate(
    models = purrr::map(
      .x = regions,
      .f = ~ {
        message(.x)

        fit_food_pref_models_per_region(
          data_source = data_to_fit %>%
            dplyr::filter(regions %in% .x),
          sel_var = "cbind(n_occurecnes, max_occurecnes - n_occurecnes)",
          sel_family = glmmTMB::betabinomial(link = "logit")
        ) %>%
          return()
      }
    )
  )

data_food_pref_models_regions <-
  food_pref_models_per_region %>%
  tidyr::unnest(models) %>%
  dplyr::filter(best_model == TRUE)

data_food_pref_models_regions %>%
  dplyr::arrange(regions) %>%
  dplyr::select(regions, mod_name)

# save
list(
  data_to_fit = data_to_fit,
  models = data_food_pref_models_regions
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "data_food_pref_models_regions",
    dir = here::here("Data/Processed/Models/")
  )
