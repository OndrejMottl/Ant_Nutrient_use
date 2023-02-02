#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Figure S1
#
#
#             O. Mottl, J. Mosses, P. Klimes
#                         2023
#
#----------------------------------------------------------#

# Load configuration ----
library(here)
source(
  here::here(
    "R/00_Config_file.R"
  )
)

# load data ----
data_diversity <-
  readr::read_csv(
    file = here::here(
      paste0("Data/Processed/data_diversity_2023-02-01.csv")
    ),
    show_col_types = FALSE
  ) %>%
  dplyr::mutate(
    Regions = as.factor(Regions),
    Seasons = as.factor(Seasons)
  )

# load models ----
mods_ab <-
  readr::read_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/ele_trend_abundances_2023-02-02.rds"
      )
    )
  )

# dummy tables ----
# dummy tables to predict upon
dummy_predict_table_simple <-
  data_diversity %>%
  dplyr::select(meanElevation, Regions) %>%
  modelbased::visualisation_matrix(
    at = c("meanElevation", "Regions"),
    length = 100,
    preserve_range = TRUE
  ) %>%
  tidyr::as_tibble()

dummy_predict_table_full <-
  data_diversity %>%
  dplyr::select(meanElevation, Regions, Seasons) %>%
  modelbased::visualisation_matrix(
    at = c("meanElevation", "Regions", "Seasons"),
    length = 100,
    preserve_range = TRUE
  ) %>%
  tidyr::as_tibble()

# predict -----
data_pred_ab_simple <-
  get_predicted_data(
    mod = mods_ab %>%
      dplyr::filter(mod_name == "poly") %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_simple
  )

data_pred_ab_full <-
  get_predicted_data(
    mod = mods_ab %>%
      dplyr::filter(mod_name == "poly_full") %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_full
  )

firure_s1 <-
  plot_elev_trend(
    data_diversity,
    data_pred_ab_simple,
    data_pred_ab_full,
    "totalAbundance",
    "Ant worker abundance",
    y_trans = "log1p",
    y_breaks = c(0, 1, 10, 100, 500, 1500, 4000)
  )

# save ----
ggplot2::ggsave(
  filename = here::here("Outputs/figure_S1.pdf"),
  plot = firure_s1,
  width = 168, 
  height = 100,
  device = cairo_pdf,
  units = "mm",
  dpi = 600,
  family = "arial",
  pointsize = 12,
  scale = 1,
  antialias = "subpixel",
  onefile = FALSE,
  bg = "transparent",
  limitsize = FALSE
)
