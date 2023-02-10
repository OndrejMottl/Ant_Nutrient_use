#----------------------------------------------------------#
#
#
#                Tropical ant nutrient use
#
#                  Figure 3 per region
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
data_food_pref_models_regions <-
  RUtilpol::get_latest_file(
    file_name = "data_food_pref_models_regions",
    dir = here::here("Data/Processed/Models/")
  )

data_to_fit <-
  data_food_pref_models_regions %>%
  purrr::pluck("data_to_fit")

data_food_pref_individual_plot <-
  data_food_pref_models_regions %>%
  purrr::pluck("models") %>%
  tidyr::unnest(anova_to_null) %>%
  dplyr::mutate(
    indiv_plot_list = purrr::pmap(
      .l = list(
        regions, # ..1
        mod_name, # ..2
        mod, # ..3
        aov_pr_chisq # ..4
      ),
      .f = ~ {
        sel_region <- ..1
        message(sel_region)

        data_to_plot <-
          data_to_fit %>%
          dplyr::filter(regions == sel_region)

        data_pred_trend <- NULL
        data_pred_season <- NULL
        data_pred_interaction <- NULL

        switch(..2,
          "bait type * season" = {
            data_pred_season <-
              get_predict_by_emmeans(
                sel_mod = ..3,
                sel_spec = ~ bait_type * seasons
              )
          },
          "bait type + season" = {
            data_pred_season <-
              get_predict_by_emmeans(
                sel_mod = ..3,
                sel_spec = ~ bait_type + seasons
              )
          }
        )

        sel_p_value <- ..4

        plot_list <-
          data_to_plot %>%
          purrr::pluck("bait_type") %>%
          unique() %>%
          rlang::set_names() %>%
          purrr::map(
            .f = ~ {
              data_bait_type <-
                data_to_plot %>%
                dplyr::filter(bait_type == .x)


              try(
                {
                  data_pred_season <-
                    data_pred_season %>%
                    dplyr::filter(bait_type == .x)
                },
                silent = TRUE
              )

              res_plot <-
                plot_elev_trend(
                  data_source = data_bait_type,
                  y_var = "rel_occurences",
                  y_var_name = "Relative nutrient use",
                  data_pred_trend = data_pred_trend,
                  data_pred_season = data_pred_season,
                  data_pred_interaction = data_pred_interaction,
                  p_value = sel_p_value,
                  y_lim = c(0, 1)
                ) +
                ggpubr::rremove("xylab")

              return(res_plot)
            }
          )
        return(plot_list)
      }
    )
  )

figure_3_per_region <-
  ggpubr::ggarrange(
    plotlist = purrr::map(
      .x = data_food_pref_individual_plot$indiv_plot_list,
      .f = ~ ggpubr::ggarrange(
        plotlist = .x,
        ncol = 1,
        common.legend = TRUE,
        legend = "bottom"
      )
    ),
    nrow = 1,
    common.legend = TRUE,
    legend = "bottom"
  ) %>%
  ggpubr::annotate_figure(
    left = ggpubr::text_grob(
      "Relative nutrient use",
      family = "arial",
      size = 12,
      rot = 90
    ),
    bottom = ggpubr::text_grob(
      "Elevation (m.a.s.l.)",
      family = "arial",
      size = 12
    )
  )

save_figure(
  filename = "figure_3_per_region",
  dir = here::here("Outputs"),
  plot = figure_3_per_region,
  width = 168,
  height = 250
)
