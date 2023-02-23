#----------------------------------------------------------#
#
#
#                 Tropical ant nutrient use
#
#               Run all food preferecne analyses
#
#
#             O. Mottl, J. Mosses, P. Klimes
#                         2023
#
#----------------------------------------------------------#

# Run all scripts in `R/02_Main_analyses/03_Food_preferences/`

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
    "R/02_Main_analyses/03_Food_preferences/"
  )

source(
  paste0(working_dir, "01_models_food_preferecnes_occurences.R")
)

source(
  paste0(working_dir, "02_figure_food_preferences_occurences.R")
)

source(
  paste0(working_dir, "03_table_food_preferences_occurences.R")
)

source(
  paste0(working_dir, "04_models_food_preferecnes_abundnace.R")
)

source(
  paste0(working_dir, "05_figure_food_preferences_abundnace.R")
)

source(
  paste0(working_dir, "06_table_food_preferences_abundnace.R")
)
