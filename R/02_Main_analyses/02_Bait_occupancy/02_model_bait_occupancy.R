#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Bait occupanvy
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
data_full <-
  RUtilpol::get_latest_file(
    file_name = "data_full_clean",
    dir = here::here("Data/Processed")
  )

dplyr::glimpse(data_full)

data_mean_elevation <-
  RUtilpol::get_latest_file(
    file_name  = "data_mean_elevation",
    dir = here::here("Data/Processed")
  )

dplyr::glimpse(data_mean_elevation)

# data wrangling ----
data_to_traps <-
  data_full %>%
  dplyr::filter(
    excl_occupancy == FALSE
  ) %>%
  dplyr::group_by(
    regions, seasons, et_pcode, trap_number_code, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    total_abundance = sum(abundance)
  ) %>%
  dplyr::mutate(
    trap_occupied = ifelse(total_abundance > 0, 1, 0)
  ) %>%
  dplyr::group_by(
    regions, seasons, et_pcode, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n = dplyr::n(),
    traps_occupied = sum(trap_occupied),
    traps_empty = n - traps_occupied
  )

data_to_fit <-
  dplyr::left_join(
    data_to_traps,
    data_mean_elevation,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(is.character),
      as.factor
    )
  )

summary(data_to_fit)

# fit models  ----
mod_bait_occupancy <-
  fit_food_elev_region_season(
    data_source = data_to_fit,
    sel_var = "cbind(traps_occupied, traps_empty)",
    sel_family = glmmTMB::betabinomial(link = "logit")
  )

print_model_summary(mod_bait_occupancy)

# save ----
list(
  data_to_fit = data_to_fit,
  models = mod_bait_occupancy
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "mod_bait_occupancy",
    dir = here::here("Data/Processed/Models/")
  )
