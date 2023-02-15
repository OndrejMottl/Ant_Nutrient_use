#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Table bait occupancy
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
mod_bait_occupancy <-
  RUtilpol::get_latest_file(
    file_name = "mod_bait_occupancy",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

table_bait_occupancy_models <-
  mod_bait_occupancy %>%
  dplyr::rename(model_df = df) %>%
  tidyr::unnest(anova_to_null) %>%
  dplyr::select(-c(mod, mod_anova))

# save ----
# csv
readr::write_csv(
  table_bait_occupancy_models,
  file = here::here(
    "Outputs/table_bait_occupancy_models.csv"
  )
)

# word
arsenal::write2word(
  object = table_bait_occupancy_models %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_bait_occupancy_models.docx"
  )
)

# params ----
table_bait_occupancy_params <-
  mod_bait_occupancy %>%
  dplyr::rename(model_df = df) %>%
  dplyr::filter(best_model == TRUE) %>%
  purrr::pluck("mod_anova", 1)

# save ----
# csv
readr::write_csv(
  table_bait_occupancy_params,
  file = here::here(
    "Outputs/table_bait_occupancy_params.csv"
  )
)

# word
arsenal::write2word(
  object = table_bait_occupancy_params %>%
    get_nice_table(),
  file = here::here(
    "Outputs/table_bait_occupancy_params.docx"
  )
)
