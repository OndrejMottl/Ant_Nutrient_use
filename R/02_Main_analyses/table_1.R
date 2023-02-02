#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Table 1
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
mods_div <-
  readr::read_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/ele_trend_diversity_2023-02-02.rds"
      )
    )
  )


mods_occ <-
  readr::read_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/ele_trend_occurences_2023-02-02.rds"
      )
    )
  )

# make table ----
table_1 <-
  list(
    mods_div,
    mods_occ
  ) %>%
  purrr::map(
    .f = ~ .x %>%
      dplyr::filter(
        mod_name == "poly_full"
      ) %>%
      purrr::pluck("model_details", 1) %>%
      get_nice_table()
  ) %>%
  knitr::kables(format = "simple")

# results for models selected based of AIC
if (FALSE) {
  table_1 <-
    list(
      mods_div,
      mods_occ
    ) %>%
    purrr::map(
      .f = ~ .x %>%
        dplyr::filter(
          best_model == TRUE
        ) %>%
        purrr::pluck("model_details", 1) %>%
        get_nice_table()
    ) %>%
    knitr::kables(format = "simple")
}

# save docx to workspace and manually copy table over to xlsx
arsenal::write2word(
  object = table_1,
  file = here::here(
      "Outputs/Table_1.docx"
    )
)
