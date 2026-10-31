nrow(energy)
dplyr::n_distinct(energy$country)
energy <- readr::read_csv(
  "data-raw/owid-energy-data.csv",
  show_col_types = FALSE
) |>
  janitor::clean_names() |>
  dplyr::filter(!is.na(iso_code) | country == "World")

usethis::use_data(electricity_mix, overwrite = TRUE)
