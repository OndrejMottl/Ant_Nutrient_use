#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                  Ant occurence models
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

# load data ----

data_diversity <-
  readr::read_csv(
    file = here::here(
      paste0("Data/Processed/data_diversity_2023-02-01.csv")
    ),
    show_col_types = FALSE
  ) %>%
  dplyr::mutate(
    Regions = as.factor(Regions),
    Seasons = as.factor(Seasons)
  )

# fit model ----

mod_occ_poiss <-
  fit_elev_models(
    data_source = data_diversity,
    sel_var = "totalSp_occurrence",
    sel_family = poisson(link = "log"),
    test_overdispersion = TRUE,
    compare = TRUE
  )

# !! Overdispersed -> NB model

mod_occ_nb <- 
  fit_elev_models(
    data_source = data_diversity,
    sel_var = "totalSp_occurrence",
    sel_mod = "nb_glm",
    test_overdispersion = FALSE,
    compare = TRUE
  )

# check best model
mod_occ_nb_sel <-
  mod_occ_nb %>%
  dplyr::filter(
    best_model == TRUE
  )

mod_occ_nb_sel

# Check parametr details
mod_occ_nb_sel$model_details[[1]]

# save
mod_occ_nb %>%
  readr::write_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/ele_trend_occurences_",
        current_date,
        ".rds"
      )
    )
  )
