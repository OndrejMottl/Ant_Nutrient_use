#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                  Guild elevation trend
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

data_mean_elevation <-
  RUtilpol::get_latest_file(
    file_name  = "data_mean_elevation",
    dir = here::here("Data/Processed")
  )

dplyr::glimpse(data_mean_elevation)

# data wragling ----
data_to_fit <-
  data_guild_occurences %>%
  dplyr::select(
    dplyr::any_of(
      c(
        "regions",
        "seasons",
        "et_pcode",
        "n_occ_generalistic_prop",
        "n_occ_herbivorous_trophobiotic_prop",
        "n_occ_predator_scavenger_prop"
      )
    )
  ) %>%
  dplyr::left_join(
    data_mean_elevation,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(is.character),
      as.factor
    )
  )

# update the data so that it can be fitted as multinomial
data_to_fit$Y <-
  DirichletReg::DR_data(data_to_fit[, c(
    "n_occ_generalistic_prop",
    "n_occ_herbivorous_trophobiotic_prop",
    "n_occ_predator_scavenger_prop"
  )])

summary(data_to_fit)

# fit model ----
mod_guilds_proportions_occurences <-
  fit_elev_region_season(
    data_source = data_to_fit,
    sel_var = "Y",
    sel_method = "DirichReg"
  )

print_model_summary(mod_guilds_proportions_occurences)

# save ----
list(
  data_to_fit = data_to_fit,
  models = mod_guilds_proportions_occurences
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "mod_guilds_proportions_occurences",
    dir = here::here("Data/Processed/Models/")
  )
