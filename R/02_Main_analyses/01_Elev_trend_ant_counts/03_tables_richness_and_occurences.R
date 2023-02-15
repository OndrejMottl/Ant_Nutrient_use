#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                Table richness and occurences
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
mod_richness <-
  RUtilpol::get_latest_file(
    file_name = "mod_richness",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

mod_occurences <-
  RUtilpol::get_latest_file(
    file_name = "mod_occurences",
    dir = here::here("Data/Processed/Models/")
  ) %>%
  purrr::pluck("models")

table_richness_and_occurence_models <-
  list(
    mod_richness,
    mod_occurences
  ) %>%
  rlang::set_names(
    nm = c("Species richness", "Species occurences")
  ) %>%
  purrr::map(
    .f = ~ .x %>%
      dplyr::rename(model_df = df) %>%
      tidyr::unnest(anova_to_null) %>%
      dplyr::select(-c(mod, mod_anova))
  )

# save ----
# csv
dplyr::bind_rows(
  table_richness_and_occurence_models,
  .id = "var"
) %>%
  readr::write_csv(
    file = here::here(
      "Outputs/table_richness_and_occurence_models.csv"
    )
  )

# word
arsenal::write2word(
  object = table_richness_and_occurence_models %>%
    purrr::map(
      .f = ~ get_nice_table(.x)
    ) %>%
    knitr::kables(format = "simple"),
  file = here::here(
    "Outputs/table_richness_and_occurence_models.docx"
  )
)


# params ----
table_richness_and_occurence_params <-
  list(
    mod_richness,
    mod_occurences
  ) %>%
  rlang::set_names(
    nm = c("Species richness", "Species occurences")
  ) %>%
  purrr::map(
    .f = ~ .x %>%
      dplyr::rename(model_df = df) %>%
      dplyr::filter(best_model == TRUE) %>%
      purrr::pluck("mod_anova", 1)
  )

# save ----
# csv
dplyr::bind_rows(
  table_richness_and_occurence_params,
  .id = "var"
) %>%
  readr::write_csv(
    file = here::here(
      "Outputs/table_richness_and_occurence_params.csv"
    )
  )

# word
arsenal::write2word(
  object = table_richness_and_occurence_params %>%
    purrr::map(
      .f = ~ get_nice_table(.x)
    ) %>%
    knitr::kables(format = "simple"),
  file = here::here(
    "Outputs/table_richness_and_occurence_params.docx"
  )
)