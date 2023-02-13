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
    dir = here::here("Data/Supplementary/Models/")
  ) %>%
  purrr::pluck("models")

# make table ----
table_s3 <-
  food_pref_models_abundance %>%
  dplyr::arrange(regions, sel_bait_type) %>%
  dplyr::rename(model_df = df) %>%
  tidyr::unnest("anova_to_null") %>%
  dplyr::select(-c(mod, mod_anova))

# save ----
# csv
readr::write_csv(
  table_s3,
  file = here::here(
    "Outputs/Table_s3.csv"
  )
)

# word
arsenal::write2word(
  object = table_s3 %>%
    get_nice_table(),
  file = here::here(
    "Outputs/Table_S3.docx"
  )
)
