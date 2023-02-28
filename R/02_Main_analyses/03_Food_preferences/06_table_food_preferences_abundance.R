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
food_pref_models_abundance <-
  RUtilpol::get_latest_file(
    file_name = "food_pref_models_abundance",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

# make table ----
table_food_preferences_abundance_models <-
  food_pref_models_abundance %>%
  get_table_models(.,
    add_first_cols = c("regions", "sel_bait_type")
  )

# save ----
# csv
readr::write_csv(
  table_food_preferences_abundance_models,
  file = here::here(
    "Outputs/table_food_preferences_abundance_models.csv"
  )
)

# word
arsenal::write2word(
  object = table_food_preferences_abundance_models %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_food_preferences_abundance_models.docx"
  )
)

# params ----
table_food_preferences_abundance_params <-
  food_pref_models_occurences %>%
  get_table_params(.,
    add_first_cols = c(
      "regions",
      "sel_bait_type",
      "mod_name"
    )
  )

# save ----
# csv
readr::write_csv(
  table_food_preferences_abundance_params,
  file = here::here(
    "Outputs/table_food_preferences_abundance_params.csv"
  )
)

# word
arsenal::write2word(
  object = table_food_preferences_abundance_params %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_food_preferences_abundance_params.docx"
  )
)
