#----------------------------------------------------------#
#
#
#                 Tropical ant nutrient use
#
#               Run all guild-related analyses
#
#
#           --- authors are hidden for review ---
#                         2023
#
#----------------------------------------------------------#

# Run all scripts in `/R/02_Main_analyses/04_Guilds/`

#----------------------------------------------------------#
# 1. Set up run -----
#----------------------------------------------------------#

library(here)

# Load configuration
source(
  here::here("R/00_Config_file.R")
)


#----------------------------------------------------------#
# 2. Run individual parts -----
#----------------------------------------------------------#

working_dir <-
  here::here(
    "R/02_Main_analyses/04_Guilds/"
  )

source(
  paste0(working_dir, "01_model_guild_elev_trend_occurences.R")
)

source(
  paste0(working_dir, "02_figure_guild_elev_trend_occurences.R")
)

source(
  paste0(working_dir, "03_table_guild_elev_trend_occurences.R")
)

source(
  paste0(working_dir, "04_model_guild_food_preference.R")
)

source(
  paste0(working_dir, "05_table_guild_food_preference.R")
)

source(
  paste0(working_dir, "06_model_guild_food_preferecne_addtion.R")
)

source(
  paste0(working_dir, "07_table_guild_food_preference_addition.R")
)

source(
  paste0(working_dir, "08_figure_guild_food_preference_addition.R")
)