#----------------------------------------------------------#
#
#
#                       Project name
#
#                       Master file
#                 
#
#                         Names 
#                         Year
#
#----------------------------------------------------------#

# Will run the whole project and automatically output data


#----------------------------------------------------------#
# 1. Set up run -----
#----------------------------------------------------------#

rm(list = ls())

# Load configuration
source("R/00_Config_file.R")


#----------------------------------------------------------#
# 2. Run individual parts -----
#----------------------------------------------------------#

source("R/01_Data_processing/Run_01.R")

source("R/02_Main_analyses/Run_02.R")

source("R/03_Supplementary_analyses/Run_03.R")







