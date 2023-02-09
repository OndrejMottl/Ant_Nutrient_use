#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#              Dataset for ant trophic groups
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
data_ant_guild_ref <-
  data_full %>%
  dplyr::distinct(
    sp_code, guild
  ) %>%
  tidyr::drop_na()

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
    regions, seasons, et_pcode, trap_number_code, guild, sp_code
  ) %>%
  tidyr::drop_na(sp_code)

data_spec_per_trap <-
  data_unique_species_per_trap %>%
  dplyr::group_by(
    regions, seasons, et_pcode, trap_number_code, guild
  ) %>%
  dplyr::count(
    name = "n_species"
  ) %>%
  dplyr::ungroup()

data_guild_occurences_total <-
  data_spec_per_trap %>%
  dplyr::group_by(
    regions, seasons, et_pcode, guild
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n_occurecnes = sum(n_species, na.rm = TRUE)
  ) %>%
  tidyr::pivot_wider(
    names_from = "guild",
    names_prefix = "n_occ_",
    values_from = "n_occurecnes",
    values_fill = 0
  ) %>%
  dplyr::left_join(
    data_all_sites_ref,
    .,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.numeric
      ),
      ~ tidyr::replace_na(.x, 0)
    )
  )

data_guild_occurences <-
  data_guild_occurences_total %>%
  dplyr::mutate(
    occurecnes_total = n_occ_generalistic + n_occ_herbivorous_trophobiotic +
      n_occ_predator_scavenger
  ) %>%
  dplyr::mutate(
    dplyr::across(
      .names = "{.col}_prop",
      dplyr::starts_with("n_occ"),
      ~ .x / occurecnes_total
    )
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.numeric
      ),
      ~ tidyr::replace_na(.x, 0)
    )
  )

# save ----
RUtilpol::save_latest_file(
  object_to_save = data_guild_occurences,
  dir = here::here("Data/Processed/")
)
