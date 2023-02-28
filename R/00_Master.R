#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                       Master file
#
#
#           --- authors are hidden for review ---
#                         2023
#
#----------------------------------------------------------#

# Will run the whole project and automatically output data


#----------------------------------------------------------#
# 1. Set up run -----
#----------------------------------------------------------#

# Load configuration
source(
  here::here("R/00_Config_file.R")
)


#----------------------------------------------------------#
# 2. Run individual parts -----
#----------------------------------------------------------#

source(
  here::here("R/01_Data_processing/Run_01.R")
)

source(
  here::here("R/02_Main_analyses/Run_02.R")
)
