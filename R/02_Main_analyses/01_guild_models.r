#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                 Guild nutrien use models
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
data_guilds <-
  readr::read_csv(
    file = here::here(
      paste0("Data/Processed/data_guilds_2023-02-02.csv")
    ),
    show_col_types = FALSE
  ) %>%
  dplyr::mutate(
    Regions = as.factor(Regions),
    Seasons = as.factor(Seasons)
  )

# fit model ----

mod_guild_bb <-
  fit_guild_models(
    data_source = data_guilds %>%
      dplyr::filter(Regions %in% "Ecuador"),
    sel_nutrient = "AminoAcid_spoc",
    max_nutrient = "MAXoccurrence",
    sel_mod = "betabinomial_glmmTMB"
  )

View(mod_guild_bb)

