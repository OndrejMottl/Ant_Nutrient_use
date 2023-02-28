#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#            Source all code for main analyses
#
#
#           --- authors are hidden for review ---
#                         2023
#
#----------------------------------------------------------#

# Sources all or selected processing steps in the folder of
# 02_Main analyses. These analyses are meant for the main output such as
# the most important figures and tables of analyses


#----------------------------------------------------------#
# 1. Set up run -----
#----------------------------------------------------------#

# Load configuration
source("R/00_Config_file.R")


#----------------------------------------------------------#
# 2. Run individual parts -----
#----------------------------------------------------------#

working_dir <-
  here::here("/R/02_Main_analyses/")

source(
   paste0(
     working_dir,
     "/01_Elev_trend_ant_counts/Run_02_01.R"))

source(
  paste0(
    working_dir,
    "/02_Bait_occupancy/Run_02_02.R"
  )
)

source(
  paste0(
    working_dir,
    "/03_Food_preferences/Run_02_03.R"
  )
)

source(
  paste0(
    working_dir,
    "/04_Guilds/Run_02_04.R"
  )
)
