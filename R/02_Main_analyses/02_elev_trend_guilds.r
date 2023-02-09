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
  tidyr::pivot_longer(
    cols = -c(regions, seasons, et_pcode),
    names_to = "guild",
    values_to = "n_occ_prop"
  ) %>%
  dplyr::left_join(
    data_mean_elevation,
    by = dplyr::join_by(regions, seasons, et_pcode)
  )

# fit model ----
mod_guilds_proportions <-
  fit_guild_elev_models(
    data_source = data_to_fit,
    sel_var = "n_occ_prop",
    sel_family = glmmTMB::ordbeta(link = "logit")
  )

mod_guilds_proportions

mod_guilds_proportions$mod_name[
  which(mod_guilds_proportions$best_model == TRUE)
]

# Check parametr details
mod_guilds_proportions$mod_anova[
  which(mod_guilds_proportions$best_model == TRUE)
]

# save ----
list(
  data_to_fit = data_to_fit,
  models = mod_guilds_proportions
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "mod_guilds_proportions",
    dir = here::here("Data/Processed/Models/")
  )
