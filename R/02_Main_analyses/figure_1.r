#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                        Figure 1
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
mods_div <-
  readr::read_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/ele_trend_diversity_2023-02-02.rds"
      )
    )
  )


mods_occ <-
  readr::read_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/ele_trend_occurences_2023-02-02.rds"
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
data_pred_div_simple <-
  get_predicted_data(
    mod = mods_div %>%
      dplyr::filter(mod_name == "poly") %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_simple
  )

data_pred_div_full <-
  get_predicted_data(
    mod = mods_div %>%
      dplyr::filter(mod_name == "poly_full") %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_full
  )

data_pred_occ_simple <-
  get_predicted_data(
    mod = mods_occ %>%
      dplyr::filter(mod_name == "poly") %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_simple
  )

data_pred_occ_full <-
  get_predicted_data(
    mod = mods_occ %>%
      dplyr::filter(mod_name == "poly_full") %>%
      purrr::pluck("mod", 1),
    dummy_table = dummy_predict_table_full
  )

# plot the figure -----

firure_1a <-
  plot_elev_trend(
    data_diversity,
    data_pred_div_simple,
    data_pred_div_full,
    "totalSp_richness",
    "Species richness"
  )

figure_1b <-
  plot_elev_trend(
    data_diversity,
    data_pred_occ_simple,
    data_pred_occ_full,
    "totalSp_occurrence",
    "Species occurences"
  )

figure_1 <-
  firure_1a + firure_1a +
    patchwork::plot_layout(guides = "collect", ncol = 1) +
    patchwork::plot_annotation(
      tag_levels = "a",
      tag_prefix = "(",
      tag_suffix = ")"
    ) &
    ggplot2::theme(legend.position = "top")


# save ----
ggplot2::ggsave(
  filename = here::here("Outputs/figure_1.pdf"),
  plot = figure_1,
  width = 168,
  height = 150,
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
