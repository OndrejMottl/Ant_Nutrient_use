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
mod_abundnace <-
  RUtilpol::get_latest_file(
    file_name = "mod_abundnace",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")


# make table ----
table_s1 <-
  mod_abundnace %>%
  dplyr::rename(model_df = df) %>%
  dplyr::filter(best_model == TRUE) %>%
  purrr::pluck("mod_anova", 1) %>%
  get_nice_table()

# save
arsenal::write2word(
  object = table_s1,
  file = here::here(
    "Outputs/Table_S1.docx"
  )
)

table_s1_extra <-
  mod_abundnace %>%
  dplyr::rename(model_df = df) %>%
  tidyr::unnest(anova_to_null) %>%
  dplyr::select(-c(mod, mod_anova)) %>%
  get_nice_table()

arsenal::write2word(
  object = table_s1_extra,
  file = here::here(
    "Outputs/Table_s1_extra.docx"
  )
)
