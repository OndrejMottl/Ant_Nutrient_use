#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                   Ant diversity models
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

mod_div_poiss <-
  fit_elev_models(
    data_source = data_diversity,
    sel_var = "totalSp_richness",
    sel_family = poisson(link = "log"),
    test_overdispersion = TRUE,
    compare = TRUE
  )

# check best model
mod_div_poiss_sel <-
  mod_div_poiss %>%
  dplyr::filter(
    best_model == TRUE
  )

mod_div_poiss_sel

# Check parametr details
mod_div_poiss_sel$model_details[[1]]

# save
mod_div_poiss %>%
  readr::write_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/ele_trend_diversity_",
        current_date,
        ".rds"
      )
    )
  )
