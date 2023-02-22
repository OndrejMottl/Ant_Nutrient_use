#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#             Table guild food preferecnes simple
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
    file_name = "data_guild_models",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")


# make table ----
table_guild_simple <-
  mod_guild_models %>%
  get_table_models(
    add_first_cols = c("regions", "sel_nutrient")
  )

# save ----
# csv
readr::write_csv(
  table_guild_simple,
  file = here::here(
    "Outputs/table_guild_simple.csv"
  )
)

# word
arsenal::write2word(
  object = table_guild_simple %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_guild_simple.docx"
  )
)

# params ----
table_guild_simple_params <-
  mod_guild_models %>%
  get_table_params(
    add_first_cols = c(
      "regions",
      "sel_nutrient",
      "mod_name"
    )
  )

# save ----
# csv
readr::write_csv(
  table_guild_simple_params,
  file = here::here(
    "Outputs/table_guild_simple_params.csv"
  )
)

# word
arsenal::write2word(
  object = table_guild_simple_params %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_guild_simple_params.docx"
  )
)

