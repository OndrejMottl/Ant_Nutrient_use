#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                       Config file
#
#
#             O. Mottl, J. Mosses, P. Klimes
#                         2023
#
#----------------------------------------------------------#
# Configuration script with the variables that should be consistent throughout
#   the whole repo. It loads packages, defines important variables,
#   authorises the user, and saves config file.


#----------------------------------------------------------#
# 1. Load packages -----
#----------------------------------------------------------#

renv::restore(
  lockfile = here::here("renv/library_list.lock")
)

# define packages
package_list <-
  c(
    "assertthat",
    "car",
    "effectsize",
    "emmeans",
    "ggbeeswarm",
    "ggpubr",
    "glmmTMB",
    "here",
    "insight",
    "knitr",
    "marginaleffects",
    "MASS",
    "MuMIn",
    "patchwork",
    "performance",
    "readxl",
    "renv",
    "roxygen2",
    "RUtilpol",
    "tidyverse",
    "usethis"
  )

# load all packages
sapply(package_list, library, character.only = TRUE)


#----------------------------------------------------------#
# 2. Define space -----
#----------------------------------------------------------#

current_date <- Sys.Date()

# project directory is set up by 'here' package, Adjust if needed
current_dir <- here::here()


#----------------------------------------------------------#
# 3. Load functions -----
#----------------------------------------------------------#

# get vector of general functions
fun_list <-
  list.files(
    path = "R/Functions/",
    pattern = "*.R",
    recursive = TRUE
  )

# source them
sapply(
  paste0("R/functions/", fun_list, sep = ""),
  source
)


#----------------------------------------------------------#
# 4. Authorise the user -----
#----------------------------------------------------------#

# if applicable

#----------------------------------------------------------#
# 5. Define variables -----
#----------------------------------------------------------#

set.seed(1234)

#----------------------------------------------------------#
# 6. Graphical options -----
#----------------------------------------------------------#

## examples
# set ggplot output
ggplot2::theme_set(
  ggplot2::theme_classic()
)

# define general
text_size <- 10
line_size <- 0.1

# define output sizes
image_width <- 16
image_height <- 12
image_units <- "cm"

# define pallets

# define common color
