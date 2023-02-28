#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#           Table guild food preferecnes addition
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
mod_guild_models <-
  RUtilpol::get_latest_file(
    file_name = "data_guild_models_addtion",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

# make table ----
table_guild_addition <-
  mod_guild_models %>%
  get_table_models(
    add_first_cols = c("regions", "sel_bait_type")
  )

# save ----
# csv
readr::write_csv(
  table_guild_addition,
  file = here::here(
    "Outputs/table_guild_addition.csv"
  )
)

# word
arsenal::write2word(
  object = table_guild_addition %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_guild_addition.docx"
  )
)

# terms ----
table_guild_addition_terms <-
  mod_guild_models %>%
  get_table_terms(
    add_first_cols = c(
      "regions",
      "sel_nutrient",
      "mod_name"
    )
  )

# save ----
# csv
readr::write_csv(
  table_guild_addition_terms,
  file = here::here(
    "Outputs/table_guild_addition_terms.csv"
  )
)

# word
arsenal::write2word(
  object = table_guild_addition_terms %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_guild_addition_terms.docx"
  )
)

# params ----
table_guild_addition_params <-
  mod_guild_models %>%
  get_table_params(
     add_first_cols = c(
       "regions",
       "sel_bait_type",
       "mod_name"
     )
  )

# save ----
# csv
readr::write_csv(
  table_guild_addition_params,
  file = here::here(
    "Outputs/table_guild_addition_params.csv"
  )
)

# word
arsenal::write2word(
  object = table_guild_addition_params %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_guild_addition_params.docx"
  )
)
