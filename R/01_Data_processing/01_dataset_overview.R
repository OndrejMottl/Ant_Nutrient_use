#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                     Dataset overview
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

data_n_sites <-
  data_full %>%
  dplyr::distinct(
    regions, elevational_bands, et_pcode,
  ) %>%
  dplyr::group_by(
    regions, elevational_bands
  ) %>%
  dplyr::count(name = "n_of_sites") %>%
  dplyr::ungroup()

data_n_sites

RUtilpol::save_latest_file(
  object_to_save = data_n_sites,
  dir = here::here("Data/Processed"),
  prefered_format = "rds"
)

data_n_traps <-
  data_full %>%
  dplyr::distinct(
    regions, elevational_bands, seasons, bait_type, trap_number_code
  ) %>%
  dplyr::group_by(
    regions, elevational_bands, seasons, bait_type
  ) %>%
  dplyr::count() %>%
  tidyr::pivot_wider(
    names_from = "bait_type",
    names_prefix = "n_traps_",
    values_from = "n",
    values_fill = 0
  ) %>%
  dplyr::ungroup()

data_n_traps

RUtilpol::save_latest_file(
  object_to_save = data_n_traps,
  dir = here::here("Data/Processed"),
  prefered_format = "rds"
)

data_mean_elevation <-
  data_full %>%
  dplyr::distinct(
    regions, seasons, elevational_bands, et_pcode, elevation
  ) %>%
  dplyr::group_by(
    regions, seasons, elevational_bands, et_pcode
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    elevation_mean = mean(elevation, na.rm = TRUE) %>%
      round()
  )

data_mean_elevation

RUtilpol::save_latest_file(
  object_to_save = data_mean_elevation,
  dir = here::here("Data/Processed"),
  prefered_format = "rds"
)
