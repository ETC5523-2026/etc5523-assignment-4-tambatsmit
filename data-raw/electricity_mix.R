energy <- readr::read_csv(
  "data-raw/owid-energy-data.csv",
  show_col_types = FALSE
) |>
  janitor::clean_names() |>
  dplyr::filter(!is.na(iso_code) | country == "World")

shares <- energy |>
  dplyr::select(
    country,
    year,
    coal = coal_share_elec,
    gas = gas_share_elec,
    oil = oil_share_elec,
    nuclear = nuclear_share_elec,
    hydro = hydro_share_elec,
    wind = wind_share_elec,
    solar = solar_share_elec,
    bioenergy = biofuel_share_elec,
    `other renewables` = other_renewables_share_elec_exc_biofuel
  ) |>
  tidyr::pivot_longer(
    cols = coal:`other renewables`,
    names_to = "source",
    values_to = "share"
  )

generation <- energy |>
  dplyr::select(
    country,
    year,
    coal = coal_electricity,
    gas = gas_electricity,
    oil = oil_electricity,
    nuclear = nuclear_electricity,
    hydro = hydro_electricity,
    wind = wind_electricity,
    solar = solar_electricity,
    bioenergy = biofuel_electricity,
    `other renewables` = other_renewable_exc_biofuel_electricity
  ) |>
  tidyr::pivot_longer(
    cols = coal:`other renewables`,
    names_to = "source",
    values_to = "generation"
  )

electricity_mix <- shares |>
  dplyr::left_join(generation, by = c("country", "year", "source")) |>
  dplyr::filter(!is.na(share)) |>
  dplyr::mutate(
    year = as.integer(year),
    source = factor(
      source,
      levels = c(
        "coal", "gas", "oil", "nuclear", "hydro", "wind", "solar",
        "bioenergy", "other renewables"
      )
    )
  ) |>
  dplyr::select(country, year, source, generation, share)

usethis::use_data(electricity_mix, overwrite = TRUE)
