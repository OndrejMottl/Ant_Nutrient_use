#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                   Prepare full dataset
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

# Load data ----
data_full_raw <-
  readxl::read_xlsx(
    path = here::here(
      "Data/Input/AntPicnic_FullData.xlsx"
    ),
    # specify directory path here. Better to use the "here" package.
    sheet = "FullData-upto-treeline",
    col_names = TRUE
  )

dim(data_full_raw)
dplyr::glimpse(data_full_raw)

# data wrangle ----
data_full_clean <-
  data_full_raw %>%
  # clean all col names
  janitor::clean_names() %>%
  # make all character values to snake_style
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.character
      ),
      ~ snakecase::to_snake_case(.x)
    )
  ) %>%
  dplyr::mutate(
    exl_food_pref = ifelse(
      excluded_for_nutrient_ratios_analyses == "yes", TRUE, FALSE
    ),
    excl_occupancy = ifelse(
      excluded_for_total_bait_occupancy_analysis == "yes", TRUE, FALSE
    )
  ) %>%
  dplyr::select(
    -c(
      excluded_for_nutrient_ratios_analyses,
      excluded_for_total_bait_occupancy_analysis
    )
  ) %>%
  dplyr::mutate(
    sp_code = ifelse(sp_code == "na", NA_character_, sp_code)
  ) %>%
  dplyr::mutate(
    regions = ifelse(regions == "kilimanjaro", "tanzania", regions)
  ) %>%
  dplyr::mutate(
    bait_type = dplyr::case_when(
      bait_type == "h_2_o" ~ "h2o",
      bait_type == "na_cl" ~ "nacl",
      TRUE ~ bait_type
    )
  ) %>%
  # make all characters into factors
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.character
      ),
      as.factor
    )
  )

dim(data_full_clean)
dplyr::glimpse(data_full_clean)
summary(data_full_clean)

# save ----
RUtilpol::save_latest_file(
  object_to_save = data_full_clean,
  dir = here::here("Data/Processed"),
  prefered_format = "rds"
)
