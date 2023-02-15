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

# Run all scripts in `/R/01_Data_processing/01_Elev_trend_ant_counts/`

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

source(
  paste0(working_dir, "01_models_ant_counts.R")
)

source(
  paste0(working_dir, "02_figure_richness_and_occurences.R")
)

source(
  paste0(working_dir, "03_tables_richness_and_occurences.R")
)

source(
  paste0(working_dir, "04_figure_abundances.R")
)

source(
  paste0(working_dir, "05_tables_abundances.R")
)