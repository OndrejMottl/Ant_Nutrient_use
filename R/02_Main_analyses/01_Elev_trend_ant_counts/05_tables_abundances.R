#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Table s1
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

# load models ----
mod_abundnace <-
  RUtilpol::get_latest_file(
    file_name = "mod_abundnace",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

table_abundance_models <-
  mod_abundnace %>%
  get_table_models()

# save ----
# csv
readr::write_csv(
  table_abundance_models,
  file = here::here(
    "Outputs/table_abundance_models.csv"
  )
)

# word
arsenal::write2word(
  object = table_abundance_models %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_abundance_models.docx"
  )
)

# params ----
table_abundance_params <-
  mod_abundnace %>%
  get_table_params()

# save ----
# csv
readr::write_csv(
  table_abundance_params,
  file = here::here(
    "Outputs/table_abundance_params.csv"
  )
)

# word
arsenal::write2word(
  object = table_abundance_params %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_abundance_params.docx"
  )
)
