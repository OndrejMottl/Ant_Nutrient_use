#----------------------------------------------------------#
#
#
#                       Project name
#
#        Source all code for data processing steps
#                 
#
#                         Names 
#                         Year
#
#----------------------------------------------------------#

# Sources all individual processing steps in the folder of 
# 01_Data_processing


#----------------------------------------------------------#
# 1. Set up run -----
#----------------------------------------------------------#

rm(list = ls())

# Load configuration
source("R/00_Config_file.R")


#----------------------------------------------------------#
# 2. Run individual parts -----
#----------------------------------------------------------#

working_dir <- 
  paste0(current_dir, "/R/01_Data_processing/")

# examples
# source(
#   paste0(
#     working_dir,
#     "/01_Neotoma_source/Run_01_01.R"))
 
# source(
#   paste0(
#     working_dir,
#     "/02_Private_source/Run_01_02.R"))

