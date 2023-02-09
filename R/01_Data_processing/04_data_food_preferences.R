#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                Dataset for food preferences
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
  dplyr::filter(exl_food_pref == FALSE) %>%
  dplyr::distinct(
    regions, seasons, et_pcode, bait_type, trap_number_code
  )

data_all_sites_ref <-
  data_all_traps_ref %>%
  dplyr::distinct(
    regions, seasons, et_pcode, bait_type
  )

# - occurences ----
data_spec_per_trap <-
  data_full %>%
  dplyr::filter(exl_food_pref == FALSE) %>%
  dplyr::distinct(
    regions, seasons, et_pcode, bait_type, trap_number_code, sp_code
  ) %>%
  tidyr::drop_na(sp_code) %>%
  dplyr::group_by(
    regions, seasons, et_pcode, bait_type, trap_number_code
  ) %>%
  dplyr::count(
    name = "n_species"
  ) %>%
  dplyr::ungroup()

data_bait_type_occurences_total <-
  data_spec_per_trap %>%
  dplyr::group_by(
    regions, seasons, et_pcode, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n_occurecnes = sum(n_species, na.rm = TRUE)
  ) %>%
  dplyr::full_join(
    data_all_sites_ref,
    by = dplyr::join_by(regions, seasons, et_pcode, bait_type)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.numeric
      ),
      ~ tidyr::replace_na(.x, 0)
    )
  )

data_bait_type_occurences_max <-
  data_bait_type_occurences_total %>%
  dplyr::group_by(
    regions, seasons, et_pcode
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    max_occurecnes = max(n_occurecnes)
  )

data_bait_type_occurences <-
  dplyr::left_join(
    data_bait_type_occurences_total,
    data_bait_type_occurences_max,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.numeric
      ),
      ~ tidyr::replace_na(.x, 0)
    )
  ) %>%
  dplyr::mutate(
    rel_occurences = n_occurecnes / max_occurecnes
  )

# - abundance ----
data_bait_type_abundance_total <-
  data_full %>%
  dplyr::filter(exl_food_pref == FALSE) %>%
  dplyr::group_by(
    regions, seasons, et_pcode, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n_abundance = sum(abundance, na.rm = TRUE)
  ) %>%
  dplyr::full_join(
    data_all_sites_ref,
    by = dplyr::join_by(regions, seasons, et_pcode, bait_type)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.numeric
      ),
      ~ tidyr::replace_na(.x, 0)
    )
  )

data_bait_type_abundance_max <-
  data_bait_type_abundance_total %>%
  dplyr::group_by(
    regions, seasons, et_pcode
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    max_abundance = max(n_abundance)
  )

data_bait_type_abundance <-
  dplyr::left_join(
    data_bait_type_abundance_total,
    data_bait_type_abundance_max,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.numeric
      ),
      ~ tidyr::replace_na(.x, 0)
    )
  ) %>%
  dplyr::mutate(
    rel_abundance = round(
      log(n_abundance + 1) / log(max_abundance + 1),
      2
    )
  )

# - merge ----
data_bait_type <-
  dplyr::inner_join(
    data_bait_type_occurences,
    data_bait_type_abundance,
    by = dplyr::join_by(regions, seasons, et_pcode, bait_type)
  )

# save ----
RUtilpol::save_latest_file(
  object_to_save = data_bait_type,
  dir = here::here("Data/Processed/")
)
