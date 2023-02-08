#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                       Figure 2
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
mod_occ <-
  readr::read_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/bait_occupence_2023-02-08.rds"
      )
    )
  ) %>%
  purrr::pluck("model_final")


data_to_fit <-
  readr::read_rds(
    file = here::here(
      paste0(
        "Data/Processed/Models/bait_occupence_2023-02-08.rds"
      )
    )
  ) %>%
  purrr::pluck("data_to_fit")


# predict ----
data_pred_bait_type <-
  emmeans::emmeans(mod_occ,
    spec = ~bait_type,
    type = "response"
  ) %>%
  as.data.frame() %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    regions = "Average across region"
  )

data_pred_region <-
  emmeans::emmeans(mod_occ,
    spec = ~ bait_type + regions,
    type = "response"
  ) %>%
  as.data.frame() %>%
  tibble::as_tibble()

figure_2 <-
  dplyr::bind_rows(
    data_pred_region,
    data_pred_bait_type
  ) %>%
  ggplot2::ggplot(
    ggplot2::aes(
      x = bait_type,
      y = prob,
      fill = bait_type
    )
  ) +
  ggplot2::geom_bar(
    color = "black",
    stat = "identity",
    position = ggplot2::position_dodge()
  ) +
  ggplot2::geom_errorbar(
    aes(
      ymin = lower.CL,
      ymax = upper.CL
    ),
    width = .5,
    position = ggplot2::position_dodge(.9)
  ) +
  ggplot2::coord_cartesian(
    ylim = c(0, 1)
  ) +
  ggplot2::facet_wrap(~regions, nrow = 1) +
  ggplot2::theme_bw(
    base_size = 12,
    base_family = "arial"
  ) +
  ggplot2::theme(
    legend.position = "none",
    axis.text.x = ggplot2::element_text(
      angle = 45,
      hjust = 1,
      size = 10
    ),
    axis.text.y = ggplot2::element_text(size = 10),
    plot.title = ggplot2::element_text(hjust = 0.5, size = 13),
    axis.title.x = ggplot2::element_text(size = 12),
    axis.title.y = ggplot2::element_text(size = 12),
    legend.title = ggplot2::element_text(size = 13),
    legend.text = ggplot2::element_text(size = 12),
    legend.key.size = unit(0.5, "cm"),
    legend.key.width = unit(0.5, "cm"),
    panel.grid = ggplot2::element_blank()
  ) +
  ggplot2::labs(
    y = "Proportion of occupied baits",
    x = ""
  )

# save ----
ggplot2::ggsave(
  filename = here::here(
    "Outputs/Figure_2.pdf"
  ),
  plot = figure_2,
  width = 168,
  height = 120,
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
