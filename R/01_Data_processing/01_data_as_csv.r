#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                   Save data as CSV
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

data_diversity <-
  readxl::read_xlsx(
    path = here::here(
      "Data/Input/AntPicnic_diversity_data.xlsx"
    ),
    sheet = "antPicnic_diversity_data",
    col_names = TRUE
  )[, -1]

dim(data_diversity)
dplyr::glimpse(data_diversity)

readr::write_csv(
  x = data_diversity,
  file = here::here(
    paste0("Data/Processed/data_diversity_", current_date, ".csv")
  )
)

data_guild <-
  readxl::read_xlsx(
    path = here::here(
      "Data/Input/AntPicnic_guilds_data.xlsx"
    ),
    sheet = "AntPicnic_guild_data",
    col_names = TRUE
  )[, -1]

dim(data_guild)
dplyr::glimpse(data_guild)

readr::write_csv(
  x = data_guild,
  file = here::here(
    paste0("Data/Processed/data_guilds_", current_date, ".csv")
  )
)
