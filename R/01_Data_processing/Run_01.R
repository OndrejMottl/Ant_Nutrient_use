#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#        Source all code for data processing steps
#
#
#             O. Mottl, J. Mosses, P. Klimes
#                         2023
#
#----------------------------------------------------------#

# Sources all individual processing steps in the folder of
# 01_Data_processing


#----------------------------------------------------------#
# 1. Set up run -----
#----------------------------------------------------------#

# Load configuration
source("R/00_Config_file.R")


#----------------------------------------------------------#
# 2. Run individual parts -----
#----------------------------------------------------------#

working_dir <-
  here::here(
    "R/01_Data_processing/"
  )

source(
  paste0(
    working_dir,
    "/01_Neotoma_source/01_full_data_process.R"
  )
)

source(
  paste0(
    working_dir,
    "/01_Neotoma_source/02_dataset_overview.R"
  )
)

source(
  paste0(
    working_dir,
    "/01_Neotoma_source/03_data_ant_counts.R"
  )
)

source(
  paste0(
    working_dir,
    "/01_Neotoma_source/04_data_guild_occurences.R"
  )
)

source(
  paste0(
    working_dir,
    "/01_Neotoma_source/05_data_guild_abundances.R"
  )
)

source(
  paste0(
    working_dir,
    "/01_Neotoma_source/06_data_food_preferences.R"
  )
)