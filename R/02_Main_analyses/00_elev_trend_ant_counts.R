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
data_ant_counts <-
  RUtilpol::get_latest_file(
    file_name = "data_ant_counts",
    dir = here::here("Data/Processed")
  )

data_mean_elevation <-
  RUtilpol::get_latest_file(
    file_name  = "data_mean_elevation",
    dir = here::here("Data/Processed")
  )

# data wrangling ---
data_to_fit <-
  dplyr::left_join(
    data_mean_elevation,
    data_ant_counts,
    by = dplyr::join_by(regions, seasons, et_pcode)
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(
        is.character
      ),
      as.factor
    )
  )

summary(data_to_fit)

# fit models ----
# - occurences ----
mod_occurences <-
  fit_elev_models(
    data_source = data_to_fit,
    sel_var = "n_occurecnes",
    sel_method = "glmmTMB",
    sel_family = glmmTMB::nbinom1(link = "log"),
    compare_aic = TRUE
  )

mod_occurences

mod_occurences$mod_name[which(mod_occurences$best_model == TRUE)]

# Check parametr details
mod_occurences$mod_anova[which(mod_occurences$best_model == TRUE)]

# save
list(
  data_to_fit = data_to_fit,
  models = mod_occurences
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "mod_occurences",
    dir = here::here("Data/Processed/Models/")
  )

# - richness ----
mod_richness <-
  fit_elev_models(
    data_source = data_to_fit,
    sel_var = "n_species",
    sel_method = "glmmTMB",
    sel_family = glmmTMB::nbinom1(link = "log"),
    compare_aic = TRUE
  )

mod_richness

mod_richness$mod_name[which(mod_richness$best_model == TRUE)]

# Check parametr details
mod_richness$mod_anova[which(mod_richness$best_model == TRUE)]

# save
list(
  data_to_fit = data_to_fit,
  models = mod_richness
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "mod_richness",
    dir = here::here("Data/Processed/Models/")
  )

# - richness ----
mod_abundnace <-
  fit_elev_models(
    data_source = data_to_fit,
    sel_var = "n_abundance",
    sel_method = "glmmTMB",
    sel_family = glmmTMB::nbinom1(link = "log"),
    compare_aic = TRUE
  )

mod_abundnace

# several models have delta < 2
# Therefoere, estimate the importance of predictors across models
MuMIn::model.avg(
  mod_abundnace$mod
) %>%
  MuMIn::sw() %>%
  as.data.frame() %>%
  tibble::rownames_to_column("term") %>%
  tibble::as_tibble() %>%
  dplyr::rename(
    importance = "."
  )

# only elevation_mean * regions has importance > 70
mod_abundnace$best_model[
  mod_abundnace$mod_name == "elevation * region * season"
] <- FALSE

mod_abundnace$mod_name[which(mod_abundnace$best_model == TRUE)]

# Check parametr details
mod_abundnace$mod_anova[which(mod_abundnace$best_model == TRUE)]

# save
list(
  data_to_fit = data_to_fit,
  models = mod_abundnace
) %>%
  RUtilpol::save_latest_file(
    object_to_save = .,
    file_name = "mod_abundnace",
    dir = here::here("Data/Processed/Models/")
  )
