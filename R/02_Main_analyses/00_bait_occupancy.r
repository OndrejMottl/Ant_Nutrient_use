#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Bait occupanvy
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
data_full <-
  readr::read_csv(
    file = here::here(
      paste0("Data/Processed/data_full_2023-02-08.csv")
    ),
    show_col_types = FALSE
  ) %>%
  dplyr::mutate(
    excluded_for_total_bait_occupancy_analysis = ifelse(
      excluded_for_total_bait_occupancy_analysis == "YES", TRUE, FALSE
    )
  ) %>%
  dplyr::filter(
    excluded_for_total_bait_occupancy_analysis == FALSE
  )

# data wrangling ----
data_to_fit <-
  data_full %>%
  dplyr::group_by(
    regions, seasons, elevational_bands,
    trap_number_code, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    total_abundance = sum(abundance)
  ) %>%
  dplyr::mutate(
    trap_occupied = ifelse(total_abundance > 0, TRUE, FALSE)
  ) %>%
  dplyr::group_by(
    regions, seasons, elevational_bands, bait_type
  ) %>%
  dplyr::summarise(
    .groups = "drop",
    n = dplyr::n(),
    traps_occupied = sum(trap_occupied),
    traps_empty = n - traps_occupied
  ) %>%
  dplyr::mutate(
    dplyr::across(
      tidyselect::where(is.character),
      as.factor
    )
  )

# fit models  ----
mod_occ_full <-
  glmmTMB::glmmTMB(
    cbind(traps_occupied, traps_empty) ~
      regions * seasons * bait_type,
    family = glmmTMB::betabinomial(link = "logit"),
    data = data_to_fit,
    ziformula = ~0,
    na.action = "na.fail"
  )

mod_occ_select <-
  MuMIn::dredge(
    global.model = mod_occ_full
  )

View(mod_occ_select)

# several models have delta < 2
# Therefoere, estimate the importance of predictors across models
MuMIn::model.avg(
  mod_occ_select,
  subset = delta < 2
) %>%
  MuMIn::sw() %>%
  as.data.frame() %>%
  tibble::rownames_to_column("term") %>%
  tibble::as_tibble() %>%
  dplyr::rename(
    importance = "."
  )

# bait_type and regions have importance > 70
# refit
mod_occ_simple <-
  stats::update(mod_occ_full, . ~ bait_type + regions)

summary(mod_occ_simple)

# save ----
list(
  data_to_fit = data_to_fit,
  models_all = mod_occ_full,
  models_select = mod_occ_select,
  model_final = mod_occ_simple
) %>%
  readr::write_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/bait_occupence_",
        current_date,
        ".rds"
      )
    )
  )
