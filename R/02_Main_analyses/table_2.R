#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Table 2
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
mods_guilds <-
  readr::read_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/guild_2023-02-08.rds"
      )
    )
  )


# make table ----
table_2 <-
  mods_guilds %>%
  dplyr::select(
    dplyr::any_of(
      c(
        "Regions",
        "sel_nutrient",
        "mod_name",
        "df",
        "AICc",
        "r2",
        "aov_df",
        "aov_log_lik",
        "aov_deviance",
        "aov_chisq",
        "aov_chi_df",
        "aov_signif"
      )
    )
  ) %>%
  get_nice_table()

# save docx to workspace and manually copy table over to xlsx
arsenal::write2word(
  object = table_2,
  file = here::here(
    "Outputs/Table_2.docx"
  )
)
