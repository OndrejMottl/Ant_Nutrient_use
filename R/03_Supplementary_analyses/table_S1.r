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
mods_ab <-
  readr::read_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/ele_trend_abundances_2023-02-02.rds"
      )
    )
  )


# make table ----
table_s1 <-
  mods_ab %>%
  dplyr::filter(
    mod_name == "poly_full"
  ) %>%
  purrr::pluck("model_details", 1) %>%
  get_nice_table()

# results for models selected based of AIC
if (FALSE) {
  table_1 <-
    mods_ab %>%
    dplyr::filter(
      best_model == TRUE
    ) %>%
    purrr::pluck("model_details", 1) %>%
    get_nice_table()
}

# save docx to workspace and manually copy table over to xlsx
arsenal::write2word(
  object = table_s1,
  file = here::here(
    "Outputs/Table_S1.docx"
  )
)
