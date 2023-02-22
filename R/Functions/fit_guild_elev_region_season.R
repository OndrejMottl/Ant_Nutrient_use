fit_guild_elev_region_season <-
  function(data_source,
           sel_var = "n_occ_prop",
           elev_poly = 1,
           sel_family = glmmTMB::ordbeta(link = "logit"),
           ...) {
    # singl pred
    mod_null <-
      glmmTMB::glmmTMB(
        formula = as.formula(paste(sel_var, "~ 1")),
        family = sel_family,
        data = data_source,
        ziformula = ~0,
        na.action = "na.fail",
        ...
      )
    mod_guild <-
      stats::update(mod_null, . ~ guild)

    # two predictors
    # guild + elevation"
    mod_guild_elev <-
      stats::update(mod_guild, . ~ . + poly(elevation_mean, elev_poly))
    # guild * elevation"
    mod_guild_elev_int <-
      stats::update(mod_guild, . ~ . * poly(elevation_mean, elev_poly))
    # guild + region"
    mod_guild_region <-
      stats::update(mod_guild, . ~ . + regions)
    # guild * region"
    mod_guild_region_int <-
      stats::update(mod_guild, . ~ . * regions)
    # guild + season"
    mod_guild_season <-
      stats::update(mod_guild, . ~ . + seasons)
    # guild * season"
    mod_guild_season_int <-
      stats::update(mod_guild, . ~ . * seasons)

    # three predictors
    # guild + elevation + region",
    mod_guild_elev_region <-
      stats::update(mod_guild_elev, . ~ . + regions)
    # guild * elevation + region",
    mod_guild_elev_int_region <-
      stats::update(mod_guild_elev_int, . ~ . + regions)
    # guild + elevation * region",
    mod_guild_elev_region_int <-
      stats::update(mod_guild_elev, . ~ . * regions)
    # guild * elevation * region",
    mod_guild_elev_int_region_int <-
      stats::update(mod_guild_elev_int, . ~ . * regions)
    # guild + elevation + season",
    mod_guild_elev_season <-
      stats::update(mod_guild_elev, . ~ . + seasons)
    # guild * elevation + season",
    mod_guild_elev_int_season <-
      stats::update(mod_guild_elev_int, . ~ . + seasons)
    # guild + elevation * season",
    mod_guild_elev_season_int <-
      stats::update(mod_guild_elev, . ~ . * seasons)
    # guild * elevation * season",
    mod_guild_elev_int_season_int <-
      stats::update(mod_guild_elev_int, . ~ . * seasons)
    # guild + region + season",
    mod_guild_region_season <-
      stats::update(mod_guild_region, . ~ . + seasons)
    # guild * region + season",
    mod_guild_region_int_season <-
      stats::update(mod_guild_region_int, . ~ . + seasons)
    # guild + region * season",
    mod_guild_region_season_int <-
      stats::update(mod_guild_region, . ~ . * seasons)
    # guild * region * season",
    mod_guild_region_int_season_int <-
      stats::update(mod_guild_region_int, . ~ . * seasons)

    # four predictors
    # guild + elevation + region + season"
    mod_guild_elev_region_season <-
      stats::update(mod_guild_elev_region, . ~ . + seasons)
    # guild * elevation + region + season"
    mod_guild_elev_int_region_season <-
      stats::update(mod_guild_elev_int_region, . ~ . + seasons)
    # guild + elevation * region + season"
    mod_guild_elev_region_int_season <-
      stats::update(mod_guild_elev_region_int, . ~ . + seasons)
    # guild + elevation + region * season"
    mod_guild_elev_region_season_it <-
      stats::update(mod_guild_elev_region, . ~ . * seasons)
    # guild * elevation * region + season"
    mod_guild_elev_int_region_int_season <-
      stats::update(mod_guild_elev_int_region_int, . ~ . + seasons)
    # guild * elevation + region * season"
    mod_guild_elev_int_region_season_int <-
      stats::update(mod_guild_elev_int_region, . ~ . * seasons)
    # guild + elevation * region * season"
    mod_guild_elev_region_int_season_int <-
      stats::update(mod_guild_elev_region_int, . ~ . * seasons)
    # guild * elevation * region * season"
    mod_guild_elev_int_region_int_season_int <-
      stats::update(mod_guild_elev_int_region_int, . ~ . * seasons)

    mod_table <-
      tibble::tibble(
        mod_name = c(
          # single
          "null",
          "guild",
          # two
          "guild + elevation",
          "guild * elevation",
          "guild + region",
          "guild * region",
          "guild + season",
          "guild * season",
          # three
          "guild + elevation + region",
          "guild * elevation + region",
          "guild + elevation * region",
          "guild * elevation * region",
          "guild + elevation + season",
          "guild * elevation + season",
          "guild + elevation * season",
          "guild * elevation * season",
          "guild + region + season",
          "guild * region + season",
          "guild + region * season",
          "guild * region * season",
          # four
          "guild + elevation + region + season",
          "guild * elevation + region + season",
          "guild + elevation * region + season",
          "guild + elevation + region * season",
          "guild * elevation * region + season",
          "guild * elevation + region * season",
          "guild + elevation * region * season",
          "guild * elevation * region * season"
        )
      ) %>%
      dplyr::mutate(
        mod = list(
          # single
          mod_null,
          mod_guild,
          # two
          mod_guild_elev,
          mod_guild_elev_int,
          mod_guild_region,
          mod_guild_region_int,
          mod_guild_season,
          mod_guild_season_int,
          # three
          mod_guild_elev_region,
          mod_guild_elev_int_region,
          mod_guild_elev_region_int,
          mod_guild_elev_int_region_int,
          mod_guild_elev_season,
          mod_guild_elev_int_season,
          mod_guild_elev_season_int,
          mod_guild_elev_int_season_int,
          mod_guild_region_season,
          mod_guild_region_int_season,
          mod_guild_region_season_int,
          mod_guild_region_int_season_int,
          # four
          mod_guild_elev_region_season,
          mod_guild_elev_int_region_season,
          mod_guild_elev_region_int_season,
          mod_guild_elev_region_season_it,
          mod_guild_elev_int_region_int_season,
          mod_guild_elev_int_region_season_int,
          mod_guild_elev_region_int_season_int,
          mod_guild_elev_int_region_int_season_int
        ) %>%
          rlang::set_names(
            nm = mod_name
          )
      )

    res <-
      get_model_details(
        data_source = mod_table,
        compare_aic = TRUE,
        test_overdispersion = FALSE
      )

    return(res)
  }
