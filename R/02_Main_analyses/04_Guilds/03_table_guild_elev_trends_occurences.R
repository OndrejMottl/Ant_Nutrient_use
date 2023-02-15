#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                 Table guilds occurences
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
mod_guilds_proportions_occurences <-
  RUtilpol::get_latest_file(
    file_name = "mod_guilds_proportions_occurences",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

table_guilds_proportions_occurences <-
  mod_guilds_proportions_occurences %>%
  dplyr::rename(model_df = df) %>%
  tidyr::unnest(anova_to_null) %>%
  dplyr::select(-c(mod, mod_anova))

# save ----
# csv
readr::write_csv(
  table_guilds_proportions_occurences,
  file = here::here(
    "Outputs/table_guilds_proportions_occurences.csv"
  )
)

# word
arsenal::write2word(
  object = table_guilds_proportions_occurences %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_guilds_proportions_occurences.docx"
  )
)

# params ----
table_guilds_proportions_occurences_params <-
  mod_guilds_proportions_occurences %>%
  dplyr::rename(model_df = df) %>%
  dplyr::filter(best_model == TRUE) %>%
  purrr::pluck("mod_anova", 1)

# save ----
# csv
readr::write_csv(
  table_guilds_proportions_occurences_params,
  file = here::here(
    "Outputs/table_guilds_proportions_occurences_params.csv"
  )
)

# word
arsenal::write2word(
  object = table_guilds_proportions_occurences_params %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_guilds_proportions_occurences_params.docx"
  )
)
