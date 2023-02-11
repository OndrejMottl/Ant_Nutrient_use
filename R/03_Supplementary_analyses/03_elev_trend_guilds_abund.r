#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#             Guild elevation trend - abundnace
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
data_guild_abundances <-
  RUtilpol::get_latest_file(
    file_name  = "data_guild_abundances",
    dir = here::here("Data/Supplementary/")
  )

dplyr::glimpse(data_guild_abundances)

data_mean_elevation <-
  RUtilpol::get_latest_file(
    file_name  = "data_mean_elevation",
    dir = here::here("Data/Processed")
  )

dplyr::glimpse(data_mean_elevation)

# data wragling ----
data_to_fit <-
  data_guild_abundances %>%
  dplyr::select(
    dplyr::any_of(
      c(
        "regions",
        "seasons",
        "et_pcode",
        "n_abund_generalistic_prop",
        "n_abund_herbivorous_trophobiotic_prop",
        "n_abund_predator_scavenger_prop"
      )
    )
  ) %>%
  tidyr::pivot_longer(
    cols = -c(regions, seasons, et_pcode),
    names_to = "guild",
    values_to = "n_abund_prop"
  ) %>%
  dplyr::left_join(
    data_mean_elevation,
    by = dplyr::join_by(regions, seasons, et_pcode)
  )

# fit model ----
mod_guilds_proportions_abund <-
  fit_guild_elev_region_season(
    data_source = data_to_fit,
    sel_var = "n_abund_prop",
    sel_family = glmmTMB::ordbeta(link = "logit")
  )

print_model_summary(mod_guilds_proportions_abund)

# save ----
list(
  data_to_fit = data_to_fit,
  models = mod_guilds_proportions_abund
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "mod_guilds_proportions_abund",
    dir = here::here("Data/Supplementary/Models/")
  )
