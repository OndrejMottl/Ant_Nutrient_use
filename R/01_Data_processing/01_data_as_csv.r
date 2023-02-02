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