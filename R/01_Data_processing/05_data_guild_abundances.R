#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#         Dataset for ant trophic groups - abundances
#
#
#           --- authors are hidden for review ---
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
  ) %>%
  dplyr::filter(
    excl_occupancy == FALSE
  ) %>%
  dplyr::filter(
    exl_food_pref == FALSE
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

data_guild_abundances_total <-
  data_full %>%
  dplyr::group_by(
    regions, seasons, et_pcode, guild
  ) %>%
  tidyr::drop_na(guild) %>%
  dplyr::summarise(
    .groups = "drop",
    n_abundances = sum(abundance, na.rm = TRUE)
  ) %>%
  tidyr::pivot_wider(
    names_from = "guild",
    names_prefix = "n_abund_",
    values_from = "n_abundances",
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

data_guild_abundances <-
  data_guild_abundances_total %>%
  dplyr::mutate(
    abundances_total = n_abund_generalistic + n_abund_herbivorous_trophobiotic +
      n_abund_predator_scavenger
  ) %>%
  dplyr::mutate(
    dplyr::across(
      .names = "{.col}_prop",
      dplyr::starts_with("n_abund"),
      ~ log10(.x + 1) / log10(abundances_total + 1)
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
  object_to_save = data_guild_abundances,
  dir = here::here("Data/Processed/")
)

RUtilpol::save_latest_file(
  object_to_save = data_guild_abundances,
  dir = here::here("Data/Reference_tables/"),
  prefered_format = "csv"
)
