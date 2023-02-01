#----------------------------------------------------------#
#
#
#                     Project name
#
#                     Project setup
#                 
#
#   O. Mottl, S. Flantua, K. Bhatta, V. Felde, A. Seddon 
#                         2021
#
#----------------------------------------------------------#

# Script to prepare all necessary components of environment to run the Project.
#   Needs to be run only once


#----------------------------------------------------------#
# Step 1: Install 'renv' package -----
#----------------------------------------------------------#

utils::install.packages("renv")


#----------------------------------------------------------#
# Step 2: Deactivate 'renv' package -----
#----------------------------------------------------------#

# deactivate to make sure that packages are updated on the machine
renv::deactivate()


#----------------------------------------------------------#
# Step 3: Create a list of packages
#----------------------------------------------------------#

package_list <- 
  c(
    "assertthat",
    "devtools",
    "here",
    "httpgd",
    "janitor",
    "jsonlite",
    "languageserver",
    "renv",       
    "roxygen2",   
    "tidyverse",  
    "usethis"   
  )

# define helper function
install_packages <-
  function(pkgs_list) {

    # install all packages in the lst from CRAN
    sapply(pkgs_list, utils::install.packages, character.only = TRUE)

    # install RFossilpol from GitHub
    # devtools::install_github(
    #  "HOPE-UIB-BIO/R-Fossilpol-package",
    #  quiet = FALSE,
    #  upgrade = FALSE
    )
  }

#----------------------------------------------------------#
# Step 4: Install packages to the machine
#----------------------------------------------------------#

install_packages(package_list)


#----------------------------------------------------------#
# Step 5: Activate 'renv' project
#----------------------------------------------------------#

renv::activate()


#----------------------------------------------------------#
# Step 6: Install packages to the project
#----------------------------------------------------------#

install_packages(package_list)


#----------------------------------------------------------#
# Step 7: Synchronize package versions with the project 
#----------------------------------------------------------#

library(here)

# if there is no lock file present make a new snapshot
if
(
  isFALSE("library_list.lock" %in% list.files(here::here("renv")))
) {
  renv::snapshot(lockfile = here::here("renv/library_list.lock"))
} else {
  renv::restore(lockfile = here::here("renv/library_list.lock"))
}

#----------------------------------------------------------#
# Step 8: GitHub hook
#----------------------------------------------------------#

# Prevent commiting to the Main
usethis::use_git_hook(
  hook = "pre-commit",
  script = '#!/bin/sh
  branch="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$branch" = "main" ]; then
  echo "You cannot commit directly to main branch. Please make a new branch"
  exit 1
  fi'
)

#----------------------------------------------------------#
# Step 9: Run the project 
#----------------------------------------------------------#
