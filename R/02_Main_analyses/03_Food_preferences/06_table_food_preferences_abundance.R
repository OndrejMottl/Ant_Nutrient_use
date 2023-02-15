#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Table s1
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
food_pref_models_abundance <-
  RUtilpol::get_latest_file(
    file_name = "food_pref_models_abundance",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

# make table ----
table_food_preferences_abundance_models <-
  food_pref_models_abundance %>%
  dplyr::arrange(regions, sel_bait_type) %>%
  dplyr::rename(model_df = df) %>%
  tidyr::unnest("anova_to_null") %>%
  dplyr::select(-c(mod, mod_anova))

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
  food_pref_models_abundance %>%
  dplyr::rename(model_df = df) %>%
  dplyr::filter(best_model == TRUE) %>%
  tidyr::unnest("mod_anova") %>%
  dplyr::select(
    dplyr::any_of(
      c(
        "regions",
        "sel_bait_type",
        "mod_name",
        "term",
        "chisq",
        "df",
        "pr_chisq",
        "signif"
      )
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
