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

usethis::use_data(electricity_mix, overwrite = TRUE)
