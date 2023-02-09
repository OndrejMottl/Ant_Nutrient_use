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

# create a table to apply model to
data_all_possibilies <-
  expand.grid(
    Regions = data_guilds$Regions %>%
      unique(),
    sel_nutrient = c(
      "AminoAcid_spoc",
      "CHO_spoc",
      "CHOAminoAcid_spoc",
      "H2O_spoc",
      "Lipid_spoc",
      "NaCl_spoc"
    )
  ) %>%
  tibble::as_tibble()

data_guild_models <-
  data_all_possibilies %>%
  dplyr::mutate(
    models = purrr::map2(
      .x = Regions,
      .y = sel_nutrient,
      .f = ~ {
        message(
          paste(.x, .y, sep = " - ")
        )

        fit_guild_models(
          data_source = data_guilds %>%
            dplyr::filter(Regions %in% .x),
          sel_nutrient = .y,
          max_nutrient = "MAXoccurrence",
          sel_mod = "betabinomial_glmmTMB"
        ) %>%
          return()
      }
    )
  )

data_guild_models_res <-
  data_guild_models %>%
  tidyr::unnest(models) %>%
  dplyr::filter(best_model == TRUE) %>%
  # replce NA for NULL models with arbitrary 1e3
  dplyr::mutate(
    weight = ifelse(is.na(weight), 1e3, weight)
  ) %>%
  dplyr::group_by(Regions, sel_nutrient) %>%
  dplyr::filter(
    weight == max(weight)
  ) %>%
  # replce NULL models back to arbitrary NA
  dplyr::mutate(
    weight = ifelse(weight == 1e3, NA_real_, weight)
  ) %>%
  dplyr::select(
    dplyr::any_of(
      c(
        "Regions",
        "sel_nutrient",
        "mod_name",
        "mod",
        "df",
        "AICc",
        "delta",
        "weight",
        "r2",
        "mod_anova",
        "aov_df",
        "aov_log_lik",
        "aov_deviance",
        "aov_chisq",
        "aov_chi_df",
        "aov_pr_chisq",
        "aov_signif"
      )
    )
  )

# save ----
data_guild_models_res %>%
  readr::write_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/guild_",
        current_date,
        ".rds"
      )
    )
  )
