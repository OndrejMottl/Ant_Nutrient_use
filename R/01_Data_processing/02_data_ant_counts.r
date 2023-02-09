#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                  Dataset for ant conts
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

# data wragling ----
data_all_traps_ref <-
  data_full %>%
  dplyr::distinct(
    regions, seasons, et_pcode, trap_number_code
  )

data_all_sites_ref <-
  data_all_traps_ref %>%
  dplyr::distinct(
    regions, seasons, et_pcode
  )

data_unique_species_per_trap <-
  data_full %>%
  dplyr::distinct(
    regions, seasons, et_pcode, trap_number_code, sp_code
  ) %>%
  tidyr::drop_na(sp_code)

data_spec_per_trap <-
  data_unique_species_per_trap %>%
  dplyr::group_by(
    regions, seasons, et_pcode, trap_number_code
  ) %>%
  dplyr::count(
    name = "n_species"
  ) %>%
  dplyr::ungroup()

data_occurences <-
  data_spec_per_trap %>%
  dplyr::group_by(
    regions, seasons, et_pcode
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n_occurecnes = sum(n_species, na.rm = TRUE)
  ) %>%
  dplyr::left_join(
    data_all_sites_ref,
    .,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    n_occurecnes = tidyr::replace_na(n_occurecnes, 0)
  )

data_richness <-
  data_unique_species_per_trap %>%
  dplyr::distinct(
    regions, seasons, et_pcode, sp_code
  ) %>%
  dplyr::group_by(
    regions, seasons, et_pcode
  ) %>%
  dplyr::count(
    name = "n_species"
  ) %>%
  dplyr::ungroup() %>%
  dplyr::left_join(
    data_all_sites_ref,
    .,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    n_species = tidyr::replace_na(n_species, 0)
  )

data_abundance <-
  data_full %>%
  dplyr::group_by(
    regions, seasons, et_pcode
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n_abundance = sum(abundance, na.rm = TRUE)
  ) %>%
  dplyr::left_join(
    data_all_sites_ref,
    .,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    n_abundance = tidyr::replace_na(n_abundance, 0)
  )

data_ant_counts <-
  dplyr::left_join(
    data_occurences,
    data_richness,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::left_join(
    data_abundance,
    by = dplyr::join_by(regions, seasons, et_pcode)
  )

# save ----
RUtilpol::save_latest_file(
  object_to_save = data_ant_counts,
  dir = here::here("Data/Processed"),
  prefered_format = "rds"
)
