#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Table 2
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
data_guild_models <-
  RUtilpol::get_latest_file(
    file_name = "data_guild_models",
    dir = here::here("Data/Processed/Models/")
  )  %>% 
  purrr::pluck("models")


# make table ----
table_2 <-
  data_guild_models %>%
  dplyr::arrange(sel_nutrient, regions) %>%
  dplyr::rename(model_df = df) %>%
  tidyr::unnest("test_to_null") %>%
    dplyr::filter(best_model == TRUE)  %>% 
  dplyr::select(-c(mod, mod_anova, best_model)) %>%
  get_nice_table()

# save
arsenal::write2word(
  object = table_2,
  file = here::here(
    "Outputs/Table_2.docx"
  )
)
