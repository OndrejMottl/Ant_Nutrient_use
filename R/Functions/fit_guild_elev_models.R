fit_guild_elev_models <-
  function(data_source,
           sel_var = "n_occ_prop",
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
    mod_elev <-
      stats::update(mod_null, . ~ poly(elevation_mean, 2))
    mod_region <-
      stats::update(mod_null, . ~ regions)
    mod_season <-
      stats::update(mod_null, . ~ seasons)

    # two predictors
    # guild + elevation"
    mod_guild_elev <-
      stats::update(mod_guild, . ~ . + poly(elevation_mean, 2))
    # guild * elevation"
    mod_guild_elev_int <-
      stats::update(mod_guild, . ~ . * poly(elevation_mean, 2))
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
    # elevation + region"
    mod_elev_region <-
      stats::update(mod_elev, . ~ . + regions)
    # elevation * region"
    mod_elev_region_int <-
      stats::update(mod_elev, . ~ . * regions)
    # elevation + season"
    mod_elev_season <-
      stats::update(mod_elev, . ~ . + seasons)
    # elevation * season"
    mod_elev_season_int <-
      stats::update(mod_elev, . ~ . * seasons)
    # region + season"
    mod_region_season <-
      stats::update(mod_region, . ~ . + seasons)
    # region * season"
    mod_region_season_int <-
      stats::update(mod_region, . ~ . * seasons)

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
    # elevation + region + season",
    mod_elev_region_seasons <-
      stats::update(mod_elev_region, . ~ . + seasons)
    # elevation * region + season",
    mod_elev_region_int_seasons <-
      stats::update(mod_elev_region_int, . ~ . + seasons)
    # elevation + region * season",
    mod_elev_region_seasons_int <-
      stats::update(mod_elev_region, . ~ . * seasons)
    # elevation * region * season",
    mod_elev_region_int_seasons_int <-
      stats::update(mod_elev_region_int, . ~ . * seasons)
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
          "elevation",
          "region",
          "season",
          # two
          "guild + elevation",
          "guild * elevation",
          "guild + region",
          "guild * region",
          "guild + season",
          "guild * season",
          "elevation + region",
          "elevation * region",
          "elevation + season",
          "elevation * season",
          "region + season",
          "region * season",
          # three
          "guild + elevation + region",
          "guild * elevation + region",
          "guild + elevation * region",
          "guild * elevation * region",
          "guild + elevation + season",
          "guild * elevation + season",
          "guild + elevation * season",
          "guild * elevation * season",
          "elevation + region + season",
          "elevation * region + season",
          "elevation + region * season",
          "elevation * region * season",
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
          mod_elev,
          mod_region,
          mod_season,
          # two
          mod_guild_elev,
          mod_guild_elev_int,
          mod_guild_region,
          mod_guild_region_int,
          mod_guild_season,
          mod_guild_season_int,
          mod_elev_region,
          mod_elev_region_int,
          mod_elev_season,
          mod_elev_season_int,
          mod_region_season,
          mod_region_season_int,
          # three
          mod_guild_elev_region,
          mod_guild_elev_int_region,
          mod_guild_elev_region_int,
          mod_guild_elev_int_region_int,
          mod_guild_elev_season,
          mod_guild_elev_int_season,
          mod_guild_elev_season_int,
          mod_guild_elev_int_season_int,
          mod_elev_region_seasons,
          mod_elev_region_int_seasons,
          mod_elev_region_seasons_int,
          mod_elev_region_int_seasons_int,
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

    mod_details <-
      get_model_details(
        data_source = mod_table,
        compare_aic = TRUE,
        test_overdispersion = FALSE
      )

    res <-
      get_anova_to_null(mod_details, mod_null)

    return(res)
  }
