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
food_pref_models_individual <-
  RUtilpol::get_latest_file(
    file_name = "food_pref_models_individual",
    dir = here::here("Data/Processed/Models/")
  )

food_pref_models_individual_models <-
  food_pref_models_individual %>%
  purrr::pluck("models") %>%
  dplyr::filter(best_model == TRUE)

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
data_source <-
  data_to_fit %>%
  dplyr::filter(regions == "ecuador") %>%
  dplyr::filter(bait_type == "amino_acid")

mod_sel <- food_pref_models_individual_models$mod[[1]]

data_sel <-
  data_to_fit %>%
  dplyr::filter(regions == "ecuador") %>%
  dplyr::filter(bait_type == "amino_acid")


data_guild_models_all <-
  food_pref_models_individual_models %>%
  dplyr::select(regions, sel_bait_type, mod) %>%
  dplyr::mutate(
    models = purrr::pmap(
      .l = list(regions, sel_bait_type, mod),
      .f = ~ {
        message(
          paste(..1, ..2, sep = " - ")
        )

        data_source <-
          data_to_fit %>%
          dplyr::filter(regions == ..1) %>%
          dplyr::filter(bait_type == ..2)

        mod_sel <- ..3

        sel_formula <-
          insight::find_formula(mod_sel) %>%
          purrr::pluck("conditional")

        mod_null_refit <-
          glmmTMB::glmmTMB(
            formula = sel_formula,
            data = data_source,
            family = glmmTMB::betabinomial(link = "logit"),
            ziformula = ~0,
            control = glmmTMBControl(
              optimizer = optim,
              optArgs = list(method = "BFGS")
            )
          )

        fit_guild_addtion(
          data_source = data_source,
          sel_var = "cbind(n_occurecnes, max_occurecnes - n_occurecnes)",
          sel_family = glmmTMB::betabinomial(link = "logit"),
          mod_null = mod_null_refit
        ) %>%
          return()
      }
    )
  )

data_guild_models <-
  data_guild_models_all %>%
  dplyr::select(-mod)  %>% 
  tidyr::unnest(models)

data_guild_models %>%
  dplyr::arrange(sel_bait_type, regions) %>%
  dplyr::filter(best_model == TRUE) %>%
  dplyr::select(regions, sel_bait_type, mod_name)

# save ----
# save
list(
  data_to_fit = data_to_fit,
  models = data_guild_models
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "data_guild_models_addtion",
    dir = here::here("Data/Processed/Models/")
  )
