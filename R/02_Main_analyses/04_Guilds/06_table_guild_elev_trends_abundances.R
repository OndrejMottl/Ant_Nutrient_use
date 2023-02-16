#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                 Table guilds abundances
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

# load models ----
mod_guilds_proportions_abundance <-
  RUtilpol::get_latest_file(
    file_name = "mod_guilds_proportions_abund",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

table_guilds_proportions_abundnace <-
  mod_guilds_proportions_abundance %>%
  get_table_models()

# save ----
# csv
readr::write_csv(
  table_guilds_proportions_abundnace,
  file = here::here(
    "Outputs/table_guilds_proportions_abundnace.csv"
  )
)

# word
arsenal::write2word(
  object = table_guilds_proportions_abundnace %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_guilds_proportions_abundnace.docx"
  )
)

# params ----
table_guilds_proportions_abundnace_params <-
  mod_guilds_proportions_abundance %>%
  get_table_params()

# save ----
# csv
readr::write_csv(
  table_guilds_proportions_abundnace_params,
  file = here::here(
    "Outputs/table_guilds_proportions_abundnace_params.csv"
  )
)

# word
arsenal::write2word(
  object = table_guilds_proportions_abundnace_params %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_guilds_proportions_abundnace_params.docx"
  )
)
