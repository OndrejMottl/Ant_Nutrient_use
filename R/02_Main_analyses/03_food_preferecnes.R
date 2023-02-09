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
data_rel_use <-
  readr::read_csv(
    file = here::here(
      paste0("Data/Processed/data_rel_use_2023-02-08.csv")
    ),
    show_col_types = FALSE
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
    regions = data_rel_use$sites %>%
      unique(),
    sel_bait_type = data_rel_use$bait_type %>%
      unique()
  ) %>%
  tibble::as_tibble()

data_food_pref_models <-
  data_all_possibilies %>%
  dplyr::mutate(
    models = purrr::map2(
      .x = regions,
      .y = sel_bait_type,
      .f = ~ {
        message(
          paste(.x, .y, sep = " - ")
        )

        fit_elev_models(
          data_source = data_rel_use %>%
            dplyr::filter(sites %in% .x) %>%
            dplyr::filter(bait_type %in% .y),
          sel_var = "cbind(total_occurrence, ma_xoccurrence - total_occurrence)",
          sel_family = glmmTMB::betabinomial(link = "logit"),
          compare_aic = TRUE,
          test_overdispersion = FALSE
        ) %>%
          return()
      }
    )
  )

data_food_pref_models_res <-
  data_food_pref_models %>%
  tidyr::unnest(models) %>%
  dplyr::filter(best_model == TRUE) %>%
  # replce NA for NULL models with arbitrary 1e3
  dplyr::mutate(
    weight = ifelse(is.na(weight), 1e3, weight)
  ) %>%
  dplyr::group_by(regions, sel_bait_type) %>%
  dplyr::filter(
    weight == max(weight)
  ) %>%
  # replce NULL models back to arbitrary NA
  dplyr::mutate(
    weight = ifelse(weight == 1e3, NA_real_, weight)
  ) %>%
  dplyr::filter(
    AICc == min(AICc)
  ) %>%
  dplyr::ungroup()

data_food_pref_models_res[, 1:3]

data_food_pref_models_res %>%
  dplyr::arrange(regions) %>%
  dplyr::select(regions, sel_bait_type, mod_name)

# save 
data_food_pref_models_res %>%
  readr::write_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/food_pref_",
        current_date,
        ".rds"
      )
    )
  )


# - regional models ----

data_food_pref_models_regions <-
  tibble::tibble(
    regions = data_rel_use$sites %>%
      unique()
  ) %>%
  dplyr::mutate(
    models = purrr::map(
      .x = regions,
      .f = ~ {
        message(.x)

        fit_food_pref_models(
          data_source = data_rel_use %>%
            dplyr::filter(sites %in% .x)
        ) %>%
          return()
      }
    )
  )

data_food_pref_models_regions_res <-
  data_food_pref_models_regions %>%
  tidyr::unnest(models) %>%
  dplyr::filter(best_model == TRUE) %>%
  # replce NA for NULL models with arbitrary 1e3
  dplyr::mutate(
    weight = ifelse(is.na(weight), 1e3, weight)
  ) %>%
  dplyr::group_by(regions) %>%
  dplyr::filter(
    weight == max(weight)
  ) %>%
  # replce NULL models back to arbitrary NA
  dplyr::mutate(
    weight = ifelse(weight == 1e3, NA_real_, weight)
  ) %>%
  dplyr::filter(
    AICc == min(AICc)
  ) %>%
  dplyr::ungroup()

data_food_pref_models_regions_res[, 1:3]

# save
data_food_pref_models_regions_res %>%
  readr::write_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/food_pref_region",
        current_date,
        ".rds"
      )
    )
  )
