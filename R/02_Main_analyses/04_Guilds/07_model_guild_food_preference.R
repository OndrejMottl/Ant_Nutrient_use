#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                 Guild nutrien use models
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
data_guild_occurences <-
  RUtilpol::get_latest_file(
    file_name = "data_guild_occurences",
    dir = here::here("Data/Processed/")
  )

dplyr::glimpse(data_guild_occurences)

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

# data wragling ----
data_to_fit <-
  dplyr::left_join(
    data_bait_type_rel_use,
    data_mean_elevation,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::left_join(
    data_guild_occurences,
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

summary(data_to_fit)

# fit model ----

# create a table to apply model to
data_all_possibilies <-
  expand.grid(
    regions = data_to_fit$regions %>%
      unique(),
    sel_nutrient = data_to_fit$bait_type %>%
      unique()
  ) %>%
  tibble::as_tibble()

data_guild_models_all <-
  data_all_possibilies %>%
  dplyr::mutate(
    models = purrr::map2(
      .x = regions,
      .y = sel_nutrient,
      .f = ~ {
        message(
          paste(.x, .y, sep = " - ")
        )

        fit_guild_addtion(
          data_source = data_to_fit %>%
            dplyr::filter(regions == .x) %>%
            dplyr::filter(bait_type == .y),
          sel_var = "cbind(n_occurecnes, max_occurecnes - n_occurecnes)",
          sel_family = glmmTMB::betabinomial(link = "logit"),
           control = glmmTMBControl(
             optimizer = optim,
             optArgs = list(method = "BFGS")
           )
        ) %>%
          return()
      }
    )
  )

data_guild_models <-
  data_guild_models_all %>%
  tidyr::unnest(models)

data_guild_models %>%
  dplyr::arrange(sel_nutrient, regions) %>%
  dplyr::filter(best_model == TRUE) %>%
  dplyr::select(regions, sel_nutrient, mod_name)

# save ----
# save
list(
  data_to_fit = data_to_fit,
  models = data_guild_models
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "data_guild_models",
    dir = here::here("Data/Processed/Models/")
  )
