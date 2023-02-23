# Nutrient use by tropical ant communities varies among three extensive elevational gradients: a cross-continental comparison

## Manuscript details

### Authors

--- TO BE ADDED ---

#### Corresponding authors

--- TO BE ADDED ---

#### Running title

Nutrient use along elevational gradients

### Abstract

#### *Aim*

Many studies demonstrated that climate limits invertebrates along tropical elevational gradients, but we have only a rudimentary understanding of the role of nutrient limitation and seasonality. Here we examine the relationships between ant community structure, nutrient use and seasonality along three undisturbed elevational gradients, each from a different continent.

#### *Location*

Ecuador (America), Papua New Guinea (PNG: Australasia), and Tanzania (Africa).

#### *Time period*

Present

#### *Major taxa studied*

Ants

#### *Methods*

Along each of the three elevational gradients, we placed six distinct nutrient types (amino acid, sucrose, sucrose + amino acid, lipid, NaCl, and H2O). In total, we distributed 2370 experimental baits at 38 sites from 200 m to ~4000 m. We used generalized linear models to test for the effects of elevation and season on ant species richness and activity and relative nutrient use. We also tested if changes in ant trophic guilds corresponded to changes in the use of particular nutrients

#### *Results*

Both species richness and activity decreased with elevation along each gradient. However, there were significant interaction effects among elevation, region and season, as ant activity in the dry season was higher in Ecuador and Tanzania but lower in PNG. Relative nutrient use varied among regions: ant preference for some nutrients changed with increasing elevation in Ecuador (decrease in lipid use) and Tanzania (decrease in amino acid, NaCl, H2O use), while only season affected nutrient use in PNG. There were common trends in trophic guilds along the three elevational gradients (e.g., the proportional increase of predators), but these did not explain the nutrient use patterns

#### *Main conclusion*

While changes in ant community structure with elevation were similar, both seasonal and elevational effects on nutrient use by ants differed among the elevational gradients. We argue that regional differences in climate and nutrient availability rather than ant functional composition shape nutrient use by ants

## Project details

## Getting the code

The project is accessible in two ways:
  
  1. If a user has a [GitHub account](https://github.com/), the easiest way is to [clone](https://happygitwithr.com/clone.html) this GitHub repo.
  
  2. A user can download the latest *Release* of the project as a zip file from the [Release page](https://github.com/OndrejMottl/Ant_Nutrient_use/releases).

The R project consists of codes with individual scripts and functions. All scripts are stored in the `R/` folder.

### Set up

Once a user obtains their version of the Workflow, there are several steps to be done before using it:

- Update [R](https://en.wikipedia.org/wiki/R_(programming_language)) and [R-studio IDE](https://posit.co/products/open-source/rstudio/). There are many guides on how to do so (e.g. [here](https://jennhuck.github.io/workshops/install_update_R.html))

- Execute all individual steps with the `___Init_project___.R` script. This will result in the preparation of all R-packages using the [`{renv}` package](https://rstudio.github.io/renv/articles/renv.html), which is an R dependency management of your projects. Mainly it will install [`{RUtilpol}`](https://github.com/HOPE-UIB-BIO/R-Utilpol-package) and all dependencies. `{RUtilpol}` is used through the project as a version control of files.

- Run `R/00_Master.R` to run the whole project. Alternatively, the user can run each script individually.

### Cascade of R scripts

This project is constructed using a *script cascade*. This means that the `00_Master.R`, located within `R` folder, executes all scripts within sub-folders of the `R` folder, which in turn, executes all their sub-folders (e.g., `R/01_Data_processing/Run_01.R` executes `R/01_Data_processing/01_full_data_process.R`, `R/01_Data_processing/02_data_overview.R`, `R/01_Data_processing/03_data_ant_counts.R`, ...). See [Script cascade example](#script-cascade-example) bellow.

#### Script cascade example

```{r}
R
│
│ 00_Master.R
│
└───01_Data_processing
        │
        │   Run_01.R
        │
            │   01_models_ant_counts.R
            │   02_data_overview.R
            │   03_data_ant_counts.R
            │   04_data_guild_occurences.R
            │   05_data_guild_abundances.R
            │   06_data_food_preferences.R
                

```
