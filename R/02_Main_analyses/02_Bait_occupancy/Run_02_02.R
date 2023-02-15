#----------------------------------------------------------#
#
#
#                 Tropical ant nutrient use
#
#           Run all ant count analyses
#
#
#             O. Mottl, J. Mosses, P. Klimes
#                         2023
#
#----------------------------------------------------------#

# Run all scripts in `/R/01_Data_processing/02_Bait_occupancy/`

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
    "R/01_Data_processing/01_Neotoma_source/"
  )
