#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                  Ant abundances models
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

mod_abund_poiss <-
  fit_elev_models(
    data_source = data_diversity,
    sel_var = "totalAbundance",
    sel_family = poisson(link = "log"),
    test_overdispersion = TRUE,
    compare = TRUE
  )

# !! Overdispersed -> NB model

mod_abund_nb <-
  fit_elev_models(
    data_source = data_diversity,
    sel_var = "totalAbundance",
    sel_mod = "nb_glm",
    test_overdispersion = FALSE,
    compare = TRUE
  )

# check best model
mod_abund_nb_sel <-
  mod_abund_nb %>%
  dplyr::filter(
    best_model == TRUE
  )

mod_abund_nb_sel

# Check parametr details
mod_abund_nb_sel$model_details[[1]]

# save
mod_abund_nb %>%
  readr::write_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/ele_trend_abundances_",
        current_date,
        ".rds"
      )
    )
  )
