#----------------------------------------------------------#
#
#
#                 Tropical ant nutrient use
#
#               Run all bait occupancy analyses
#
#
#           --- authors are hidden for review ---
#                         2023
#
#----------------------------------------------------------#

# Run all scripts in `/R/02_Main_analyses/02_Bait_occupancy/`

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
    "R/02_Main_analyses/02_Bait_occupancy/"
  )

source(
  paste0(working_dir, "01_figure_bait_occupancy_data.R")
)

source(
  paste0(working_dir, "02_model_bait_occupancy.R")
)

source(
  paste0(working_dir, "03_figure_bait_occupancy_model.R")
)

source(
  paste0(working_dir, "04_table_bait_occupancy_model.R")
)
